from datetime import datetime
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, or_, and_, func, desc

from app.database import get_db
from app.models.user import User
from app.models.chat import ChatMessage, DailyMessageCount
from app.schemas.chat import ChatMessageCreate, ChatMessageResponse, ChatConversation, MessageLimitResponse
from app.utils.security import get_current_user, get_premium_user, get_premium_or_trainer

router = APIRouter(prefix="/api/v1/chat", tags=["Chat"])

DAILY_MESSAGE_LIMIT = 10


@router.post("/send", response_model=ChatMessageResponse)
async def send_message(
    msg: ChatMessageCreate,
    current_user: User = Depends(get_premium_or_trainer),
    db: AsyncSession = Depends(get_db),
):
    """Mesaj gonder (Premium only, gunluk limit 10)."""
    # Receiver movcud olmalidir
    result = await db.execute(select(User).where(User.id == msg.receiver_id))
    receiver = result.scalar_one_or_none()
    if not receiver:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Istifadeci tapilmadi")

    # Ozune mesaj gondermesin
    if current_user.id == msg.receiver_id:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Ozunuze mesaj gondere bilmezsiniz")

    # Trainer-student elaqesi olmalidir
    is_trainer_student = (
        (current_user.trainer_id == msg.receiver_id) or
        (receiver.trainer_id == current_user.id)
    )
    if not is_trainer_student:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Yalniz trainer-telebe arasinda mesaj gondermek olar",
        )

    # Gunluk limit yoxla
    today = datetime.utcnow().strftime("%Y-%m-%d")
    count_result = await db.execute(
        select(DailyMessageCount).where(
            DailyMessageCount.user_id == current_user.id,
            DailyMessageCount.date == today,
        )
    )
    daily_count = count_result.scalar_one_or_none()

    if daily_count and daily_count.count >= DAILY_MESSAGE_LIMIT:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail=f"Gunluk mesaj limitine catdiniz ({DAILY_MESSAGE_LIMIT}/gun)",
        )

    # Mesaj yarat
    chat_msg = ChatMessage(
        sender_id=current_user.id,
        receiver_id=msg.receiver_id,
        message=msg.message,
    )
    db.add(chat_msg)

    # Gunluk saygaci artir
    if daily_count:
        daily_count.count += 1
    else:
        db.add(DailyMessageCount(user_id=current_user.id, date=today, count=1))

    await db.flush()

    return ChatMessageResponse(
        id=chat_msg.id,
        sender_id=chat_msg.sender_id,
        receiver_id=chat_msg.receiver_id,
        sender_name=current_user.name,
        sender_profile_image=current_user.profile_image_url,
        message=chat_msg.message,
        is_read=chat_msg.is_read,
        created_at=chat_msg.created_at,
    )


@router.get("/history/{user_id}", response_model=list[ChatMessageResponse])
async def get_chat_history(
    user_id: str,
    current_user: User = Depends(get_premium_or_trainer),
    db: AsyncSession = Depends(get_db),
):
    """Iki istifadeci arasinda mesaj tarixcesi."""
    result = await db.execute(
        select(ChatMessage)
        .where(
            or_(
                and_(ChatMessage.sender_id == current_user.id, ChatMessage.receiver_id == user_id),
                and_(ChatMessage.sender_id == user_id, ChatMessage.receiver_id == current_user.id),
            )
        )
        .order_by(ChatMessage.created_at.asc())
    )
    messages = result.scalars().all()

    # Oxunmamis mesajlari oxunmus isaretle
    for msg in messages:
        if msg.receiver_id == current_user.id and not msg.is_read:
            msg.is_read = True

    response = []
    for msg in messages:
        sender_result = await db.execute(select(User).where(User.id == msg.sender_id))
        sender = sender_result.scalar_one_or_none()
        response.append(
            ChatMessageResponse(
                id=msg.id,
                sender_id=msg.sender_id,
                receiver_id=msg.receiver_id,
                sender_name=sender.name if sender else "Unknown",
                sender_profile_image=sender.profile_image_url if sender else None,
                message=msg.message,
                is_read=msg.is_read,
                created_at=msg.created_at,
            )
        )

    return response


@router.get("/conversations", response_model=list[ChatConversation])
async def get_conversations(
    current_user: User = Depends(get_premium_or_trainer),
    db: AsyncSession = Depends(get_db),
):
    """Istifadecinin butun sobet listi."""
    result = await db.execute(
        select(ChatMessage)
        .where(
            or_(
                ChatMessage.sender_id == current_user.id,
                ChatMessage.receiver_id == current_user.id,
            )
        )
        .order_by(desc(ChatMessage.created_at))
    )
    messages = result.scalars().all()

    conversations = {}
    for msg in messages:
        other_id = msg.receiver_id if msg.sender_id == current_user.id else msg.sender_id
        if other_id not in conversations:
            conversations[other_id] = {
                "last_message": msg.message,
                "last_message_time": msg.created_at,
                "unread_count": 0,
            }
        if msg.receiver_id == current_user.id and not msg.is_read:
            conversations[other_id]["unread_count"] += 1

    response = []
    for user_id, conv in conversations.items():
        user_result = await db.execute(select(User).where(User.id == user_id))
        user = user_result.scalar_one_or_none()
        if user:
            response.append(
                ChatConversation(
                    user_id=user.id,
                    user_name=user.name,
                    user_profile_image=user.profile_image_url,
                    last_message=conv["last_message"],
                    last_message_time=conv["last_message_time"],
                    unread_count=conv["unread_count"],
                )
            )

    return response


@router.get("/limit", response_model=MessageLimitResponse)
async def get_message_limit(
    current_user: User = Depends(get_premium_or_trainer),
    db: AsyncSession = Depends(get_db),
):
    """Gunluk mesaj limitini yoxla."""
    today = datetime.utcnow().strftime("%Y-%m-%d")
    result = await db.execute(
        select(DailyMessageCount).where(
            DailyMessageCount.user_id == current_user.id,
            DailyMessageCount.date == today,
        )
    )
    daily_count = result.scalar_one_or_none()
    used = daily_count.count if daily_count else 0

    return MessageLimitResponse(
        daily_limit=DAILY_MESSAGE_LIMIT,
        used_today=used,
        remaining=max(0, DAILY_MESSAGE_LIMIT - used),
    )
