from pydantic import BaseModel, Field
from datetime import datetime


class OnboardingCreate(BaseModel):
    fitness_goal: str | None = Field(None, max_length=100)
    fitness_level: str | None = Field(None, max_length=50)
    preferred_trainer_type: str | None = Field(None, max_length=100)
    gender: str | None = Field(None, max_length=20)
    age: int | None = Field(None, ge=13, le=100)
    weight: float | None = Field(None, ge=20, le=300)
    height: float | None = Field(None, ge=100, le=250)
    # Trainer-specific fields
    specialization: str | None = Field(None, max_length=100)
    experience: int | None = Field(None, ge=0, le=50)
    bio: str | None = Field(None, max_length=500)


class OnboardingResponse(BaseModel):
    id: str
    user_id: str
    fitness_goal: str | None = None
    fitness_level: str | None = None
    preferred_trainer_type: str | None = None
    is_completed: bool
    completed_at: datetime | None = None

    model_config = {"from_attributes": True}


class OnboardingOptions(BaseModel):
    goals: list[dict[str, str]]
    fitness_levels: list[dict[str, str]]
    trainer_types: list[dict[str, str]]
