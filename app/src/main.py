from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import RedirectResponse
import os, hashlib, time, logging
from pydantic import BaseModel, AnyUrl
from .ddb import put_mapping, get_mapping

app = FastAPI()
logger = logging.getLogger("app")


class ShortenPayload(BaseModel):
    url: AnyUrl

@app.get("/healthz")
def health():
    return {"status": "ok", "ts": int(time.time())}

@app.post("/shorten")
async def shorten(payload: ShortenPayload):
    url = str(payload.url)
    short = hashlib.sha256(url.encode()).hexdigest()[:8]
    put_mapping(short, url)
    return {"short": short, "url": url}

@app.get("/{short_id}")
def resolve(short_id: str):
    item = get_mapping(short_id)
    if not item:
        raise HTTPException(404, "not found")
    return RedirectResponse(item["url"])


@app.middleware("http")
async def log_errors(request: Request, call_next):
    try:
        return await call_next(request)
    except Exception:
        logger.exception("Unhandled error")
        raise
