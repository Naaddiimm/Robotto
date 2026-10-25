import secrets
import string
import hashlib

def generate_secure_code(length: int = 8) -> str:
    """Generate an 8-character uppercase alphanumeric code securely."""
    alphabet = string.ascii_uppercase + string.digits
    return ''.join(secrets.choice(alphabet) for _ in range(length))

def generate_reset_token() -> str:
    """Generate a single-use secure reset token."""
    return secrets.token_urlsafe(32)

def hash_verifier(value: str) -> str:
    """
    Since this is short-lived memory data, a fast SHA-256 hash is sufficient
    to avoid keeping the code or token in plaintext in memory/DB.
    """
    return hashlib.sha256(value.encode('utf-8')).hexdigest()
