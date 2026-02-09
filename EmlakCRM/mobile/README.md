# Əmlak CRM - iOS App

Native iOS app for Əmlak CRM built with SwiftUI.

## 📱 Features

### ✅ Implemented:
- **Authentication** - Login & Register
- **Dashboard** - Complete statistics overview
- **Properties** - List, Detail & Add Property
- **Clients** - List, Detail & Add Client
- **Tab Navigation** - Easy navigation between sections
- **API Integration** - Full backend connection
- **Theme System** - Custom colors & typography
- **Search** - Search properties and clients
- **Pull to Refresh** - Refresh data with pull gesture
- **Infinite Scroll** - Load more items automatically

### 📊 Features by Section:

**Dashboard:**
- Properties, Clients, Activities, Deals overview
- Revenue & Commission tracking
- Recent activities feed
- Today's schedule & overdue items

**Properties:**
- List all properties with search
- Property details with full information
- Add new property with form validation
- Filter by type, status, listing type
- Infinite scroll pagination

**Clients:**
- List all clients with search
- Client details with contact info
- Add new client with type selection
- Activity timeline for each client
- Quick call/email actions

## 🛠 Tech Stack

- **SwiftUI** - Modern declarative UI
- **Async/Await** - Modern concurrency
- **Combine** - Reactive programming
- **URLSession** - Networking
- **UserDefaults** - Token storage

## 📁 Project Structure

```
EmlakCRM/
├── Models/              # Data models (Auth, Property, Client, etc.)
├── Views/               # SwiftUI views
│   ├── Auth/            # Login, Register
│   ├── Dashboard/       # Main dashboard with stats
│   ├── Properties/      # List, Detail, Add Property
│   ├── Clients/         # List, Detail, Add Client
│   └── MainTabView.swift # Tab navigation
├── ViewModels/          # Business logic & state management
├── Services/            # API service layer with auto-refresh
└── Utils/               # Theme, extensions, helpers
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

### App Features:
- **Dashboard:** View stats, revenue, and recent activities
- **Properties:** Browse, search, and add properties
- **Clients:** Manage clients with full contact details
- **Search:** Quick search across properties and clients
- **Navigation:** Easy tab-based navigation
- **Forms:** Smart forms with validation

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
- [ ] Activities Calendar & Management
- [ ] Deals Management & Pipeline
- [ ] Property Image Upload (Camera, Gallery)
- [ ] Location Picker & Map View
- [ ] Edit Property & Client
- [ ] Delete with confirmation
- [ ] Push Notifications
- [ ] Offline Mode & Caching
- [ ] Filters & Advanced Search

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
