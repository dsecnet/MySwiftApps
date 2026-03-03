import uuid
import logging
from typing import Any

from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.models.notification import Notification, NotificationType

logger = logging.getLogger(__name__)


class NotificationService:
    """Service for creating and managing notifications."""

    @staticmethod
    async def create_notification(
        db: AsyncSession,
        user_id: uuid.UUID,
        title: str,
        body: str,
        notification_type: NotificationType,
        data: dict[str, Any] | None = None,
    ) -> Notification:
        """Create a new notification for a user."""
        notification = Notification(
            user_id=user_id,
            title=title,
            body=body,
            type=notification_type,
            data=data,
        )
        db.add(notification)
        await db.flush()
        logger.info(
            f"Notification created: type={notification_type.value} "
            f"user={user_id}"
        )
        return notification

    @staticmethod
    async def notify_listing_approved(
        db: AsyncSession,
        user_id: uuid.UUID,
        listing_id: uuid.UUID,
        listing_title: str,
    ) -> Notification:
        """Notify user that their listing has been approved."""
        return await NotificationService.create_notification(
            db=db,
            user_id=user_id,
            title="Elan tesdiq edildi",
            body=f'Sizin "{listing_title}" elaniniz tesdiq edildi ve artiq aktiv veziyyetdedir.',
            notification_type=NotificationType.LISTING_APPROVED,
            data={"listing_id": str(listing_id)},
        )

    @staticmethod
    async def notify_new_review(
        db: AsyncSession,
        agent_user_id: uuid.UUID,
        reviewer_name: str,
        rating: int,
        agent_id: uuid.UUID,
    ) -> Notification:
        """Notify agent about a new review."""
        return await NotificationService.create_notification(
            db=db,
            user_id=agent_user_id,
            title="Yeni reydestay",
            body=f"{reviewer_name} size {rating} ulduz rey verdi.",
            notification_type=NotificationType.NEW_REVIEW,
            data={"agent_id": str(agent_id), "rating": rating},
        )

    @staticmethod
    async def notify_new_favorite(
        db: AsyncSession,
        listing_owner_id: uuid.UUID,
        listing_title: str,
        listing_id: uuid.UUID,
    ) -> Notification:
        """Notify listing owner that someone favorited their listing."""
        return await NotificationService.create_notification(
            db=db,
            user_id=listing_owner_id,
            title="Yeni secilmis",
            body=f'Kimsə sizin "{listing_title}" elaninizi seçilmişlərə əlavə etdi.',
            notification_type=NotificationType.NEW_FAVORITE,
            data={"listing_id": str(listing_id)},
        )

    @staticmethod
    async def notify_payment_success(
        db: AsyncSession,
        user_id: uuid.UUID,
        payment_type: str,
        amount: str,
    ) -> Notification:
        """Notify user about successful payment."""
        return await NotificationService.create_notification(
            db=db,
            user_id=user_id,
            title="Odenis ugurla tamamlandi",
            body=f"{payment_type} ucun {amount} odenis ugurla tamamlandi.",
            notification_type=NotificationType.PAYMENT_SUCCESS,
            data={"payment_type": payment_type, "amount": amount},
        )

    @staticmethod
    async def notify_boost_expired(
        db: AsyncSession,
        user_id: uuid.UUID,
        listing_title: str,
        listing_id: uuid.UUID,
    ) -> Notification:
        """Notify user that their listing boost has expired."""
        return await NotificationService.create_notification(
            db=db,
            user_id=user_id,
            title="Boost mudeti bitdi",
            body=f'"{listing_title}" elaninizin boost mudeti bitdi.',
            notification_type=NotificationType.BOOST_EXPIRED,
            data={"listing_id": str(listing_id)},
        )

    @staticmethod
    async def get_unread_count(
        db: AsyncSession,
        user_id: uuid.UUID,
    ) -> int:
        """Get the count of unread notifications for a user."""
        result = await db.execute(
            select(func.count(Notification.id)).where(
                Notification.user_id == user_id,
                Notification.is_read == False,
            )
        )
        return result.scalar() or 0


notification_service = NotificationService()
