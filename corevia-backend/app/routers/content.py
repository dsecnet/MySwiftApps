from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File, Form
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc
from pathlib import Path
import uuid
import aiofiles

from app.database import get_db
from app.models.user import User, UserType
from app.models.content import TrainerContent, ContentType
from app.schemas.content import ContentCreate, ContentResponse, ContentUpdate
from app.utils.security import get_current_user, get_premium_user

router = APIRouter(prefix="/api/v1/content", tags=["Content"])

UPLOAD_DIR = Path(__file__).parent.parent.parent / "uploads" / "content"
UPLOAD_DIR.mkdir(parents=True, exist_ok=True)


@router.post("/", response_model=ContentResponse)
async def create_content(
    content_data: ContentCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Trainer yeni content yaratsin."""
    if current_user.user_type != UserType.trainer:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Yalniz trainer content yarada biler",
        )

    content = TrainerContent(
        trainer_id=current_user.id,
        title=content_data.title,
        body=content_data.body,
        content_type=content_data.content_type,
        is_premium_only=content_data.is_premium_only,
    )
    db.add(content)
    await db.flush()

    return ContentResponse(
        id=content.id,
        trainer_id=content.trainer_id,
        trainer_name=current_user.name,
        trainer_profile_image=current_user.profile_image_url,
        title=content.title,
        body=content.body,
        content_type=content.content_type,
        image_url=content.image_url,
        is_premium_only=content.is_premium_only,
        created_at=content.created_at,
    )


@router.post("/{content_id}/image", response_model=ContentResponse)
async def upload_content_image(
    content_id: str,
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Content-e sekil yukle."""
    if current_user.user_type != UserType.trainer:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Yalniz trainer content redakte ede biler",
        )

    result = await db.execute(
        select(TrainerContent).where(
            TrainerContent.id == content_id,
            TrainerContent.trainer_id == current_user.id,
        )
    )
    content = result.scalar_one_or_none()
    if not content:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Content tapilmadi")

    # Fayl validasiyasi
    ALLOWED_EXTENSIONS = {"jpg", "jpeg", "png", "gif", "webp"}
    ext = (file.filename.split(".")[-1] if file.filename else "jpg").lower()
    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(status_code=400, detail="Yalniz sekil fayllari yuklene biler (jpg, png, gif, webp)")

    # Max file size check
    MAX_FILE_SIZE = 10 * 1024 * 1024  # 10MB
    data = await file.read()
    if len(data) > MAX_FILE_SIZE:
        raise HTTPException(status_code=400, detail="Fayl olcusu 10MB-dan cox ola bilmez")

    # Fayli saxla
    filename = f"{uuid.uuid4()}.{ext}"
    filepath = UPLOAD_DIR / filename

    async with aiofiles.open(filepath, "wb") as f:
        await f.write(data)

    content.image_url = f"/uploads/content/{filename}"
    content.content_type = ContentType.image

    return ContentResponse(
        id=content.id,
        trainer_id=content.trainer_id,
        trainer_name=current_user.name,
        trainer_profile_image=current_user.profile_image_url,
        title=content.title,
        body=content.body,
        content_type=content.content_type,
        image_url=content.image_url,
        is_premium_only=content.is_premium_only,
        created_at=content.created_at,
    )


@router.get("/trainer/{trainer_id}", response_model=list[ContentResponse])
async def get_trainer_content(
    trainer_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Trainer-in content-lerini getir. Premium-only content yalniz subscribe olunduqda."""
    result = await db.execute(
        select(TrainerContent)
        .where(TrainerContent.trainer_id == trainer_id)
        .order_by(desc(TrainerContent.created_at))
    )
    contents = result.scalars().all()

    # Trainer movcud olmalidir
    trainer_result = await db.execute(select(User).where(User.id == trainer_id))
    trainer = trainer_result.scalar_one_or_none()
    if not trainer:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Trainer tapilmadi")

    is_subscribed = current_user.trainer_id == trainer_id or current_user.id == trainer_id

    response = []
    for c in contents:
        if c.is_premium_only and not is_subscribed and not current_user.is_premium:
            continue
        response.append(
            ContentResponse(
                id=c.id,
                trainer_id=c.trainer_id,
                trainer_name=trainer.name,
                trainer_profile_image=trainer.profile_image_url,
                title=c.title,
                body=c.body,
                content_type=c.content_type,
                image_url=c.image_url,
                is_premium_only=c.is_premium_only,
                created_at=c.created_at,
            )
        )

    return response


@router.get("/my", response_model=list[ContentResponse])
async def get_my_content(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Trainer oz content-lerini gorur."""
    if current_user.user_type != UserType.trainer:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Yalniz trainer oz content-lerini gore biler",
        )

    result = await db.execute(
        select(TrainerContent)
        .where(TrainerContent.trainer_id == current_user.id)
        .order_by(desc(TrainerContent.created_at))
    )
    contents = result.scalars().all()

    return [
        ContentResponse(
            id=c.id,
            trainer_id=c.trainer_id,
            trainer_name=current_user.name,
            trainer_profile_image=current_user.profile_image_url,
            title=c.title,
            body=c.body,
            content_type=c.content_type,
            image_url=c.image_url,
            is_premium_only=c.is_premium_only,
            created_at=c.created_at,
        )
        for c in contents
    ]


@router.put("/{content_id}", response_model=ContentResponse)
async def update_content(
    content_id: str,
    update_data: ContentUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Trainer oz content-ini yenilesin."""
    if current_user.user_type != UserType.trainer:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Yalniz trainer")

    result = await db.execute(
        select(TrainerContent).where(
            TrainerContent.id == content_id,
            TrainerContent.trainer_id == current_user.id,
        )
    )
    content = result.scalar_one_or_none()
    if not content:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Content tapilmadi")

    data = update_data.model_dump(exclude_unset=True)
    for field, value in data.items():
        setattr(content, field, value)

    return ContentResponse(
        id=content.id,
        trainer_id=content.trainer_id,
        trainer_name=current_user.name,
        trainer_profile_image=current_user.profile_image_url,
        title=content.title,
        body=content.body,
        content_type=content.content_type,
        image_url=content.image_url,
        is_premium_only=content.is_premium_only,
        created_at=content.created_at,
    )


@router.delete("/{content_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_content(
    content_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Trainer oz content-ini silsin."""
    if current_user.user_type != UserType.trainer:
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Yalniz trainer")

    result = await db.execute(
        select(TrainerContent).where(
            TrainerContent.id == content_id,
            TrainerContent.trainer_id == current_user.id,
        )
    )
    content = result.scalar_one_or_none()
    if not content:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Content tapilmadi")

    await db.delete(content)
