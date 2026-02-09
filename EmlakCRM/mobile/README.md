# Əmlak CRM - iOS App

Native iOS app for Əmlak CRM built with SwiftUI.

## 📱 Features

### ✅ Implemented:
- **Authentication** - Login & Register
- **Dashboard** - Complete statistics overview
- **API Integration** - Full backend connection
- **Theme System** - Custom colors & typography

### 📊 Dashboard Stats:
- Properties, Clients, Activities, Deals overview
- Revenue & Commission tracking
- Recent activities feed
- Today's schedule & overdue items

## 🛠 Tech Stack

- **SwiftUI** - Modern declarative UI
- **Async/Await** - Modern concurrency
- **Combine** - Reactive programming
- **URLSession** - Networking
- **UserDefaults** - Token storage

## 📁 Project Structure

```
EmlakCRM/
├── Models/          # Data models
├── Views/           # SwiftUI views
│   ├── Auth/        # Login, Register
│   └── Dashboard/   # Main dashboard
├── ViewModels/      # Business logic
├── Services/        # API service layer
└── Utils/           # Theme, extensions
```

## 🚀 Getting Started

### Prerequisites:
- Xcode 15+
- iOS 17+
- Backend running on http://localhost:8001

### Setup:

1. **Open in Xcode:**
   ```bash
   cd mobile
   open EmlakCRM.xcodeproj
   ```

2. **Update API URL:**
   Edit `Services/APIService.swift`:
   ```swift
   private let baseURL = "http://YOUR_IP:8001/api/v1"
   ```

3. **Run:**
   - Select target device/simulator
   - Press ⌘R to run

## 📝 Usage

### Login:
- Email: `agent@emlak.az`
- Password: `Test123456`

### Dashboard Features:
- View total properties, clients, activities
- Track revenue & commission
- See recent activities
- Monitor today's schedule

## 🔄 API Endpoints Used

- `POST /auth/login` - Authentication
- `POST /auth/register` - New user
- `GET /auth/me` - Current user
- `GET /dashboard/` - Dashboard stats
- `GET /properties/` - Properties list
- `GET /clients/` - Clients list
- `GET /activities/upcoming` - Upcoming activities
- `GET /deals/with-details` - Deals with details

## 🎨 Design

- **Primary Color:** #2563EB (Blue)
- **Secondary Color:** #10B981 (Green)
- **Card-based UI** with shadows
- **Clean typography** with SF Pro
- **Light mode** optimized

## 📦 Next Steps

### To Implement:
- [ ] Properties List & Detail
- [ ] Clients List & Detail
- [ ] Activities Calendar
- [ ] Deals Management
- [ ] Add Property (Camera, Location)
- [ ] Add Client
- [ ] Push Notifications
- [ ] Offline Mode

### Future:
- [ ] Dark Mode
- [ ] iPad Support
- [ ] Apple Watch Companion
- [ ] Widgets
- [ ] Siri Shortcuts

## 🐛 Known Issues

- API URL hardcoded (need to change for real device)
- No image upload yet
- No offline caching
- Token refresh needs improvement

## 📄 License

Private project - Əmlak CRM for Azerbaijan Real Estate Agents

---

Made with ❤️ in SwiftUI
