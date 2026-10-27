from sqlalchemy import Column, Integer
from app.core.database import Base

class Artwork(Base):
    __tablename__ = "artworks"

    id = Column(Integer, primary_key=True, index=True)
