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

    # OpenAI / GPT settings (optional)
    openai_api_key: str | None = Field(default=None, alias="OPENAI_API_KEY")
    openai_api_base: str | None = Field(default=None, alias="OPENAI_API_BASE")
    gpt_questions_model: str = Field(default="gpt-4o-mini", alias="GPT_QUESTIONS_MODEL")
    daily_questions_count: int = Field(default=3, alias="DAILY_QUESTIONS_COUNT")
    gpt_questions_lang: str = Field(default="ko", alias="GPT_QUESTIONS_LANG")

    # TTS settings (optional)
    tts_provider: str = Field(default="openai", alias="TTS_PROVIDER")
    tts_model: str = Field(default="gpt-4o-mini-tts", alias="TTS_MODEL")
    tts_voice: str = Field(default="alloy", alias="TTS_VOICE")

    # Global questions root (shared question WAVs)
    questions_root: str = Field(default="q", alias="QUESTIONS_ROOT")

    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
os.makedirs(settings.media_root, exist_ok=True)
