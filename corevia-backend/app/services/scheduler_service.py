import logging
from datetime import datetime, timedelta
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.cron import CronTrigger
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import async_session
from app.models.user import User
from app.models.settings import UserSettings
from app.models.workout import Workout
from app.models.food_entry import FoodEntry
from app.models.notification import DeviceToken, Notification
from app.services.notification_service import (
    send_push_notification,
    get_notification_template,
)

logger = logging.getLogger(__name__)

scheduler = AsyncIOScheduler()


async def _get_user_active_tokens(db: AsyncSession, user_id: str) -> list[str]:
    """User-in aktiv FCM token-lerini al"""
    result = await db.execute(
        select(DeviceToken.fcm_token).where(
            DeviceToken.user_id == user_id,
            DeviceToken.is_active == True,
        )
    )
    return [row[0] for row in result.all()]


async def _save_and_send(db: AsyncSession, user_id: str, notification_type: str, **kwargs):
    """Bildirisi DB-ye yaz ve push gonder"""
    title, body = get_notification_template(notification_type, **kwargs)

    # DB-ye yaz
    notification = Notification(
        user_id=user_id,
        title=title,
        body=body,
        notification_type=notification_type,
    )
    db.add(notification)

    # Push gonder
    tokens = await _get_user_active_tokens(db, user_id)
    sent = False
    for token in tokens:
        sent = await send_push_notification(token, title, body, {"type": notification_type})
        if sent:
            break
    notification.is_sent = sent


async def send_workout_reminders():
    """Mesq xatirlatmasi: Bugun mesq etmeyen user-lere gonder (her gun saat 18:00)"""
    logger.info("Workout reminder job basladi")

    async with async_session() as db:
        try:
            today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)

            # Settings-de workout_reminders=True olan user-leri tap
            settings_result = await db.execute(
                select(UserSettings).where(
                    UserSettings.notifications_enabled == True,
                    UserSettings.workout_reminders == True,
                )
            )
            settings_list = settings_result.scalars().all()

            for settings in settings_list:
                # Bugun mesq edib-etmediyini yoxla
                workout_result = await db.execute(
                    select(Workout.id).where(
                        Workout.user_id == settings.user_id,
                        Workout.date >= today_start,
                    ).limit(1)
                )
                has_workout = workout_result.scalar_one_or_none()

                if not has_workout:
                    await _save_and_send(db, settings.user_id, "workout_reminder")

            await db.commit()
            logger.info("Workout reminders gonderildi")
        except Exception as e:
            await db.rollback()
            logger.error(f"Workout reminder xetasi: {e}")


async def send_meal_reminders():
    """Yemek xatirlatmasi: Bugun yemek qeyd etmeyen user-lere (her gun saat 12:00 ve 19:00)"""
    logger.info("Meal reminder job basladi")

    async with async_session() as db:
        try:
            today_start = datetime.utcnow().replace(hour=0, minute=0, second=0, microsecond=0)

            settings_result = await db.execute(
                select(UserSettings).where(
                    UserSettings.notifications_enabled == True,
                    UserSettings.meal_reminders == True,
                )
            )
            settings_list = settings_result.scalars().all()

            for settings in settings_list:
                food_result = await db.execute(
                    select(FoodEntry.id).where(
                        FoodEntry.user_id == settings.user_id,
                        FoodEntry.date >= today_start,
                    ).limit(1)
                )
                has_food = food_result.scalar_one_or_none()

                if not has_food:
                    await _save_and_send(db, settings.user_id, "meal_reminder")

            await db.commit()
            logger.info("Meal reminders gonderildi")
        except Exception as e:
            await db.rollback()
            logger.error(f"Meal reminder xetasi: {e}")


async def send_weekly_reports():
    """Heftelik hesabat: weekly_reports=True olan user-lere (her bazar gunu saat 10:00)"""
    logger.info("Weekly report job basladi")

    async with async_session() as db:
        try:
            settings_result = await db.execute(
                select(UserSettings).where(
                    UserSettings.notifications_enabled == True,
                    UserSettings.weekly_reports == True,
                )
            )
            settings_list = settings_result.scalars().all()

            for settings in settings_list:
                await _save_and_send(db, settings.user_id, "weekly_report")

            await db.commit()
            logger.info("Weekly reports gonderildi")
        except Exception as e:
            await db.rollback()
            logger.error(f"Weekly report xetasi: {e}")


async def check_expired_subscriptions():
    """Bitmis abunelikleri yoxla ve premium-u sondur (her gun saat 00:30)"""
    logger.info("Subscription check job basladi")

    from app.models.subscription import Subscription

    async with async_session() as db:
        try:
            now = datetime.utcnow()
            result = await db.execute(
                select(Subscription).where(
                    Subscription.is_active == True,
                    Subscription.expires_at < now,
                )
            )
            expired_subs = result.scalars().all()

            for sub in expired_subs:
                sub.is_active = False
                # User-in premium-unu sondur
                user_result = await db.execute(
                    select(User).where(User.id == sub.user_id)
                )
                user = user_result.scalar_one_or_none()
                if user and user.is_premium:
                    user.is_premium = False
                    logger.info(f"Premium sonduruldu: {user.email}")

            await db.commit()
            logger.info(f"{len(expired_subs)} bitmis abunəlik deaktiv edildi")
        except Exception as e:
            await db.rollback()
            logger.error(f"Subscription check xetasi: {e}")


def init_scheduler():
    """Scheduler-i baslat ve job-lari elave et"""
    # Mesq xatirlatmasi - her gun saat 18:00 UTC (Baki: 22:00)
    scheduler.add_job(
        send_workout_reminders,
        CronTrigger(hour=18, minute=0),
        id="workout_reminders",
        replace_existing=True,
    )

    # Yemek xatirlatmasi - her gun saat 12:00 ve 19:00 UTC
    scheduler.add_job(
        send_meal_reminders,
        CronTrigger(hour=12, minute=0),
        id="meal_reminders_noon",
        replace_existing=True,
    )
    scheduler.add_job(
        send_meal_reminders,
        CronTrigger(hour=19, minute=0),
        id="meal_reminders_evening",
        replace_existing=True,
    )

    # Heftelik hesabat - her bazar gunu saat 10:00 UTC
    scheduler.add_job(
        send_weekly_reports,
        CronTrigger(day_of_week="sun", hour=10, minute=0),
        id="weekly_reports",
        replace_existing=True,
    )

    # Bitmis abunelikleri yoxla - her gun saat 00:30 UTC
    scheduler.add_job(
        check_expired_subscriptions,
        CronTrigger(hour=0, minute=30),
        id="check_subscriptions",
        replace_existing=True,
    )

    scheduler.start()
    logger.info("APScheduler basladildi - 5 job elave olundu")
