# 🛠️ Əmlak CRM - Setup Guide

## Prerequisites

- **Python:** 3.12+
- **Node.js:** 18+
- **PostgreSQL:** 14+
- **Redis:** 7+
- **Git**

---

## 🐍 Backend Setup

### 1. Create Virtual Environment
```bash
cd backend
python3 -m venv venv
source venv/bin/activate  # Mac/Linux
# or
venv\Scripts\activate  # Windows
```

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Create Database
```bash
# Create PostgreSQL database
createdb emlak_crm_db

# Or via psql
psql -U postgres
CREATE DATABASE emlak_crm_db;
\q
```

### 4. Environment Setup
```bash
cp .env.example .env
# Edit .env with your credentials
```

**Required `.env` variables:**
```env
DATABASE_URL=postgresql+asyncpg://postgres:yourpassword@localhost:5432/emlak_crm_db
SECRET_KEY=generate-a-strong-random-key-here
REDIS_URL=redis://localhost:6379/0
```

### 5. Run Migrations
```bash
# Initialize Alembic (first time only)
alembic init alembic

# Create initial migration
alembic revision --autogenerate -m "Initial migration"

# Apply migrations
alembic upgrade head
```

### 6. Start Backend Server
```bash
uvicorn app.main:app --reload --port 8000
```

Backend will be available at: **http://localhost:8000**

API Docs: **http://localhost:8000/docs**

---

## ⚛️ Frontend Setup

### 1. Install Dependencies
```bash
cd frontend
npm install
```

### 2. Environment Setup
```bash
cp .env.example .env.local
```

```env
NEXT_PUBLIC_API_URL=http://localhost:8000
NEXT_PUBLIC_GOOGLE_MAPS_KEY=your-google-maps-api-key
```

### 3. Start Development Server
```bash
npm run dev
```

Frontend will be available at: **http://localhost:3000**

---

## 📱 Mobile Setup (Optional)

### 1. Install Dependencies
```bash
cd mobile
npm install
```

### 2. Start Expo
```bash
npm start
```

Scan QR code with Expo Go app (iOS/Android)

---

## 🐳 Docker Setup (Alternative)

### Run Everything with Docker Compose
```bash
# From project root
docker-compose up -d
```

Services:
- Backend API: http://localhost:8000
- Frontend: http://localhost:3000
- PostgreSQL: localhost:5432
- Redis: localhost:6379
- Adminer (DB GUI): http://localhost:8080

---

## 🧪 Testing

### Backend Tests
```bash
cd backend
pytest
```

### Frontend Tests
```bash
cd frontend
npm test
```

---

## 📊 Database Migrations

### Create New Migration
```bash
alembic revision --autogenerate -m "Add new feature"
```

### Apply Migrations
```bash
alembic upgrade head
```

### Rollback Migration
```bash
alembic downgrade -1
```

---

## 🔑 Generate Secret Key

```python
import secrets
print(secrets.token_urlsafe(32))
```

Copy output to `.env` as `SECRET_KEY`

---

## 🚀 Deployment

### Backend (DigitalOcean/AWS)
```bash
# Install dependencies
pip install -r requirements.txt

# Set environment variables
export DATABASE_URL=postgresql+asyncpg://...
export SECRET_KEY=...

# Run migrations
alembic upgrade head

# Start with Gunicorn
gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

### Frontend (Vercel)
```bash
npm run build
vercel --prod
```

---

## 🐛 Troubleshooting

### Database Connection Error
```bash
# Check PostgreSQL is running
pg_isready

# Check connection string in .env
echo $DATABASE_URL
```

### Redis Connection Error
```bash
# Start Redis
redis-server

# Or via Homebrew (Mac)
brew services start redis
```

### Port Already in Use
```bash
# Find process using port 8000
lsof -i :8000

# Kill process
kill -9 <PID>
```

---

## 📚 Useful Commands

```bash
# Backend
uvicorn app.main:app --reload  # Dev server
alembic upgrade head            # Run migrations
pytest                          # Run tests

# Frontend
npm run dev                     # Dev server
npm run build                   # Production build
npm run lint                    # Linting

# Database
psql emlak_crm_db               # Connect to DB
pg_dump emlak_crm_db > backup.sql  # Backup
```

---

Need help? Open an issue on GitHub! 🚀
