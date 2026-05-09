import os
from urllib.parse import urlencode

from fastapi import APIRouter
from fastapi.responses import JSONResponse, RedirectResponse

router = APIRouter(prefix="/auth", tags=["auth"])

_GOOGLE_AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth"


@router.get("/google")
async def google_login():
    params = {
        "client_id": os.getenv("GOOGLE_CLIENT_ID"),
        "redirect_uri": os.getenv("GOOGLE_REDIRECT_URI"),
        "response_type": "code",
        "scope": "openid email profile",
        "access_type": "offline",
    }
    return RedirectResponse(url=f"{_GOOGLE_AUTH_URL}?{urlencode(params)}", status_code=307)


@router.get("/callback")
async def google_callback(code: str = None):
    return JSONResponse({"detail": "not implemented"}, status_code=501)


@router.get("/me")
async def get_me():
    return JSONResponse({"detail": "not implemented"}, status_code=501)


@router.post("/logout")
async def logout():
    return JSONResponse({"detail": "not implemented"}, status_code=501)
