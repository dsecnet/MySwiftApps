import asyncio
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession
from sqlalchemy.orm import sessionmaker
from app.models.user import User, UserType
from passlib.context import CryptContext
import uuid

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

async def create_users():
    engine = create_async_engine(
        "postgresql+asyncpg://postgres:postgres@localhost:5432/corevia_db",
        echo=False
    )
    
    async_session = sessionmaker(
        engine, class_=AsyncSession, expire_on_commit=False
    )
    
    async with async_session() as session:
        # Student user
        student = User(
            id=str(uuid.uuid4()),
            name="Vusal Student",
            email="student@test.com",
            hashed_password=pwd_context.hash("test123"),
            user_type=UserType.client,
            age=25,
            weight=75.0,
            height=180.0,
            goal="Build muscle",
            is_active=True
        )
        
        # Trainer user
        trainer = User(
            id=str(uuid.uuid4()),
            name="Vusal Trainer",
            email="trainer@test.com",
            hashed_password=pwd_context.hash("test123"),
            user_type=UserType.trainer,
            age=30,
            specialization="Strength & Conditioning",
            experience=5,
            rating=4.8,
            price_per_session=50.0,
            bio="Professional fitness trainer with 5 years experience",
            is_active=True
        )

        # Demo Teacher - hazır hesab (müəllim üçün premium yoxdur)
        demo_teacher = User(
            id=str(uuid.uuid4()),
            name="Test Müəllim",
            email="testmuellim@demo.com",
            hashed_password=pwd_context.hash("demo123"),
            user_type=UserType.trainer,
            age=30,
            weight=75.0,
            height=180.0,
            specialization="Fitness və Qidalanma",
            experience=5,
            rating=4.8,
            price_per_session=50.0,
            bio="Peşəkar fitness məşqçisi və qidalanma mütəxəssisi",
            is_active=True,
            instagram_handle="@testmuellim",
            verification_status="verified",
            verification_score=0.95
        )

        session.add(student)
        session.add(trainer)
        session.add(demo_teacher)
        await session.commit()

        print("✅ Test users created:")
        print(f"  Student: student@test.com / test123")
        print(f"  Trainer: trainer@test.com / test123")
        print(f"  Demo Teacher: testmuellim@demo.com / demo123")

if __name__ == "__main__":
    asyncio.run(create_users())
