from typing import Dict, Any
import os, sys
from pathlib import Path
from app.core.config import settings

def _import_external_analysis():
    mod = None
    try:
        # prefer ai.analysis module within repository
        import ai.analysis as mod  # type: ignore
    except Exception:
        # attempt to add project root (which may contain ai/) to sys.path
        try:
            here = Path(__file__).resolve()
            proj_root = here.parents[3]
            if str(proj_root) not in sys.path:
                sys.path.insert(0, str(proj_root))
            import ai.analysis as mod  # type: ignore
        except Exception:
            try:
                import analysis as mod  # fallback to top-level module name
            except Exception:
                mod = None
    return mod

async def run_voice_analysis(base_path: str) -> Dict[str, Any]:
    ext = _import_external_analysis()
    if ext is None:
        return {"success": False, "message": "analysis module not found. Place ai/analysis.py or analysis.py alongside the server process."}
    return await ext.main(base_path)

async def run_multi_voice_analysis(base_path: str) -> Dict[str, Any]:
    """
    Multi-file analysis wrapper. Expects directory containing one or more wav files.
    Uses external ai.analysis if available. Returns {success, score, mel_path?} on success.
    """
    # Prefer external HTTP service if configured
    if settings.ai_service_url:
        try:
            import httpx
            url = settings.ai_service_url.rstrip("/") + "/system/voice-analysis"
            # Attach up to 3 wav files as multipart form-data with field name 'files'
            files_list = []
            try:
                for name in sorted(os.listdir(base_path)):
                    if name.lower().endswith('.wav'):
                        fp = os.path.join(base_path, name)
                        files_list.append(('files', (name, open(fp, 'rb'), 'audio/wav')))
                        if len(files_list) >= 3:
                            break
            except FileNotFoundError:
                files_list = []

            async with httpx.AsyncClient(timeout=120.0) as client:
                if files_list:
                    resp = await client.post(url, files=files_list)
                else:
                    # Fallback: no local files found; still call with empty body
                    resp = await client.post(url)
                resp.raise_for_status()
                return resp.json()
        except Exception as e:
            # Fallback to local module if HTTP call fails
            pass
    ext = _import_external_analysis()
    if ext is None:
        return {"success": False, "message": "analysis module not found. Place ai/analysis.py or analysis.py alongside the server process."}
    return await ext.main(base_path)
