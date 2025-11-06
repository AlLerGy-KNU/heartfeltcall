import os
from fastapi import UploadFile
from app.core.config import settings
def ensure_dir(path: str): os.makedirs(path, exist_ok=True)
def save_upload(dir_path: str, upload: UploadFile, filename: str | None = None) -> str:
    ensure_dir(dir_path); name = filename or upload.filename; fp = os.path.join(dir_path, name)
    with open(fp, "wb") as f: f.write(upload.file.read())
    return fp
