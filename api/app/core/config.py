from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict
from typing import List



API_DIR = Path(__file__).resolve().parent.parent.parent
ENV_FILE_PATH = API_DIR / ".env"


class Settings(BaseSettings):
    PROJECT_NAME: str = "Michelangelo's Atelier API"
    VERSION: str = "1.0.0"
    DESCRIPTION: str = "Klasik ve Modern Sanat Galerisi RESTful Web API"
    API_V1_STR: str = "/api/v1"
    DEBUG: bool = True
    
    HOST: str = "localhost"
    PORT: int = 8000
    

    CORS_ORIGINS: List[str] = ["*"]
    model_config = SettingsConfigDict(env_file=ENV_FILE_PATH, env_file_encoding="utf-8", extra="ignore")


settings = Settings()
