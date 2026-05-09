from fastapi import APIRouter
from fastapi.responses import JSONResponse

router = APIRouter(prefix="/auth", tags=["auth"])


@router.get("/google")
async def google_login():
    return JSONResponse({"detail": "not implemented"}, status_code=501)


@router.get("/callback")
async def google_callback(code: str = None):
    return JSONResponse({"detail": "not implemented"}, status_code=501)


@router.get("/me")
async def get_me():
    return JSONResponse({"detail": "not implemented"}, status_code=501)


@router.post("/logout")
async def logout():
    return JSONResponse({"detail": "not implemented"}, status_code=501)
