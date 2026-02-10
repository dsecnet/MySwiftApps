from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from typing import Optional, Dict, Any

from app.database import get_db
from app.models.user import User
from app.models.property import Property
from app.models.client import Client
from app.utils.security import get_current_user
from app.services.whatsapp_service import WhatsAppService

router = APIRouter(prefix="/whatsapp", tags=["WhatsApp"])


# Request/Response Models
class SendMessageRequest(BaseModel):
    phone: str
    message: str


class SendPropertyRequest(BaseModel):
    property_id: str
    client_phone: str
    custom_message: Optional[str] = None


class SendTemplateRequest(BaseModel):
    template_key: str
    phone: str
    data: Dict[str, Any]


@router.get("/templates")
def get_templates(current_user: User = Depends(get_current_user)):
    """
    WhatsApp mesaj template-lərinin siyahısı.

    **Response:**
    ```json
    {
        "templates": {
            "property_info": {
                "name": "Property Məlumatı",
                "description": "Property haqqında ətraflı məlumat"
            }
        }
    }
    ```
    """
    return {
        "templates": WhatsAppService.get_all_templates()
    }


@router.post("/send")
def send_message(
    request: SendMessageRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    WhatsApp mesajı göndər (generic).

    **Body:**
    ```json
    {
        "phone": "+994501234567",
        "message": "Salam! Test mesajı"
    }
    ```

    **Response:**
    ```json
    {
        "success": true,
        "whatsapp_link": "https://wa.me/994501234567?text=...",
        "message_id": "wamid.xxx"
    }
    ```
    """
    try:
        # Format phone
        formatted_phone = WhatsAppService.format_phone_number(request.phone)

        # Generate WhatsApp link
        link = WhatsAppService.generate_whatsapp_link(formatted_phone, request.message)

        # Mock API call (real-da Twilio və ya WhatsApp Business API istifadə olunacaq)
        result = WhatsAppService.send_message_via_api(formatted_phone, request.message)

        return {
            "success": True,
            "whatsapp_link": link,
            "message_id": result.get("message_id"),
            "phone": formatted_phone,
            "message": "WhatsApp link hazırdır. Link-ə klikləyərək mesaj göndərə bilərsiniz."
        }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/send/property")
def send_property_to_client(
    request: SendPropertyRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Property məlumatını müştəriyə WhatsApp ilə göndər.

    **Body:**
    ```json
    {
        "property_id": "uuid",
        "client_phone": "+994501234567",
        "custom_message": "Əlavə qeydlər (optional)"
    }
    ```
    """
    # Property tap
    property_obj = db.query(Property).filter(
        Property.id == request.property_id,
        Property.agent_id == current_user.id
    ).first()

    if not property_obj:
        raise HTTPException(status_code=404, detail="Property tapılmadı")

    # Property data hazırla
    property_data = {
        "title": property_obj.title,
        "address": property_obj.address or property_obj.district or "Bakı",
        "price": property_obj.price,
        "area_sqm": property_obj.area_sqm,
        "rooms": property_obj.rooms,
        "nearest_metro": property_obj.nearest_metro,
        "metro_distance_m": property_obj.metro_distance_m,
        "description": property_obj.description or "",
        "link": f"https://app.emlakcrm.com/property/{property_obj.id}"  # Real link
    }

    agent_data = {
        "name": current_user.name,
        "phone": current_user.phone or "+994501234567"
    }

    # Mesaj yarad
    message = WhatsAppService.generate_property_message(property_data, agent_data)

    # Custom message varsa əlavə et
    if request.custom_message:
        message += f"\n\n📝 *Qeyd:* {request.custom_message}"

    # WhatsApp link
    formatted_phone = WhatsAppService.format_phone_number(request.client_phone)
    link = WhatsAppService.generate_whatsapp_link(formatted_phone, message)

    # Mock API call
    result = WhatsAppService.send_message_via_api(formatted_phone, message)

    return {
        "success": True,
        "whatsapp_link": link,
        "message_id": result.get("message_id"),
        "phone": formatted_phone,
        "property_id": request.property_id,
        "message": "Property məlumatı hazırlanıb. WhatsApp-da paylaşa bilərsiniz.",
        "preview": message[:200] + "..."
    }


@router.post("/send/template")
def send_template_message(
    request: SendTemplateRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Template əsasında mesaj göndər.

    **Body:**
    ```json
    {
        "template_key": "client_greeting",
        "phone": "+994501234567",
        "data": {
            "client_name": "Vüsal",
            "agent_name": "Elçin",
            "property_type": "mənzil",
            "agent_phone": "+994501111111",
            "agency_name": "EmlakCRM"
        }
    }
    ```
    """
    try:
        # Generate message from template
        message = WhatsAppService.generate_message(request.template_key, request.data)

        # WhatsApp link
        formatted_phone = WhatsAppService.format_phone_number(request.phone)
        link = WhatsAppService.generate_whatsapp_link(formatted_phone, message)

        # Mock API call
        result = WhatsAppService.send_message_via_api(formatted_phone, message)

        return {
            "success": True,
            "whatsapp_link": link,
            "message_id": result.get("message_id"),
            "phone": formatted_phone,
            "template": request.template_key,
            "message": "Template mesajı hazırdır.",
            "preview": message[:200] + "..."
        }

    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))


@router.post("/send/client/{client_id}")
def send_message_to_client(
    client_id: str,
    message: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    """
    Müştəriyə mesaj göndər (client_id əsasında).

    **Body:**
    ```
    message=Salam! Test mesajı
    ```
    """
    # Client tap
    client = db.query(Client).filter(
        Client.id == client_id,
        Client.agent_id == current_user.id
    ).first()

    if not client:
        raise HTTPException(status_code=404, detail="Client tapılmadı")

    if not client.phone:
        raise HTTPException(status_code=400, detail="Client-in telefon nömrəsi yoxdur")

    # WhatsApp link
    formatted_phone = WhatsAppService.format_phone_number(client.phone)
    link = WhatsAppService.generate_whatsapp_link(formatted_phone, message)

    # Mock API call
    result = WhatsAppService.send_message_via_api(formatted_phone, message)

    return {
        "success": True,
        "whatsapp_link": link,
        "message_id": result.get("message_id"),
        "phone": formatted_phone,
        "client_id": client_id,
        "client_name": client.name,
        "message": "Mesaj hazırdır."
    }


@router.get("/format-phone")
def format_phone(phone: str, current_user: User = Depends(get_current_user)):
    """
    Telefon nömrəsini WhatsApp formatına çevir.

    **Nümunə:**
    ```
    GET /whatsapp/format-phone?phone=0501234567
    ```

    **Response:**
    ```json
    {
        "original": "0501234567",
        "formatted": "+994501234567"
    }
    ```
    """
    try:
        formatted = WhatsAppService.format_phone_number(phone)
        return {
            "original": phone,
            "formatted": formatted
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))
