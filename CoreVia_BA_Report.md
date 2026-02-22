# CoreVia - Business Analysis Hesabati
# Tam Funksional Audit & Gorulocok Isler
---
**Tarix:** 21 Fevral 2026
**Hazirlayan:** BA (Business Analyst)
**Layiho:** CoreVia - Fitness & Wellness Platform
**Prioritet:** Android -> iOS

---

## 1. LAYIHO HAQQINDA

CoreVia - fitness ve saglamliq platformasidir. Layiho 3 hissodon ibarotdir:
- **Backend:** Python/FastAPI (Deployed - api.corevia.life)
- **Android:** Kotlin/Jetpack Compose (Inkisafda)
- **iOS:** SwiftUI (Tamamlanib, teskmillesdirmeler lazim)

---

## 2. DIZAYN UYGUNSUZLUQLARI

Asagidaki ekranlar dizayn mockup-dan ferqlenir ve ya movcud deyil:

### 2.1 Yaradilmali olan YENI ekranlar

| # | Ekran | Tesvir | Prioritet |
|---|-------|--------|-----------|
| 1 | Gender Selection | "Tell us about yourself" - Kisi/Qadin secimi, arxa fon sekilli | Yuksek |
| 2 | Age Picker | Scroll wheel ile yas secimi (18-80) | Yuksek |
| 3 | Weight Picker | Ruler-style slider ile coki secimi (kg) | Yuksek |
| 4 | Height Picker | Boy secimi (cm) | Yuksek |
| 5 | Goal Selection | Meqsed secimi: Ariqlamaq, Kilo almaq, Formada qalmaq, Elastiklik, Osas mesqler | Yuksek |
| 6 | Workout Detail Screen | Gun uzre mesq detallari, herekot siyahisi, "Mesqe Basla" duymesi | Yuksek |
| 7 | Workout Category View | Kateqoriya uzre mesqler (Beginner/Intermediate/Advanced) | Orta |

### 2.2 Movcud ekranlarda deyisiklikler

| # | Ekran | Deyisiklik | Prioritet |
|---|-------|-----------|-----------|
| 1 | Onboarding | 4 slide -> 3 slide, arxa fon sekilleri, "Start Now" duymesi | Yuksek |
| 2 | Login | Sexsilesdirmis salamlama ("Xos geldin, [Ad]"), arxa fon sekili | Orta |
| 3 | Register | "Hello newbie" basliq, Apple/Google social login duymeleri | Orta |
| 4 | Home Screen | Sexsi salamlama, Workout Categories tab-lari (Beginner/Intermediate/Advance), "New Workouts" bolmesi | Yuksek |
| 5 | Premium | Ayliq/Illik plan muqayisesi | Orta |
| 6 | Trainers List | Ixtisas, reytinq, tecrube gosterilmeli | Orta |
| 7 | Trainer Profile | Stats: Tecrube/Tamamlanmis/Aktiv telebler, "Gorusme planla" duymesi | Orta |

### 2.3 Arxa fon sekilleri (Background Images)

Dizaynda her ekranda arxa fonda fitness temali blur/gradient sekiller var. Bu hazirda app-da yoxdur:
- Onboarding: Fitness model sekilleri arxa fonda
- Login/Register: Qaranlig temali idman zali fonunda
- Gender Selection: Kisi/Qadin idman sekilleri
- Goal Selection: Meqsede uygun sekiller
- Premium: Motivasiya edici arxa fon

**Holl:** Asset-ler hazirlanmali ve ya stock photo istifade olunmalidir.

---

## 3. MOVCUD FUNKSIYALARIN AUDIT CEDVELI

### 3.1 Qida Izleme & Qida Plani

| # | Funksiya | Backend | Android | iOS | Status | Is |
|---|----------|---------|---------|-----|--------|----|
| 1 | Qida elave et | OK | OK | OK | Tam | - |
| 2 | Qida siyahisi | OK | OK | OK | Tam | - |
| 3 | Qida redakte et | OK | OK | OK | Tam | - |
| 4 | Qida sil | OK | OK | OK | Tam | - |
| 5 | Gunluk kalori proqresi | OK | OK | OK | Tam | - |
| 6 | Makro gostericiler | OK | OK | OK | Tam | - |
| 7 | AI ile sekil analizi | OK | YOX | YOX | Catismir | Kamera inteqrasiyasi lazim |
| 8 | Gunluk xulase endpoint | OK | Istifade olunmur | Istifade olunmur | Bos | Endpoint cagirmali |
| 9 | Qida plani yarat | OK | OK | OK | Tam | - |
| 10 | Qida plani sil | OK | OK | OK | Tam | - |
| 11 | Qida plani tamamla | OK | OK | OK | Tam | - |
| 12 | Qida plani REDAKTE et | Yarimciq (yalniz basliq) | YOX | YOX | Catismir | Backend + Mobile UI lazim |
| 13 | Qida plani item elave/sil | YOX | YOX | YOX | YOX | Backend endpoint + UI lazim |
| 14 | Heftelik teqvim gorunusu | YOX | YOX | YOX | YOX | Tam yeni feature |
| 15 | Kalori hedofi sinxronizasiya | YOX | Lokal 2000 | Lokal 2000 | Catismir | Backend endpoint lazim |
| 16 | Qida plani sablon/kopyalama | YOX | YOX | YOX | YOX | Tam yeni feature |
| 17 | Su izleme | YOX | YOX | YOX | YOX | Tam yeni feature |

### 3.2 Mesq & Telim Plani

| # | Funksiya | Backend | Android | iOS | Status | Is |
|---|----------|---------|---------|-----|--------|----|
| 1 | Mesq elave et | OK | OK | OK | Tam | - |
| 2 | Mesq siyahisi | OK | OK | OK | Tam | - |
| 3 | Mesq tamamla/toggle | OK | OK | OK | Tam | - |
| 4 | Mesq sil | OK | OK | OK | Tam | - |
| 5 | Mesq REDAKTE et | OK | YOX | YOX | Catismir | Mobile UI lazim |
| 6 | Mesq detallari sehifesi | OK | YOX | YOX | Catismir | Yeni ekran lazim |
| 7 | Mesq statistikasi endpoint | OK | Cagrilmir | Cagrilmir | Bos | Endpoint istifade olunmali |
| 8 | Bugunku mesqler endpoint | OK | Client-side | Client-side | Bos | Endpoint istifade olunmali |
| 9 | GPS izleme (qacis/gezinti) | Schema var | Duyme var, kod yox | YOX | Catismir | Tam implementasiya lazim |
| 10 | Kateqoriya filteri | Backend var | YOX | YOX | Catismir | UI lazim |
| 11 | Telim plani yarat | OK | OK | OK | Tam | - |
| 12 | Telim plani sil | OK | OK | OK | Tam | - |
| 13 | Telim plani tamamla | OK | OK | OK | Tam | - |
| 14 | Telim plani REDAKTE et | OK | YOX | YOX | Catismir | Mobile UI lazim |
| 15 | Telim plani detallari | OK | Cagrilmir | Cagrilmir | Bos | Endpoint istifade olunmali |
| 16 | Hereket kitabxanasi | YOX | YOX | YOX | YOX | Backend + UI lazim |
| 17 | Set/rep izleme | YOX | YOX | YOX | YOX | Tam yeni feature |
| 18 | Workout Timer | YOX | YOX | YOX | YOX | Tam yeni feature |

### 3.3 Sohbet (Chat)

| # | Funksiya | Backend | Android | iOS | Status | Is |
|---|----------|---------|---------|-----|--------|----|
| 1 | Mesaj gonder | OK | OK | OK | Tam | - |
| 2 | Sohbet tarixcesi | OK | OK | OK | Tam | - |
| 3 | Sohbetler siyahisi | OK | OK | OK | Tam | - |
| 4 | Mesaj limiti (10/gun) | OK | OK | OK | Tam | - |
| 5 | Real-time (WebSocket) | YOX | YOX | YOX | YOX | Backend + Mobile lazim |
| 6 | Mesaj oxundu bildirisi | Backend-de var | YOX | YOX | Catismir | Mobile UI lazim |
| 7 | Mesaj sil/redakte | YOX | YOX | YOX | YOX | Tam yeni feature |
| 8 | Yazir... indikatoru | YOX | YOX | YOX | YOX | WebSocket ile birge |

### 3.4 Sosial Sebeke

| # | Funksiya | Backend | Android | iOS | Status | Is |
|---|----------|---------|---------|-----|--------|----|
| 1 | Post yarat | OK | OK | Yarimciq | Yarimciq | iOS tamamlanmali |
| 2 | Post sil | OK | OK | OK | Tam | - |
| 3 | Beyen/beyanma legv | OK | OK | OK | Tam | - |
| 4 | Serhler yaz/oxu | OK | OK | YOX | iOS catismir | iOS UI lazim |
| 5 | Serh sil | OK | YOX | YOX | Catismir | Mobile UI lazim |
| 6 | Post sekil yukle | OK | YOX | YOX | Catismir | Mobile UI lazim |
| 7 | Follow/Unfollow | OK | YOX | YOX | Catismir | Mobile UI lazim |
| 8 | Istifadeci profili | OK | YOX | YOX | Catismir | Mobile UI lazim |
| 9 | Nailiyyetler (Achievements) | OK | YOX | YOX | Catismir | Mobile UI lazim |

### 3.5 Bildirisler (Notifications)

| # | Funksiya | Backend | Android | iOS | Status | Is |
|---|----------|---------|---------|-----|--------|----|
| 1 | Bildiris siyahisi | OK | OK | TAM YOX | iOS bos | iOS yaradilmali |
| 2 | Oxundu isarele | OK | OK | TAM YOX | iOS bos | iOS yaradilmali |
| 3 | Bildiris sil | OK | OK | TAM YOX | iOS bos | iOS yaradilmali |
| 4 | FCM device token qeydiyyati | OK | CAGRILMIR | TAM YOX | KRITIK | Her iki platformada lazim |
| 5 | Push notification alma | Service var | FCM yoxdur | TAM YOX | KRITIK | Her iki platformada lazim |

### 3.6 Marketplace

| # | Funksiya | Backend | Android | iOS | Status | Is |
|---|----------|---------|---------|-----|--------|----|
| 1 | Mehsul siyahisi | OK | OK | OK | Tam | - |
| 2 | Mehsul axtarisi | OK | OK | OK | Tam | - |
| 3 | Rey yaz | OK | YOX | YOX | Catismir | Mobile UI lazim |
| 4 | Mehsul yarat (trainer) | OK | YOX | YOX | Catismir | Mobile UI lazim |

### 3.7 Canli Sessiyalar (Live Sessions)

| # | Funksiya | Backend | Android | iOS | Status | Is |
|---|----------|---------|---------|-----|--------|----|
| 1 | Sessiya siyahisi | OK | OK | OK | Tam | - |
| 2 | Sessiya detallari | OK | Yarimciq | Yarimciq | Yarimciq | UI tamamlanmali |
| 3 | Sessiyaya qosul | OK | YOX | YOX | Catismir | Mobile UI lazim |
| 4 | WebSocket real-time | Endpoint var | YOX | YOX | Catismir | Mobile implementasiya lazim |
| 5 | Video/Audio stream | YOX | YOX | YOX | YOX | WebRTC lazim (boyuk is) |

### 3.8 Analitika

| # | Funksiya | Backend | Android | iOS | Status | Is |
|---|----------|---------|---------|-----|--------|----|
| 1 | Gunluk statistika | OK | OK | OK | Tam | - |
| 2 | Heftelik statistika | OK | OK | OK | Tam | - |
| 3 | Beden olculeri | OK | OK | OK | Tam | - |
| 4 | Streak hesablama | OK | OK | OK | Tam | - |
| 5 | Muqayise (hefte/ay) | OK | YOX | OK | Android catismir | Android UI lazim |

### 3.9 Autentifikasiya & Profil

| # | Funksiya | Backend | Android | iOS | Status | Is |
|---|----------|---------|---------|-----|--------|----|
| 1 | Qeydiyyat (2-addim OTP) | OK | OK | OK | Tam | - |
| 2 | Giris (2FA OTP) | OK | OK | OK | Tam | - |
| 3 | Sifre berpasi | OK | OK | OK | Tam | - |
| 4 | Token refresh | OK | OK | OK | Tam | - |
| 5 | Profil goruntule | OK | OK | OK | Tam | - |
| 6 | Profil redakte | OK | Yarimciq | OK | Android yarimciq | Android UI tamamlanmali |
| 7 | Sekil yukle | OK | UI only | OK | Android yarimciq | Android implementasiya lazim |
| 8 | Onboarding | API var | API-ye bagli deyil | Basic | Dekorativ | API inteqrasiya + yeni dizayn |
| 9 | Ayarlar | Endpoint YOX | Lokal state | Lokal state | Islemir | Backend endpoint + Mobile |
| 10 | Sifre deyis | YOX | YOX | YOX | YOX | Backend + Mobile lazim |
| 11 | Hesab sil | YOX | YOX | YOX | YOX | Backend + Mobile lazim |
| 12 | Dil secimi saxlama | YOX | Reset olur | Reset olur | YOX | Persistence lazim |
| 13 | Social Login (Apple/Google) | YOX | YOX | YOX | YOX | Backend + Mobile lazim |

### 3.10 Trainer Funksiyalari

| # | Funksiya | Backend | Android | iOS | Status | Is |
|---|----------|---------|---------|-----|--------|----|
| 1 | Trainer siyahisi | OK | OK | OK | Tam | - |
| 2 | Trainer profili | OK | OK | OK | Tam | - |
| 3 | Trainer rev yazma | OK | OK | OK | Tam | - |
| 4 | Trainer dashboard stats | OK | YOX | YOX | Catismir | Mobile UI lazim |
| 5 | My Students sehifesi | OK | Yarimciq | Yarimciq | Yarimciq | Tamamlanmali |
| 6 | Trainer content idaresi | OK | Yarimciq | Yarimciq | Yarimciq | Tamamlanmali |

---

## 4. KRITIK PROBLEMLER (Derhal hell olunmali)

| # | Problem | Tesir | Hell |
|---|---------|-------|------|
| 1 | Push notification islemir | Istifadeciler mesaj/yenilik almir | FCM token qeydiyyati + push handling |
| 2 | Chat real-time deyil | UX cox zeifdir, manual refresh lazim | WebSocket implementasiyasi |
| 3 | Onboarding data saxlamir | Istifadeci secimleri itir | API inteqrasiya + yeni dizayn ekranlari |
| 4 | Ayarlar saxlanmir | Her acilisda sifirlanir | Backend endpoint + Mobile persistence |
| 5 | Email OTP mock rejimindedir | Production-da real email gondormir | Config deyisikliyi |
| 6 | Marketplace satinalma islemir | Endpoint uygunsuzlugu | API mapping duzeltme |
| 7 | Arxa fon sekilleri yoxdur | Dizayndan ferqlenir | Asset-ler hazirlanmali |

---

## 5. ANDROID PRIORITET IS SIYAHISI

### Faza 1: Dizayn Uygunlasdirma & Onboarding (1-2 hefte)

| # | Is | Tip | Prioritet |
|---|-----|-----|-----------|
| 1.1 | Gender Selection ekrani yaratmaq (arxa fon sekilli) | Yeni ekran | Yuksek |
| 1.2 | Age Picker ekrani yaratmaq (scroll wheel) | Yeni ekran | Yuksek |
| 1.3 | Weight Picker ekrani yaratmaq (ruler slider) | Yeni ekran | Yuksek |
| 1.4 | Height Picker ekrani yaratmaq | Yeni ekran | Yuksek |
| 1.5 | Goal Selection ekrani yaratmaq | Yeni ekran | Yuksek |
| 1.6 | Onboarding flow-nu yenilemek (3 slide + arxa fon sekilleri) | Deyisiklik | Yuksek |
| 1.7 | Onboarding-i backend API-ye baglamaq | Inteqrasiya | Yuksek |
| 1.8 | Fitness arxa fon sekilleri hazirlamaq/elave etmek | Asset | Yuksek |

### Faza 2: Home Screen & Workout Yenilenme (1-2 hefte)

| # | Is | Tip | Prioritet |
|---|-----|-----|-----------|
| 2.1 | Home Screen-e sexsi salamlama elave etmek ("Salam, [Ad]") | Deyisiklik | Yuksek |
| 2.2 | Workout Categories tab-lari elave etmek (Beginner/Intermediate/Advance) | Yeni komponent | Yuksek |
| 2.3 | Workout Detail Screen yaratmaq (herekot siyahisi + "Mesqe Basla") | Yeni ekran | Yuksek |
| 2.4 | Workout Category View yaratmaq | Yeni ekran | Orta |
| 2.5 | Mesq REDAKTE et funksiyasi elave etmek | Yeni feature | Yuksek |
| 2.6 | "New Workouts" bolmesi Home Screen-e elave etmek | Deyisiklik | Orta |
| 2.7 | Mesq statistikasi endpoint-ini istifade etmek | Inteqrasiya | Orta |

### Faza 3: Profil & Ayarlar (1 hefte)

| # | Is | Tip | Prioritet |
|---|-----|-----|-----------|
| 3.1 | Profil redakte ekranini tamamlamaq | Duzeltme | Yuksek |
| 3.2 | Profil sekil yukleme implementasiyasi | Duzeltme | Yuksek |
| 3.3 | Ayarlar ucun backend endpoint yaratmaq | Backend | Orta |
| 3.4 | Ayarlari mobile-da saxlamaq | Inteqrasiya | Orta |
| 3.5 | Sifre deyisdirme funksiyasi (backend + mobile) | Yeni feature | Orta |
| 3.6 | Hesab silme funksiyasi (backend + mobile) | Yeni feature | Orta |
| 3.7 | Dil secimi persistence | Duzeltme | Orta |

### Faza 4: Qida & Mesq Planlari Tamamlama (1 hefte)

| # | Is | Tip | Prioritet |
|---|-----|-----|-----------|
| 4.1 | Qida plani REDAKTE et UI-si | Yeni feature | Yuksek |
| 4.2 | Qida plani item elave/sil (backend endpoint + UI) | Yeni feature | Yuksek |
| 4.3 | Telim plani REDAKTE et UI-si | Yeni feature | Yuksek |
| 4.4 | AI qida analizi - kamera inteqrasiyasi | Duzeltme | Orta |
| 4.5 | Gunluk xulase endpoint-ini cagirmaq | Inteqrasiya | Asagi |
| 4.6 | Kalori hedofi backend sinxronizasiya | Backend + Mobile | Orta |

### Faza 5: Chat & Bildirisler (1-2 hefte)

| # | Is | Tip | Prioritet |
|---|-----|-----|-----------|
| 5.1 | FCM device token qeydiyyati (app startup) | Kritik duzeltme | Yuksek |
| 5.2 | Push notification alma/gosterme | Kritik duzeltme | Yuksek |
| 5.3 | WebSocket inteqrasiyasi (real-time chat) | Yeni feature | Yuksek |
| 5.4 | Mesaj oxundu bildirisi UI | Yeni feature | Orta |
| 5.5 | Email OTP mock rejimini sodurmek | Config | Yuksek |

### Faza 6: Sosial & Trainer (1 hefte)

| # | Is | Tip | Prioritet |
|---|-----|-----|-----------|
| 6.1 | Post sekil yukleme UI-si | Yeni feature | Orta |
| 6.2 | Follow/Unfollow duymeleri | Yeni feature | Orta |
| 6.3 | Istifadeci profili sehifesi | Yeni ekran | Orta |
| 6.4 | Nailiyyetler (Achievements) sehifesi | Yeni ekran | Asagi |
| 6.5 | Trainer siyahisina ixtisas/reytinq/tecrube elave etmek | Deyisiklik | Orta |
| 6.6 | Trainer dashboard stats mobile UI | Yeni ekran | Orta |

### Faza 7: Diger Modullar (1 hefte)

| # | Is | Tip | Prioritet |
|---|-----|-----|-----------|
| 7.1 | Marketplace satinalma endpoint mapping duzeltmek | Duzeltme | Yuksek |
| 7.2 | Marketplace rey yazma UI | Yeni feature | Orta |
| 7.3 | Live Sessions qosulma funksiyasi | Yeni feature | Orta |
| 7.4 | Analitika muqayise bolmesi (Android) | Yeni feature | Asagi |
| 7.5 | Premium ekraninda ayliq/illik plan muqayisesi | Deyisiklik | Orta |

---

## 6. iOS IS SIYAHISI (Android-dan sonra)

| # | Is | Prioritet |
|---|-----|-----------|
| 1 | Yeni onboarding ekranlari (Gender/Age/Weight/Goal) | Yuksek |
| 2 | Bildiris modulu tam yaratmaq | Yuksek |
| 3 | FCM device token qeydiyyati | Yuksek |
| 4 | Push notification handling | Yuksek |
| 5 | Sosial: serhler UI-si | Orta |
| 6 | Sosial: follow/unfollow UI | Orta |
| 7 | Post sekil yukleme | Orta |
| 8 | Mesq redakte UI | Orta |
| 9 | Telim/Qida plani redakte UI | Orta |
| 10 | Arxa fon sekilleri elave etmek | Orta |
| 11 | Chat WebSocket inteqrasiyasi | Yuksek |
| 12 | Ayarlar persistence | Orta |

---

## 7. BACKEND IS SIYAHISI

| # | Is | Prioritet |
|---|-----|-----------|
| 1 | Qida plani item CRUD endpoint-leri | Yuksek |
| 2 | Istifadeci ayarlari CRUD endpoint-leri | Orta |
| 3 | Sifre deyisdirme endpoint-i | Orta |
| 4 | Hesab silme endpoint-i | Orta |
| 5 | Kalori hedofi saxlama endpoint-i | Orta |
| 6 | WebSocket chat implementasiyasi | Yuksek |
| 7 | Email OTP mock rejimini production ucun sodurmek | Yuksek |
| 8 | Social login (Apple/Google OAuth) endpoint-leri | Asagi |

---

## 8. UMUMI STATISTIKA

| Metrik | Reqem |
|--------|-------|
| Tam islenen funksiyalar | 42 |
| Yarimciq funksiyalar | 28 |
| Tam catismayan funksiyalar | 19 |
| Backend-de olub Mobile-da olmayan | 15 |
| Yaradilmali yeni ekranlar (Android) | 7 |
| Deyisdirilmeli movcud ekranlar (Android) | 7 |
| Kritik problemler | 7 |
| Umumi is (Android prioritet) | ~45 task |
| Texmini vaxt (Android) | 6-8 hefte |

---

## 9. FAZALARIN XULASESI

```
Faza 1: Dizayn & Onboarding ............ 1-2 hefte
Faza 2: Home & Workout ................. 1-2 hefte
Faza 3: Profil & Ayarlar ............... 1 hefte
Faza 4: Plan Redakte ................... 1 hefte
Faza 5: Chat & Bildirisler ............. 1-2 hefte
Faza 6: Sosial & Trainer ............... 1 hefte
Faza 7: Diger Modullar ................. 1 hefte
                                          --------
                         UMUMI:          ~7-10 hefte (Android)
                         iOS:            +3-4 hefte
```

---

## QEYD

Bu hesabat CoreVia layihesinin tam funksional auditini ehate edir. Odenis modulu (Apple IAP, Google Play Billing) bu hesabatdan xaric edilmisdir - gelecek fazada ayrica planlanacaq.

Her bir faza baslamazdan evvel texniki spesifikasiya ve user story-ler hazirlanacaq.

---

**Hesabati hazirlayan:** Business Analyst
**Tarix:** 21.02.2026
**Version:** 1.0
