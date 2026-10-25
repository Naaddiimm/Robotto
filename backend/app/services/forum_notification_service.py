import resend
import html
from app.config import settings

class ForumNotificationService:
    @staticmethod
    def send_reply_email(
        to_email: str,
        first_name: str,
        post_title: str,
        reply_author_name: str,
        reply_preview: str
    ) -> bool:
        if not hasattr(settings, 'RESEND_API_KEY'):
            print("WARNING: Resend API Key is missing.")
            return False

        resend.api_key = settings.RESEND_API_KEY

        # Escape HTML to prevent injection
        safe_first_name = html.escape(first_name)
        safe_post_title = html.escape(post_title)
        safe_author = html.escape(reply_author_name)
        safe_preview = html.escape(reply_preview)
        
        # Consistent ROBOTTO Theme
        html_content = f"""
        <div style="font-family: 'Plus Jakarta Sans', sans-serif; background-color: #091422; color: #D8E3F7; padding: 32px; border-radius: 12px; max-width: 500px; margin: auto;">
            <h2 style="color: #85FFDE; margin-top: 0;">ROBOTTO Forum &mdash; New Reply</h2>
            <p>Hello {safe_first_name},</p>
            <p>Someone has replied to your forum post on ROBOTTO.</p>
            <div style="background-color: #15202F; padding: 24px; border-radius: 8px; margin: 32px 0;">
                <p style="color: #FFFFFF; font-weight: bold; margin-bottom: 8px;">Post: {safe_post_title}</p>
                <p style="color: #BACAC3; font-size: 14px; margin-bottom: 8px;"><strong>Reply from:</strong> {safe_author}</p>
                <p style="color: #D8E3F7; font-size: 14px; font-style: italic; border-left: 4px solid #85FFDE; padding-left: 12px;">"{safe_preview}"</p>
            </div>
            <p style="color: #BACAC3; font-size: 14px;">Open ROBOTTO to read the complete reply and continue the discussion.</p>
            <p style="color: #BACAC3; font-size: 14px; margin-top: 24px;">Best regards,<br>The ROBOTTO Team</p>
        </div>
        """

        try:
            response = resend.Emails.send({
                "from": settings.RESEND_FROM_EMAIL,
                "to": [to_email],
                "subject": "ROBOTTO Forum — New Reply to Your Post",
                "html": html_content,
                "text": f"Hello {safe_first_name},\\n\\nSomeone has replied to your forum post '{safe_post_title}'.\\n\\nReply from {safe_author}:\\n\\\"{safe_preview}\\\"\\n\\nOpen ROBOTTO to continue the discussion.\\n\\nBest regards,\\nThe ROBOTTO Team"
            })
            return True
        except Exception as e:
            print(f"Resend email failure: {e}")
            return False
