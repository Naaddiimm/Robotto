import resend
from app.config import settings

def send_reset_code_email(to_email: str, code: str) -> bool:
    """
    Sends a transactional email via Resend with the verification code.
    Returns True if successful, False if the provider rejected it.
    """
    try:
        if not hasattr(settings, 'RESEND_API_KEY'):
            print("WARNING: Resend API Key is missing.")
            return False
            
        resend.api_key = settings.RESEND_API_KEY
        
        html_content = f"""
        <div style="font-family: 'Plus Jakarta Sans', sans-serif; background-color: #091422; color: #D8E3F7; padding: 32px; border-radius: 12px; max-width: 500px; margin: auto;">
            <h2 style="color: #85FFDE; margin-top: 0;">ROBOTTO Password Reset</h2>
            <p>You requested a password reset for your ROBOTTO account. Use the verification code below to authorize the reset:</p>
            <div style="background-color: #15202F; padding: 24px; border-radius: 8px; text-align: center; margin: 32px 0;">
                <span style="font-size: 32px; font-weight: bold; letter-spacing: 4px; color: #FFFFFF;">{code}</span>
            </div>
            <p style="color: #BACAC3; font-size: 14px;">This code will expire in {settings.PASSWORD_RESET_CODE_TTL_SECONDS // 60} minutes.</p>
            <p style="color: #BACAC3; font-size: 14px;">If you did not request this, please ignore this email. Do not share this code with anyone.</p>
        </div>
        """
        
        response = resend.Emails.send({
            "from": settings.RESEND_FROM_EMAIL,
            "to": [to_email],
            "subject": "Your ROBOTTO Password Reset Code",
            "html": html_content,
            "text": f"Your ROBOTTO verification code is: {code}. It expires in {settings.PASSWORD_RESET_CODE_TTL_SECONDS // 60} minutes."
        })
        return True
    except Exception as e:
        print(f"Resend email failure: {e}")
        return False
