from fastapi import APIRouter, HTTPException, status
from app.schemas.password_reset import ResetRequest, VerifyRequest, ConfirmRequest, GenericResponse, VerifyResponse
from app.services.password_reset_service import PasswordResetService

router = APIRouter(prefix="/auth/password-reset", tags=["Password Reset"])

@router.post("/request", response_model=GenericResponse)
def request_reset(payload: ResetRequest):
    try:
        PasswordResetService.request_code(payload.email)
        # Always return a generic success message to prevent email enumeration
        return GenericResponse(message="If the email is registered, a reset code has been sent.")
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
    except Exception:
        # Mask internal errors
        raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail="Service unavailable.")

@router.post("/verify", response_model=VerifyResponse)
def verify_code(payload: VerifyRequest):
    try:
        token = PasswordResetService.verify_code(payload.email, payload.code)
        return VerifyResponse(
            message="Verification successful.",
            reset_token=token
        )
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))

@router.post("/confirm", response_model=GenericResponse)
def confirm_reset(payload: ConfirmRequest):
    try:
        email = PasswordResetService.confirm_reset(payload.reset_token, payload.new_password)
        # In a fully remote app, the password is updated in the backend DB here.
        # Since ROBOTTO uses a local SQLite DB, we just validate the token and tell the app it's OK to proceed.
        return GenericResponse(message="Authorization valid.")
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))
