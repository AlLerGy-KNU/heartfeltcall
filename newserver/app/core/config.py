from pydantic_settings import BaseSettings
from pydantic import Field
import os

class Settings(BaseSettings):
    app_env: str = Field(alias="APP_ENV")
    secret_key: str = Field(alias="SECRET_KEY")
    access_token_expire_minutes: int = Field(alias="ACCESS_TOKEN_EXPIRE_MINUTES")
    algorithm: str = Field(alias="ALGORITHM")
    database_url: str = Field(alias="DATABASE_URL")
    media_root: str = Field(alias="MEDIA_ROOT")

    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
os.makedirs(settings.media_root, exist_ok=True)
