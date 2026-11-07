from sqlalchemy import Column, Integer, String, Text, DateTime, ForeignKey, func
from sqlalchemy.orm import relationship
from app.core.database import Base


class Artwork(Base):
    __tablename__ = "artworks"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String(200), index=True, nullable=False)
    artist = Column(String(150), index=True, nullable=False)
    year = Column(Integer, nullable=False)
    image_url = Column(String(500), nullable=False)
    description = Column(Text, nullable=True)
    category_id = Column(Integer, ForeignKey("categories.id", ondelete="CASCADE"), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)

    category = relationship("Category", back_populates="artworks")
    favorites = relationship("Favorite", back_populates="artwork", cascade="all, delete-orphan")
    reviews = relationship("Review", back_populates="artwork", cascade="all, delete-orphan")
