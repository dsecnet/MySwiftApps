"""
WhatsApp Business Integration Service

Bu modul WhatsApp Business API ilə inteqrasiya üçündür.
Real production-da Twilio WhatsApp API və ya WhatsApp Business API istifadə olunmalıdır.

Hazırda: Template-based message system (mock implementation)
"""

from typing import Optional, Dict, Any
import re


class WhatsAppService:
    """WhatsApp mesaj göndərmə servisi"""

    # WhatsApp Business message templates
    TEMPLATES = {
        "property_info": {
            "name": "Property Məlumatı",
            "description": "Property haqqında ətraflı məlumat",
            "template": """
🏢 *{property_title}*

📍 *Ünvan:* {address}
💰 *Qiymət:* {price} ₼
📏 *Sahə:* {area} m²
🛏️ *Otaq:* {rooms}
{metro_info}

{description}

🔗 Ətraflı: {link}

_{agent_name}_
_{agent_phone}_
"""
        },

        "client_greeting": {
            "name": "Müştəri Salamlama",
            "description": "Yeni müştəri üçün salamlama mesajı",
            "template": """
Salam *{client_name}*! 👋

Mən *{agent_name}*, əmlak məsləhətçisiyəm.

Sizin *{property_type}* axtarışınızda köməklik etməkdən məmnun olaram.

📱 Əlaqə: {agent_phone}
🏢 Agentlik: {agency_name}

Necə kömək edə bilərəm? 😊
"""
        },

        "appointment_confirmation": {
            "name": "Görüş Təsdiqi",
            "description": "Property baxışı üçün görüş təsdiqi",
            "template": """
✅ *Görüş Təsdiqləndi*

📅 *Tarix:* {date}
⏰ *Saat:* {time}
📍 *Ünvan:* {address}

🏢 *Property:* {property_title}

Görüşmək üçün səbirsizlənirəm!

_{agent_name}_
_{agent_phone}_
"""
        },

        "property_shortlist": {
            "name": "Property Siyahısı",
            "description": "Müştəri üçün seçilmiş property-lər",
            "template": """
Sizin üçün seçdiyim property-lər: 🏠

{properties_list}

Hansını baxmaq istərdiniz?

Təklif edirəm ilk olaraq *{recommended_property}* baxaq.

_{agent_name}_
_{agent_phone}_
"""
        },

        "deal_offer": {
            "name": "Təklif Göndərmə",
            "description": "Alıcıya və ya satıcıya təklif",
            "template": """
📝 *Yeni Təklif*

🏢 *Property:* {property_title}
💰 *Təklif Qiyməti:* {offer_price} ₼
📊 *Status:* {status}

{additional_notes}

Cavabınızı gözləyirəm.

_{agent_name}_
_{agent_phone}_
"""
        },

        "deal_closed": {
            "name": "Deal Bağlandı",
            "description": "Uğurlu sövdələşmə təbriki",
            "template": """
🎉 *Təbriklər!*

Sövdələşmə uğurla tamamlandı! 🏡

🏢 *Property:* {property_title}
💰 *Son Qiymət:* {final_price} ₼

Bizimlə işləməyinizə görə təşəkkür edirik!

Gələcəkdə yenə əməkdaşlıq etsək, xoşbəxt olarıq.

_{agent_name}_
_{agent_phone}_
_{agency_name}_
"""
        },

        "follow_up": {
            "name": "Follow-up Mesajı",
            "description": "Müştəri ilə təkrar əlaqə",
            "template": """
Salam *{client_name}*! 👋

{days_ago} gün əvvəl danışmışdıq.

Əmlak axtarışınızda nə vəziyyətdə?

Yeni gələn maraqlı variant var:
🏢 {new_property}
💰 {price} ₼

Baxmaq istərdiniz?

_{agent_name}_
_{agent_phone}_
"""
        },

        "price_update": {
            "name": "Qiymət Dəyişikliyi",
            "description": "Property qiymətində dəyişiklik",
            "template": """
🔔 *Qiymət Dəyişikliyi!*

Sizin bəyəndiyiniz property-də qiymət dəyişdi:

🏢 *{property_title}*
~~{old_price} ₼~~
💰 *{new_price} ₼* {change_type}

{discount_percent}

Tələsməyin! Bu fürsəti qaçırmayın! ⏰

_{agent_name}_
_{agent_phone}_
"""
        },

        "property_status_change": {
            "name": "Status Dəyişikliyi",
            "description": "Property statusunda dəyişiklik (satıldı, rezerv, etc.)",
            "template": """
ℹ️ *Status Dəyişikliyi*

*{property_title}*
📍 {address}

Status: *{old_status}* → *{new_status}*

{message}

_{agent_name}_
"""
        },

        "viewing_reminder": {
            "name": "Baxış Xatırlatması",
            "description": "Property baxışı xatırlatması",
            "template": """
⏰ *Xatırlatma*

Sabah property baxışınız var!

📅 *{date}*
⏰ *{time}*
📍 *{address}*

🏢 {property_title}

Görüşənədək!

_{agent_name}_
_{agent_phone}_
"""
        }
    }

    @staticmethod
    def format_phone_number(phone: str) -> str:
        """
        Telefon nömrəsini WhatsApp formatına çevir.
        Məs: +994501234567
        """
        # Remove all non-digit characters
        digits = re.sub(r'\D', '', phone)

        # Add Azerbaijan country code if not present
        if not digits.startswith('994'):
            if digits.startswith('0'):
                digits = '994' + digits[1:]
            else:
                digits = '994' + digits

        return '+' + digits

    @staticmethod
    def generate_message(template_key: str, data: Dict[str, Any]) -> str:
        """
        Template əsasında mesaj yaradır.

        Args:
            template_key: Template açarı (property_info, client_greeting, etc.)
            data: Template-də istifadə ediləcək məlumatlar

        Returns:
            Formatlanmış WhatsApp mesajı
        """
        if template_key not in WhatsAppService.TEMPLATES:
            raise ValueError(f"Template tapılmadı: {template_key}")

        template = WhatsAppService.TEMPLATES[template_key]["template"]

        try:
            # Format template with provided data
            message = template.format(**data)
            return message.strip()
        except KeyError as e:
            raise ValueError(f"Template-də lazım olan field yoxdur: {e}")

    @staticmethod
    def generate_property_message(property_data: Dict[str, Any], agent_data: Dict[str, Any]) -> str:
        """Property məlumatı mesajı"""
        data = {
            "property_title": property_data.get("title", "Property"),
            "address": property_data.get("address", property_data.get("district", "Bakı")),
            "price": f"{property_data.get('price', 0):,.0f}",
            "area": property_data.get("area_sqm", "N/A"),
            "rooms": property_data.get("rooms", "N/A"),
            "metro_info": f"🚇 *Metro:* {property_data['nearest_metro']} ({property_data['metro_distance_m']}m)" if property_data.get("nearest_metro") else "",
            "description": property_data.get("description", "")[:200],
            "link": property_data.get("link", ""),
            "agent_name": agent_data.get("name", "Agent"),
            "agent_phone": agent_data.get("phone", "")
        }

        return WhatsAppService.generate_message("property_info", data)

    @staticmethod
    def generate_whatsapp_link(phone: str, message: str) -> str:
        """
        WhatsApp mesaj linki yaradır (web.whatsapp.com və ya wa.me).

        Args:
            phone: Telefon nömrəsi
            message: Göndəriləcək mesaj

        Returns:
            WhatsApp link (wa.me format)
        """
        formatted_phone = WhatsAppService.format_phone_number(phone)

        # URL encode message
        import urllib.parse
        encoded_message = urllib.parse.quote(message)

        # wa.me link (works on both mobile and web)
        return f"https://wa.me/{formatted_phone.replace('+', '')}?text={encoded_message}"

    @staticmethod
    def send_message_via_api(
        phone: str,
        message: str,
        api_key: Optional[str] = None
    ) -> Dict[str, Any]:
        """
        WhatsApp Business API vasitəsilə mesaj göndərir.

        Bu mock implementation-dır. Real production-da:
        - Twilio WhatsApp API
        - WhatsApp Business API (Official)
        - 360Dialog
        - Vonage WhatsApp Business API

        Args:
            phone: Qəbul edən telefon
            message: Mesaj mətni
            api_key: API key (əgər varsa)

        Returns:
            Response {success, message_id, error}
        """

        # Mock implementation
        formatted_phone = WhatsAppService.format_phone_number(phone)

        # Simulated API response
        return {
            "success": True,
            "message_id": f"wamid.mock_{formatted_phone}",
            "phone": formatted_phone,
            "status": "sent",
            "message": "Message queued for delivery (MOCK)",
            "whatsapp_link": WhatsAppService.generate_whatsapp_link(phone, message)
        }

    @staticmethod
    def get_all_templates() -> Dict[str, Dict[str, str]]:
        """Bütün template-lərin siyahısı"""
        return {
            key: {
                "name": value["name"],
                "description": value["description"]
            }
            for key, value in WhatsAppService.TEMPLATES.items()
        }


# Example usage
if __name__ == "__main__":
    # Property message nümunəsi
    property_data = {
        "title": "3 otaqlı yeni təmirli mənzil",
        "address": "Nəsimi rayonu, 28 May metrosu yaxınlığı",
        "price": 150000,
        "area_sqm": 85,
        "rooms": 3,
        "nearest_metro": "28 May",
        "metro_distance_m": 350,
        "description": "Yeni təmirli, mebelli, kondisionerli...",
        "link": "https://example.com/property/123"
    }

    agent_data = {
        "name": "Vüsal Dadaşov",
        "phone": "+994501234567"
    }

    message = WhatsAppService.generate_property_message(property_data, agent_data)
    print(message)
    print("\n" + "="*50 + "\n")

    link = WhatsAppService.generate_whatsapp_link("+994501234567", message)
    print(f"WhatsApp Link: {link}")
