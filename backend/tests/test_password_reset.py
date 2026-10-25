import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.services.password_reset_service import _reset_sessions, _authorized_tokens

client = TestClient(app)

@pytest.fixture(autouse=True)
def clear_sessions():
    _reset_sessions.clear()
    _authorized_tokens.clear()
    yield

def test_health_check():
    response = client.get("/")
    assert response.status_code == 200
    assert response.json() == {"status": "online", "service": "ROBOTTO Password Reset API"}

def test_request_reset(mocker):
    mocker.patch('app.services.password_reset_service.send_reset_code_email', return_value=True)
    
    response = client.post("/auth/password-reset/request", json={"email": "test@example.com"})
    assert response.status_code == 200
    assert response.json()["message"] == "If the email is registered, a reset code has been sent."
    assert "test@example.com" in _reset_sessions

def test_verify_code_success(mocker):
    mocker.patch('app.services.password_reset_service.send_reset_code_email', return_value=True)
    
    # Request code
    client.post("/auth/password-reset/request", json={"email": "test@example.com"})
    
    # Extract code (mocking the fact that it was sent)
    session = _reset_sessions["test@example.com"]
    # We can't easily get the plaintext code, let's mock generate_secure_code
    
def test_verify_flow(mocker):
    mocker.patch('app.services.password_reset_service.send_reset_code_email', return_value=True)
    mocker.patch('app.services.password_reset_service.generate_secure_code', return_value="ABCDEFGH")
    
    client.post("/auth/password-reset/request", json={"email": "test@example.com"})
    
    response = client.post("/auth/password-reset/verify", json={"email": "test@example.com", "code": "ABCDEFGH"})
    assert response.status_code == 200
    assert "reset_token" in response.json()
    assert "test@example.com" not in _reset_sessions

def test_verify_flow_failure_max_attempts(mocker):
    mocker.patch('app.services.password_reset_service.send_reset_code_email', return_value=True)
    mocker.patch('app.services.password_reset_service.generate_secure_code', return_value="ABCDEFGH")
    
    client.post("/auth/password-reset/request", json={"email": "test@example.com"})
    
    for _ in range(5):
        resp = client.post("/auth/password-reset/verify", json={"email": "test@example.com", "code": "WRONGCOD"})
        assert resp.status_code == 400
        
    # Sixth attempt should be blocked
    resp = client.post("/auth/password-reset/verify", json={"email": "test@example.com", "code": "ABCDEFGH"})
    assert resp.status_code == 400
    assert "Too many incorrect attempts" in resp.json()["detail"]

def test_confirm_reset(mocker):
    mocker.patch('app.services.password_reset_service.send_reset_code_email', return_value=True)
    mocker.patch('app.services.password_reset_service.generate_secure_code', return_value="ABCDEFGH")
    
    client.post("/auth/password-reset/request", json={"email": "test@example.com"})
    verify_resp = client.post("/auth/password-reset/verify", json={"email": "test@example.com", "code": "ABCDEFGH"})
    token = verify_resp.json()["reset_token"]
    
    confirm_resp = client.post("/auth/password-reset/confirm", json={"reset_token": token, "new_password": "NewSecurePassword123!"})
    assert confirm_resp.status_code == 200
    assert confirm_resp.json()["message"] == "Authorization valid."
