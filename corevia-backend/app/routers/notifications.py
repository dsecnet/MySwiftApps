from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, update

from app.database import get_db
from app.models.user import User
from app.models.notification import DeviceToken, Notification
from app.schemas.notification import (
    DeviceTokenCreate,
    NotificationResponse,
    NotificationSend,
    NotificationMarkRead,
)
from app.utils.security import get_current_user
from app.services.notification_service import (
    send_push_notification,
    get_notification_template,
)

router = APIRouter(prefix="/api/v1/notifications", tags=["Notifications"])


# === Device Token ===

@router.post("/device-token", status_code=status.HTTP_201_CREATED)
async def register_device_token(
    token_data: DeviceTokenCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """iOS app-in FCM token-ini qeyd et (login/startup zamani)"""
    result = await db.execute(
        select(DeviceToken).where(
            DeviceToken.user_id == current_user.id,
            DeviceToken.fcm_token == token_data.fcm_token,
        )
    )
    existing = result.scalar_one_or_none()

    if existing:
        existing.is_active = True
        existing.updated_at = datetime.utcnow()
        existing.device_name = token_data.device_name or existing.device_name
        return {"message": "Token yenilendi", "device_token_id": existing.id}

    device = DeviceToken(
        user_id=current_user.id,
        fcm_token=token_data.fcm_token,
        device_name=token_data.device_name,
        platform=token_data.platform,
    )
    db.add(device)
    await db.flush()
    return {"message": "Token qeyd olundu", "device_token_id": device.id}


@router.delete("/device-token")
async def unregister_device_token(
    fcm_token: str = Query(...),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Device token-i deaktiv et (logout zamani)"""
    result = await db.execute(
        select(DeviceToken).where(
            DeviceToken.user_id == current_user.id,
            DeviceToken.fcm_token == fcm_token,
        )
    )
    device = result.scalar_one_or_none()
    if device:
        device.is_active = False
    return {"message": "Token deaktiv olundu"}


# === Notifications ===

@router.get("/", response_model=list[NotificationResponse])
async def get_notifications(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
    unread_only: bool = False,
    limit: int = Query(default=50, le=100),
    offset: int = Query(default=0, ge=0),
):
    """Istifadecinin bildirislerini getir"""
    query = select(Notification).where(Notification.user_id == current_user.id)

    if unread_only:
        query = query.where(Notification.is_read == False)

    query = query.order_by(Notification.created_at.desc()).offset(offset).limit(limit)
    result = await db.execute(query)
    return result.scalars().all()


@router.get("/unread-count")
async def get_unread_count(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Oxunmamis bildiris sayini qaytar"""
    result = await db.execute(
        select(func.count(Notification.id)).where(
            Notification.user_id == current_user.id,
            Notification.is_read == False,
        )
    )
    count = result.scalar()
    return {"unread_count": count}


@router.post("/mark-read")
async def mark_notifications_read(
    data: NotificationMarkRead,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Bildirisleri oxunmus olaraq isaretle"""
    await db.execute(
        update(Notification)
        .where(
            Notification.id.in_(data.notification_ids),
            Notification.user_id == current_user.id,
        )
        .values(is_read=True)
    )
    return {"message": f"{len(data.notification_ids)} bildiris oxunmus olaraq isarelendi"}


@router.post("/mark-all-read")
async def mark_all_read(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Butun bildirisleri oxunmus et"""
    result = await db.execute(
        update(Notification)
        .where(
            Notification.user_id == current_user.id,
            Notification.is_read == False,
        )
        .values(is_read=True)
    )
    return {"message": "Butun bildirisler oxunmus olaraq isarelendi"}


@router.delete("/{notification_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_notification(
    notification_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Tek bildirisi sil"""
    result = await db.execute(
        select(Notification).where(
            Notification.id == notification_id,
            Notification.user_id == current_user.id,
        )
    )
    notification = result.scalar_one_or_none()
    if not notification:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Bildiris tapilmadi")
    await db.delete(notification)


# === Trainer -> Student mesaj gondermek ===

@router.post("/send", status_code=status.HTTP_201_CREATED)
async def send_notification_to_student(
    data: NotificationSend,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Trainer oz student-ine bildiris gondersin"""
    if current_user.user_type != "trainer":
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Yalniz trainer bildiris gondare biler",
        )

    student_result = await db.execute(
        select(User).where(User.id == data.student_id)
    )
    student = student_result.scalar_one_or_none()
    if not student:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Student tapilmadi")
    if student.trainer_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Bu student sizin student-iniz deyil",
        )

    notification = Notification(
        user_id=data.student_id,
        title=data.title,
        body=data.body,
        notification_type="trainer_message",
        is_sent=False,
    )
    db.add(notification)
    await db.flush()

    tokens_result = await db.execute(
        select(DeviceToken).where(
            DeviceToken.user_id == data.student_id,
            DeviceToken.is_active == True,
        )
    )
    tokens = tokens_result.scalars().all()

    sent = False
    for token in tokens:
        sent = await send_push_notification(
            fcm_token=token.fcm_token,
            title=data.title,
            body=data.body,
            data={"type": "trainer_message", "trainer_id": current_user.id},
        )
        if sent:
            break

    notification.is_sent = sent
    return {
        "message": "Bildiris gonderildi" if sent else "Bildiris saxlanildi (push gonderile bilmedi)",
        "notification_id": notification.id,
        "push_sent": sent,
    }
