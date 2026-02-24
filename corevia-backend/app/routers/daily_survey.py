"""
Daily Survey Router — Günlük vəziyyət sorğusu API

POST   /api/v1/survey/daily       — Günlük survey cavabla
GET    /api/v1/survey/daily/today  — Bugünkü survey statusu
GET    /api/v1/survey/daily/history — Son 30 günlük tarixçə
GET    /api/v1/survey/questions     — Sual siyahısı (lokalizə edilmiş)
"""

from datetime import datetime, date, timedelta
from typing import Optional, List

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc

from app.database import get_db
from app.models.user import User
from app.models.daily_survey import DailySurvey
from app.utils.security import get_current_user

router = APIRouter(prefix="/api/v1/survey", tags=["Daily Survey"])


# ── Schemas ──────────────────────────────────────────────

class DailySurveyRequest(BaseModel):
    energy_level: int = Field(..., ge=1, le=5, description="Enerji səviyyəsi (1-5)")
    sleep_hours: float = Field(..., ge=0, le=24, description="Yuxu saatı")
    sleep_quality: int = Field(..., ge=1, le=5, description="Yuxu keyfiyyəti (1-5)")
    stress_level: int = Field(..., ge=1, le=5, description="Stress səviyyəsi (1-5)")
    muscle_soreness: int = Field(..., ge=1, le=5, description="Əzələ ağrısı (1-5)")
    mood: int = Field(..., ge=1, le=5, description="Əhval (1-5)")
    water_glasses: int = Field(..., ge=0, le=30, description="Su stəkanları")
    notes: Optional[str] = Field(None, max_length=500, description="Əlavə qeydlər")


class DailySurveyResponse(BaseModel):
    id: str
    date: str
    energy_level: int
    sleep_hours: float
    sleep_quality: int
    stress_level: int
    muscle_soreness: int
    mood: int
    water_glasses: int
    notes: Optional[str]
    created_at: str

    class Config:
        from_attributes = True


class SurveyQuestion(BaseModel):
    key: str
    title: str
    description: str
    type: str  # "slider", "number"
    min_value: int
    max_value: int
    emoji_labels: Optional[List[str]] = None


class SurveyQuestionsResponse(BaseModel):
    questions: List[SurveyQuestion]
    already_completed: bool


# ── Endpoints ─────────────────────────────────────────────

@router.post("/daily", response_model=DailySurveyResponse)
async def submit_daily_survey(
    data: DailySurveyRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Günlük survey-i doldur. Gündə 1 dəfə icazə verilir."""
    today = date.today()

    # Bugün artıq doldurulub?
    existing = await db.execute(
        select(DailySurvey).where(
            DailySurvey.user_id == current_user.id,
            DailySurvey.date == today,
        )
    )
    existing_survey = existing.scalar_one_or_none()

    if existing_survey:
        # Update existing
        existing_survey.energy_level = data.energy_level
        existing_survey.sleep_hours = data.sleep_hours
        existing_survey.sleep_quality = data.sleep_quality
        existing_survey.stress_level = data.stress_level
        existing_survey.muscle_soreness = data.muscle_soreness
        existing_survey.mood = data.mood
        existing_survey.water_glasses = data.water_glasses
        existing_survey.notes = data.notes
        await db.commit()
        await db.refresh(existing_survey)
        survey = existing_survey
    else:
        # Create new
        survey = DailySurvey(
            user_id=current_user.id,
            date=today,
            energy_level=data.energy_level,
            sleep_hours=data.sleep_hours,
            sleep_quality=data.sleep_quality,
            stress_level=data.stress_level,
            muscle_soreness=data.muscle_soreness,
            mood=data.mood,
            water_glasses=data.water_glasses,
            notes=data.notes,
        )
        db.add(survey)
        await db.commit()
        await db.refresh(survey)

    return DailySurveyResponse(
        id=survey.id,
        date=str(survey.date),
        energy_level=survey.energy_level,
        sleep_hours=survey.sleep_hours,
        sleep_quality=survey.sleep_quality,
        stress_level=survey.stress_level,
        muscle_soreness=survey.muscle_soreness,
        mood=survey.mood,
        water_glasses=survey.water_glasses,
        notes=survey.notes,
        created_at=str(survey.created_at),
    )


@router.get("/daily/today")
async def get_today_survey(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Bugünkü survey statusu"""
    today = date.today()

    result = await db.execute(
        select(DailySurvey).where(
            DailySurvey.user_id == current_user.id,
            DailySurvey.date == today,
        )
    )
    survey = result.scalar_one_or_none()

    if not survey:
        return {"completed": False, "survey": None}

    return {
        "completed": True,
        "survey": DailySurveyResponse(
            id=survey.id,
            date=str(survey.date),
            energy_level=survey.energy_level,
            sleep_hours=survey.sleep_hours,
            sleep_quality=survey.sleep_quality,
            stress_level=survey.stress_level,
            muscle_soreness=survey.muscle_soreness,
            mood=survey.mood,
            water_glasses=survey.water_glasses,
            notes=survey.notes,
            created_at=str(survey.created_at),
        ),
    }


@router.get("/daily/history")
async def get_survey_history(
    days: int = 30,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Son N günlük survey tarixçəsi"""
    since = date.today() - timedelta(days=days)

    result = await db.execute(
        select(DailySurvey)
        .where(
            DailySurvey.user_id == current_user.id,
            DailySurvey.date >= since,
        )
        .order_by(desc(DailySurvey.date))
    )
    surveys = result.scalars().all()

    return {
        "count": len(surveys),
        "surveys": [
            DailySurveyResponse(
                id=s.id,
                date=str(s.date),
                energy_level=s.energy_level,
                sleep_hours=s.sleep_hours,
                sleep_quality=s.sleep_quality,
                stress_level=s.stress_level,
                muscle_soreness=s.muscle_soreness,
                mood=s.mood,
                water_glasses=s.water_glasses,
                notes=s.notes,
                created_at=str(s.created_at),
            )
            for s in surveys
        ],
    }


@router.get("/questions", response_model=SurveyQuestionsResponse)
async def get_survey_questions(
    lang: str = "az",
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Sual siyahısı (lokalizə edilmiş)"""
    today = date.today()

    # Bugün doldurulub?
    result = await db.execute(
        select(DailySurvey).where(
            DailySurvey.user_id == current_user.id,
            DailySurvey.date == today,
        )
    )
    already_completed = result.scalar_one_or_none() is not None

    QUESTIONS = {
        "az": [
            SurveyQuestion(
                key="energy_level", title="Enerji səviyyəsi",
                description="Bu gün özünü necə hiss edirsən?",
                type="slider", min_value=1, max_value=5,
                emoji_labels=["😴", "😐", "🙂", "😊", "⚡"],
            ),
            SurveyQuestion(
                key="sleep_hours", title="Yuxu saatı",
                description="Dünən gecə neçə saat yatdın?",
                type="number", min_value=0, max_value=24,
            ),
            SurveyQuestion(
                key="sleep_quality", title="Yuxu keyfiyyəti",
                description="Yuxunun keyfiyyəti necə idi?",
                type="slider", min_value=1, max_value=5,
                emoji_labels=["😫", "😕", "😐", "😊", "😴"],
            ),
            SurveyQuestion(
                key="stress_level", title="Stress səviyyəsi",
                description="Stress səviyyən necədir?",
                type="slider", min_value=1, max_value=5,
                emoji_labels=["😌", "🙂", "😐", "😰", "🤯"],
            ),
            SurveyQuestion(
                key="muscle_soreness", title="Əzələ ağrısı",
                description="Əzələ ağrın var?",
                type="slider", min_value=1, max_value=5,
                emoji_labels=["💪", "🙂", "😐", "😣", "🥵"],
            ),
            SurveyQuestion(
                key="mood", title="Əhval",
                description="Ümumi əhvalın necədir?",
                type="slider", min_value=1, max_value=5,
                emoji_labels=["😢", "😕", "😐", "😊", "🤩"],
            ),
            SurveyQuestion(
                key="water_glasses", title="Su qəbulu",
                description="Bu gün neçə stəkan su içdin?",
                type="number", min_value=0, max_value=30,
            ),
        ],
        "en": [
            SurveyQuestion(
                key="energy_level", title="Energy Level",
                description="How are you feeling today?",
                type="slider", min_value=1, max_value=5,
                emoji_labels=["😴", "😐", "🙂", "😊", "⚡"],
            ),
            SurveyQuestion(
                key="sleep_hours", title="Sleep Hours",
                description="How many hours did you sleep last night?",
                type="number", min_value=0, max_value=24,
            ),
            SurveyQuestion(
                key="sleep_quality", title="Sleep Quality",
                description="How was your sleep quality?",
                type="slider", min_value=1, max_value=5,
                emoji_labels=["😫", "😕", "😐", "😊", "😴"],
            ),
            SurveyQuestion(
                key="stress_level", title="Stress Level",
                description="What's your stress level?",
                type="slider", min_value=1, max_value=5,
                emoji_labels=["😌", "🙂", "😐", "😰", "🤯"],
            ),
            SurveyQuestion(
                key="muscle_soreness", title="Muscle Soreness",
                description="Any muscle soreness?",
                type="slider", min_value=1, max_value=5,
                emoji_labels=["💪", "🙂", "😐", "😣", "🥵"],
            ),
            SurveyQuestion(
                key="mood", title="Mood",
                description="How's your overall mood?",
                type="slider", min_value=1, max_value=5,
                emoji_labels=["😢", "😕", "😐", "😊", "🤩"],
            ),
            SurveyQuestion(
                key="water_glasses", title="Water Intake",
                description="How many glasses of water today?",
                type="number", min_value=0, max_value=30,
            ),
        ],
        "ru": [
            SurveyQuestion(
                key="energy_level", title="Уровень энергии",
                description="Как вы себя чувствуете сегодня?",
                type="slider", min_value=1, max_value=5,
                emoji_labels=["😴", "😐", "🙂", "😊", "⚡"],
            ),
            SurveyQuestion(
                key="sleep_hours", title="Часы сна",
                description="Сколько часов вы спали прошлой ночью?",
                type="number", min_value=0, max_value=24,
            ),
            SurveyQuestion(
                key="sleep_quality", title="Качество сна",
                description="Как было качество вашего сна?",
                type="slider", min_value=1, max_value=5,
                emoji_labels=["😫", "😕", "😐", "😊", "😴"],
            ),
            SurveyQuestion(
                key="stress_level", title="Уровень стресса",
                description="Каков ваш уровень стресса?",
                type="slider", min_value=1, max_value=5,
                emoji_labels=["😌", "🙂", "😐", "😰", "🤯"],
            ),
            SurveyQuestion(
                key="muscle_soreness", title="Мышечная боль",
                description="Есть мышечная боль?",
                type="slider", min_value=1, max_value=5,
                emoji_labels=["💪", "🙂", "😐", "😣", "🥵"],
            ),
            SurveyQuestion(
                key="mood", title="Настроение",
                description="Какое у вас настроение?",
                type="slider", min_value=1, max_value=5,
                emoji_labels=["😢", "😕", "😐", "😊", "🤩"],
            ),
            SurveyQuestion(
                key="water_glasses", title="Потребление воды",
                description="Сколько стаканов воды вы выпили сегодня?",
                type="number", min_value=0, max_value=30,
            ),
        ],
    }

    questions = QUESTIONS.get(lang, QUESTIONS["az"])

    return SurveyQuestionsResponse(
        questions=questions,
        already_completed=already_completed,
    )
