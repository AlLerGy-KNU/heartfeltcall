import wave, struct, os
from app.core.config import settings

def _write_silence_wav(path: str, seconds: float = 1.0, samplerate: int = 16000):
    nframes = int(seconds * samplerate)
    with wave.open(path, 'wb') as wf:
        wf.setnchannels(1)
        wf.setsampwidth(2)  # 16-bit
        wf.setframerate(samplerate)
        silence_frame = struct.pack('<h', 0)
        for _ in range(nframes):
            wf.writeframesraw(silence_frame)

def synthesize_to_wav(text: str, path: str):
    """
    TTS synthesizer with OpenAI support when configured.
    - If OPENAI_API_KEY is set and TTS_PROVIDER=openai, attempts OpenAI TTS.
    - Otherwise, writes a 1-second silent WAV as placeholder.
    """
    os.makedirs(os.path.dirname(path), exist_ok=True)
    if settings.openai_api_key and (settings.tts_provider or "").lower() == "openai":
        try:
            from openai import OpenAI
            client = OpenAI(api_key=settings.openai_api_key, base_url=settings.openai_api_base or None)
            # Streaming to file (supported in new SDKs)
            with client.audio.speech.with_streaming_response.create(
                model=settings.tts_model,
                voice=settings.tts_voice,
                input=text,
            ) as resp:
                resp.stream_to_file(path)
                return
        except Exception:
            # Fallback to silence if OpenAI call fails or SDK missing
            pass
    _write_silence_wav(path)
