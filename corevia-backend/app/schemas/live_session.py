"""
Live Session Schemas - OWASP A03 Input Validation
"""

from pydantic import BaseModel, Field, field_validator
from datetime import datetime
from typing import Optional, List, Dict, Any


# ============================================================
# Live Session Schemas
# ============================================================

class WorkoutExercise(BaseModel):
    """Exercise in workout plan"""
    name: str = Field(..., min_length=1, max_length=200)
    type: str = Field(..., min_length=1, max_length=50)
    reps: Optional[int] = Field(None, ge=0, le=1000)
    sets: Optional[int] = Field(None, ge=0, le=100)
    duration_seconds: Optional[int] = Field(None, ge=0, le=7200)
    rest_seconds: int = Field(60, ge=0, le=600)


class CreateLiveSessionRequest(BaseModel):
    """Create live session - OWASP A03 validation"""
    title: str = Field(..., min_length=1, max_length=200)
    description: Optional[str] = Field(None, max_length=2000)
    session_type: str = Field(..., pattern="^(group|one_on_one|open)$")
    max_participants: int = Field(10, ge=1, le=100)
    difficulty_level: str = Field(..., pattern="^(beginner|intermediate|advanced)$")
    duration_minutes: int = Field(..., ge=15, le=180)

    scheduled_start: datetime
    is_public: bool = True

    # Pricing
    is_paid: bool = False
    price: Optional[float] = Field(None, ge=0, le=1000)
    currency: str = Field("USD", pattern="^(USD|EUR|AZN)$")

    # Workout plan
    workout_plan: List[WorkoutExercise] = Field(..., min_length=1, max_length=50)

    @field_validator('scheduled_start')
    @classmethod
    def validate_start_time(cls, v):
        """Ensure session is scheduled in future"""
        if v < datetime.utcnow():
            raise ValueError("Session must be scheduled in the future")
        return v


class UpdateLiveSessionRequest(BaseModel):
    """Update live session"""
    title: Optional[str] = Field(None, min_length=1, max_length=200)
    description: Optional[str] = Field(None, max_length=2000)
    max_participants: Optional[int] = Field(None, ge=1, le=100)
    is_public: Optional[bool] = None
    price: Optional[float] = Field(None, ge=0, le=1000)


class LiveSessionResponse(BaseModel):
    """Live session response"""
    id: str
    trainer_id: str
    title: str
    description: Optional[str]
    session_type: str
    max_participants: int
    difficulty_level: str
    duration_minutes: int

    scheduled_start: datetime
    scheduled_end: datetime
    actual_start: Optional[datetime]
    actual_end: Optional[datetime]

    status: str
    is_public: bool

    is_paid: bool
    price: float
    currency: str

    workout_plan: Optional[Dict[str, Any]]

    # Participant count
    registered_count: Optional[int] = 0
    active_count: Optional[int] = 0

    # Trainer info
    trainer: Optional[Dict[str, Any]]

    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class SessionListResponse(BaseModel):
    """List of sessions with pagination"""
    sessions: List[LiveSessionResponse]
    total: int
    page: int
    page_size: int
    has_more: bool


# ============================================================
# Participant Schemas
# ============================================================

class JoinSessionRequest(BaseModel):
    """Join a live session"""
    session_id: str


class ParticipantResponse(BaseModel):
    """Session participant"""
    id: str
    session_id: str
    user_id: str
    status: str
    joined_at: Optional[datetime]
    left_at: Optional[datetime]

    completed_exercises: int
    total_reps: int
    calories_burned: float
    avg_form_score: Optional[float]
    total_corrections: int

    # User info
    user: Optional[Dict[str, Any]]

    created_at: datetime

    class Config:
        from_attributes = True


# ============================================================
# Exercise Tracking Schemas
# ============================================================

class SessionExerciseResponse(BaseModel):
    """Exercise in session"""
    id: str
    session_id: str
    exercise_name: str
    exercise_type: str
    target_reps: Optional[int]
    target_sets: Optional[int]
    target_duration_seconds: Optional[int]
    rest_duration_seconds: int
    order_index: int
    instructions: Optional[str]
    demo_video_url: Optional[str]
    pose_detection_enabled: bool
    started_at: Optional[datetime]
    completed_at: Optional[datetime]
    created_at: datetime

    class Config:
        from_attributes = True


class UpdateExerciseProgressRequest(BaseModel):
    """Update participant's exercise progress"""
    completed_reps: Optional[int] = Field(None, ge=0, le=1000)
    completed_sets: Optional[int] = Field(None, ge=0, le=100)
    completed_duration_seconds: Optional[int] = Field(None, ge=0, le=7200)
    is_completed: Optional[bool] = None


class ParticipantExerciseResponse(BaseModel):
    """Participant's exercise progress"""
    id: str
    participant_id: str
    exercise_id: str
    completed_reps: int
    completed_sets: int
    completed_duration_seconds: int
    is_completed: bool
    avg_form_score: Optional[float]
    corrections_received: int
    started_at: Optional[datetime]
    completed_at: Optional[datetime]
    created_at: datetime

    class Config:
        from_attributes = True


# ============================================================
# Pose Detection Schemas
# ============================================================

class KeyPoint(BaseModel):
    """Body keypoint"""
    name: str = Field(..., max_length=50)
    x: float = Field(..., ge=0, le=1)  # Normalized 0-1
    y: float = Field(..., ge=0, le=1)
    confidence: float = Field(..., ge=0, le=1)


class JointAngle(BaseModel):
    """Joint angle measurement"""
    joint: str = Field(..., max_length=50)
    angle: float = Field(..., ge=0, le=360)


class PoseDetectionRequest(BaseModel):
    """Submit pose detection data"""
    exercise_id: str
    rep_number: int = Field(..., ge=1, le=1000)
    keypoints: List[KeyPoint] = Field(..., min_length=1, max_length=50)
    angles: List[JointAngle] = Field(..., min_length=1, max_length=20)
    timestamp: datetime


class FormFeedback(BaseModel):
    """Real-time form feedback"""
    form_score: float  # 0-100
    correction_type: Optional[str]
    correction_message: Optional[str]
    is_correct: bool


class PoseDetectionResponse(BaseModel):
    """Pose detection analysis result"""
    id: str
    feedback: FormFeedback
    timestamp: datetime

    class Config:
        from_attributes = True


# ============================================================
# Session Stats Schemas
# ============================================================

class SessionStatsResponse(BaseModel):
    """Session statistics"""
    id: str
    session_id: str

    # Participation
    total_registered: int
    total_joined: int
    total_completed: int
    peak_concurrent: int

    # Performance
    avg_completion_rate: float
    avg_form_score: float
    total_corrections: int

    # Engagement
    total_reps: int
    total_calories_burned: float
    avg_duration_minutes: float

    # Feedback
    avg_rating: Optional[float]
    total_ratings: int

    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


# ============================================================
# WebSocket Messages
# ============================================================

class WSMessage(BaseModel):
    """WebSocket message base"""
    type: str
    data: Dict[str, Any]


class SessionStartMessage(BaseModel):
    """Session start notification"""
    type: str = "session_start"
    session_id: str
    timestamp: datetime


class ExerciseStartMessage(BaseModel):
    """Exercise start notification"""
    type: str = "exercise_start"
    exercise_id: str
    exercise_name: str
    target_reps: Optional[int]
    target_duration: Optional[int]


class ParticipantJoinedMessage(BaseModel):
    """Participant joined notification"""
    type: str = "participant_joined"
    user_id: str
    user_name: str
    participant_count: int


class FormCorrectionMessage(BaseModel):
    """Real-time form correction"""
    type: str = "form_correction"
    user_id: str
    correction_type: str
    message: str
    form_score: float


class SessionEndMessage(BaseModel):
    """Session end notification"""
    type: str = "session_end"
    session_id: str
    stats: Dict[str, Any]
