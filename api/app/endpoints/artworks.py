from typing import List, Optional
from fastapi import APIRouter, Depends, Query
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
                Artwork.artist.ilike(search_filter)
            )
        )

    # 4. Sorguyu çalıştır ve döndür
    artworks = db.execute(stmt).scalars().all()
    return artworks