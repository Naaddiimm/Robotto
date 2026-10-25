from datetime import datetime, timedelta
from typing import Dict
import secrets
from app.config import settings
from app.security.reset_code import generate_secure_code, generate_reset_token, hash_verifier
from app.services.resend_service import send_reset_code_email

# In-memory storage for prototype. In production, use Redis or a DB table.
# Structure: { normalized_email: {"code_hash": str, "expires_at": datetime, "attempts": int, "last_sent": datetime} }
_reset_sessions: Dict[str, dict] = {}

# Structure: { token_hash: {"email": str, "expires_at": datetime} }
_authorized_tokens: Dict[str, dict] = {}

class PasswordResetService:
    @staticmethod
    def normalize_email(email: str) -> str:
        return email.strip().lower()

    @staticmethod
    def request_code(email: str) -> bool:
        normalized_email = PasswordResetService.normalize_email(email)
        now = datetime.utcnow()
        
        # Enforce Cooldown
        session = _reset_sessions.get(normalized_email)
        if session and session.get("last_sent"):
            cooldown_period = session["last_sent"] + timedelta(seconds=settings.PASSWORD_RESET_RESEND_COOLDOWN_SECONDS)
            if now < cooldown_period:
                raise ValueError("Please wait before requesting another code.")

        code = generate_secure_code()
        
        # Send Email
        success = send_reset_code_email(to_email=normalized_email, code=code)
        if not success:
            raise RuntimeError("Failed to deliver email.")

        # Store session
        _reset_sessions[normalized_email] = {
            "code_hash": hash_verifier(code),
            "expires_at": now + timedelta(seconds=settings.PASSWORD_RESET_CODE_TTL_SECONDS),
            "attempts": 0,
            "last_sent": now
        }
        return True

    @staticmethod
    def verify_code(email: str, code: str) -> str:
        normalized_email = PasswordResetService.normalize_email(email)
        session = _reset_sessions.get(normalized_email)

        if not session:
            raise ValueError("No active reset request found.")
        
        if datetime.utcnow() > session["expires_at"]:
            del _reset_sessions[normalized_email]
            raise ValueError("Verification code has expired.")
            
        if session["attempts"] >= settings.PASSWORD_RESET_MAX_ATTEMPTS:
            del _reset_sessions[normalized_email]
            raise ValueError("Too many incorrect attempts. Please request a new code.")
            
        session["attempts"] += 1

        if not secrets.compare_digest(session["code_hash"], hash_verifier(code.upper().strip())):
            raise ValueError("Invalid verification code.")

        # Verification successful. Invalidate code and issue reset token.
        del _reset_sessions[normalized_email]
        
        reset_token = generate_reset_token()
        _authorized_tokens[hash_verifier(reset_token)] = {
            "email": normalized_email,
            "expires_at": datetime.utcnow() + timedelta(minutes=15) # Token valid for 15 mins
        }
        
        return reset_token

    @staticmethod
    def confirm_reset(reset_token: str, new_password: str) -> str:
        token_hash = hash_verifier(reset_token)
        auth = _authorized_tokens.get(token_hash)
        
        if not auth:
            raise ValueError("Invalid or consumed reset authorization.")
            
        if datetime.utcnow() > auth["expires_at"]:
            del _authorized_tokens[token_hash]
            raise ValueError("Reset authorization has expired.")
            
        email = auth["email"]
        
        # Valid. In a real remote architecture, update the DB here.
        # But this backend only issues the token. The actual update happens locally on the device.
        
        # Invalidate token
        del _authorized_tokens[token_hash]
        
        return email
