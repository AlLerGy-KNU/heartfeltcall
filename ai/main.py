import os
import uuid
from typing import List, Optional
from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
import analysis

app = FastAPI()
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

@app.post("/system/voice-analysis")
async def upload_voiceFile(
    files: Optional[List[UploadFile]] = File(None),
    callId: Optional[str] = Form(None),
    mel_pick: Optional[str] = Form(None)
):
    """
    Accepts up to 3 wav files as multipart/form-data under field name 'files'.
    Saves them to ./voice-files/{callId} and runs analysis over that folder.
    If no files are provided, expects that ./voice-files/{callId} already exists.
    """
    call_id = callId or f"call-{uuid.uuid4().hex[:8]}"
    base_path = os.path.join("voice-files", call_id)
    os.makedirs(base_path, exist_ok=True)

    saved = []
    if files:
        for i, up in enumerate(files[:3], start=1):
            name = up.filename or f"answer{i}.wav"
            dest = os.path.join(base_path, name)
            with open(dest, "wb") as f:
                f.write(await up.read())
            saved.append(dest)

    result = await analysis.main(base_path, mel_pick=mel_pick)
    if not result.get("success"):
        return result

    return {
        "success": True,
        "result": result.get("result"),
        "mel_path": result.get("mel_path"),
        "callId": call_id,
        "saved_count": len(saved)
    }
