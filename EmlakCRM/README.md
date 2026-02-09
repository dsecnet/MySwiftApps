# 🏠 Əmlak CRM - Real Estate Management System

## Azərbaycan Əmlakçıları üçün CRM Sistemi

### Features:
- 🏘️ Əmlak portfeli idarəetməsi
- 👥 Müştəri CRM
- 📅 Görüş planlaması
- 💬 WhatsApp inteqrasiyası
- 📊 Satış analitikası
- 🔗 bina.az, tap.az parser

### Tech Stack:
- **Backend**: FastAPI (Python 3.12+)
- **Database**: PostgreSQL + Redis
- **Frontend**: Next.js 14 + TypeScript
- **Mobile**: React Native (iOS/Android)

---

## 🚀 Quick Start

### Backend Setup
```bash
cd backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # Mac/Linux
# or: venv\Scripts\activate  # Windows

# Install dependencies
pip install -r requirements.txt

# Create database
createdb emlak_crm_db

# Setup environment
cp .env.example .env
# Edit .env with your credentials

# Run migrations
alembic upgrade head

# Start server
uvicorn app.main:app --reload --port 8000
```

**Backend API:** http://localhost:8000
**API Docs:** http://localhost:8000/docs

### Test Authentication
```bash
cd backend
chmod +x test_auth.sh
./test_auth.sh
```

---

## 📡 API Endpoints

### 🔐 Authentication
- `POST /api/v1/auth/register` - Yeni agent qeydiyyatı
- `POST /api/v1/auth/login` - Login
- `POST /api/v1/auth/refresh` - Refresh token
- `GET /api/v1/auth/me` - Current user info
- `GET /api/v1/auth/health` - Health check

### 🏘️ Properties (Coming Soon)
- `GET /api/v1/properties` - List properties
- `POST /api/v1/properties` - Create property
- `GET /api/v1/properties/{id}` - Get property
- `PUT /api/v1/properties/{id}` - Update property
- `DELETE /api/v1/properties/{id}` - Delete property

### 👥 Clients (Coming Soon)
- `GET /api/v1/clients` - List clients
- `POST /api/v1/clients` - Create client
- `GET /api/v1/clients/{id}` - Get client

### 📅 Activities (Coming Soon)
- `GET /api/v1/activities` - List activities
- `POST /api/v1/activities` - Create activity

---

## 💳 Subscription Plans

| Plan | Price/Month | Properties | Clients | Features |
|------|-------------|------------|---------|----------|
| **Free** | 0 AZN | 10 | 50 | Basic CRM |
| **Basic** | 79 AZN | 100 | 500 | + WhatsApp, Analytics |
| **Premium** | 149 AZN | Unlimited | Unlimited | + Parser, API, Team |

---

## 📊 Development Progress

- ✅ **Database Models** (User, Property, Client, Activity, Deal)
- ✅ **Auth System** (Register, Login, JWT)
- ✅ **Project Documentation**
- 🚧 **Properties API** (Next)
- 🚧 **Clients API** (Next)
- 🚧 **Activities API** (Next)
- 🚧 **Frontend** (Next)

---

## 📚 Documentation

- [Project Plan](docs/PROJECT_PLAN.md) - MVP features, timeline, revenue model
- [Setup Guide](docs/SETUP.md) - Installation & deployment
- [GitHub Setup](GITHUB_SETUP.md) - How to push to GitHub

---

## 🤝 Contributing

This is a private project for Azerbaijan real estate market. Contact owner for collaboration.

---

Made with ❤️ for Azerbaijan Real Estate Agents
