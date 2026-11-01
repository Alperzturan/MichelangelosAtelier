from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.models.review import Review

router = APIRouter(prefix="/reviews", tags=["Reviews"])

@router.get("/")
def get_reviews(db: Session = Depends(get_db)):
    return db.query(Review).all()