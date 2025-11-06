from fastapi import APIRouter
router = APIRouter()
@router.get("/health", response_model=dict)
def health(): 
    return {"status": "ok"}
