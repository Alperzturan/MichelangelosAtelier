
from datetime import datetime

from fastapi import APIRouter

from app.core.config import Settings, settings

health_router = APIRouter()

@health_router.get("/health", tags=["Health"])
async def health_check():
    
    return {
        "status": "healthy",
        "app_name": settings.PROJECT_NAME,
        "version": settings.VERSION,
        "timestamp": datetime.now().isoformat() + "Z"
    }