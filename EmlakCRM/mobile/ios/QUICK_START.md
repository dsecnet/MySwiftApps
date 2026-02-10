# EmlakCRM iOS - Quick Start Guide

## Prerequisites
- macOS with Xcode 15+
- iOS 17+ Simulator or Device
- Backend server running on localhost:8001

## Running the Backend
```bash
cd /Users/vusaldadashov/Desktop/ConsoleApp/EmlakCRM
uvicorn main:app --reload --port 8001
```

## Demo Credentials
- Email: demo@emlakcrm.az
- Password: demo123

## Opening the Project
1. Navigate to: `/Users/vusaldadashov/Desktop/ConsoleApp/EmlakCRM/mobile/ios/`
2. Open `EmlakCRM.xcodeproj` in Xcode
3. Select iPhone 15 simulator
4. Press Cmd+R to build and run

## Testing Features

### Authentication
1. Launch app → Login screen
2. Use demo credentials or register new account
3. ✅ Should load Dashboard

### Dashboard
1. View stats cards
2. Tap Quick Actions:
   - "Əmlak Əlavə Et" → Opens add property form
   - "Müştəri Əlavə Et" → Opens add client form
   - "Fəaliyyət Planla" → Opens add activity form
3. Tap gear icon → Opens Settings

### Properties Tab
1. View properties list with stats
2. Tap filter pills to filter by type
3. Search by name/location
4. **Swipe left on item → Delete**
5. Tap item → View details
6. Tap 3-dot menu → Edit/Delete
7. Tap + button → Add new property

### Clients Tab
1. View clients with gradient avatars
2. Search by name/email/phone
3. **Swipe left → Delete**
4. Tap item → View details
5. Tap 3-dot menu → Edit/Delete
6. Tap + button → Add new client

### Activities Tab
1. Filter by activity type
2. **Swipe left → Delete or Complete**
3. Tap checkmark button → Mark complete
4. Tap item → View details
5. Tap + button → Add new activity

### Deals Tab
1. View deals with status colors
2. Use sort menu (top-left) → Sort by date/price
3. Filter by status
4. **Swipe left → Delete**
5. Tap item → View details
6. Tap + button → Add new deal

### Settings
1. Tap gear icon on Dashboard
2. View profile info
3. Tap sections (not yet implemented)
4. Tap "Çıxış" → Logout with confirmation

## Key UI Features

### Swipe Actions
- **Properties/Clients/Deals**: Swipe left → Red delete button
- **Activities**: Swipe left → Green complete + Red delete

### Pull to Refresh
- Pull down on any list → Refreshes data

### Pagination
- Scroll to bottom → Automatically loads more

### Search
- Use search bar at top
- Filters in real-time

### Filters
- Tap filter pills to toggle
- Multiple filters can be active

## Common Issues

### Backend Not Connected
- Error: "Connection failed"
- Solution: Ensure backend is running on port 8001

### Empty Lists
- If no data appears, backend may not have demo data
- Run backend setup to create demo data

### Build Errors
- Clean build folder: Cmd+Shift+K
- Rebuild: Cmd+B

## File Structure
```
EmlakCRM/
├── Models/              # Data models
├── Services/            # API service
├── ViewModels/          # Business logic
├── Views/
│   ├── Auth/           # Login, Register
│   ├── Dashboard/      # Dashboard
│   ├── Properties/     # Properties module
│   ├── Clients/        # Clients module
│   ├── Activities/     # Activities module
│   ├── Deals/          # Deals module
│   ├── Settings/       # Settings
│   └── Reports/        # Reports
└── Utils/              # Theme, helpers
```

## API Endpoints Used
- Auth: /auth/login, /auth/register, /auth/me
- Properties: /properties (GET, POST, PUT, DELETE)
- Clients: /clients (GET, POST, PUT, DELETE)
- Activities: /activities (GET, POST, PUT, DELETE)
- Deals: /deals (GET, POST, PUT, DELETE)
- Dashboard: /dashboard/stats

## Testing Checklist
- [ ] Login with demo account
- [ ] View dashboard stats
- [ ] Add new property
- [ ] Search properties
- [ ] Filter properties
- [ ] Swipe to delete property
- [ ] Add new client
- [ ] View client details
- [ ] Add new activity
- [ ] Complete activity via swipe
- [ ] Add new deal
- [ ] Sort deals
- [ ] Pull to refresh
- [ ] Logout

## Notes
- All forms have validation
- Delete actions require confirmation (alert)
- Swipe actions are immediate but can be undone
- Backend auto-refreshes tokens

---
Ready to test! 🚀
