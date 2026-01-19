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

    # Gemini LLM settings (Google)
    gemini_api_key: str | None = Field(default=None, alias="GEMINI_API_KEY")
    gemini_api_base: str = Field(default="https://generativelanguage.googleapis.com/v1beta/openai/", alias="GEMINI_API_BASE")
    gemini_model: str = Field(default="gemini-2.5-flash-preview-04-17", alias="GEMINI_MODEL")
    daily_questions_count: int = Field(default=3, alias="DAILY_QUESTIONS_COUNT")

    # Google Cloud TTS settings
    google_tts_enabled: bool = Field(default=True, alias="GOOGLE_TTS_ENABLED")
    google_tts_language: str = Field(default="ko-KR", alias="GOOGLE_TTS_LANGUAGE")
    google_tts_voice: str = Field(default="ko-KR-Wavenet-A", alias="GOOGLE_TTS_VOICE")

    # Global questions root (shared question WAVs)
    questions_root: str = Field(default="q", alias="QUESTIONS_ROOT")

    # AI model paths (optional)
    mci_model_path: str | None = Field(default=None, alias="MCI_MODEL_PATH")

    # External AI service (optional)
    ai_service_url: str = Field(default="http://localhost:8001", alias="AI_SERVICE_URL")

    class Config:
        env_file = ".env"
        case_sensitive = True

settings = Settings()
os.makedirs(settings.media_root, exist_ok=True)
