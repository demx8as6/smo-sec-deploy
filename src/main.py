from fastapi import FastAPI
from fastapi.responses import JSONResponse, FileResponse
from fastapi.staticfiles import StaticFiles
from pathlib import Path

app = FastAPI()

BASE_DIR = Path(__file__).resolve().parent
STATIC_DIR = BASE_DIR / "static"

# Define /ready first
@app.get("/ready")
def ready():
    return JSONResponse(content={"status": "ready"})

# Then mount static files at "/"
app.mount("/", StaticFiles(directory=STATIC_DIR, html=True), name="static")
