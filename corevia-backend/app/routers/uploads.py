from fastapi import APIRouter, Depends, HTTPException, status, UploadFile, File
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select

from app.database import get_db
from app.models.user import User, UserType
from app.models.food_entry import FoodEntry
from app.schemas.user import UserResponse
from app.schemas.food import FoodEntryResponse
from app.utils.security import get_current_user
from app.services.file_service import save_upload, delete_upload

router = APIRouter(prefix="/api/v1/uploads", tags=["Uploads"])


@router.post("/profile-image", response_model=UserResponse)
async def upload_profile_image(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    # Kohne sekili sil
    if current_user.profile_image_url:
        await delete_upload(current_user.profile_image_url)

    # Yeni sekili saxla
    file_path = await save_upload(file, "profiles")
    current_user.profile_image_url = file_path
    return current_user


@router.post("/food-image/{entry_id}", response_model=FoodEntryResponse)
async def upload_food_image(
    entry_id: str,
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(FoodEntry).where(FoodEntry.id == entry_id, FoodEntry.user_id == current_user.id)
    )
    entry = result.scalar_one_or_none()
    if not entry:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Qida qeydi tapilmadi")

    # Kohne sekili sil
    if entry.image_url:
        await delete_upload(entry.image_url)

    # Yeni sekili saxla
    file_path = await save_upload(file, "food")
    entry.image_url = file_path
    entry.has_image = True
    return entry


@router.post("/certificate")
async def upload_certificate(
    file: UploadFile = File(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if current_user.user_type != UserType.trainer:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Yalniz trainer sertifikat yukleye biler",
        )

    # Kohne sertifikati sil
    if current_user.certificate_image_url:
        await delete_upload(current_user.certificate_image_url)

    # Yeni sertifikati saxla
    file_path = await save_upload(file, "certificates")
    current_user.certificate_image_url = file_path

    return {
        "message": "Sertifikat yuklendi. Verifikasiya gozlenilir.",
        "certificate_url": file_path,
        "verification_status": current_user.verification_status.value,
    }


@router.delete("/profile-image")
async def delete_profile_image(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if not current_user.profile_image_url:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Profil sekili yoxdur")

    await delete_upload(current_user.profile_image_url)
    current_user.profile_image_url = None
    return {"message": "Profil sekili silindi"}
