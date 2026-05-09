def test_logout_returns_200(authenticated_client):
    response = authenticated_client.post("/auth/logout")
    assert response.status_code == 200


def test_logout_clears_cookie(authenticated_client):
    response = authenticated_client.post("/auth/logout")
    set_cookie = response.headers.get("set-cookie", "")
    assert "access_token" in set_cookie
    assert "max-age=0" in set_cookie.lower() or 'expires=Thu, 01 Jan 1970' in set_cookie


def test_me_after_logout_returns_401(authenticated_client):
    authenticated_client.post("/auth/logout")
    response = authenticated_client.get("/auth/me")
    assert response.status_code == 401
