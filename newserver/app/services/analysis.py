from typing import Dict, Any
import os
try:
    import analysis as external_analysis
except Exception:
    external_analysis = None
async def run_voice_analysis(base_path: str) -> Dict[str, Any]:
    if external_analysis is None:
        return {"success": False, "message": "analysis module not found. Place analysis.py alongside the server process."}
    return await external_analysis.main(base_path)
