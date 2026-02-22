from pydantic import BaseModel, Field


class UserSettingsResponse(BaseModel):
    notifications_enabled: bool = True
    workout_reminders: bool = True
    meal_reminders: bool = True
    weekly_reports: bool = False
    language: str = "az"
    dark_mode: bool = False

    model_config = {"from_attributes": True}


class UserSettingsUpdate(BaseModel):
    notifications_enabled: bool | None = None
    workout_reminders: bool | None = None
    meal_reminders: bool | None = None
    weekly_reports: bool | None = None
    language: str | None = Field(None, max_length=10)
    dark_mode: bool | None = None
