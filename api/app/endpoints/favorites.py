from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.favorite import Favorite

router = APIRouter(prefix="/favorites", tags=["Favorites"])

@router.get("/")
def get_favorites(db: Session = Depends(get_db)):
    return db.query(Favorite).all()