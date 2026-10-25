import pytest
from fastapi.testclient import TestClient
from app.main import app

client = TestClient(app)

def test_notify_reply_success(mocker):
    # Mock Resend to always return True
    mocker.patch('app.services.forum_notification_service.ForumNotificationService.send_reply_email', return_value=True)
    
    payload = {
        "recipient_email": "author@example.com",
        "recipient_first_name": "Alice",
        "post_title": "How to build a combat robot?",
        "reply_author_name": "Bob",
        "reply_preview": "You should start with a solid aluminum chassis..."
    }
    
    response = client.post("/forum/notifications/reply", json=payload)
    
    assert response.status_code == 200
    assert response.json()["message"] == "Notification sent successfully."

def test_notify_reply_failure(mocker):
    # Mock Resend to return False (simulating API failure)
    mocker.patch('app.services.forum_notification_service.ForumNotificationService.send_reply_email', return_value=False)
    
    payload = {
        "recipient_email": "author@example.com",
        "recipient_first_name": "Alice",
        "post_title": "How to build a combat robot?",
        "reply_author_name": "Bob",
        "reply_preview": "You should start with a solid aluminum chassis..."
    }
    
    response = client.post("/forum/notifications/reply", json=payload)
    
    assert response.status_code == 500
    assert response.json()["detail"] == "Failed to deliver notification."

def test_notify_reply_validation_error():
    # Missing required field (reply_preview)
    payload = {
        "recipient_email": "author@example.com",
        "recipient_first_name": "Alice",
        "post_title": "How to build a combat robot?",
        "reply_author_name": "Bob"
    }
    
    response = client.post("/forum/notifications/reply", json=payload)
    
    assert response.status_code == 422 # Unprocessable Entity (FastAPI validation)
