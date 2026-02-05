import json
import logging
from pathlib import Path
from app.config import get_settings

settings = get_settings()
logger = logging.getLogger(__name__)

# Firebase Admin SDK initialization
_firebase_app = None


def _init_firebase():
    """Firebase Admin SDK-ni initialize et (bir defe)"""
    global _firebase_app
    if _firebase_app is not None:
        return _firebase_app

    try:
        import firebase_admin
        from firebase_admin import credentials

        cred_path = Path(settings.firebase_credentials_path)
        if not cred_path.exists():
            logger.warning(f"Firebase credentials tapilmadi: {cred_path}. Push notification gondermek mumkun olmayacaq.")
            return None

        cred = credentials.Certificate(str(cred_path))
        _firebase_app = firebase_admin.initialize_app(cred)
        logger.info("Firebase Admin SDK ugurla initialize olundu")
        return _firebase_app
    except Exception as e:
        logger.error(f"Firebase initialization xetasi: {e}")
        return None


async def send_push_notification(
    fcm_token: str,
    title: str,
    body: str,
    data: dict | None = None,
) -> bool:
    """Tek bir cihaza push notification gonder"""
    app = _init_firebase()
    if not app:
        logger.info(f"[MOCK] Push notification: {title} - {body}")
        return False

    try:
        from firebase_admin import messaging

        message = messaging.Message(
            notification=messaging.Notification(title=title, body=body),
            data={k: str(v) for k, v in (data or {}).items()},
            token=fcm_token,
            apns=messaging.APNSConfig(
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(
                        badge=1,
                        sound="default",
                    ),
                ),
            ),
        )

        response = messaging.send(message)
        logger.info(f"Push notification gonderildi: {response}")
        return True
    except Exception as e:
        logger.error(f"Push notification xetasi: {e}")
        return False


async def send_push_to_multiple(
    fcm_tokens: list[str],
    title: str,
    body: str,
    data: dict | None = None,
) -> int:
    """Bir nece cihaza push notification gonder. Ugurlu sayi qaytarir."""
    app = _init_firebase()
    if not app:
        logger.info(f"[MOCK] Bulk push: {title} - {body} to {len(fcm_tokens)} devices")
        return 0

    try:
        from firebase_admin import messaging

        message = messaging.MulticastMessage(
            notification=messaging.Notification(title=title, body=body),
            data={k: str(v) for k, v in (data or {}).items()},
            tokens=fcm_tokens,
            apns=messaging.APNSConfig(
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(
                        badge=1,
                        sound="default",
                    ),
                ),
            ),
        )

        response = messaging.send_each_for_multicast(message)
        logger.info(f"Bulk push: {response.success_count}/{len(fcm_tokens)} ugurlu")
        return response.success_count
    except Exception as e:
        logger.error(f"Bulk push xetasi: {e}")
        return 0


# Notification type-larina gore template-ler (3 dil: az, en, ru)
NOTIFICATION_TEMPLATES = {
    "workout_reminder": {
        "az": {"title": "Məşq vaxtıdır! 💪", "body": "Bugün hələ məşq etməmisən. Sağlamlıq üçün hərəkətə keç!"},
        "en": {"title": "Time to work out! 💪", "body": "You haven't exercised today. Get moving for your health!"},
        "ru": {"title": "Время тренировки! 💪", "body": "Вы ещё не тренировались сегодня. Вперёд к здоровью!"},
    },
    "meal_reminder": {
        "az": {"title": "Yemək vaxtını unutma! 🍎", "body": "Qida qeydini yaz ki, günlük kalori hədəfinə çatasan."},
        "en": {"title": "Don't forget your meal! 🍎", "body": "Log your food to reach your daily calorie goal."},
        "ru": {"title": "Не забудь про еду! 🍎", "body": "Запиши приём пищи, чтобы достичь цели по калориям."},
    },
    "weekly_report": {
        "az": {"title": "Həftəlik hesabat hazırdır 📊", "body": "Bu həftənin nəticələrini gör və gələcək həftə üçün plan qur."},
        "en": {"title": "Weekly report is ready 📊", "body": "Check this week's results and plan for next week."},
        "ru": {"title": "Еженедельный отчёт готов 📊", "body": "Посмотрите результаты этой недели и спланируйте следующую."},
    },
    "trainer_message": {
        "az": {"title": "Trenerinizdən mesaj 📩", "body": "{message}"},
        "en": {"title": "Message from your trainer 📩", "body": "{message}"},
        "ru": {"title": "Сообщение от тренера 📩", "body": "{message}"},
    },
    "premium_promo": {
        "az": {"title": "Premium-a keçin! ⭐", "body": "AI tövsiyələr, unlimited məşqlər və daha çox. İndi 20% endirimlə!"},
        "en": {"title": "Go Premium! ⭐", "body": "AI recommendations, unlimited workouts and more. Now 20% off!"},
        "ru": {"title": "Переходите на Премиум! ⭐", "body": "AI рекомендации, безлимит тренировок и многое другое. Скидка 20%!"},
    },
    "route_assigned": {
        "az": {"title": "Yeni marşrut təyin olundu 🗺️", "body": "Treneriniz sizə yeni marşrut təyin etdi. Baxmaq üçün toxunun."},
        "en": {"title": "New route assigned 🗺️", "body": "Your trainer assigned a new route. Tap to view."},
        "ru": {"title": "Назначен новый маршрут 🗺️", "body": "Ваш тренер назначил новый маршрут. Нажмите для просмотра."},
    },
    "new_review": {
        "az": {"title": "Yeni rəy aldınız ⭐", "body": "Bir tələbəniz sizə rəy yazdı."},
        "en": {"title": "New review received ⭐", "body": "A student has written a review for you."},
        "ru": {"title": "Новый отзыв ⭐", "body": "Ученик оставил вам отзыв."},
    },
    "new_message": {
        "az": {"title": "Yeni mesaj 💬", "body": "{sender}: {message}"},
        "en": {"title": "New message 💬", "body": "{sender}: {message}"},
        "ru": {"title": "Новое сообщение 💬", "body": "{sender}: {message}"},
    },
    "new_subscriber": {
        "az": {"title": "Yeni abunəçi! 🎉", "body": "{student_name} sizə abunə oldu."},
        "en": {"title": "New subscriber! 🎉", "body": "{student_name} subscribed to you."},
        "ru": {"title": "Новый подписчик! 🎉", "body": "{student_name} подписался на вас."},
    },
}

DEFAULT_LANG = "az"


def get_notification_template(notification_type: str, lang: str = "az", **kwargs) -> tuple[str, str]:
    """Notification template-ini dil secimi ile al (az, en, ru)."""
    templates = NOTIFICATION_TEMPLATES.get(notification_type)
    if not templates:
        fallback = {"az": "Yeni bildiriş", "en": "New notification", "ru": "Новое уведомление"}
        return "CoreVia", fallback.get(lang, fallback["en"])

    template = templates.get(lang, templates.get(DEFAULT_LANG, templates.get("en", {})))
    title = template.get("title", "CoreVia")
    body = template.get("body", "")
    if kwargs:
        try:
            body = body.format(**kwargs)
        except KeyError:
            pass
    return title, body
