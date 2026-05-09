def test_redirects_to_google(client):
    response = client.get("/auth/google", follow_redirects=False)
    assert response.status_code == 307


def test_redirect_url_contains_google_domain(client):
    response = client.get("/auth/google", follow_redirects=False)
    assert "accounts.google.com" in response.headers["location"]


def test_redirect_url_contains_client_id(client):
    response = client.get("/auth/google", follow_redirects=False)
    assert "client_id=" in response.headers["location"]


def test_redirect_url_contains_callback_uri(client):
    response = client.get("/auth/google", follow_redirects=False)
    assert "redirect_uri=" in response.headers["location"]


def test_no_auth_required(client):
    response = client.get("/auth/google", follow_redirects=False)
    assert response.status_code != 401
