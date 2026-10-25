from fastapi import FastAPI
from app.routes import password_reset, forum_notifications

app = FastAPI(title="ROBOTTO Auth API")

app.include_router(password_reset.router)
app.include_router(forum_notifications.router)

@app.get("/")
def health_check():
    return {"status": "online", "service": "ROBOTTO Password Reset API"}
