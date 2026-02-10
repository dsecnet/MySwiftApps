# 🏢 EmlakCRM iOS App

Modern iOS tətbiqi Azərbaycandakı daşınmaz əmlak agentlikləri üçün - SwiftUI ilə hazırlanıb.

## 📱 Xüsusiyyətlər

### ✅ Core Funksiyalar
- **Authentication** - Login, Register, JWT tokens
- **Dashboard** - Statistika, quick actions, search
- **Properties** - Əmlak idarəetməsi (CRUD)
- **Clients** - Müştəri idarəetməsi (CRUD)
- **Activities** - Fəaliyyət planlaması (CRUD)
- **Deals** - Sövdələşmə idarəetməsi (CRUD)
- **Settings** - Profil və tənzimləmələr
- **Reports** - Analitika və hesabatlar

### 🎯 Advanced Xüsusiyyətlər
- **Universal Search** - Bütün entity-ləri bir yerdə axtar
- **Share** - WhatsApp, SMS, Email ilə paylaş
- **Swipe Actions** - Sürüşdürərək sil/tamamla
- **Filters & Sort** - Qabaqcıl filterləmə
- **Pull-to-Refresh** - Yeniləmək üçün aşağı çək
- **Pagination** - Avtomatik load more
- **Statistics** - Detallı hesablamalar
- **Haptic Feedback** - Touch əks-əlaqəsi

### 🎨 UI/UX
- Modern gradient dizayn
- Soft blue color scheme
- Card-based layouts
- Smooth animations
- Empty states
- Loading indicators
- Error handling

## 🚀 Quraşdırma

### Tələblər
- macOS 14+
- Xcode 15+
- iOS 17+ Simulator/Device
- Backend server (localhost:8001)

### Backend İşə Salma
```bash
cd /Users/vusaldadashov/Desktop/ConsoleApp/EmlakCRM
uvicorn main:app --reload --port 8001
```

### iOS App Açma
1. Xcode-da aç: `EmlakCRM.xcodeproj`
2. iPhone 15 simulator seç
3. `Cmd+R` bas

### Demo Hesab
- Email: `demo@emlakcrm.az`
- Password: `demo123`

## 📂 Struktur

```
EmlakCRM/
├── Models/              # Data models
├── Services/            # API service layer
├── ViewModels/          # MVVM view models
├── Views/
│   ├── Auth/           # Login & Register
│   ├── Dashboard/      # Main dashboard
│   ├── Properties/     # Properties module
│   ├── Clients/        # Clients module
│   ├── Activities/     # Activities module
│   ├── Deals/          # Deals module
│   ├── Settings/       # Settings
│   ├── Reports/        # Analytics
│   └── Search/         # Universal search
└── Utils/
    ├── Theme.swift             # Design system
    ├── Extensions.swift        # Swift extensions
    ├── ShareHelper.swift       # Share functionality
    ├── StatisticsHelper.swift  # Stats calculations
    └── ViewModifiers.swift     # Reusable modifiers
```

## 🎓 Texnologiyalar

- **Framework**: SwiftUI
- **Architecture**: MVVM
- **Networking**: URLSession + async/await
- **Auth**: JWT tokens
- **Backend**: FastAPI REST API
- **Database**: PostgreSQL

## 📖 İstifadə

### Əmlak Əlavə Etmək
1. Dashboard → "Əmlak Əlavə Et"
2. Formu doldur
3. "Əlavə et" düyməsini bas

### Axtarış
1. Dashboard → 🔍 düyməsi
2. Axtarış et
3. Nəticələri filter et

### Paylaşma
1. Property/Client detail-ə gir
2. ⋮ menu → "Paylaş"
3. WhatsApp, SMS, və s.

### Swipe Actions
- **Sol tərəfə sürüşdür** → Sil
- **Activities-də** → Sil və ya Tamamla

## 📊 Statistika

| Metric | Count |
|--------|-------|
| Views | 35+ |
| Swift Files | 35+ |
| Features | 60+ |
| API Endpoints | 35 |
| Helper Classes | 5 |

## ✅ Status

- **CRUD Operations**: ✅ Complete
- **Search**: ✅ Universal search
- **Share**: ✅ All entities
- **Statistics**: ✅ Advanced
- **UI/UX**: ✅ Modern & polished
- **Backend**: ✅ Integrated
- **Ready**: ✅ Production

## 📝 Sənədlər

- `FINAL_STATUS.md` - Tam layihə statusu
- `FEATURES_COMPLETED.md` - Xüsusiyyətlər siyahısı
- `QUICK_START.md` - Test təlimatları
- `CHANGELOG.md` - Yeniləmələr tarixi
- `README.md` - Bu fayl

## 🔧 Tövsiyələr

### Test Etmək
```bash
# Backend işə sal
cd /Users/vusaldadashov/Desktop/ConsoleApp/EmlakCRM
uvicorn main:app --reload --port 8001

# Xcode-da run et
```

### Yeni Xüsusiyyət Əlavə Etmək
1. Model əlavə et `Models.swift`-ə
2. API method əlavə et `APIService.swift`-ə
3. ViewModel yarat
4. Views yarat (List, Detail, Add)
5. Navigation əlavə et

## 🎯 Növbəti Addımlar

### Təkmilləşdirmələr
- [ ] Offline support
- [ ] Push notifications
- [ ] Image upload
- [ ] PDF export
- [ ] Dark mode
- [ ] Calendar sync
- [ ] Map view

## 📞 Dəstək

İstifadə üçün suallarınız varsa:
1. `QUICK_START.md` oxuyun
2. Backend-in işlədiyindən əmin olun
3. Demo hesabla giriş edin

## 📜 License

Private project - EmlakCRM

---

**Versiya**: 1.1  
**Status**: ✅ Production Ready  
**Dil**: Azərbaycan  
**Platform**: iOS 17+  

🎉 **Hazırdır və istifadəyə yararlıdır!**
