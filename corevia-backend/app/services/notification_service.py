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


# Notification type-larina gore template-ler
NOTIFICATION_TEMPLATES = {
    "workout_reminder": {
        "title": "Mesq vaxtidir! 💪",
        "body": "Bugun hele mesq etmemisen. Saglamliq ucun herekete kec!",
    },
    "meal_reminder": {
        "title": "Yemek vaxtini unutma! 🍎",
        "body": "Qida qeydini yaz ki, gunluk kalori hedefinə catasan.",
    },
    "weekly_report": {
        "title": "Heftelik hesabat hazirdir 📊",
        "body": "Bu heftenin neticelerini gor ve gelecek hefte ucun plan qur.",
    },
    "trainer_message": {
        "title": "Trenerinizden mesaj 📩",
        "body": "{message}",
    },
    "premium_promo": {
        "title": "Premium-a kecin! ⭐",
        "body": "AI tovsiyeler, unlimited mesqler ve daha cox. Indi 20% endirimle!",
    },
    "route_assigned": {
        "title": "Yeni marsrut teyin olundu 🗺️",
        "body": "Treneriniz sizə yeni marsrut teyin etdi. Baximaq ucun toxunun.",
    },
}


def get_notification_template(notification_type: str, **kwargs) -> tuple[str, str]:
    """Notification template-ini al"""
    template = NOTIFICATION_TEMPLATES.get(notification_type, {
        "title": "CoreVia",
        "body": "Yeni bildiris",
    })
    title = template["title"]
    body = template["body"].format(**kwargs) if kwargs else template["body"]
    return title, body
