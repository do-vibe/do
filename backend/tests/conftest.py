import os

os.environ.setdefault("GOOGLE_CLIENT_ID", "test-client-id")
os.environ.setdefault("GOOGLE_CLIENT_SECRET", "test-client-secret")
os.environ.setdefault("GOOGLE_REDIRECT_URI", "http://localhost:8000/auth/callback")
os.environ.setdefault("JWT_SECRET", "test-jwt-secret-key-for-testing-only")
os.environ.setdefault("FRONTEND_URL", "http://localhost:3000")

import pytest
from datetime import datetime, timedelta, timezone
from fastapi.testclient import TestClient
from jose import jwt

from main import app

_JWT_SECRET = os.environ["JWT_SECRET"]
_ALGORITHM = "HS256"


@pytest.fixture
def client():
    with TestClient(app, raise_server_exceptions=False) as c:
        yield c


@pytest.fixture
def mock_user():
    return {
        "id": "user-uuid-123",
        "email": "test@example.com",
        "name": "Test User",
        "google_id": "google_123",
    }


@pytest.fixture
def valid_jwt_token(mock_user):
    payload = {
        "user_id": mock_user["id"],
        "email": mock_user["email"],
        "exp": datetime.now(timezone.utc) + timedelta(hours=1),
    }
    return jwt.encode(payload, _JWT_SECRET, algorithm=_ALGORITHM)


@pytest.fixture
def expired_jwt_token(mock_user):
    payload = {
        "user_id": mock_user["id"],
        "email": mock_user["email"],
        "exp": datetime.now(timezone.utc) - timedelta(hours=1),
    }
    return jwt.encode(payload, _JWT_SECRET, algorithm=_ALGORITHM)


@pytest.fixture
def authenticated_client(client, valid_jwt_token):
    client.cookies.set("access_token", valid_jwt_token)
    return client
