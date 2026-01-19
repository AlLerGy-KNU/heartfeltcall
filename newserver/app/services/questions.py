import os
import shutil
import threading
import time
from datetime import datetime, timedelta
from typing import List
from app.core.config import settings
from app.services.tts import synthesize_to_wav

DEFAULT_QUESTIONS_KO = [
    "오늘 기분이 어떠세요?",
    "최근에 즐겁게 보낸 시간이 있으셨나요?",
    "오늘 식사는 맛있게 하셨나요?",
]

def global_questions_dir() -> str:
    base = settings.questions_root
    if not os.path.isabs(base):
        base = os.path.join(os.getcwd(), base)
    os.makedirs(base, exist_ok=True)
    return base

def _generate_questions_with_gemini(dep_name: str | None = None) -> List[str]:
    """
    Generate three daily questions using Google Gemini 2.5 Flash if configured. Returns 3 strings.
    Fallback to DEFAULT_QUESTIONS_KO on failure.
    """
    api_key = settings.gemini_api_key
    if not api_key:
        return DEFAULT_QUESTIONS_KO[:3]

    system = (
        "당신은 고령의 사용자와 대화할 상냥한 비서입니다. "
        "일상 대화를 위한 한국어 질문 3개를 생성하세요. 각 질문은 40자 이하, 공손하고 따뜻한 톤. "
        "질문만 출력하고 번호나 불릿 없이 줄바꿈으로 구분하세요."
    )
    user = f"피보호자 이름: {dep_name or ''}"

    try:
        from openai import OpenAI
        client = OpenAI(
            api_key=api_key,
            base_url=settings.gemini_api_base
        )
        resp = client.chat.completions.create(
            model=settings.gemini_model,
            messages=[
                {"role": "system", "content": system},
                {"role": "user", "content": user},
            ],
            temperature=0.7,
            max_tokens=256,
        )
        text = resp.choices[0].message.content or ""
        lines = [ln.strip().lstrip("-•1234567890. ") for ln in text.splitlines()]
        qs = [ln for ln in lines if ln]
        if len(qs) >= 3:
            return qs[:3]
    except Exception:
        pass
    return DEFAULT_QUESTIONS_KO[:3]

def ensure_global_questions(questions: List[str] | None = None) -> list[str]:
    """
    Ensure shared global question WAV files exist under questions_root as a1.wav..aN.wav.
    If files missing or empty, re-generate all of them via GPT→TTS (or silence).
    Returns absolute file paths.
    """
    qdir = global_questions_dir()
    count = max(1, int(getattr(settings, 'daily_questions_count', 3)))
    paths = [os.path.join(qdir, f"a{i}.wav") for i in range(1, count + 1)]
    need = not all(os.path.exists(p) and os.path.getsize(p) > 0 for p in paths)
    if need:
        if questions is None:
            questions = _generate_questions_with_gemini(None)
        for i, text in enumerate((questions or DEFAULT_QUESTIONS_KO)[:count], start=1):
            synthesize_to_wav(text, os.path.join(qdir, f"a{i}.wav"))
    return paths

def purge_and_regenerate_global_questions():
    """
    At midnight, purge the global questions_root folder and regenerate a1..aN.wav.
    """
    qdir = global_questions_dir()
    # Purge files
    for name in os.listdir(qdir):
        try:
            os.remove(os.path.join(qdir, name))
        except Exception:
            pass
    # Re-generate
    ensure_global_questions()


def _seconds_until_next_midnight(now: datetime | None = None) -> float:
    now = now or datetime.utcnow()
    tomorrow = (now + timedelta(days=1)).replace(hour=0, minute=0, second=5, microsecond=0)
    return max(1.0, (tomorrow - now).total_seconds())

def run_daily_generation_once():
    # Generate shared questions once (purge + regenerate)
    purge_and_regenerate_global_questions()

def start_daily_question_job():
    def _loop():
        # Initial run on startup
        try:
            run_daily_generation_once()
        except Exception:
            pass
        # Sleep until next midnight and run repeatedly
        while True:
            try:
                time.sleep(_seconds_until_next_midnight())
                run_daily_generation_once()
            except Exception:
                # avoid crashing the thread
                time.sleep(60)
    t = threading.Thread(target=_loop, daemon=True)
    t.start()
