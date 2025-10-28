from fastapi import FastAPI, Depends, HTTPException, status
from typing import Optional
from pydantic import BaseModel

class HelloResponse(BaseModel):
    message: str

app = FastAPI(
    title="HeartfeltCall API",
    description="HeartfeltCall server API ",
    version="0.1.0",
)

@app.get("/", response_model=HelloResponse)
def root():
    return {"message": "HeartfeltCall API is running."}


@app.get("/health")
def health_check():
    return {"status": "ok"}

