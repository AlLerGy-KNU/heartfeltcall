from sqlalchemy import String, Integer, Float, DateTime, Enum, ForeignKey, Text, JSON, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship
from datetime import datetime
from app.core.database import Base
class Analysis(Base):
    __tablename__ = "analyses"
    __table_args__ = (UniqueConstraint('call_id', name='uq_analyses_call_id'),)
    id: Mapped[int] = mapped_column(Integer, primary_key=True, index=True)
    dependent_id: Mapped[int] = mapped_column(Integer, ForeignKey("dependents.id", ondelete="CASCADE"))
    call_id: Mapped[int] = mapped_column(Integer, ForeignKey("calls.id", ondelete="CASCADE"))
    state: Mapped[str | None] = mapped_column(Enum("NORMAL","MCI","DEMENTIA", name="analysis_state"), nullable=True)
    risk_score: Mapped[float | None] = mapped_column(Float, nullable=True)
    graph_points: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    reasoning: Mapped[str | None] = mapped_column(Text, nullable=True)
    diarization: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    features: Mapped[dict | None] = mapped_column(JSON, nullable=True)
    model_version: Mapped[str | None] = mapped_column(String(64), nullable=True)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=datetime.utcnow)
    dependent = relationship("Dependent", back_populates="analyses")
    call = relationship("Call", back_populates="analysis")
