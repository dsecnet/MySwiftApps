# Xcode Project Düzəlişi

## Problem
MortgageCalculatorView.swift ViewModels qovluğundan Views/Mortgage qovluğuna köçürüldü, amma Xcode project faylı yenilənmədi.

## Həll 1: Xcode UI vasitəsilə (Ən asan)

1. Xcode-da project aç
2. Sol paneldə (Navigator) `ViewModels` qovluğunu tap
3. `MortgageCalculatorView.swift`-ə sağ klik → **Delete** → **Remove Reference** seç (faylı silmə!)
4. Sol paneldə `Views` qovluğuna sağ klik → **New Group** → Adını `Mortgage` qoy
5. `Mortgage` qrupuna sağ klik → **Add Files to "EmlakCRM"**
6. Navigate edib bu fayl seç: `Views/Mortgage/MortgageCalculatorView.swift`
7. **Add** düyməsinə bas

Eyni şəkildə bu faylları da əlavə et:
- `Views/WhatsApp/WhatsAppShareSheet.swift` (əvvəlcə WhatsApp group yarat)
- `Services/MortgageService.swift`
- `Services/WhatsAppService.swift`
- `Services/MapService.swift`

8. Build et: **Cmd + B**

## Həll 2: File System vasitəsilə (Sürətli)

Terminal-da:

```bash
cd /Users/vusaldadashov/Desktop/ConsoleApp/EmlakCRM/mobile/ios
rm -rf ~/Library/Developer/Xcode/DerivedData/*
open -a Xcode EmlakCRM.xcodeproj
```

Xcode açılanda:
1. File → Close Workspace
2. File → Open → EmlakCRM.xcodeproj seç
3. Project Navigator-da fayllar görünmürsə, fayllara sağ klik → **Show in Finder** edib yoxla

## Həll 3: Clean & Rebuild

Xcode-da:
1. **Product** → **Clean Build Folder** (Shift + Cmd + K)
2. Xcode-u bağla
3. DerivedData silin:
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/*
```
4. Xcode-u yenidən aç və build et

## Yoxlama

Build uğurlu olmalıdır. Əgər hələ error varsa:
- Error mesajını tam kopyala
- Hansı faylda error olduğunu göstər
- Screenshot göndər
