from fastapi import APIRouter, HTTPException, status
from app.schemas.forum_notification import ReplyNotificationRequest, GenericResponse
from app.services.forum_notification_service import ForumNotificationService

router = APIRouter(prefix="/forum/notifications", tags=["Forum Notifications"])

@router.post("/reply", response_model=GenericResponse)
def notify_reply(payload: ReplyNotificationRequest):
    try:
        success = ForumNotificationService.send_reply_email(
            to_email=payload.recipient_email,
            first_name=payload.recipient_first_name,
            post_title=payload.post_title,
            reply_author_name=payload.reply_author_name,
            reply_preview=payload.reply_preview
        )
        if not success:
            raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Failed to deliver notification.")
            
        return GenericResponse(message="Notification sent successfully.")
    except Exception as e:
        if isinstance(e, HTTPException):
            raise e
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Internal server error.")
