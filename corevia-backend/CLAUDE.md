# CoreVia Backend

## Layihe Haqqinda
CoreVia - SwiftUI ile yazilmis iOS fitness ve qidalanma tetbiqi ucun Python backend.
iOS app yeri: /Users/vusaldadashov/Desktop/ConsoleApp/CoreVia

## Tech Stack
- **Dil:** Python 3.14.2
- **Framework:** FastAPI
- **Database:** PostgreSQL 14.20
- **Cache:** Redis 8.4.0
- **ORM:** SQLAlchemy + Alembic (migrations)
- **Auth:** JWT (python-jose) + bcrypt
- **File Storage:** AWS S3 (boto3)
- **AI:** OpenAI API (GPT-4 Vision - kalori hesablama)
- **Async Tasks:** Celery + Redis
- **Geo/Location:** PostGIS + GeoAlchemy2 + Mapbox
- **Notifications:** Firebase Admin (FCM)
- **Scheduler:** APScheduler

## Backend-i Run Etmek
```bash
cd /Users/vusaldadashov/Desktop/ConsoleApp/corevia-backend
source venv/bin/activate
uvicorn app.main:app --reload --port 8000
```

## Layihe Strukturu
```
corevia-backend/
├── app/
│   ├── main.py              # FastAPI entry point
│   ├── config.py            # Settings & env variables
│   ├── database.py          # DB connection
│   ├── models/              # SQLAlchemy models
│   ├── schemas/             # Pydantic schemas
│   ├── routers/             # API endpoints
│   ├── services/            # Business logic
│   └── utils/               # Helpers
├── alembic/                 # Database migrations
├── tests/                   # Testler
├── requirements.txt         # Python dependencies
├── .env                     # Environment variables
└── docker-compose.yml       # Docker setup
```

## Inkisaf Merhelesi

### Tamamlanmis Merheleler:
- [x] Merhele 0: Muhit hazirligi (Python, PostgreSQL, Redis, venv)
- [x] Paket install: Butun 22 paket install olunub (requirements.txt-de 86 paket)

### Hazirki Merhele:
- [ ] Merhele 1: Layihe strukturu + Database setup + Esas modeller

### Gelecek Merheleler:
- [ ] Merhele 2: Authentication sistemi (JWT + bcrypt)
- [ ] Merhele 3: CRUD API endpoints (User, Workout, Food, Plans)
- [ ] Merhele 4: Fayl/Sekil upload sistemi (S3)
- [ ] Merhele 5: Trainer verifikasiya sistemi
- [ ] Merhele 6: AI - Sekilden kalori hesablama (OpenAI Vision)
- [ ] Merhele 7: AI - User data analiz + tovsiyeler
- [ ] Merhele 8: Location + Route sistemi (PostGIS + Mapbox)
- [ ] Merhele 9: Notification + Premium

## iOS App Model-leri (Backend modeller buna uygun yazilir)
- **User:** id, name, email, userType (client/trainer), profileImageURL, age, weight, height, goal, trainerId, specialization, experience, rating, pricePerSession, bio
- **Workout:** id, title, category (strength/cardio/flexibility/endurance), duration, caloriesBurned, notes, date, isCompleted
- **FoodEntry:** id, name, calories, protein, carbs, fats, mealType (breakfast/lunch/dinner/snack), date, notes, hasImage
- **MealPlan:** id, title, planType (weightLoss/weightGain/strengthTraining), meals[], assignedStudentName, createdDate, dailyCalorieTarget, notes
- **TrainingPlan:** id, title, planType, workouts[], assignedStudentName, createdDate, notes
- **PlanWorkout:** id, name, sets, reps, duration
- **MealPlanItem:** id, name, calories, protein, carbs, fats, mealType
- **AppSettings:** notificationsEnabled, workoutReminders, mealReminders, weeklyReports, faceIDEnabled, hasAppPassword, isPremium

## Qeydler
- Virtual environment: venv/ qovlugunda
- Her defe isleyende evvelce `source venv/bin/activate` lazimdir
- PostgreSQL ve Redis service-leri isleyir olmalidir
