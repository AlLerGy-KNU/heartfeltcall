from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.core.database import Base, engine
from app.api.v1 import auth, dependents, connections, voice, analyses, system, invitations

app = FastAPI(title="MemoryOn API", version="1.0.0")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])

@app.on_event("startup")
def on_startup():
    Base.metadata.create_all(bind=engine)

app.include_router(auth.router, prefix="/auth", tags=["Auth"])
app.include_router(dependents.router, prefix="/dependents", tags=["Dependents"])
app.include_router(connections.router, prefix="/connections", tags=["Connections"])
app.include_router(voice.router, prefix="/voice", tags=["Voice Sessions"])
app.include_router(analyses.router, prefix="/dependents", tags=["Analyses"])
app.include_router(system.router, prefix="/system", tags=["System"])
app.include_router(invitations.router, tags=["Connections & Dependent Auth"])
