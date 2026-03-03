from fastapi import APIRouter, Depends, HTTPException, UploadFile, File, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.models.user import User
from app.schemas.payment import VerifyReceiptRequest, PaymentResponse
from app.schemas.auth import MessageResponse
from app.services.payment_service import payment_service
from app.services.image_service import image_service
from app.utils.dependencies import get_current_user

router = APIRouter(tags=["Payments & Uploads"])


@router.post("/payments/verify-receipt", response_model=PaymentResponse)
async def verify_apple_receipt(
    request: VerifyReceiptRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Verify an Apple In-App Purchase receipt and record the payment."""
    payment = await payment_service.verify_apple_receipt(
        db=db,
        user_id=current_user.id,
        receipt_data=request.receipt_data,
        transaction_id=request.transaction_id,
        product_id=request.product_id,
    )

    if payment.status.value == "failed":
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Receipt verification failed",
        )

    return PaymentResponse.model_validate(payment)


@router.post("/upload/image")
async def upload_image(
    file: UploadFile = File(...),
    subdirectory: str = "listings",
    current_user: User = Depends(get_current_user),
):
    """
    Upload an image file. Supports JPEG, PNG, and WebP.
    Subdirectory options: listings, avatars, complaints.
    """
    allowed_subdirs = {"listings", "avatars", "complaints"}
    if subdirectory not in allowed_subdirs:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=f"Invalid subdirectory. Allowed: {', '.join(allowed_subdirs)}",
        )

    url = await image_service.upload_image(file, subdirectory)

    return {"url": url, "message": "Image uploaded successfully"}
