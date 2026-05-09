import pytest


@pytest.mark.skip(reason="not yet implemented")
def test_valid_cookie_returns_user(authenticated_client, mock_user):
    response = authenticated_client.get("/auth/me")
    assert response.status_code == 200
    data = response.json()
    assert data["email"] == mock_user["email"]


@pytest.mark.skip(reason="not yet implemented")
def test_missing_cookie_returns_401(client):
    response = client.get("/auth/me")
    assert response.status_code == 401


@pytest.mark.skip(reason="not yet implemented")
def test_expired_jwt_returns_401(client, expired_jwt_token):
    client.cookies.set("access_token", expired_jwt_token)
    response = client.get("/auth/me")
    assert response.status_code == 401


@pytest.mark.skip(reason="not yet implemented")
def test_tampered_jwt_returns_401(client):
    client.cookies.set("access_token", "tampered.jwt.token")
    response = client.get("/auth/me")
    assert response.status_code == 401
