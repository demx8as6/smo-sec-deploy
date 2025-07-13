import httpx
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from pathlib import Path

app = FastAPI()

BASE_DIR = Path(__file__).resolve().parent
STATIC_DIR = BASE_DIR / "static"

@app.get("/proxy/routers")
async def proxy_routers(request: Request):
    cookies = request.cookies
    headers = {"Cookie": "; ".join([f"{k}={v}" for k, v in cookies.items()])}
    url = "https://traefik.smo.o-ran-sc.org/api/http/routers"
    async with httpx.AsyncClient(verify='/etc/ssl/certs/mydomain-ca.crt') as client:
        try:
            response = await client.get(url, headers=headers)
            response.raise_for_status()
            return JSONResponse(content=response.json(), status_code=response.status_code)
        except httpx.HTTPError as exc:
            return JSONResponse(content={"error": str(exc)}, status_code=502)

# Define /ready first
@app.get("/ready")
def ready():
    return JSONResponse(content={"status": "ready"})

# Then mount static files at "/"
app.mount("/", StaticFiles(directory=STATIC_DIR, html=True), name="static")
