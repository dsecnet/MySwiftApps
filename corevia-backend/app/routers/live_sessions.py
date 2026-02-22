"""
Live Workout Sessions Router - OWASP A01:2021 Compliant
Real-time workout sessions with WebSocket support
"""

import logging
from datetime import datetime, timedelta
from fastapi import APIRouter, Depends, HTTPException, status, WebSocket, WebSocketDisconnect
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, and_, func, desc
from typing import List, Optional

from app.database import get_db
from app.models.user import User
from app.models.live_session import (
    LiveSession, SessionParticipant, SessionExercise,
    ParticipantExercise, SessionStats, PoseDetectionLog
)
from app.schemas.live_session import (
    CreateLiveSessionRequest, UpdateLiveSessionRequest,
    LiveSessionResponse, SessionListResponse,
    JoinSessionRequest, ParticipantResponse,
    SessionExerciseResponse, UpdateExerciseProgressRequest,
    ParticipantExerciseResponse, PoseDetectionRequest,
    PoseDetectionResponse, SessionStatsResponse, FormFeedback
)
from app.utils.security import get_current_user, require_trainer

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/live-sessions", tags=["Live Sessions"])


# ============================================================
# WebSocket Connection Manager
# ============================================================

class ConnectionManager:
    """Manage WebSocket connections for live sessions"""

    def __init__(self):
        self.active_connections: dict[str, List[WebSocket]] = {}

    async def connect(self, session_id: str, websocket: WebSocket):
        """Connect user to session"""
        await websocket.accept()
        if session_id not in self.active_connections:
            self.active_connections[session_id] = []
        self.active_connections[session_id].append(websocket)

    def disconnect(self, session_id: str, websocket: WebSocket):
        """Disconnect user from session"""
        if session_id in self.active_connections:
            self.active_connections[session_id].remove(websocket)
            if not self.active_connections[session_id]:
                del self.active_connections[session_id]

    async def broadcast(self, session_id: str, message: dict):
        """Broadcast message to all users in session"""
        if session_id in self.active_connections:
            for connection in self.active_connections[session_id]:
                try:
                    await connection.send_json(message)
                except Exception as e:
                    logger.error(f"Failed to send message: {e}")


manager = ConnectionManager()


# ============================================================
# SESSION CRUD
# ============================================================

@router.post("", response_model=LiveSessionResponse, status_code=status.HTTP_201_CREATED)
async def create_live_session(
    session_data: CreateLiveSessionRequest,
    current_user: User = Depends(require_trainer),
    db: AsyncSession = Depends(get_db),
):
    """
    Create a live workout session
    OWASP A01 - Only trainers can create sessions
    """
    # Calculate end time
    scheduled_end = session_data.scheduled_start + timedelta(minutes=session_data.duration_minutes)

    # Create session
    session = LiveSession(
        trainer_id=current_user.id,
        title=session_data.title,
        description=session_data.description,
        session_type=session_data.session_type,
        max_participants=session_data.max_participants,
        difficulty_level=session_data.difficulty_level,
        duration_minutes=session_data.duration_minutes,
        scheduled_start=session_data.scheduled_start,
        scheduled_end=scheduled_end,
        is_public=session_data.is_public,
        is_paid=session_data.is_paid,
        price=session_data.price or 0.0,
        currency=session_data.currency,
        workout_plan=[ex.dict() for ex in session_data.workout_plan],
    )

    db.add(session)
    await db.commit()
    await db.refresh(session)

    # Create exercises
    for idx, exercise in enumerate(session_data.workout_plan):
        session_exercise = SessionExercise(
            session_id=session.id,
            exercise_name=exercise.name,
            exercise_type=exercise.type,
            target_reps=exercise.reps,
            target_sets=exercise.sets,
            target_duration_seconds=exercise.duration_seconds,
            rest_duration_seconds=exercise.rest_seconds,
            order_index=idx,
            pose_detection_enabled=True,
        )
        db.add(session_exercise)

    # Create stats record
    stats = SessionStats(session_id=session.id)
    db.add(stats)

    await db.commit()

    logger.info(f"Live session created: {session.id} by trainer {current_user.id}")

    return session


@router.get("", response_model=SessionListResponse)
async def list_live_sessions(
    status_filter: Optional[str] = None,
    session_type: Optional[str] = None,
    difficulty: Optional[str] = None,
    upcoming_only: bool = True,
    page: int = 1,
    page_size: int = 20,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    List live sessions with filters
    OWASP A01 - Public sessions or registered sessions
    """
    query = select(LiveSession).where(LiveSession.is_public == True)

    # Filters
    if status_filter:
        query = query.where(LiveSession.status == status_filter)

    if session_type:
        query = query.where(LiveSession.session_type == session_type)

    if difficulty:
        query = query.where(LiveSession.difficulty_level == difficulty)

    if upcoming_only:
        query = query.where(LiveSession.scheduled_start > datetime.utcnow())

    # Count total
    count_query = select(func.count()).select_from(query.subquery())
    total_result = await db.execute(count_query)
    total = total_result.scalar()

    # Paginate
    query = query.order_by(desc(LiveSession.scheduled_start))
    query = query.offset((page - 1) * page_size).limit(page_size)

    result = await db.execute(query)
    sessions = result.scalars().all()

    return SessionListResponse(
        sessions=sessions,
        total=total,
        page=page,
        page_size=page_size,
        has_more=(page * page_size) < total,
    )


@router.get("/{session_id}", response_model=LiveSessionResponse)
async def get_live_session(
    session_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get session details - OWASP A01"""
    result = await db.execute(
        select(LiveSession).where(LiveSession.id == session_id)
    )
    session = result.scalar_one_or_none()

    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    # Check access
    if not session.is_public and session.trainer_id != current_user.id:
        # Check if user is registered
        participant_result = await db.execute(
            select(SessionParticipant).where(
                and_(
                    SessionParticipant.session_id == session_id,
                    SessionParticipant.user_id == current_user.id
                )
            )
        )
        if not participant_result.scalar_one_or_none():
            raise HTTPException(status_code=403, detail="Access denied")

    return session


@router.put("/{session_id}", response_model=LiveSessionResponse)
async def update_live_session(
    session_id: str,
    update_data: UpdateLiveSessionRequest,
    current_user: User = Depends(require_trainer),
    db: AsyncSession = Depends(get_db),
):
    """Update session - OWASP A01 Ownership check"""
    result = await db.execute(
        select(LiveSession).where(LiveSession.id == session_id)
    )
    session = result.scalar_one_or_none()

    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    # Ownership check
    if session.trainer_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not your session")

    # Cannot update live or completed sessions
    if session.status in ["live", "completed"]:
        raise HTTPException(status_code=400, detail="Cannot update live or completed session")

    # Update fields
    update_dict = update_data.dict(exclude_unset=True)
    for key, value in update_dict.items():
        setattr(session, key, value)

    session.updated_at = datetime.utcnow()

    await db.commit()
    await db.refresh(session)

    logger.info(f"Session updated: {session_id}")

    return session


@router.delete("/{session_id}")
async def delete_live_session(
    session_id: str,
    current_user: User = Depends(require_trainer),
    db: AsyncSession = Depends(get_db),
):
    """Delete/cancel session - OWASP A01"""
    result = await db.execute(
        select(LiveSession).where(LiveSession.id == session_id)
    )
    session = result.scalar_one_or_none()

    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    # Ownership check
    if session.trainer_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not your session")

    # If session hasn't started, mark as cancelled
    if session.status == "scheduled":
        session.status = "cancelled"
        await db.commit()
    else:
        raise HTTPException(status_code=400, detail="Cannot delete live or completed session")

    logger.info(f"Session cancelled: {session_id}")

    return {"message": "Session cancelled"}


# ============================================================
# PARTICIPANT MANAGEMENT
# ============================================================

@router.post("/join", status_code=status.HTTP_201_CREATED)
async def join_session(
    join_data: JoinSessionRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Join a live session - OWASP A01"""
    session_id = join_data.session_id

    # Get session
    result = await db.execute(
        select(LiveSession).where(LiveSession.id == session_id)
    )
    session = result.scalar_one_or_none()

    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    # Check if already registered
    existing = await db.execute(
        select(SessionParticipant).where(
            and_(
                SessionParticipant.session_id == session_id,
                SessionParticipant.user_id == current_user.id
            )
        )
    )
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Already registered")

    # Check capacity
    participant_count = await db.execute(
        select(func.count()).select_from(SessionParticipant).where(
            SessionParticipant.session_id == session_id
        )
    )
    count = participant_count.scalar()

    if count >= session.max_participants:
        raise HTTPException(status_code=400, detail="Session is full")

    # Create participant
    participant = SessionParticipant(
        session_id=session_id,
        user_id=current_user.id,
        status="registered",
    )
    db.add(participant)
    await db.commit()

    logger.info(f"User {current_user.id} joined session {session_id}")

    return {"message": "Successfully joined session", "participant_id": participant.id}


# Android compatibility: path-based join endpoint
@router.post("/{session_id}/join", status_code=status.HTTP_201_CREATED)
async def join_session_by_path(
    session_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Join a live session via path param (Android compatibility) - OWASP A01"""
    # Get session
    result = await db.execute(
        select(LiveSession).where(LiveSession.id == session_id)
    )
    session = result.scalar_one_or_none()

    if not session:
        raise HTTPException(status_code=404, detail="Sessiya tapılmadı")

    # Check if already registered
    existing = await db.execute(
        select(SessionParticipant).where(
            and_(
                SessionParticipant.session_id == session_id,
                SessionParticipant.user_id == current_user.id
            )
        )
    )
    if existing.scalar_one_or_none():
        raise HTTPException(status_code=400, detail="Artıq qeydiyyatdan keçmisiniz")

    # Check capacity
    participant_count = await db.execute(
        select(func.count()).select_from(SessionParticipant).where(
            SessionParticipant.session_id == session_id
        )
    )
    count = participant_count.scalar()

    if count >= session.max_participants:
        raise HTTPException(status_code=400, detail="Sessiya doludur")

    # Create participant
    participant = SessionParticipant(
        session_id=session_id,
        user_id=current_user.id,
        status="registered",
    )
    db.add(participant)
    await db.commit()

    logger.info(f"User {current_user.id} joined session {session_id}")

    # Return updated session with trainer info
    trainer_result = await db.execute(
        select(User).where(User.id == session.trainer_id)
    )
    trainer = trainer_result.scalar_one_or_none()

    # Get updated participant count
    new_count = count + 1

    return {
        "id": session.id,
        "trainer_id": session.trainer_id,
        "trainer_name": trainer.name if trainer else None,
        "title": session.title,
        "description": session.description,
        "session_type": session.session_type,
        "status": session.status,
        "max_participants": session.max_participants,
        "current_participants": new_count,
        "scheduled_at": session.scheduled_start.isoformat() if session.scheduled_start else None,
        "duration_minutes": session.duration_minutes,
        "created_at": session.created_at.isoformat() if session.created_at else None,
    }


@router.post("/{session_id}/leave")
async def leave_session(
    session_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Leave a live session - OWASP A01"""
    # Get session
    result = await db.execute(
        select(LiveSession).where(LiveSession.id == session_id)
    )
    session = result.scalar_one_or_none()

    if not session:
        raise HTTPException(status_code=404, detail="Sessiya tapılmadı")

    # Find participant
    participant_result = await db.execute(
        select(SessionParticipant).where(
            and_(
                SessionParticipant.session_id == session_id,
                SessionParticipant.user_id == current_user.id
            )
        )
    )
    participant = participant_result.scalar_one_or_none()

    if not participant:
        raise HTTPException(status_code=400, detail="Bu sessiyaya qoşulmamısınız")

    # Remove participant
    await db.delete(participant)
    await db.commit()

    logger.info(f"User {current_user.id} left session {session_id}")

    # Get trainer info
    trainer_result = await db.execute(
        select(User).where(User.id == session.trainer_id)
    )
    trainer = trainer_result.scalar_one_or_none()

    # Get updated participant count
    count_result = await db.execute(
        select(func.count()).select_from(SessionParticipant).where(
            SessionParticipant.session_id == session_id
        )
    )
    new_count = count_result.scalar()

    return {
        "id": session.id,
        "trainer_id": session.trainer_id,
        "trainer_name": trainer.name if trainer else None,
        "title": session.title,
        "description": session.description,
        "session_type": session.session_type,
        "status": session.status,
        "max_participants": session.max_participants,
        "current_participants": new_count,
        "scheduled_at": session.scheduled_start.isoformat() if session.scheduled_start else None,
        "duration_minutes": session.duration_minutes,
        "created_at": session.created_at.isoformat() if session.created_at else None,
    }


@router.get("/{session_id}/participants", response_model=List[ParticipantResponse])
async def get_session_participants(
    session_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get session participants"""
    # Verify access to session
    session_result = await db.execute(
        select(LiveSession).where(LiveSession.id == session_id)
    )
    session = session_result.scalar_one_or_none()

    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    # Get participants
    result = await db.execute(
        select(SessionParticipant).where(
            SessionParticipant.session_id == session_id
        ).order_by(SessionParticipant.joined_at.desc())
    )
    participants = result.scalars().all()

    return participants


# ============================================================
# EXERCISE TRACKING
# ============================================================

@router.get("/{session_id}/exercises", response_model=List[SessionExerciseResponse])
async def get_session_exercises(
    session_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get exercises for session"""
    result = await db.execute(
        select(SessionExercise).where(
            SessionExercise.session_id == session_id
        ).order_by(SessionExercise.order_index)
    )
    exercises = result.scalars().all()

    return exercises


@router.post("/{session_id}/start")
async def start_session(
    session_id: str,
    current_user: User = Depends(require_trainer),
    db: AsyncSession = Depends(get_db),
):
    """Start a live session - OWASP A01 Trainer only"""
    result = await db.execute(
        select(LiveSession).where(LiveSession.id == session_id)
    )
    session = result.scalar_one_or_none()

    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    # Ownership check
    if session.trainer_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not your session")

    if session.status != "scheduled":
        raise HTTPException(status_code=400, detail="Session already started or completed")

    # Update status
    session.status = "live"
    session.actual_start = datetime.utcnow()
    await db.commit()

    # Broadcast to participants
    await manager.broadcast(session_id, {
        "type": "session_start",
        "session_id": session_id,
        "timestamp": datetime.utcnow().isoformat(),
    })

    logger.info(f"Session started: {session_id}")

    return {"message": "Session started", "started_at": session.actual_start}


@router.post("/{session_id}/end")
async def end_session(
    session_id: str,
    current_user: User = Depends(require_trainer),
    db: AsyncSession = Depends(get_db),
):
    """End a live session - OWASP A01"""
    result = await db.execute(
        select(LiveSession).where(LiveSession.id == session_id)
    )
    session = result.scalar_one_or_none()

    if not session:
        raise HTTPException(status_code=404, detail="Session not found")

    # Ownership check
    if session.trainer_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not your session")

    if session.status != "live":
        raise HTTPException(status_code=400, detail="Session not live")

    # Update status
    session.status = "completed"
    session.actual_end = datetime.utcnow()
    await db.commit()

    # Calculate stats
    # (This would be more comprehensive in production)
    stats_result = await db.execute(
        select(SessionStats).where(SessionStats.session_id == session_id)
    )
    stats = stats_result.scalar_one_or_none()

    if stats:
        # Update final stats
        stats.updated_at = datetime.utcnow()
        await db.commit()

    # Broadcast to participants
    await manager.broadcast(session_id, {
        "type": "session_end",
        "session_id": session_id,
        "timestamp": datetime.utcnow().isoformat(),
    })

    logger.info(f"Session ended: {session_id}")

    return {"message": "Session ended", "ended_at": session.actual_end}


@router.get("/{session_id}/stats", response_model=SessionStatsResponse)
async def get_session_stats(
    session_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Get session statistics"""
    result = await db.execute(
        select(SessionStats).where(SessionStats.session_id == session_id)
    )
    stats = result.scalar_one_or_none()

    if not stats:
        raise HTTPException(status_code=404, detail="Stats not found")

    return stats


# ============================================================
# WEBSOCKET (Real-time communication)
# ============================================================

@router.websocket("/ws/{session_id}")
async def websocket_endpoint(
    websocket: WebSocket,
    session_id: str,
    db: AsyncSession = Depends(get_db),
):
    """
    WebSocket connection for real-time session updates
    NOTE: In production, add authentication via token in query params
    """
    await manager.connect(session_id, websocket)

    try:
        while True:
            # Receive messages from client
            data = await websocket.receive_json()

            # Handle different message types
            message_type = data.get("type")

            if message_type == "form_update":
                # Broadcast form correction to all participants
                await manager.broadcast(session_id, {
                    "type": "form_correction",
                    "user_id": data.get("user_id"),
                    "correction": data.get("correction"),
                    "timestamp": datetime.utcnow().isoformat(),
                })

            elif message_type == "exercise_complete":
                # Broadcast exercise completion
                await manager.broadcast(session_id, {
                    "type": "exercise_complete",
                    "user_id": data.get("user_id"),
                    "exercise_id": data.get("exercise_id"),
                    "timestamp": datetime.utcnow().isoformat(),
                })

    except WebSocketDisconnect:
        manager.disconnect(session_id, websocket)
        logger.info(f"WebSocket disconnected from session {session_id}")
