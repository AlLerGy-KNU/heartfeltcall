import wave, struct, os
from app.core.config import settings

# Google Cloud TTS 인증 설정
if settings.google_application_credentials:
    os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = settings.google_application_credentials


def _write_silence_wav(path: str, seconds: float = 1.0, samplerate: int = 16000):
    """Write a silent WAV file as fallback."""
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
    TTS synthesizer with Google Cloud TTS support.
    - If GOOGLE_TTS_ENABLED is True, attempts Google Cloud TTS.
    - Otherwise, writes a 1-second silent WAV as placeholder.

    Requires GOOGLE_APPLICATION_CREDENTIALS environment variable
    to be set to the path of the service account JSON file.
    """
    os.makedirs(os.path.dirname(path) or ".", exist_ok=True)

    if settings.google_tts_enabled:
        try:
            from google.cloud import texttospeech

            client = texttospeech.TextToSpeechClient()

            synthesis_input = texttospeech.SynthesisInput(text=text)

            voice = texttospeech.VoiceSelectionParams(
                language_code=settings.google_tts_language,
                name=settings.google_tts_voice,
            )

            audio_config = texttospeech.AudioConfig(
                audio_encoding=texttospeech.AudioEncoding.LINEAR16,
                sample_rate_hertz=16000,
            )

            response = client.synthesize_speech(
                input=synthesis_input,
                voice=voice,
                audio_config=audio_config,
            )

            with open(path, "wb") as out:
                out.write(response.audio_content)
            return

        except Exception:
            # Fallback to silence if Google Cloud TTS fails
            pass

    _write_silence_wav(path)
