from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session
from sqlalchemy import select, or_

from app.core.database import get_db
from app.models.artwork import Artwork
from app.schemas.artwork import ArtworkResponse

router = APIRouter(prefix="/artworks", tags=["Artworks"])


@router.get("/", response_model=List[ArtworkResponse])
def get_artworks(
    category_id: Optional[int] = Query(None, description="Sanat akımı kategori ID"),
    q: Optional[str] = Query(None, description="Başlık veya sanatçı arama sorgusu"),
    db: Session = Depends(get_db),
):
    stmt = select(Artwork)

    if category_id is not None:
        stmt = stmt.where(Artwork.category_id == category_id)

    if q:
        search_filter = f"%{q.strip()}%"
        stmt = stmt.where(
            or_(
                # not case-sensitive search
                Artwork.title.ilike(search_filter),
                Artwork.artist.ilike(search_filter),
            )
        )

    artworks = db.execute(stmt).scalars().all()
    return artworks


@router.get("/{artwork_id}", response_model=ArtworkResponse, summary="Tekil Eser Detayı")
def get_artwork_detail(artwork_id: int, db: Session = Depends(get_db)):
    stmt = select(Artwork).where(Artwork.id == artwork_id)
    artwork = db.execute(stmt).scalar_one_or_none()
    if artwork is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Sanat eseri bulunamadı.",
        )
    return artwork