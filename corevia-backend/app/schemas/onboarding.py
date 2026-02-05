from pydantic import BaseModel, Field
from datetime import datetime


class OnboardingCreate(BaseModel):
    fitness_goal: str = Field(..., max_length=100)
    fitness_level: str = Field(..., max_length=50)
    preferred_trainer_type: str | None = Field(None, max_length=100)


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
