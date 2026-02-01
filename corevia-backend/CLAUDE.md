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
- [x] Paket install: Butun 22 paket install olunub (requirements.txt-de 88 paket)
- [x] Merhele 1: Layihe strukturu + Database setup + Esas modeller
  - Layihe qovluq strukturu yaradildi
  - config.py + .env konfiqurasiya olundu
  - database.py (async PostgreSQL connection) yazildi
  - SQLAlchemy modeller yazildi: User, Workout, FoodEntry, MealPlan, MealPlanItem, TrainingPlan, PlanWorkout, UserSettings
  - Pydantic schemas yazildi: user.py, workout.py, food.py, plan.py
  - utils/security.py (JWT + bcrypt) yazildi
  - main.py (FastAPI entry point) yazildi
  - Alembic migration yaradildi ve run olundu (8 table)
  - PostgreSQL-de corevia_db database-i yaradildi
  - Server test olundu: http://localhost:8000 isleyir

- [x] Merhele 2: Authentication sistemi (JWT + bcrypt)
  - Auth router yazildi: POST /api/v1/auth/register, /login, /refresh, GET /me
  - Users router yazildi: GET/PUT /profile, GET /trainers, /trainer/{id}, /my-students, POST /assign-trainer/{id}
  - JWT access + refresh token sistemi isleyir
  - bcrypt ile password hashing (passlib evezine birbaşa bcrypt 5.x istifade olunur)
  - get_current_user dependency ile protected endpoints
  - Butun endpoints test olundu ve isleyir

- [x] Merhele 3: CRUD API endpoints (Workout, Food, Plans)
  - Workouts router: POST/GET/PUT/DELETE /api/v1/workouts/, GET /today, /stats, PATCH /toggle
  - Food router: POST/GET/PUT/DELETE /api/v1/food/, GET /today, /daily-summary
  - Plans router: Meal plans (POST/GET/PUT/DELETE /api/v1/plans/meal), Training plans (POST/GET/PUT/DELETE /api/v1/plans/training)
  - Workout stats (bugunki + heftelik): workout_count, total_minutes, total_calories
  - Daily nutrition summary: total_calories, protein, carbs, fats, remaining_calories
  - Trainer-only plan creation + student assignment
  - Butun endpoints test olundu ve isleyir

- [x] Merhele 4: Fayl/Sekil upload sistemi
  - file_service.py: Sekil upload, resize (max 1024px), optimize (JPEG 85%), EXIF fix
  - uploads router: POST /api/v1/uploads/profile-image, /food-image/{id}, /certificate, DELETE /profile-image
  - Hazirda lokal fayl sisteminde saxlanilir (uploads/ qovluqu)
  - Static files /uploads/ URL-den serve olunur
  - S3-e kecid ucun yalniz file_service.py deyisdirilmelidir (router-ler eyni qalir)
  - Max fayl olcusu: 10MB, icaze verilen formatlar: jpg, jpeg, png, webp
  - Butun upload-lar test olundu ve isleyir

- [x] Merhele 5: Trainer verifikasiya sistemi
  - Admin router: GET /api/v1/admin/pending-trainers, /all-trainers, /stats
  - POST /api/v1/admin/verify-trainer/{id}, /reject-trainer/{id}
  - Verification flow: register (pending) -> sertifikat upload -> admin verify/reject
  - Admin stats: total_users, total_clients, total_trainers, pending_verifications
  - Helelik her verified trainer admin rolu dasiyir (gelecekde is_admin field elave olunacaq)

- [x] Merhele 6: AI - Sekilden kalori hesablama (OpenAI Vision)
  - ai_service.py: OpenAI GPT-4o Vision ile sekil analizi + mock fallback (API key olmayanda)
  - ai.py router: POST /api/v1/ai/analyze-food, /analyze-and-save, GET /recommendations
  - analyze-food: Sekil upload → AI analiz → kalori/makro netice qaytarir
  - analyze-and-save: Sekil upload → AI analiz → FoodEntry olaraq DB-ye saxlayir
  - OpenAI key yoxdursa mock data qaytarir (test ucun)
  - Butun endpoints test olundu ve isleyir

- [x] Merhele 7: AI - User data analiz + tovsiyeler
  - recommendations endpoint Stage 6-da yazildi (ai.py router-de)
  - GET /api/v1/ai/recommendations: Son 7 gunluk workout + food stats → AI tovsiyeler
  - User-in heftelik mesq ve qidalanma datalarini aggregasiya edir
  - OpenAI GPT-4o ile sexsi tovsiyeler verir (mock fallback var)
  - weekly_score, nutrition_tips, workout_tips, warnings qaytarir

- [x] Merhele 8: Location + Route sistemi (Mapbox)
  - Route model yaradildi: GPS marsrut izleme (running, cycling, walking)
  - route.py model: start/end koordinatlari, polyline, coordinates_json, mesafe, muddət, pace, speed, elevation, kalori
  - Trainer route assignment: trainer oz student-lerine marsrut teyin ede biler
  - location_service.py: Haversine mesafe hesablama, pace/speed, elevation, kalori (MET formula), Mapbox Static Maps + Directions API
  - location.py router endpointleri:
    - POST /api/v1/routes/ - yeni marsrut yarat (auto-stats hesablama)
    - GET /api/v1/routes/ - marsrutlari getir (filter: activity_type, is_completed, date range + pagination)
    - GET /api/v1/routes/stats - marsrut statistikasi (son N gun)
    - GET /api/v1/routes/assigned - student-in teyin olunmus marsrutlari
    - GET /api/v1/routes/{id} - tek marsrut
    - PUT /api/v1/routes/{id} - marsrutu yenile
    - DELETE /api/v1/routes/{id} - marsrutu sil
    - POST /api/v1/routes/assign - trainer -> student marsrut teyin etme
    - GET /api/v1/routes/trainer/assigned - trainer-in teyin etdiyi marsrutlar
    - GET /api/v1/routes/directions/preview - Mapbox Directions ile marsrut preview
  - Alembic migration: routes table yaradildi (user_id, workout_id index)
  - Mapbox key olmayanda mock/null qaytarir (math hesablamalar isleyir)
  - Butun endpoints test olundu ve isleyir

### Hazirki Merhele:
- [ ] Merhele 9: Notification + Premium

### Gelecek Merheleler:
- (Butun esas merheleler tamamlanib)

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

## GOZLENEN TAPSIRIGLAR
- **Domen:** Hele alinmayib. Bu ay erzinde alinacaq. Domen alindiqda user deyecek ki "domeni deyis" - o zaman .env, CORS, config ve deploy ayarlarinda localhost-u domen ile evez etmek lazimdir. Hazirda her sey localhost:8000 uzerinde isleyir.
