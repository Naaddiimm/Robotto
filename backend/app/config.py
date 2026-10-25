import os
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    RESEND_API_KEY: str = os.getenv("RESEND_API_KEY", "fallback_key")
    RESEND_FROM_EMAIL: str = os.getenv("RESEND_FROM_EMAIL", "fallback@example.com")
    PASSWORD_RESET_CODE_TTL_SECONDS: int = 600
    PASSWORD_RESET_RESEND_COOLDOWN_SECONDS: int = 60
    PASSWORD_RESET_MAX_ATTEMPTS: int = 5
    
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

settings = Settings()
