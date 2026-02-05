"""
Live Workout Session Models
Real-time workout sessions with pose detection
"""

from sqlalchemy import Column, String, DateTime, Integer, Boolean, Float, Text, ForeignKey, JSON
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid

from app.database import Base


class LiveSession(Base):
    """Live workout session"""
    __tablename__ = "live_sessions"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    trainer_id = Column(String, ForeignKey("users.id"), nullable=False)
    title = Column(String(200), nullable=False)
    description = Column(Text)
    session_type = Column(String(50), nullable=False)  # group, one_on_one, open
    max_participants = Column(Integer, default=10)
    difficulty_level = Column(String(20))  # beginner, intermediate, advanced
    duration_minutes = Column(Integer, nullable=False)

    # Schedule
    scheduled_start = Column(DateTime, nullable=False)
    scheduled_end = Column(DateTime, nullable=False)
    actual_start = Column(DateTime)
    actual_end = Column(DateTime)

    # Status
    status = Column(String(20), default="scheduled")  # scheduled, live, completed, cancelled
    is_public = Column(Boolean, default=True)

    # Pricing (optional)
    is_paid = Column(Boolean, default=False)
    price = Column(Float, default=0.0)
    currency = Column(String(3), default="USD")

    # Session data
    workout_plan = Column(JSON)  # Exercise list with reps/sets
    session_recording_url = Column(String(500))

    # Metadata
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    trainer = relationship("User", foreign_keys=[trainer_id])
    participants = relationship("SessionParticipant", back_populates="session", cascade="all, delete-orphan")
    exercises = relationship("SessionExercise", back_populates="session", cascade="all, delete-orphan")
    stats = relationship("SessionStats", back_populates="session", uselist=False, cascade="all, delete-orphan")


class SessionParticipant(Base):
    """User participating in a live session"""
    __tablename__ = "session_participants"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    session_id = Column(String, ForeignKey("live_sessions.id"), nullable=False)
    user_id = Column(String, ForeignKey("users.id"), nullable=False)

    # Participation status
    status = Column(String(20), default="registered")  # registered, active, completed, left
    joined_at = Column(DateTime)
    left_at = Column(DateTime)

    # Performance tracking
    completed_exercises = Column(Integer, default=0)
    total_reps = Column(Integer, default=0)
    calories_burned = Column(Float, default=0.0)

    # Form quality (from ML model)
    avg_form_score = Column(Float)  # 0-100
    total_corrections = Column(Integer, default=0)

    # Metadata
    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    session = relationship("LiveSession", back_populates="participants")
    user = relationship("User")
    exercise_tracking = relationship("ParticipantExercise", back_populates="participant", cascade="all, delete-orphan")


class SessionExercise(Base):
    """Exercise in a live session"""
    __tablename__ = "session_exercises"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    session_id = Column(String, ForeignKey("live_sessions.id"), nullable=False)

    # Exercise details
    exercise_name = Column(String(200), nullable=False)
    exercise_type = Column(String(50))  # strength, cardio, flexibility, etc.
    target_reps = Column(Integer)
    target_sets = Column(Integer)
    target_duration_seconds = Column(Integer)
    rest_duration_seconds = Column(Integer, default=60)

    # Order in session
    order_index = Column(Integer, nullable=False)

    # Instructions
    instructions = Column(Text)
    demo_video_url = Column(String(500))

    # ML pose detection config
    pose_detection_enabled = Column(Boolean, default=True)
    key_points = Column(JSON)  # Body keypoints to track
    form_criteria = Column(JSON)  # Angle ranges, positions, etc.

    # Timestamps
    started_at = Column(DateTime)
    completed_at = Column(DateTime)

    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    session = relationship("LiveSession", back_populates="exercises")
    participant_progress = relationship("ParticipantExercise", back_populates="exercise", cascade="all, delete-orphan")


class ParticipantExercise(Base):
    """Individual participant's exercise tracking"""
    __tablename__ = "participant_exercises"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    participant_id = Column(String, ForeignKey("session_participants.id"), nullable=False)
    exercise_id = Column(String, ForeignKey("session_exercises.id"), nullable=False)

    # Completion
    completed_reps = Column(Integer, default=0)
    completed_sets = Column(Integer, default=0)
    completed_duration_seconds = Column(Integer, default=0)
    is_completed = Column(Boolean, default=False)

    # Form quality (from ML)
    form_scores = Column(JSON)  # Array of scores per rep
    avg_form_score = Column(Float)
    corrections_received = Column(Integer, default=0)

    # Timestamps
    started_at = Column(DateTime)
    completed_at = Column(DateTime)

    created_at = Column(DateTime, default=datetime.utcnow)

    # Relationships
    participant = relationship("SessionParticipant", back_populates="exercise_tracking")
    exercise = relationship("SessionExercise", back_populates="participant_progress")


class SessionStats(Base):
    """Overall session statistics"""
    __tablename__ = "session_stats"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    session_id = Column(String, ForeignKey("live_sessions.id"), nullable=False, unique=True)

    # Participation
    total_registered = Column(Integer, default=0)
    total_joined = Column(Integer, default=0)
    total_completed = Column(Integer, default=0)
    peak_concurrent = Column(Integer, default=0)

    # Performance
    avg_completion_rate = Column(Float, default=0.0)  # Percentage
    avg_form_score = Column(Float, default=0.0)
    total_corrections = Column(Integer, default=0)

    # Engagement
    total_reps = Column(Integer, default=0)
    total_calories_burned = Column(Float, default=0.0)
    avg_duration_minutes = Column(Float, default=0.0)

    # Feedback
    avg_rating = Column(Float)
    total_ratings = Column(Integer, default=0)

    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)

    # Relationships
    session = relationship("LiveSession", back_populates="stats")


class PoseDetectionLog(Base):
    """Log of pose detection events for analysis"""
    __tablename__ = "pose_detection_logs"

    id = Column(String, primary_key=True, default=lambda: str(uuid.uuid4()))
    participant_id = Column(String, ForeignKey("session_participants.id"), nullable=False)
    exercise_id = Column(String, ForeignKey("session_exercises.id"), nullable=False)

    # Detection data
    timestamp = Column(DateTime, default=datetime.utcnow, nullable=False)
    rep_number = Column(Integer)

    # Pose data (from ML model)
    keypoints = Column(JSON)  # Body keypoint coordinates
    angles = Column(JSON)  # Joint angles
    form_score = Column(Float)  # 0-100

    # Feedback
    correction_type = Column(String(50))  # knee_alignment, back_straight, etc.
    correction_message = Column(Text)

    created_at = Column(DateTime, default=datetime.utcnow)
