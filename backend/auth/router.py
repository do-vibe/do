import os
from datetime import datetime, timedelta, timezone
from typing import Optional
from urllib.parse import urlencode

import httpx
from fastapi import APIRouter, Cookie, HTTPException
from fastapi.responses import JSONResponse, RedirectResponse
from jose import JWTError, jwt
from supabase import Client, create_client

router = APIRouter(prefix="/auth", tags=["auth"])

_GOOGLE_AUTH_URL = "https://accounts.google.com/o/oauth2/v2/auth"
_GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token"
_GOOGLE_USERINFO_URL = "https://www.googleapis.com/oauth2/v2/userinfo"
_JWT_ALGORITHM = "HS256"
_JWT_EXPIRY_HOURS = 24


def _get_supabase() -> Client:
    return create_client(
        os.getenv("SUPABASE_URL"),
        os.getenv("SUPABASE_SERVICE_KEY"),
    )


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
async def google_callback(code: str):
    async with httpx.AsyncClient() as http:
        token_response = await http.post(
            _GOOGLE_TOKEN_URL,
            data={
                "code": code,
                "client_id": os.getenv("GOOGLE_CLIENT_ID"),
                "client_secret": os.getenv("GOOGLE_CLIENT_SECRET"),
                "redirect_uri": os.getenv("GOOGLE_REDIRECT_URI"),
                "grant_type": "authorization_code",
            },
        )

        if token_response.status_code != 200:
            raise HTTPException(status_code=401, detail="Failed to exchange authorization code")

        access_token = token_response.json()["access_token"]

        userinfo_response = await http.get(
            _GOOGLE_USERINFO_URL,
            headers={"Authorization": f"Bearer {access_token}"},
        )

    userinfo = userinfo_response.json()

    supabase = _get_supabase()
    result = supabase.table("users").upsert(
        {
            "google_id": userinfo["id"],
            "email": userinfo["email"],
            "name": userinfo["name"],
        },
        on_conflict="google_id",
    ).execute()

    user = result.data[0]

    token = jwt.encode(
        {
            "user_id": user["id"],
            "email": user["email"],
            "exp": datetime.now(timezone.utc) + timedelta(hours=_JWT_EXPIRY_HOURS),
        },
        os.getenv("JWT_SECRET"),
        algorithm=_JWT_ALGORITHM,
    )

    response = RedirectResponse(
        url=f"{os.getenv('FRONTEND_URL')}/dashboard",
        status_code=302,
    )
    response.set_cookie(
        key="access_token",
        value=token,
        httponly=True,
        secure=True,
        samesite="lax",
        max_age=_JWT_EXPIRY_HOURS * 3600,
    )
    return response


@router.get("/me")
async def get_me(access_token: Optional[str] = Cookie(default=None)):
    if not access_token:
        raise HTTPException(status_code=401, detail="Not authenticated")
    try:
        payload = jwt.decode(access_token, os.getenv("JWT_SECRET"), algorithms=[_JWT_ALGORITHM])
    except JWTError:
        raise HTTPException(status_code=401, detail="Invalid or expired token")
    return {"user_id": payload["user_id"], "email": payload["email"]}


@router.post("/logout")
async def logout():
    response = JSONResponse({"detail": "logged out"})
    response.delete_cookie(key="access_token", httponly=True, secure=True, samesite="lax")
    return response
