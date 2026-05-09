import httpx
import respx

GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token"
GOOGLE_USERINFO_URL = "https://www.googleapis.com/oauth2/v2/userinfo"


@respx.mock
def test_happy_path_sets_cookie(client, mock_user):
    respx.post(GOOGLE_TOKEN_URL).mock(
        return_value=httpx.Response(200, json={"access_token": "fake_token"})
    )
    respx.get(GOOGLE_USERINFO_URL).mock(
        return_value=httpx.Response(200, json={
            "id": mock_user["google_id"],
            "email": mock_user["email"],
            "name": mock_user["name"],
        })
    )
    response = client.get("/auth/callback?code=fake_code", follow_redirects=False)
    assert "access_token" in response.cookies


@respx.mock
def test_happy_path_redirects_to_frontend(client, mock_user):
    respx.post(GOOGLE_TOKEN_URL).mock(
        return_value=httpx.Response(200, json={"access_token": "fake_token"})
    )
    respx.get(GOOGLE_USERINFO_URL).mock(
        return_value=httpx.Response(200, json={
            "id": mock_user["google_id"],
            "email": mock_user["email"],
            "name": mock_user["name"],
        })
    )
    response = client.get("/auth/callback?code=fake_code", follow_redirects=False)
    assert response.status_code in (302, 307)


@respx.mock
def test_cookie_is_httponly(client, mock_user):
    respx.post(GOOGLE_TOKEN_URL).mock(
        return_value=httpx.Response(200, json={"access_token": "fake_token"})
    )
    respx.get(GOOGLE_USERINFO_URL).mock(
        return_value=httpx.Response(200, json={
            "id": mock_user["google_id"],
            "email": mock_user["email"],
            "name": mock_user["name"],
        })
    )
    response = client.get("/auth/callback?code=fake_code", follow_redirects=False)
    set_cookie = response.headers.get("set-cookie", "")
    assert "httponly" in set_cookie.lower()


@respx.mock
def test_google_token_exchange_failure(client):
    respx.post(GOOGLE_TOKEN_URL).mock(
        return_value=httpx.Response(400, json={"error": "invalid_grant"})
    )
    response = client.get("/auth/callback?code=bad_code", follow_redirects=False)
    assert response.status_code in (400, 401)


def test_missing_code_returns_422(client):
    response = client.get("/auth/callback")
    assert response.status_code == 422
