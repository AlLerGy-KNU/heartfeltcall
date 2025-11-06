from typing import Dict, Any
import os

def _import_external_analysis():
    mod = None
    try:
        # prefer ai.analysis module within repository
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
    ext = _import_external_analysis()
    if ext is None:
        return {"success": False, "message": "analysis module not found. Place ai/analysis.py or analysis.py alongside the server process."}
    return await ext.main(base_path)
