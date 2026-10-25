from pydantic import BaseModel, EmailStr

class ResetRequest(BaseModel):
    email: EmailStr

class VerifyRequest(BaseModel):
    email: EmailStr
    code: str

class ConfirmRequest(BaseModel):
    reset_token: str
    new_password: str

class GenericResponse(BaseModel):
    message: str

class VerifyResponse(BaseModel):
    message: str
    reset_token: str
