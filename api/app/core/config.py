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



    POSTGRES_SERVER: str = "127.0.0.1"
    POSTGRES_PORT: int = 5432
    POSTGRES_USER: str = "postgres"
    POSTGRES_PASSWORD: str = "1234"
    POSTGRES_DB: str = "atelier_db"

    @property
    def SQLALCHEMY_DATABASE_URI(self) -> str:
        return f"postgresql://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}@{self.POSTGRES_SERVER}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"



settings = Settings()
