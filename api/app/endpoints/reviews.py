from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy import select
from sqlalchemy.orm import Session, joinedload

from app.core.database import get_db
from app.core.deps import get_current_user
from app.models.artwork import Artwork
from app.models.review import Review
from app.models.user import User
from app.schemas.review import ReviewCreate, ReviewResponse

router = APIRouter(prefix="/reviews", tags=["Reviews"])


def _to_review_response(review: Review, user_name: Optional[str] = None) -> ReviewResponse:
    """ORM Review nesnesini kullanıcı adı dahil ReviewResponse şemasına dönüştürür."""
    return ReviewResponse(
        id=review.id,
        user_id=review.user_id,
        artwork_id=review.artwork_id,
        rating=review.rating,
        comment=review.comment or "",
        created_at=review.created_at,
        user_name=user_name if user_name is not None else (review.user.full_name if review.user else None),
    )


@router.get("/", response_model=List[ReviewResponse], summary="Eser İncelemelerini Listele")
def get_reviews(
    artwork_id: Optional[int] = Query(None, gt=0, description="Filtrelenecek sanat eseri ID"),
    db: Session = Depends(get_db),
):
    stmt = (
        select(Review)
        .options(joinedload(Review.user))
        .order_by(Review.created_at.desc(), Review.id.desc())
    )
    if artwork_id is not None:
        stmt = stmt.where(Review.artwork_id == artwork_id)

    reviews = db.execute(stmt).scalars().all()
    return [_to_review_response(review) for review in reviews]


@router.post(
    "/",
    response_model=ReviewResponse,
    status_code=status.HTTP_201_CREATED,
    summary="Yeni Eser Puanı ve Eleştirisi Ekle",
)
def create_review(
    review_in: ReviewCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    artwork = db.execute(
        select(Artwork).where(Artwork.id == review_in.artwork_id)
    ).scalar_one_or_none()
    if artwork is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Değerlendirilmek istenen sanat eseri bulunamadı.",
        )

    new_review = Review(
        user_id=current_user.id,
        artwork_id=review_in.artwork_id,
        rating=review_in.rating,
        comment=review_in.comment,
    )
    db.add(new_review)
    db.commit()
    db.refresh(new_review)
    return _to_review_response(new_review, user_name=current_user.full_name)