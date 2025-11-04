import os
from fastapi import FastAPI, UploadFile, File, Form
import shutil
import analysis

app = FastAPI()

@app.post("/system/voice-analysis")
async def upload_voiceFile(callId: str = Form(...)):

    base_path = os.path.join("voice-files/", f"{callId}")
    """
    file_name = file.filename.lower()
    save_path = ""
    os.makedirs(base_path, exist_ok=True)

    # 파일명과 확장자 체크, 저장경로 설정
    if file_name.endswith(".wav"):
        save_path = os.path.join(base_path, f"{callId}/{file_name[-3:]}")
    else:
        return {"success": False }

    # 저장
    try:
        with open(save_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
    except Exception as e:
        return {"success": False, "message": f"fail to save File: {e}"}
    finally:
        file.file.close()
    """

    # 분석
    analysis_json = await analysis.main(base_path)
    if not analysis_json["success"]:
        return analysis_json

    return {"success": True, "result" : analysis_json["result"]}
