
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="FoodForecast Connection Test")

# Allow Flutter Web to communicate with FastAPI during development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=False,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def home():
    return {"message": "FoodForecast FastAPI is running"}

@app.get("/health")
def health():
    return {
        "status": "success",
        "message": "Backend is working"
    }

@app.get("/test-connection")
def test_connection():
    return {
        "connected": True,
        "message": "Flutter frontend can connect to FastAPI!"
    }
