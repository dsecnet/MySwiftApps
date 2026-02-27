# CoreVia - Business Analysis Document
## iOS → Android Migration Blueprint

**Tarix:** 2026-02-24
**Versiya:** 1.0
**Məqsəd:** iOS (SwiftUI) appinin 1:1 Android (Kotlin + Jetpack Compose) versiyasını yaratmaq

---

## 1. ÜMUMI MƏLUMAT

| Parametr | Dəyər |
|----------|-------|
| **App Adı** | CoreVia |
| **Platforma** | iOS (mövcud) → Android (yaradılacaq) |
| **Backend** | FastAPI (Python) - Hetzner Server |
| **API Base URL** | `https://api.corevia.life` |
| **Direct IP** | `http://89.167.53.205` |
| **Database** | PostgreSQL (corevia_db) |
| **iOS Fayl Sayı** | 111 Swift fayl |
| **Dillər** | Azərbaycan 🇦🇿, İngilis 🇬🇧, Rus 🇷🇺 |
| **User Types** | Client (Tələbə), Trainer (Müəllim) |
| **Package Name** | `life.corevia.app` |

---

## 2. TEXNOLOGİYA STACK-İ

### iOS (Mövcud)
| Texnologiya | Məqsəd |
|-------------|--------|
| SwiftUI | UI Framework |
| MVVM + Manager | Arxitektura |
| async/await | Asinxron əməliyyatlar |
| CoreML (YOLO v8 + EfficientNet) | AI Food Detection |
| Keychain | Token saxlama |
| NavigationStack | Naviqasiya |
| StoreKit | In-App Purchase |
| URLSession | Networking |

### Android (Yaradılacaq)
| Texnologiya | Məqsəd |
|-------------|--------|
| Kotlin | Proqramlaşdırma dili |
| Jetpack Compose | UI Framework |
| MVVM + Repository | Arxitektura |
| Kotlin Coroutines + Flow | Asinxron əməliyyatlar |
| TensorFlow Lite | AI Food Detection |
| EncryptedSharedPreferences | Token saxlama |
| Navigation Compose | Naviqasiya |
| Google Play Billing | In-App Purchase |
| Retrofit + OkHttp | Networking |
| Hilt | Dependency Injection |
| Coil | Şəkil yükləmə |
| CameraX | Kamera |
| kotlinx.serialization | JSON parsing |

---

## 3. NAVİQASİYA STRUKTURU

### 3.1 Client (Tələbə) - 6 Tab

```
┌─────────────────────────────────────────────────────┐
│  Tab 1: 🏠 Home (Ana Səhifə)                       │
│  Tab 2: 💪 Workouts (Məşqlər)                      │
│  Tab 3: 🍎 Food (Qidalanma / AI Kalori)            │
│  Tab 4: 💬 Chat (Mesajlar)                          │
│  Tab 5: 📊 Analytics (Statistika)                   │
│  Tab 6: 👤 Profile (Profil)                         │
└─────────────────────────────────────────────────────┘
```

### 3.2 Trainer (Müəllim) - 6 Tab

```
┌─────────────────────────────────────────────────────┐
│  Tab 1: 🏠 Trainer Home (Trainer Dashboard)         │
│  Tab 2: 📋 Training Plans (Məşq Planları)           │
│  Tab 3: 🍽️ Meal Plans (Qidalanma Planları)         │
│  Tab 4: 💬 Chat (Mesajlar)                          │
│  Tab 5: 🏪 Trainer Hub (Məhsul/Session İdarə)      │
│  Tab 6: 👤 Profile (Profil)                         │
└─────────────────────────────────────────────────────┘
```

### 3.3 Ortaq Ekranlar (Hər iki tip üçün)

```
- Login / Register / Forgot Password / OTP
- Onboarding (yalnız Client üçün)
- Marketplace (Browse Products)
- Live Sessions (Browse/Join)
- Social Feed
- Daily Survey
- Settings
- Premium
- Trainer Browse (yalnız Client)
```

---

## 4. EKRANLAR - TAM SİYAHI

### 4.1 AUTH EKRANLARI

#### Screen 1: LoginView → LoginScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `LoginView.swift` |
| **Android Fayl** | `ui/auth/LoginScreen.kt` |
| **Status** | ✅ HAZIR (artıq yazılıb) |

**Elementlər:**
- Dil seçici (AZ 🇦🇿 / EN 🇬🇧 / RU 🇷🇺)
- CoreVia logo (glow effekti ilə)
- User type seçimi (Client / Trainer)
- Email input field
- Password input field (göz ikonu ilə göstər/gizlə)
- "Şifrəni unutdum?" linki
- Login düyməsi (gradient)
- "Hesabın yoxdur? Qeydiyyat" linki
- OTP verification step (6 rəqəmli kod)
- 60 saniyə geri sayım (resend üçün)

**API:**
- `POST /api/v1/auth/login` → `AuthResponse`

---

#### Screen 2: RegisterView → RegisterScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `RegisterView.swift` |
| **Android Fayl** | `ui/auth/RegisterScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- User type seçimi (Client / Trainer)
- Ad input field
- Email input field
- Şifrə input field
- Şifrə təsdiq input field
- Qeydiyyat düyməsi
- "Hesabın var? Giriş" linki

**API:**
- `POST /api/v1/auth/register` → `UserResponse`
- Request: `{ name, email, password, userType }`

---

#### Screen 3: ForgotPasswordView → ForgotPasswordScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `ForgotPasswordView.swift` |
| **Android Fayl** | `ui/auth/ForgotPasswordScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Step 1: Email daxil et → OTP göndər
- Step 2: OTP kodu daxil et (6 rəqəm)
- Step 3: Yeni şifrə daxil et + təsdiqlə
- 60 saniyə geri sayım (resend üçün)

**API:**
- `POST /api/v1/auth/forgot-password` → `OTPResponse`
- `POST /api/v1/auth/reset-password` → `ResetPasswordResponse`
- Request: `{ email, otp_code, new_password }`

---

### 4.2 ONBOARDING EKRANLARI

#### Screen 4: OnboardingView → OnboardingScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `OnboardingView.swift` |
| **Android Fayl** | `ui/onboarding/OnboardingScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Yalnız Client üçün! Trainer skip edir.**

**4 Step:**
1. **Fitness Goal seçimi** - Backend-dən gələn optionlar
2. **Fitness Level seçimi** - Backend-dən gələn optionlar
3. **Bədən məlumatları** - Yaş, Çəki (kg), Boy (cm)
4. **Trainer tipi seçimi** - İstəyə bağlı (optional)

**API:**
- `GET /api/v1/onboarding/options` → Goals, Levels, Trainer Types
- `POST /api/v1/onboarding/complete` → `OnboardingStatusResponse`
- `GET /api/v1/onboarding/status` → Tamamlanıb/tamamlanmayıb

---

### 4.3 CLIENT HOME

#### Screen 5: HomeView → HomeScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `HomeView.swift` |
| **Android Fayl** | `ui/home/HomeScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Salamlama başlığı ("Salam, {ad}!")
- Gündəlik statistika kartları:
  - Məşq vaxtı (dəqiqə)
  - Yandırılan kalori
- Daily Survey prompt (doldurulmayıbsa)
- Gündəlik hədəf progress bar
- Bugünkü məşqlər preview (top 2)
- AI Recommendation bölməsi
- Ümumi statistikaya keçid
- Pull-to-refresh

**API:**
- `GET /api/v1/workouts/` → Bugünkü məşqlər
- `GET /api/v1/ai/recommendations` → Tövsiyələr
- `GET /api/v1/survey/daily/today` → Survey status

---

### 4.4 TRAINER HOME

#### Screen 6: TrainerHomeView → TrainerHomeScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `TrainerHomeView.swift` |
| **Android Fayl** | `ui/home/TrainerHomeScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Profil şəkli ilə header
- 2x2 Statistika grid:
  - Toplam abunəçi sayı
  - Aktiv tələbə sayı
  - Aylıq gəlir
  - Toplam plan sayı
- Tələbə proqresi bölməsi
- Quick action düymələri
- Pull-to-refresh

**API:**
- `GET /api/v1/trainer/stats` → Trainer statistikaları

---

### 4.5 WORKOUT EKRANLARI (Client)

#### Screen 7: WorkoutView → WorkoutScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `WorkoutView.swift` |
| **Android Fayl** | `ui/workout/WorkoutScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Məşq siyahısı (LazyColumn)
- Kateqoriya filtri (strength, cardio, flexibility, endurance)
- Tarix filtri
- Hər məşq kartında:
  - Başlıq, kateqoriya
  - Müddət, kalori
  - Tamamlanma statusu
  - Silmə/redaktə
- FloatingActionButton → AddWorkout
- Pull-to-refresh

**API:**
- `GET /api/v1/workouts/` → `[Workout]`
- `DELETE /api/v1/workouts/{id}`
- `PATCH /api/v1/workouts/{id}/toggle`

---

#### Screen 8: AddWorkoutView → AddWorkoutScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `AddWorkoutView.swift` |
| **Android Fayl** | `ui/workout/AddWorkoutScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Başlıq input
- Kateqoriya seçici (strength, cardio, flexibility, endurance)
- Müddət (dəqiqə) input
- Kalori (optional) input
- Qeydlər (optional) input
- Tarix seçici (DatePicker)
- Saxla düyməsi

**API:**
- `POST /api/v1/workouts/` → `Workout`
- Request: `{ title, category, duration, caloriesBurned?, notes?, date? }`

---

### 4.6 FOOD / AI KALORİ EKRANLARI

#### Screen 9: EatingView → FoodScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `EatingView.swift` |
| **Android Fayl** | `ui/food/FoodScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Qida girişləri siyahısı
- Gündəlik nutrition xülasəsi (kalori, protein, karbohidrat, yağ)
- Yemək tipi filtri (breakfast, lunch, dinner, snack)
- Hər giriş kartında:
  - Adı, kalori
  - Makro dəyərlər
  - Yemək tipi
  - Silmə/redaktə
- FloatingActionButton → AddFood
- AI Kalori düyməsi (kamera)

**API:**
- `GET /api/v1/food/` → `[FoodEntry]`
- `DELETE /api/v1/food/{id}`

---

#### Screen 10: AddFoodView → AddFoodScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `AddFoodView.swift` |
| **Android Fayl** | `ui/food/AddFoodScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Kamera / Qalereyadan şəkil seç
- Şəkil preview
- AI analiz düyməsi
- Manuel giriş:
  - Adı input
  - Kalori input
  - Protein input (optional)
  - Karbohidrat input (optional)
  - Yağ input (optional)
  - Yemək tipi seçici
  - Qeydlər (optional)
- Saxla düyməsi

**API:**
- `POST /api/v1/food/` → `FoodEntry`
- `POST /api/v1/food/{id}/image` → Şəkil upload
- `POST /api/v1/food/analyze` → AI analiz (multipart)

---

#### Screen 11: AICalorieAnalysisView → AICalorieResultScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `AICalorieAnalysisView.swift` |
| **Android Fayl** | `ui/food/AICalorieResultScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Aşkar edilmiş yeməklər siyahısı
- Hər yemək üçün:
  - Adı
  - Kalori
  - Protein, karbohidrat, yağ
  - Porsiya ölçüsü
  - Confidence score (%)
- Toplam nutrition xülasəsi
- Porsiyaları redaktə et
- Food log-a saxla düyməsi

**ML Pipeline (On-Device):**
1. Kameradan şəkil al
2. YOLO v8 → Yemək obyektlərini aşkar et
3. EfficientNet → Hər yeməyi təsnifləşdir
4. USDA Database → Qida dəyərlərini tap
5. Nəticəni göstər

**Android üçün:** TensorFlow Lite (YOLO v8 + EfficientNet .tflite modelləri)

---

#### Screen 12: AICalorieHistoryView → AICalorieHistoryScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `AICalorieHistoryView.swift` |
| **Android Fayl** | `ui/food/AICalorieHistoryScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Analiz tarixçəsi siyahısı
- Hər giriş: tarix, kalori, yemək sayı
- Gündəlik toplamlar
- Pagination

**API:**
- `GET /api/v1/food?page=1&page_size=20` → `CalorieHistoryResponse`

---

### 4.7 CHAT EKRANLARI

#### Screen 13: ConversationsView → ConversationsScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `ChatView.swift` (conversations part) |
| **Android Fayl** | `ui/chat/ConversationsScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Söhbət siyahısı
- Trainer bölməsi (əgər təyin olunubsa)
- Hər söhbətdə:
  - Profil şəkli
  - İstifadəçi adı
  - Son mesaj preview
  - Vaxt
  - Oxunmamış sayı badge
- Pull-to-refresh

**Giriş Nəzarəti:**
- Client: Premium lazımdır (gündəlik mesaj limiti)
- Trainer: Pulsuz (limitsiz)
- Free client: "Premium al" mesajı

**API:**
- `GET /api/v1/chat/conversations` → `[ChatConversation]`
- `GET /api/v1/chat/limit` → `MessageLimitResponse`

---

#### Screen 14: ChatDetailView → ChatDetailScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `ChatView.swift` (detail part) |
| **Android Fayl** | `ui/chat/ChatDetailScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Mesaj tarixçəsi (LazyColumn, reverse)
- Göndərən/alan mesaj bubble-ları
- Mesaj input field
- Göndər düyməsi
- Oxunma indikatoru

**API:**
- `GET /api/v1/chat/history/{userId}` → `[ChatMessageResponse]`
- `POST /api/v1/chat/send` → `ChatMessageResponse`
- Request: `{ receiverId, message }`

---

### 4.8 TRAINER BROWSE (Client üçün)

#### Screen 15: TrainerBrowsingView → TrainerBrowseScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `Teachers.swift` |
| **Android Fayl** | `ui/trainers/TrainerBrowseScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Axtarış field (ad ilə)
- Kateqoriya/ixtisas filtri
- Rating filtri
- Qiymət aralığı filtri
- Trainer kartları:
  - Profil şəkli
  - Ad
  - İxtisaslar
  - Təcrübə
  - Rating (ulduzlar)
  - Qiymət/session
  - Bio
- Trainer profile detail
- Mesaj göndər düyməsi
- Abunə ol düyməsi

**API:**
- `GET /api/v1/users/trainers` → `[TrainerResponse]`
- `POST /api/v1/users/assign-trainer/{trainerId}`
- `DELETE /api/v1/users/unassign-trainer`

---

### 4.9 TRAİNİNG PLAN EKRANLARI (Trainer)

#### Screen 16: TrainingPlanView → TrainingPlanScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `TrainingPlanView.swift` |
| **Android Fayl** | `ui/plans/TrainingPlanScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Plan siyahısı
- Tələbəyə görə filtr
- Plan tipinə görə filtr
- Hər plan kartında:
  - Başlıq, tip
  - Təyin olunmuş tələbə
  - Tamamlanma statusu
  - Silmə/redaktə
- FAB → AddTrainingPlan

**API:**
- `GET /api/v1/plans/training` → `[TrainingPlan]`
- `DELETE /api/v1/plans/training/{id}`

---

#### Screen 17: AddTrainingPlanView → AddTrainingPlanScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `AddTrainingPlanView.swift` |
| **Android Fayl** | `ui/plans/AddTrainingPlanScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Plan başlığı input
- Plan tipi seçici (weight_loss, weight_gain, strength_training)
- Exercises əlavə et:
  - Hərəkət adı
  - Set sayı
  - Təkrar sayı
  - Müddət
- Tələbə seçici (assign)
- Qeydlər
- Saxla düyməsi

**API:**
- `POST /api/v1/plans/training` → `TrainingPlan`
- Request: `{ title, planType, notes?, assignedStudentId?, workouts: [...] }`

---

### 4.10 MEAL PLAN EKRANLARI (Trainer)

#### Screen 18: MealPlanView → MealPlanScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `MealPlanView.swift` |
| **Android Fayl** | `ui/plans/MealPlanScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Plan siyahısı
- Tələbəyə görə filtr
- Hər plan kartında:
  - Başlıq
  - Gündəlik kalori hədəfi
  - Təyin olunmuş tələbə
  - Silmə/redaktə
- FAB → AddMealPlan

**API:**
- `GET /api/v1/plans/meal` → `[MealPlan]`
- `DELETE /api/v1/plans/meal/{id}`

---

#### Screen 19: AddMealPlanView → AddMealPlanScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `AddMealPlanView.swift` |
| **Android Fayl** | `ui/plans/AddMealPlanScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Plan başlığı input
- Gündəlik kalori hədəfi input
- Yemək əlavə et:
  - Adı
  - Kalori
  - Protein, karb, yağ
  - Yemək tipi (breakfast, lunch, dinner, snack)
- Tələbə seçici
- Qeydlər
- Saxla düyməsi

**API:**
- `POST /api/v1/plans/meal` → `MealPlan`
- Request: `{ title, planType, dailyCalorieTarget, notes?, assignedStudentId?, items: [...] }`

---

### 4.11 MARKETPLACE EKRANLARI

#### Screen 20: MarketplaceView → MarketplaceScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `MarketplaceView.swift` |
| **Android Fayl** | `ui/marketplace/MarketplaceScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Məhsul tipi filtri:
  - Hamısı
  - Workout Plan
  - Meal Plan
  - Training Program
  - E-book
  - Video Course
- Məhsul kartları:
  - Cover şəkli
  - Başlıq
  - Qiymət
  - Rating (ulduzlar)
  - Satıcı məlumatı
- Pagination
- Pull-to-refresh

**API:**
- `GET /api/v1/marketplace/products?page=1&page_size=20&product_type=all`

---

#### Screen 21: ProductDetailView → ProductDetailScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `ProductDetailView.swift` |
| **Android Fayl** | `ui/marketplace/ProductDetailScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Cover şəkli (tam genişlik)
- Başlıq, təsvir
- Qiymət
- Satıcı info (şəkil, ad)
- Orta rating
- Reviews siyahısı
- "Rəy yaz" düyməsi
- "Satın al" düyməsi

**API:**
- `GET /api/v1/marketplace/products/{id}` → `MarketplaceProduct`
- `GET /api/v1/marketplace/products/{id}/reviews` → `[ProductReview]`
- `POST /api/v1/marketplace/purchase` → `ProductPurchase`

---

#### Screen 22: WriteReviewView → WriteReviewScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `WriteReviewView.swift` |
| **Android Fayl** | `ui/marketplace/WriteReviewScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Ulduz rating seçimi (1-5)
- Şərh text area
- Saxla düyməsi

**API:**
- `POST /api/v1/marketplace/reviews`
- Request: `{ productId, rating, comment }`

---

### 4.12 TRAINER HUB EKRANLARI (Trainer)

#### Screen 23: TrainerHubView → TrainerHubScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `TrainerHubView.swift` |
| **Android Fayl** | `ui/trainerhub/TrainerHubScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Quick stats
- Alt bölmələrə naviqasiya:
  - Məhsullarım
  - Live Sessionlarım
  - Satışlar
- Quick action düymələri

---

#### Screen 24: TrainerMarketplaceView → TrainerProductsScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `TrainerMarketplaceView.swift` |
| **Android Fayl** | `ui/trainerhub/TrainerProductsScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Trainer-in öz məhsulları siyahısı
- Tipə görə filtr
- Hər məhsul: başlıq, qiymət, rating, satış
- Yeni məhsul yarat düyməsi
- Silmə/redaktə

---

#### Screen 25: CreateProductView → CreateProductScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `CreateProductView.swift` |
| **Android Fayl** | `ui/trainerhub/CreateProductScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Məhsul tipi seçici
- Başlıq input
- Təsvir input
- Qiymət input
- Cover şəkli upload
- Published toggle
- Saxla düyməsi

**API:**
- `POST /api/v1/marketplace/products` → `MarketplaceProduct`

---

#### Screen 26: TrainerSessionsView → TrainerSessionsScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `TrainerSessionsView.swift` |
| **Android Fayl** | `ui/trainerhub/TrainerSessionsScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Trainer-in sessionları siyahısı
- Statusa görə filtr (scheduled, live, completed, cancelled)
- Hər session: başlıq, tarix, iştirakçı sayı
- Yeni session yarat
- Silmə/redaktə

---

#### Screen 27: CreateLiveSessionView → CreateLiveSessionScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `CreateLiveSessionView.swift` |
| **Android Fayl** | `ui/trainerhub/CreateLiveSessionScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Başlıq input
- Təsvir input
- Session tipi seçici (group, one_on_one, open)
- Max iştirakçı sayı
- Çətinlik səviyyəsi
- Müddət (dəqiqə)
- Tarix/vaxt seçici (DateTimePicker)
- Public/Private toggle
- Ödənişli/Pulsuz toggle
- Qiymət (ödənişli olarsa)
- Exercises əlavə et
- Saxla düyməsi

**API:**
- `POST /api/v1/live-sessions` → `LiveSession`

---

### 4.13 LIVE SESSION EKRANLARI

#### Screen 28: LiveSessionListView → LiveSessionListScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `LiveSessionListView.swift` |
| **Android Fayl** | `ui/livesession/LiveSessionListScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Session siyahısı
- Çətinlik filtri
- Session tipi filtri
- Session kartları:
  - Başlıq
  - Trainer info
  - Qiymət
  - İştirakçı sayı / Max
  - Tarix/vaxt
  - Qeydiyyat düyməsi
- Pagination

**API:**
- `GET /api/v1/live-sessions?page=1&page_size=20`

---

#### Screen 29: LiveSessionDetailView → LiveSessionDetailScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `LiveSessionDetailView.swift` |
| **Android Fayl** | `ui/livesession/LiveSessionDetailScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Başlıq, təsvir
- Trainer info
- Cədvəl vaxtı
- Çətinlik
- Max iştirakçı / Qeydiyyatlı sayı
- Workout planı preview
- Qeydiyyat / Qoşul düyməsi
- İştirakçılar siyahısı
- Rating (tamamlandıqdan sonra)

**API:**
- `GET /api/v1/live-sessions/{id}` → `LiveSession`
- `POST /api/v1/live-sessions/{id}/join`
- `GET /api/v1/live-sessions/{id}/participants`

---

#### Screen 30: LiveWorkoutView → LiveWorkoutScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `LiveWorkoutView.swift` |
| **Android Fayl** | `ui/livesession/LiveWorkoutScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Canlı geri sayım
- Cari hərəkət göstəricisi
- Kamera ilə poza aşkarlama feedback
- Real-time iştirakçı siyahısı
- Performans metrikləri
- Trainer ilə chat
- Session taymer

**WebSocket:** `wss://api.corevia.life/api/v1/live-sessions/ws/{sessionId}?token={accessToken}`

**Messages (Göndərilən):**
- `form_update` - Poza yeniləmə
- `exercise_complete` - Hərəkət tamamlandı
- `heartbeat` - Bağlantı yoxlaması

**Messages (Alınan):**
- `session_start` - Session başladı
- `session_end` - Session bitdi
- `form_correction` - Forma düzəlişi
- `participant_joined` - Yeni iştirakçı
- `exercise_start` - Hərəkət başladı

---

### 4.14 SOCIAL EKRANLARI

#### Screen 31: SocialFeedView → SocialFeedScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `SocialFeedView.swift` |
| **Android Fayl** | `ui/social/SocialFeedScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Post siyahısı (feed)
- Hər postda:
  - Müəllif info (şəkil, ad)
  - Mətn/təsvir
  - Şəkil (əgər varsa)
  - Like sayı, şərh sayı
  - Like düyməsi (❤️)
  - Şərh düyməsi (💬)
  - Post tipi badge
- FAB → CreatePost
- Pagination
- Pull-to-refresh

**API:**
- `GET /api/v1/social/feed?page=1&page_size=20` → `FeedResponse`
- `POST /api/v1/social/posts/{id}/like` (Like)
- `DELETE /api/v1/social/posts/{id}/like` (Unlike)

---

#### Screen 32: CreatePostView → CreatePostScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `CreatePostView.swift` |
| **Android Fayl** | `ui/social/CreatePostScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Post tipi seçici (workout, meal, progress, achievement, general)
- Mətn input
- Şəkil əlavə et (optional)
- Workout/meal bağla (optional)
- Public/Private toggle
- Paylaş düyməsi

**API:**
- `POST /api/v1/social/posts` → `SocialPost`
- `POST /api/v1/social/posts/{id}/image` → Şəkil upload

---

#### Screen 33: CommentsView → CommentsScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `CommentsView.swift` |
| **Android Fayl** | `ui/social/CommentsScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Şərhlərin siyahısı
- Hər şərh: müəllif, mətn, vaxt
- Şərh input field
- Göndər düyməsi

**API:**
- `GET /api/v1/social/posts/{id}/comments` → `[PostComment]`
- `POST /api/v1/social/posts/{id}/comments`
- Request: `{ content }`

---

### 4.15 DAILY SURVEY

#### Screen 34: DailySurveyView → DailySurveyScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `DailySurveyView.swift` |
| **Android Fayl** | `ui/survey/DailySurveyScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Enerji səviyyəsi (1-5 slider)
- Yuxu saatı (0-24 slider)
- Yuxu keyfiyyəti (1-5 slider)
- Stress səviyyəsi (1-5 slider)
- Əzələ ağrısı (1-5 slider)
- Əhval (1-5 slider)
- Su stəkanları (0-30)
- Qeydlər (optional)
- Təsdiqlə düyməsi

**Suallar backend-dən gəlir (multi-language)**

**API:**
- `GET /api/v1/survey/questions?lang=az` → Suallar
- `POST /api/v1/survey/daily` → `DailySurveyResponse`
- `GET /api/v1/survey/daily/today` → Status (doldurulub/doldurulmayıb)
- Request: `{ energyLevel, sleepHours, sleepQuality, stressLevel, muscleSoreness, mood, waterGlasses, notes? }`

---

### 4.16 ANALYTICS EKRANLARI

#### Screen 35: AnalyticsDashboardView → AnalyticsDashboardScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `AnalyticsDashboardView.swift` |
| **Android Fayl** | `ui/analytics/AnalyticsDashboardScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Cari həftə statistikası
- Çəki trendi çart (line chart)
- Məşq trendi çart
- Qidalanma trendi çart
- Workout streak sayğacı
- 30 günlük toplamlar:
  - Toplam məşq
  - Toplam dəqiqə
  - Toplam yandırılan kalori
  - Orta gündəlik kalori

**API:**
- `GET /api/v1/analytics/dashboard` → `AnalyticsDashboardResponse`

---

#### Screen 36: OverallStatisticsView → OverallStatsScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | (HomeView daxilindən keçid) |
| **Android Fayl** | `ui/analytics/OverallStatsScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Toplam məşq sayı
- Toplam dəqiqə
- Toplam yandırılan kalori
- Orta gündəlik kalori
- Consistency faizi (%)

---

### 4.17 PROFİL EKRANLARI

#### Screen 37: ProfileViewDynamic → ProfileScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `ProfileViewDynamic.swift` |
| **Android Fayl** | `ui/profile/ProfileScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- User type-a görə fərqli content göstər
- Profil şəkli
- İstifadəçi statistikaları
- Edit düyməsi
- Settings düyməsi
- Logout düyməsi

**Client profil:**
- Ad, email, yaş, çəki, boy, hədəf

**Trainer profil:**
- Ad, email, ixtisas, təcrübə, bio, qiymət/session
- Verification status
- Instagram handle

**API:**
- `GET /api/v1/auth/me` → `UserResponse`

---

#### Screen 38: EditProfileView → EditProfileScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `EditProfileViews.swift` |
| **Android Fayl** | `ui/profile/EditProfileScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Client input-ları:**
- Ad, yaş, çəki, boy, hədəf
- Profil şəkli upload

**Trainer input-ları:**
- Ad, ixtisas, təcrübə, bio, qiymət/session
- Profil şəkli upload

**API:**
- `PUT /api/v1/users/profile` → `UserResponse`
- `POST /api/v1/uploads/profile-image` → Şəkil upload

---

### 4.18 SETTINGS

#### Screen 39: SettingsView → SettingsScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `SettingsView.swift` |
| **Android Fayl** | `ui/settings/SettingsScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Dil seçici (AZ, EN, RU)
- Tema (Light / Dark)
- Bildiriş ayarları
- Gizlilik ayarları
- Hesabı sil düyməsi (təsdiq dialog ilə)
- Çıxış düyməsi

**API:**
- `DELETE /api/v1/auth/delete-account`
- Request: `{ password }`

---

### 4.19 PREMIUM

#### Screen 40: PremiumView → PremiumScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `PremiumView.swift` |
| **Android Fayl** | `ui/premium/PremiumScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Premium üstünlükləri siyahısı:
  - Limitsiz chat
  - Ətraflı analitika
  - Prioritet dəstək
  - Eksklüziv content
- Qiymət göstəricisi
- Abunə ol düyməsi
- Alışları bərpa et düyməsi

**iOS:** StoreKit → **Android:** Google Play Billing Library

**API:**
- `POST /api/v1/premium/activate`
- `POST /api/v1/premium/cancel`

---

### 4.20 TRAINER VERIFICATION

#### Screen 41: TrainerVerificationView → TrainerVerificationScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `TrainerVerificationView.swift` |
| **Android Fayl** | `ui/auth/TrainerVerificationScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Verification foto upload
- Instagram handle input
- Status göstəricisi (pending/verified/rejected)
- Göndər düyməsi

**API:**
- `POST /api/v1/auth/verify-trainer` → Multipart (şəkil)

---

### 4.21 ROUTE TRACKING

#### Screen 42: RouteTrackingView → RouteTrackingScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | `RouteManager.swift` + related views |
| **Android Fayl** | `ui/route/RouteTrackingScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Xəritə görünüşü (Google Maps)
- Start/Stop düyməsi
- Fəaliyyət tipi seçimi
- Məsafə göstəricisi
- Müddət göstəricisi
- Kalori göstəricisi
- Marşrut tarixçəsi

**API:**
- `POST /api/v1/routes/` → Marşrut saxla
- `GET /api/v1/routes/` → Marşrut siyahısı
- `GET /api/v1/routes/stats?days=7` → Statistika
- `DELETE /api/v1/routes/{id}` → Sil

---

### 4.22 CONTENT (Trainer Content)

#### Screen 43: TrainerContentView → TrainerContentScreen
| Parametr | Dəyər |
|----------|-------|
| **iOS Fayl** | Content-related views |
| **Android Fayl** | `ui/content/TrainerContentScreen.kt` |
| **Status** | ⬜ Yazılmalı |

**Elementlər:**
- Content siyahısı
- Yeni content yarat düyməsi
- Hər content: başlıq, tip, premium/free
- Silmə/redaktə

**API:**
- `GET /api/v1/content/my` → `[ContentResponse]`
- `POST /api/v1/content/` → `ContentResponse`
- `POST /api/v1/content/{id}/image` → Şəkil upload
- `DELETE /api/v1/content/{id}`

---

## 5. DATA MODELLƏRİ

### 5.1 Auth Models

```kotlin
// LoginRequest
data class LoginRequest(
    val email: String,
    val password: String
)

// RegisterRequest
data class RegisterRequest(
    val name: String,
    val email: String,
    val password: String,
    val userType: String // "client" or "trainer"
)

// AuthResponse (Token)
data class AuthResponse(
    val accessToken: String,
    val refreshToken: String,
    val tokenType: String
)

// UserResponse
data class UserResponse(
    val id: String,
    val name: String,
    val email: String,
    val userType: String,
    val profileImageUrl: String?,
    val isActive: Boolean,
    val isPremium: Boolean,
    val createdAt: String,
    val age: Int?,
    val weight: Double?,
    val height: Double?,
    val goal: String?,
    val trainerId: String?,
    val specialization: String?,
    val experience: Int?,
    val rating: Double?,
    val pricePerSession: Double?,
    val bio: String?,
    val verificationStatus: String?,
    val instagramHandle: String?,
    val verificationPhotoUrl: String?,
    val verificationScore: Double?
)

// OTPResponse
data class OTPResponse(
    val success: Boolean,
    val message: String,
    val code: String? // Test mode only
)
```

### 5.2 Workout Models

```kotlin
data class Workout(
    val id: String,
    val userId: String,
    val title: String,
    val category: String, // strength, cardio, flexibility, endurance
    val duration: Int, // minutes
    val caloriesBurned: Int?,
    val notes: String?,
    val date: String,
    val isCompleted: Boolean,
    val createdAt: String
)

data class WorkoutCreateRequest(
    val title: String,
    val category: String,
    val duration: Int,
    val caloriesBurned: Int?,
    val notes: String?,
    val date: String?
)
```

### 5.3 Food Models

```kotlin
data class FoodEntry(
    val id: String,
    val userId: String,
    val name: String,
    val calories: Int,
    val protein: Double?,
    val carbs: Double?,
    val fats: Double?,
    val mealType: String, // breakfast, lunch, dinner, snack
    val date: String,
    val imageUrl: String?,
    val notes: String?,
    val createdAt: String
)

data class FoodCreateRequest(
    val name: String,
    val calories: Int,
    val protein: Double?,
    val carbs: Double?,
    val fats: Double?,
    val mealType: String,
    val date: String?,
    val notes: String?
)

data class AICalorieResult(
    val foods: List<DetectedFood>,
    val totalCalories: Double,
    val totalProtein: Double,
    val totalCarbs: Double,
    val totalFat: Double,
    val confidence: Double,
    val imageUrl: String?
)

data class DetectedFood(
    val name: String,
    val calories: Double,
    val protein: Double,
    val carbs: Double,
    val fat: Double,
    val portionSize: String,
    val confidence: Double
)
```

### 5.4 Training Plan Models

```kotlin
data class TrainingPlan(
    val id: String,
    val trainerId: String,
    val title: String,
    val planType: String, // weight_loss, weight_gain, strength_training
    val workouts: List<PlanWorkout>,
    val assignedStudentId: String?,
    val isCompleted: Boolean,
    val notes: String?,
    val createdAt: String
)

data class PlanWorkout(
    val id: String,
    val name: String,
    val sets: Int,
    val reps: Int,
    val duration: Int?
)
```

### 5.5 Meal Plan Models

```kotlin
data class MealPlan(
    val id: String,
    val trainerId: String,
    val title: String,
    val planType: String,
    val dailyCalorieTarget: Int,
    val items: List<MealPlanItem>,
    val assignedStudentId: String?,
    val notes: String?,
    val createdAt: String
)

data class MealPlanItem(
    val id: String,
    val name: String,
    val calories: Int,
    val protein: Double,
    val carbs: Double,
    val fats: Double,
    val mealType: String // breakfast, lunch, dinner, snack
)
```

### 5.6 Chat Models

```kotlin
data class ChatConversation(
    val userId: String,
    val userName: String,
    val userProfileImage: String?,
    val lastMessage: String?,
    val lastMessageTime: String?,
    val unreadCount: Int
)

data class ChatMessageResponse(
    val id: String,
    val senderId: String,
    val receiverId: String,
    val message: String,
    val isRead: Boolean,
    val createdAt: String
)

data class ChatMessageCreate(
    val receiverId: String,
    val message: String
)

data class MessageLimitResponse(
    val dailyLimit: Int,
    val usedToday: Int,
    val remaining: Int
)
```

### 5.7 Marketplace Models

```kotlin
data class MarketplaceProduct(
    val id: String,
    val sellerId: String,
    val productType: String, // workout_plan, meal_plan, training_program, ebook, video_course
    val title: String,
    val description: String,
    val price: Double,
    val currency: String,
    val coverImageUrl: String?,
    val isPublished: Boolean,
    val createdAt: String,
    val updatedAt: String,
    val seller: ProductSeller?,
    val averageRating: Double?,
    val reviewCount: Int?
)

data class ProductSeller(
    val id: String,
    val name: String,
    val profileImageUrl: String?
)

data class ProductReview(
    val id: String,
    val productId: String,
    val userId: String,
    val rating: Int, // 1-5
    val comment: String?,
    val createdAt: String,
    val reviewer: ReviewAuthor?
)
```

### 5.8 Live Session Models

```kotlin
data class LiveSession(
    val id: String,
    val trainerId: String,
    val title: String,
    val description: String?,
    val sessionType: String, // group, one_on_one, open
    val maxParticipants: Int,
    val difficultyLevel: String,
    val durationMinutes: Int,
    val scheduledStart: String,
    val scheduledEnd: String,
    val actualStart: String?,
    val actualEnd: String?,
    val status: String, // scheduled, live, completed, cancelled
    val isPublic: Boolean,
    val isPaid: Boolean,
    val price: Double,
    val currency: String,
    val workoutPlan: List<WorkoutExercise>?,
    val registeredCount: Int?,
    val activeCount: Int?,
    val trainer: SessionTrainer?,
    val createdAt: String,
    val updatedAt: String
)
```

### 5.9 Social Models

```kotlin
data class SocialPost(
    val id: String,
    val userId: String,
    val postType: String, // workout, meal, progress, achievement, general
    val content: String?,
    val imageUrl: String?,
    val workoutId: String?,
    val foodEntryId: String?,
    val likesCount: Int,
    val commentsCount: Int,
    val isPublic: Boolean,
    val createdAt: String,
    val updatedAt: String,
    val author: PostAuthor?,
    val isLiked: Boolean
)

data class PostComment(
    val id: String,
    val postId: String,
    val userId: String,
    val content: String,
    val createdAt: String,
    val author: CommentAuthor?
)
```

### 5.10 Daily Survey Models

```kotlin
data class DailySurveyRequest(
    val energyLevel: Int, // 1-5
    val sleepHours: Double, // 0-24
    val sleepQuality: Int, // 1-5
    val stressLevel: Int, // 1-5
    val muscleSoreness: Int, // 1-5
    val mood: Int, // 1-5
    val waterGlasses: Int, // 0-30
    val notes: String?
)

data class DailySurveyResponse(
    val id: String,
    val date: String,
    val energyLevel: Int,
    val sleepHours: Double,
    val sleepQuality: Int,
    val stressLevel: Int,
    val muscleSoreness: Int,
    val mood: Int,
    val waterGlasses: Int,
    val notes: String?,
    val createdAt: String
)
```

### 5.11 Analytics Models

```kotlin
data class AnalyticsDashboardResponse(
    val currentWeek: WeekStats,
    val weightTrend: List<WeightPoint>,
    val workoutTrend: List<WorkoutPoint>,
    val nutritionTrend: List<NutritionPoint>,
    val totalWorkouts30d: Int,
    val totalMinutes30d: Int,
    val totalCaloriesBurned30d: Int,
    val avgDailyCalories: Int,
    val workoutStreakDays: Int
)

data class BodyMeasurementResponse(
    val id: String,
    val userId: String,
    val measuredAt: String,
    val weightKg: Double,
    val bodyFatPercent: Double?,
    val muscleMassKg: Double?,
    val chestCm: Double?,
    val waistCm: Double?,
    val hipsCm: Double?,
    val armsCm: Double?,
    val legsCm: Double?,
    val notes: String?,
    val createdAt: String
)
```

### 5.12 Route Models

```kotlin
data class RouteCreateRequest(
    val activityType: String,
    val startLatitude: Double,
    val startLongitude: Double,
    val endLatitude: Double?,
    val endLongitude: Double?,
    val coordinatesJson: String?,
    val distanceKm: Double,
    val durationSeconds: Int,
    val startedAt: String,
    val finishedAt: String?
)

data class RouteResponse(
    val id: String,
    val userId: String,
    val activityType: String,
    val distanceKm: Double,
    val durationSeconds: Int,
    val caloriesBurned: Int?,
    val startedAt: String,
    val finishedAt: String?,
    val createdAt: String
)

data class RouteStatsResponse(
    val totalRoutes: Int,
    val totalDistanceKm: Double,
    val totalDurationSeconds: Int,
    val totalCalories: Int,
    val avgPace: Double?,
    val avgSpeedKmh: Double?,
    val longestRouteKm: Double,
    val activityBreakdown: Map<String, Int>
)
```

---

## 6. API ENDPOİNTLƏRİ - TAM SİYAHI

### 6.1 Authentication (8 endpoint)

| # | Method | Endpoint | Auth | Məqsəd |
|---|--------|----------|------|--------|
| 1 | POST | `/api/v1/auth/login` | ❌ | Giriş |
| 2 | POST | `/api/v1/auth/register` | ❌ | Qeydiyyat |
| 3 | GET | `/api/v1/auth/me` | ✅ | Cari istifadəçi |
| 4 | POST | `/api/v1/auth/refresh` | ❌ | Token yeniləmə |
| 5 | POST | `/api/v1/auth/refresh-claims` | ✅ | Claims yeniləmə |
| 6 | DELETE | `/api/v1/auth/delete-account` | ✅ | Hesab silmə |
| 7 | POST | `/api/v1/auth/forgot-password` | ❌ | Şifrə sıfırlama OTP |
| 8 | POST | `/api/v1/auth/reset-password` | ❌ | Yeni şifrə təyin et |

### 6.2 User/Profile (6 endpoint)

| # | Method | Endpoint | Auth | Məqsəd |
|---|--------|----------|------|--------|
| 9 | PUT | `/api/v1/users/profile` | ✅ | Profil yenilə |
| 10 | POST | `/api/v1/uploads/profile-image` | ✅ | Profil şəkli upload |
| 11 | GET | `/api/v1/users/trainers` | ✅ | Bütün trainerlər |
| 12 | POST | `/api/v1/users/assign-trainer/{id}` | ✅ | Trainer təyin et |
| 13 | DELETE | `/api/v1/users/unassign-trainer` | ✅ | Trainer silmə |
| 14 | GET | `/api/v1/users/my-students` | ✅ | Tələbələrim |

### 6.3 Workouts (5 endpoint)

| # | Method | Endpoint | Auth | Məqsəd |
|---|--------|----------|------|--------|
| 15 | POST | `/api/v1/workouts/` | ✅ | Məşq yarat |
| 16 | GET | `/api/v1/workouts/` | ✅ | Məşqlər siyahısı |
| 17 | PUT | `/api/v1/workouts/{id}` | ✅ | Məşq yenilə |
| 18 | DELETE | `/api/v1/workouts/{id}` | ✅ | Məşq sil |
| 19 | PATCH | `/api/v1/workouts/{id}/toggle` | ✅ | Tamamlanma toggle |

### 6.4 Food (6 endpoint)

| # | Method | Endpoint | Auth | Məqsəd |
|---|--------|----------|------|--------|
| 20 | POST | `/api/v1/food/` | ✅ | Qida əlavə et |
| 21 | GET | `/api/v1/food/` | ✅ | Qida siyahısı |
| 22 | PUT | `/api/v1/food/{id}` | ✅ | Qida yenilə |
| 23 | DELETE | `/api/v1/food/{id}` | ✅ | Qida sil |
| 24 | POST | `/api/v1/food/{id}/image` | ✅ | Qida şəkli upload |
| 25 | POST | `/api/v1/food/analyze` | ✅ | AI analiz (multipart) |

### 6.5 Training Plans (5 endpoint)

| # | Method | Endpoint | Auth | Məqsəd |
|---|--------|----------|------|--------|
| 26 | POST | `/api/v1/plans/training` | ✅ | Plan yarat |
| 27 | GET | `/api/v1/plans/training` | ✅ | Planlar siyahısı |
| 28 | PUT | `/api/v1/plans/training/{id}` | ✅ | Plan yenilə |
| 29 | DELETE | `/api/v1/plans/training/{id}` | ✅ | Plan sil |
| 30 | PUT | `/api/v1/plans/training/{id}/complete` | ✅ | Plan tamamla |

### 6.6 Meal Plans (5 endpoint)

| # | Method | Endpoint | Auth | Məqsəd |
|---|--------|----------|------|--------|
| 31 | POST | `/api/v1/plans/meal` | ✅ | Meal plan yarat |
| 32 | GET | `/api/v1/plans/meal` | ✅ | Meal planlar |
| 33 | PUT | `/api/v1/plans/meal/{id}` | ✅ | Meal plan yenilə |
| 34 | DELETE | `/api/v1/plans/meal/{id}` | ✅ | Meal plan sil |
| 35 | PUT | `/api/v1/plans/meal/{id}/complete` | ✅ | Meal plan tamamla |

### 6.7 Chat (4 endpoint)

| # | Method | Endpoint | Auth | Məqsəd |
|---|--------|----------|------|--------|
| 36 | GET | `/api/v1/chat/conversations` | ✅ | Söhbətlər |
| 37 | GET | `/api/v1/chat/history/{userId}` | ✅ | Mesaj tarixçəsi |
| 38 | POST | `/api/v1/chat/send` | ✅ | Mesaj göndər |
| 39 | GET | `/api/v1/chat/limit` | ✅ | Mesaj limiti |

### 6.8 Social (8 endpoint)

| # | Method | Endpoint | Auth | Məqsəd |
|---|--------|----------|------|--------|
| 40 | GET | `/api/v1/social/feed` | ✅ | Feed |
| 41 | POST | `/api/v1/social/posts` | ✅ | Post yarat |
| 42 | POST | `/api/v1/social/posts/{id}/image` | ✅ | Post şəkli |
| 43 | POST | `/api/v1/social/posts/{id}/like` | ✅ | Like |
| 44 | DELETE | `/api/v1/social/posts/{id}/like` | ✅ | Unlike |
| 45 | DELETE | `/api/v1/social/posts/{id}` | ✅ | Post sil |
| 46 | GET | `/api/v1/social/posts/{id}/comments` | ✅ | Şərhlər |
| 47 | POST | `/api/v1/social/posts/{id}/comments` | ✅ | Şərh yaz |

### 6.9 Live Sessions (7 endpoint + WebSocket)

| # | Method | Endpoint | Auth | Məqsəd |
|---|--------|----------|------|--------|
| 48 | GET | `/api/v1/live-sessions` | ✅ | Session siyahısı |
| 49 | POST | `/api/v1/live-sessions` | ✅ | Session yarat |
| 50 | GET | `/api/v1/live-sessions/{id}` | ✅ | Session detalları |
| 51 | POST | `/api/v1/live-sessions/{id}/join` | ✅ | Qoşul |
| 52 | GET | `/api/v1/live-sessions/{id}/participants` | ✅ | İştirakçılar |
| 53 | DELETE | `/api/v1/live-sessions/{id}` | ✅ | Session sil |
| 54 | WS | `/api/v1/live-sessions/ws/{id}?token=` | ✅ | WebSocket |

### 6.10 Marketplace (8 endpoint)

| # | Method | Endpoint | Auth | Məqsəd |
|---|--------|----------|------|--------|
| 55 | GET | `/api/v1/marketplace/products` | ✅ | Məhsullar |
| 56 | GET | `/api/v1/marketplace/products/{id}` | ✅ | Məhsul detalları |
| 57 | POST | `/api/v1/marketplace/products` | ✅ | Məhsul yarat |
| 58 | DELETE | `/api/v1/marketplace/products/{id}` | ✅ | Məhsul sil |
| 59 | GET | `/api/v1/marketplace/products/{id}/reviews` | ✅ | Rəylər |
| 60 | POST | `/api/v1/marketplace/reviews` | ✅ | Rəy yaz |
| 61 | POST | `/api/v1/marketplace/purchase` | ✅ | Satın al |
| 62 | GET | `/api/v1/marketplace/my-purchases` | ✅ | Alışlarım |

### 6.11 Trainer Reviews (4 endpoint)

| # | Method | Endpoint | Auth | Məqsəd |
|---|--------|----------|------|--------|
| 63 | GET | `/api/v1/trainer/{id}/reviews` | ✅ | Trainer rəyləri |
| 64 | GET | `/api/v1/trainer/{id}/reviews/summary` | ✅ | Rəy xülasəsi |
| 65 | POST | `/api/v1/trainer/{id}/reviews` | ✅ | Rəy yaz |
| 66 | DELETE | `/api/v1/trainer/{id}/reviews` | ✅ | Rəy sil |

### 6.12 Content (5 endpoint)

| # | Method | Endpoint | Auth | Məqsəd |
|---|--------|----------|------|--------|
| 67 | GET | `/api/v1/content/my` | ✅ | Öz contentim |
| 68 | GET | `/api/v1/content/trainer/{id}` | ✅ | Trainer contenti |
| 69 | POST | `/api/v1/content/` | ✅ | Content yarat |
| 70 | POST | `/api/v1/content/{id}/image` | ✅ | Şəkil upload |
| 71 | DELETE | `/api/v1/content/{id}` | ✅ | Content sil |

### 6.13 Survey (4 endpoint)

| # | Method | Endpoint | Auth | Məqsəd |
|---|--------|----------|------|--------|
| 72 | GET | `/api/v1/survey/questions` | ✅ | Suallar |
| 73 | POST | `/api/v1/survey/daily` | ✅ | Survey göndər |
| 74 | GET | `/api/v1/survey/daily/today` | ✅ | Bugünkü status |
| 75 | GET | `/api/v1/survey/daily/history` | ✅ | Tarixçə |

### 6.14 Routes (4 endpoint)

| # | Method | Endpoint | Auth | Məqsəd |
|---|--------|----------|------|--------|
| 76 | POST | `/api/v1/routes/` | ✅ | Marşrut yarat |
| 77 | GET | `/api/v1/routes/` | ✅ | Marşrut siyahısı |
| 78 | GET | `/api/v1/routes/stats` | ✅ | Statistika |
| 79 | DELETE | `/api/v1/routes/{id}` | ✅ | Marşrut sil |

### 6.15 Analytics (1 endpoint)

| # | Method | Endpoint | Auth | Məqsəd |
|---|--------|----------|------|--------|
| 80 | GET | `/api/v1/analytics/dashboard` | ✅ | Dashboard |

### 6.16 AI Recommendations (1 endpoint)

| # | Method | Endpoint | Auth | Məqsəd |
|---|--------|----------|------|--------|
| 81 | GET | `/api/v1/ai/recommendations` | ✅ | Tövsiyələr |

### 6.17 Onboarding (3 endpoint)

| # | Method | Endpoint | Auth | Məqsəd |
|---|--------|----------|------|--------|
| 82 | GET | `/api/v1/onboarding/options` | ❌ | Seçimlər |
| 83 | GET | `/api/v1/onboarding/status` | ✅ | Status |
| 84 | POST | `/api/v1/onboarding/complete` | ✅ | Tamamla |

### 6.18 Premium (2 endpoint)

| # | Method | Endpoint | Auth | Məqsəd |
|---|--------|----------|------|--------|
| 85 | POST | `/api/v1/premium/activate` | ✅ | Aktivləşdir |
| 86 | POST | `/api/v1/premium/cancel` | ✅ | Ləğv et |

### 6.19 Trainer Stats (1 endpoint)

| # | Method | Endpoint | Auth | Məqsəd |
|---|--------|----------|------|--------|
| 87 | GET | `/api/v1/trainer/stats` | ✅ | Trainer stats |

### 6.20 Trainer Verification (1 endpoint)

| # | Method | Endpoint | Auth | Məqsəd |
|---|--------|----------|------|--------|
| 88 | POST | `/api/v1/auth/verify-trainer` | ✅ | Verifikasiya |

### 6.21 News (3 endpoint)

| # | Method | Endpoint | Auth | Məqsəd |
|---|--------|----------|------|--------|
| 89 | GET | `/news/` | ✅ | Xəbərlər |
| 90 | GET | `/news/categories` | ✅ | Kateqoriyalar |
| 91 | POST | `/news/refresh` | ✅ | Cache yenilə |

**TOPLAM: 91 endpoint + 1 WebSocket = 92 connection point**

---

## 7. ANDROID PAKET STRUKTURU

```
life.corevia.app/
├── CoreViaApp.kt                    (Hilt Application)
├── MainActivity.kt                  (Single Activity)
│
├── data/
│   ├── remote/
│   │   ├── ApiService.kt           (Retrofit interface - bütün endpointlər)
│   │   ├── AuthInterceptor.kt      (OkHttp interceptor - JWT token)
│   │   └── TokenRefreshAuthenticator.kt  (Auto token refresh)
│   │
│   ├── local/
│   │   ├── TokenManager.kt         (EncryptedSharedPreferences)
│   │   ├── PreferencesManager.kt   (App settings, language, theme)
│   │   └── UserPreferences.kt      (DataStore preferences)
│   │
│   ├── repository/
│   │   ├── AuthRepository.kt
│   │   ├── WorkoutRepository.kt
│   │   ├── FoodRepository.kt
│   │   ├── TrainingPlanRepository.kt
│   │   ├── MealPlanRepository.kt
│   │   ├── ChatRepository.kt
│   │   ├── SocialRepository.kt
│   │   ├── MarketplaceRepository.kt
│   │   ├── LiveSessionRepository.kt
│   │   ├── AnalyticsRepository.kt
│   │   ├── SurveyRepository.kt
│   │   ├── RouteRepository.kt
│   │   ├── TrainerRepository.kt
│   │   ├── ContentRepository.kt
│   │   ├── PremiumRepository.kt
│   │   └── OnboardingRepository.kt
│   │
│   └── model/
│       ├── AuthModels.kt
│       ├── UserModels.kt
│       ├── WorkoutModels.kt
│       ├── FoodModels.kt
│       ├── TrainingPlanModels.kt
│       ├── MealPlanModels.kt
│       ├── ChatModels.kt
│       ├── SocialModels.kt
│       ├── MarketplaceModels.kt
│       ├── LiveSessionModels.kt
│       ├── AnalyticsModels.kt
│       ├── SurveyModels.kt
│       ├── RouteModels.kt
│       ├── ContentModels.kt
│       └── OnboardingModels.kt
│
├── di/
│   ├── AppModule.kt                (Hilt - general bindings)
│   ├── NetworkModule.kt            (Hilt - Retrofit, OkHttp)
│   └── RepositoryModule.kt         (Hilt - repository bindings)
│
├── ui/
│   ├── navigation/
│   │   └── AppNavigation.kt        (NavHost, bütün route-lar)
│   │
│   ├── theme/
│   │   ├── Color.kt
│   │   ├── Type.kt
│   │   └── Theme.kt
│   │
│   ├── components/                  (Shared UI components)
│   │   ├── CoreViaButton.kt
│   │   ├── CoreViaTextField.kt
│   │   ├── CoreViaCard.kt
│   │   ├── LoadingIndicator.kt
│   │   ├── ErrorDialog.kt
│   │   ├── FilterChip.kt
│   │   ├── RatingStars.kt
│   │   ├── ImagePicker.kt
│   │   └── LanguageSelector.kt
│   │
│   ├── auth/
│   │   ├── LoginScreen.kt          ✅ HAZIR
│   │   ├── LoginViewModel.kt
│   │   ├── RegisterScreen.kt
│   │   ├── RegisterViewModel.kt
│   │   ├── ForgotPasswordScreen.kt
│   │   └── ForgotPasswordViewModel.kt
│   │
│   ├── onboarding/
│   │   ├── OnboardingScreen.kt
│   │   └── OnboardingViewModel.kt
│   │
│   ├── home/
│   │   ├── HomeScreen.kt           (Client)
│   │   ├── HomeViewModel.kt
│   │   ├── TrainerHomeScreen.kt     (Trainer)
│   │   └── TrainerHomeViewModel.kt
│   │
│   ├── workout/
│   │   ├── WorkoutScreen.kt
│   │   ├── WorkoutViewModel.kt
│   │   ├── AddWorkoutScreen.kt
│   │   └── AddWorkoutViewModel.kt
│   │
│   ├── food/
│   │   ├── FoodScreen.kt
│   │   ├── FoodViewModel.kt
│   │   ├── AddFoodScreen.kt
│   │   ├── AddFoodViewModel.kt
│   │   ├── AICalorieResultScreen.kt
│   │   ├── AICalorieHistoryScreen.kt
│   │   └── AICalorieViewModel.kt
│   │
│   ├── chat/
│   │   ├── ConversationsScreen.kt
│   │   ├── ConversationsViewModel.kt
│   │   ├── ChatDetailScreen.kt
│   │   └── ChatDetailViewModel.kt
│   │
│   ├── trainers/
│   │   ├── TrainerBrowseScreen.kt
│   │   └── TrainerBrowseViewModel.kt
│   │
│   ├── plans/
│   │   ├── TrainingPlanScreen.kt
│   │   ├── TrainingPlanViewModel.kt
│   │   ├── AddTrainingPlanScreen.kt
│   │   ├── MealPlanScreen.kt
│   │   ├── MealPlanViewModel.kt
│   │   └── AddMealPlanScreen.kt
│   │
│   ├── marketplace/
│   │   ├── MarketplaceScreen.kt
│   │   ├── MarketplaceViewModel.kt
│   │   ├── ProductDetailScreen.kt
│   │   ├── ProductDetailViewModel.kt
│   │   └── WriteReviewScreen.kt
│   │
│   ├── trainerhub/
│   │   ├── TrainerHubScreen.kt
│   │   ├── TrainerProductsScreen.kt
│   │   ├── CreateProductScreen.kt
│   │   ├── TrainerSessionsScreen.kt
│   │   └── CreateLiveSessionScreen.kt
│   │
│   ├── livesession/
│   │   ├── LiveSessionListScreen.kt
│   │   ├── LiveSessionDetailScreen.kt
│   │   ├── LiveWorkoutScreen.kt
│   │   └── LiveSessionViewModel.kt
│   │
│   ├── social/
│   │   ├── SocialFeedScreen.kt
│   │   ├── SocialFeedViewModel.kt
│   │   ├── CreatePostScreen.kt
│   │   └── CommentsScreen.kt
│   │
│   ├── survey/
│   │   ├── DailySurveyScreen.kt
│   │   └── DailySurveyViewModel.kt
│   │
│   ├── analytics/
│   │   ├── AnalyticsDashboardScreen.kt
│   │   ├── AnalyticsViewModel.kt
│   │   └── OverallStatsScreen.kt
│   │
│   ├── profile/
│   │   ├── ProfileScreen.kt
│   │   ├── ProfileViewModel.kt
│   │   └── EditProfileScreen.kt
│   │
│   ├── settings/
│   │   ├── SettingsScreen.kt
│   │   └── SettingsViewModel.kt
│   │
│   ├── premium/
│   │   ├── PremiumScreen.kt
│   │   └── PremiumViewModel.kt
│   │
│   ├── route/
│   │   ├── RouteTrackingScreen.kt
│   │   └── RouteViewModel.kt
│   │
│   └── content/
│       ├── TrainerContentScreen.kt
│       └── ContentViewModel.kt
│
└── util/
    ├── Constants.kt                 (API URLs, keys)
    ├── Extensions.kt                (Kotlin extensions)
    ├── DateUtils.kt                 (Date formatting)
    ├── NetworkResult.kt             (Sealed class for API results)
    └── LocalizationManager.kt       (Multi-language support)
```

---

## 8. İNKİŞAF PLANI (Prioritet Sırasına Görə)

### Phase 1: Əsas İnfrastruktur ⚙️
1. ✅ Layihə yaradılması (build.gradle, dependencies)
2. ✅ Theme (Color, Type, Theme)
3. ⬜ NetworkModule (Retrofit + OkHttp + Auth Interceptor)
4. ⬜ TokenManager (EncryptedSharedPreferences)
5. ⬜ ApiService (Retrofit interface)
6. ⬜ NetworkResult sealed class
7. ⬜ AppNavigation (bütün route-lar)

### Phase 2: Auth 🔐
8. ✅ LoginScreen (UI hazır)
9. ⬜ LoginViewModel (API call)
10. ⬜ RegisterScreen + ViewModel
11. ⬜ ForgotPasswordScreen + ViewModel
12. ⬜ AuthRepository

### Phase 3: Core Screens 🏠
13. ⬜ OnboardingScreen + ViewModel
14. ⬜ HomeScreen (Client) + ViewModel
15. ⬜ TrainerHomeScreen + ViewModel
16. ⬜ Custom TabBar (user type-a görə)
17. ⬜ ProfileScreen + EditProfileScreen

### Phase 4: Workout & Food 💪🍎
18. ⬜ WorkoutScreen + AddWorkoutScreen
19. ⬜ FoodScreen + AddFoodScreen
20. ⬜ AI Calorie (TensorFlow Lite) - Sonraya buraxıla bilər

### Phase 5: Plans & Chat 📋💬
21. ⬜ TrainingPlanScreen + AddTrainingPlanScreen
22. ⬜ MealPlanScreen + AddMealPlanScreen
23. ⬜ ConversationsScreen + ChatDetailScreen

### Phase 6: Marketplace & Social 🏪📱
24. ⬜ MarketplaceScreen + ProductDetailScreen
25. ⬜ SocialFeedScreen + CreatePostScreen + CommentsScreen
26. ⬜ TrainerBrowseScreen

### Phase 7: Advanced Features 🚀
27. ⬜ Live Sessions (WebSocket + UI)
28. ⬜ Trainer Hub (Product/Session management)
29. ⬜ Analytics Dashboard (Charts)
30. ⬜ Daily Survey
31. ⬜ Route Tracking (Google Maps)
32. ⬜ Premium (Google Play Billing)
33. ⬜ Settings + Localization

---

## 9. XÜLASƏ CƏDVƏLİ

| Kateqoriya | Say |
|------------|-----|
| **Toplam Ekranlar** | 43 |
| **Toplam API Endpointlər** | 91 + 1 WS = 92 |
| **Data Modelləri** | 30+ |
| **Repository-lər** | 16 |
| **ViewModel-lər** | 25+ |
| **Dillər** | 3 (AZ, EN, RU) |
| **User Types** | 2 (Client, Trainer) |
| **iOS Fayl Sayı** | 111 |
| **Android Təxmini Fayl Sayı** | ~120-130 |

---

**Bu sənəd CoreVia iOS appinin tam analizinə əsaslanır və Android versiyasının 1:1 yaradılması üçün blueprint kimi istifadə olunacaq.**
