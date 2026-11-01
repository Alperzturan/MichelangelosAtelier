from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.artwork import Artwork

router = APIRouter(prefix="/artworks", tags=["Artworks"])

@router.get("/")
def get_artworks(db: Session = Depends(get_db)):
    return db.query(Artwork).all()