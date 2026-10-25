


from fastapi import FastAPI
from app.core.config import settings
from app.endpoints.health import health_router  


app = FastAPI(
    title=settings.PROJECT_NAME,
    version=settings.VERSION,
    description=settings.DESCRIPTION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url="/docs",
    redoc_url="/redoc",
    debug=settings.DEBUG,
)


app.include_router(
    router=health_router,
    prefix=settings.API_V1_STR
)


@app.get("/", summary="Root Endpoint", tags=["Root"])
async def root():
  return {
      "message": "Michelangelo's Atelier API Servisine Hoş Geldiniz",
      "docs": "/docs",
      "version": settings.VERSION,
  }
