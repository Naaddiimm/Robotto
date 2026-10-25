from pydantic import BaseModel, EmailStr, Field

class ReplyNotificationRequest(BaseModel):
    recipient_email: EmailStr
    recipient_first_name: str
    post_title: str
    reply_author_name: str
    reply_preview: str = Field(..., max_length=250)

class GenericResponse(BaseModel):
    message: str
