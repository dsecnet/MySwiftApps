#!/usr/bin/env python3
"""
CoreVia iOS — QA/BA Test Report PDF Generator
Comprehensive bug list and analysis
"""

from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.colors import HexColor, black, white
from reportlab.lib.units import mm
from reportlab.lib.enums import TA_LEFT, TA_CENTER, TA_JUSTIFY
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle,
    PageBreak, HRFlowable
)
import os
from datetime import datetime

# Colors
PRIMARY = HexColor("#007AFF")  # iOS Blue
PRIMARY_DARK = HexColor("#0056CC")
CRITICAL = HexColor("#FF3B30")  # iOS Red
HIGH = HexColor("#FF9500")      # iOS Orange
MEDIUM = HexColor("#FFCC00")    # iOS Yellow
LOW = HexColor("#34C759")       # iOS Green
BG_LIGHT = HexColor("#F2F2F7")  # iOS Light Gray
BG_CODE = HexColor("#F8F9FA")
BORDER = HexColor("#C6C6C8")
TEXT_PRIMARY = HexColor("#1C1C1E")
TEXT_SECONDARY = HexColor("#8E8E93")

OUTPUT_PATH = os.path.expanduser("~/Desktop/CoreVia_iOS_QA_BA_Report.pdf")


def create_styles():
    styles = getSampleStyleSheet()

    styles.add(ParagraphStyle(name='DocTitle', fontSize=26, leading=32,
        textColor=PRIMARY_DARK, spaceAfter=4*mm, alignment=TA_CENTER, fontName='Helvetica-Bold'))
    styles.add(ParagraphStyle(name='DocSubtitle', fontSize=13, leading=18,
        textColor=TEXT_SECONDARY, spaceAfter=8*mm, alignment=TA_CENTER, fontName='Helvetica'))
    styles.add(ParagraphStyle(name='SectionHeader', fontSize=16, leading=22,
        textColor=PRIMARY_DARK, spaceBefore=8*mm, spaceAfter=4*mm, fontName='Helvetica-Bold'))
    styles.add(ParagraphStyle(name='SubSection', fontSize=12, leading=17,
        textColor=PRIMARY, spaceBefore=5*mm, spaceAfter=2*mm, fontName='Helvetica-Bold'))
    styles.add(ParagraphStyle(name='Body2', fontSize=9.5, leading=14,
        textColor=TEXT_PRIMARY, spaceAfter=2*mm, fontName='Helvetica', alignment=TA_JUSTIFY))
    styles.add(ParagraphStyle(name='BulletText', fontSize=9.5, leading=14,
        textColor=TEXT_PRIMARY, spaceAfter=1.5*mm, fontName='Helvetica', leftIndent=8*mm, bulletIndent=3*mm))
    styles.add(ParagraphStyle(name='CodeBlock', fontSize=7.5, leading=10.5,
        textColor=HexColor("#333333"), fontName='Courier', backColor=BG_CODE,
        leftIndent=4*mm, rightIndent=4*mm, spaceBefore=1.5*mm, spaceAfter=2*mm,
        borderWidth=0.5, borderColor=BORDER, borderPadding=3*mm))
    styles.add(ParagraphStyle(name='FileRef', fontSize=8, leading=11,
        textColor=PRIMARY, fontName='Courier', spaceBefore=1*mm, spaceAfter=1*mm))
    styles.add(ParagraphStyle(name='CriticalText', fontSize=10, leading=14,
        textColor=CRITICAL, fontName='Helvetica-Bold', spaceAfter=2*mm))

    return styles


def add_header_footer(canvas, doc):
    canvas.saveState()
    canvas.setStrokeColor(PRIMARY)
    canvas.setLineWidth(2)
    canvas.line(20*mm, A4[1] - 15*mm, A4[0] - 20*mm, A4[1] - 15*mm)
    canvas.setFont('Helvetica-Bold', 8)
    canvas.setFillColor(PRIMARY_DARK)
    canvas.drawString(20*mm, A4[1] - 13*mm, "CoreVia iOS")
    canvas.setFont('Helvetica', 8)
    canvas.setFillColor(TEXT_SECONDARY)
    canvas.drawRightString(A4[0] - 20*mm, A4[1] - 13*mm, "QA/BA Test Report")
    canvas.setStrokeColor(BORDER)
    canvas.setLineWidth(0.5)
    canvas.line(20*mm, 15*mm, A4[0] - 20*mm, 15*mm)
    canvas.setFont('Helvetica', 7)
    canvas.setFillColor(TEXT_SECONDARY)
    canvas.drawString(20*mm, 10*mm, f"Generated: {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    canvas.drawCentredString(A4[0]/2, 10*mm, "CONFIDENTIAL")
    canvas.drawRightString(A4[0] - 20*mm, 10*mm, f"Page {doc.page}")
    canvas.restoreState()


def build_pdf():
    doc = SimpleDocTemplate(OUTPUT_PATH, pagesize=A4,
        topMargin=22*mm, bottomMargin=22*mm, leftMargin=18*mm, rightMargin=18*mm,
        title="CoreVia iOS — QA/BA Test Report", author="CoreVia QA Team")

    styles = create_styles()
    story = []

    # ═══════════ TITLE PAGE ═══════════
    story.append(Spacer(1, 35*mm))
    story.append(Paragraph("CoreVia iOS", styles['DocTitle']))
    story.append(Paragraph("QA/BA Test Report", ParagraphStyle(
        'BigSub', parent=styles['DocSubtitle'], fontSize=18, leading=24, spaceAfter=5*mm)))
    story.append(Paragraph("Bug & Problem Analizi", styles['DocSubtitle']))
    story.append(HRFlowable(width="50%", thickness=1, color=PRIMARY, spaceAfter=10*mm))

    info = [
        ["Layihe:", "CoreVia - Fitness & Wellness App (iOS)"],
        ["Platform:", "iOS 17+ / SwiftUI / Swift 5.9"],
        ["Swift Fayllari:", "111 fayl"],
        ["Tarix:", datetime.now().strftime("%d %B %Y")],
        ["Versiya:", "1.0.0"],
        ["Testin Novu:", "Statik Kod Analizi + QA/BA Audit"],
    ]
    info_t = Table(info, colWidths=[38*mm, 100*mm])
    info_t.setStyle(TableStyle([
        ('FONTNAME', (0,0), (0,-1), 'Helvetica-Bold'), ('FONTNAME', (1,0), (1,-1), 'Helvetica'),
        ('FONTSIZE', (0,0), (-1,-1), 10), ('TEXTCOLOR', (0,0), (0,-1), TEXT_SECONDARY),
        ('TEXTCOLOR', (1,0), (1,-1), TEXT_PRIMARY), ('BOTTOMPADDING', (0,0), (-1,-1), 3*mm),
        ('TOPPADDING', (0,0), (-1,-1), 2*mm), ('ALIGN', (0,0), (0,-1), 'RIGHT'),
    ]))
    story.append(info_t)
    story.append(PageBreak())

    # ═══════════ EXECUTIVE SUMMARY ═══════════
    story.append(Paragraph("Executive Summary", styles['SectionHeader']))
    story.append(HRFlowable(width="100%", thickness=0.5, color=PRIMARY, spaceAfter=4*mm))

    summary_data = [
        ["Severity", "Say", "Kateqoriya"],
        ["CRITICAL", "10", "Security, Crash, Data Loss"],
        ["HIGH", "12", "Security, UX, Functionality"],
        ["MEDIUM", "14", "UI, Performance, Code Quality"],
        ["LOW", "6", "Best Practices, Cleanup"],
        ["TOTAL", "42", ""],
    ]
    st = Table(summary_data, colWidths=[30*mm, 15*mm, 100*mm])
    st.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), PRIMARY), ('TEXTCOLOR', (0,0), (-1,0), white),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'), ('FONTNAME', (0,1), (-1,-1), 'Helvetica'),
        ('FONTNAME', (0,1), (0,-1), 'Helvetica-Bold'),
        ('FONTSIZE', (0,0), (-1,-1), 9.5), ('GRID', (0,0), (-1,-1), 0.5, BORDER),
        ('BOTTOMPADDING', (0,0), (-1,-1), 3*mm), ('TOPPADDING', (0,0), (-1,-1), 3*mm),
        ('LEFTPADDING', (0,0), (-1,-1), 3*mm),
        ('ALIGN', (1,0), (1,-1), 'CENTER'),
        ('BACKGROUND', (0,1), (0,1), HexColor("#FFEBEE")), ('TEXTCOLOR', (0,1), (0,1), CRITICAL),
        ('BACKGROUND', (0,2), (0,2), HexColor("#FFF3E0")), ('TEXTCOLOR', (0,2), (0,2), HIGH),
        ('BACKGROUND', (0,3), (0,3), HexColor("#FFFDE7")), ('TEXTCOLOR', (0,3), (0,3), HexColor("#F9A825")),
        ('BACKGROUND', (0,4), (0,4), HexColor("#E8F5E9")), ('TEXTCOLOR', (0,4), (0,4), LOW),
        ('BACKGROUND', (0,5), (-1,5), BG_LIGHT), ('FONTNAME', (0,5), (-1,5), 'Helvetica-Bold'),
    ]))
    story.append(st)

    story.append(Spacer(1, 5*mm))
    story.append(Paragraph(
        "CoreVia iOS app-da <b>42 problem</b> askar edilib. Bunlardan <b>10-u KRITIK</b> seviyyededir "
        "ve production-a cixmazdan evvel MUTLEQ hell edilmelidir. En vacib meseleler: "
        "SSL Pinning yoxdur, Jailbreak Detection yoxdur, 128 print() statement production-da data leak edir, "
        "Premium status client-side UserDefaults-da saxlanir (bypass oluna biler), "
        "NewsService hardcoded localhost URL istifade edir.",
        styles['Body2']))

    # ═══════════ CRITICAL BUGS ═══════════
    story.append(PageBreak())
    story.append(Paragraph("CRITICAL Bugs (10)", styles['SectionHeader']))
    story.append(HRFlowable(width="100%", thickness=0.5, color=CRITICAL, spaceAfter=4*mm))

    bugs_critical = [
        ["BUG-C01", "SSL Certificate Pinning yoxdur",
         "APIService.swift",
         "App hec bir SSL pinning ve ya URLSessionDelegate implementasiyasi yoxdur. "
         "Man-in-the-middle hucumlarina aciqdir. Android-da artiq implementasiya olunub.",
         "URLSessionDelegate ile certificate pinning elave et, TrustKit ve ya Alamofire istifade ede bilersin."],

        ["BUG-C02", "Jailbreak Detection yoxdur",
         "Butun app",
         "Jailbroken cihazdlarda app aciq isleyir. Root/jailbreak detection yoxdur. "
         "Android-da SecurityUtils.kt artiq movcuddur.",
         "JailbreakDetection utility yarat: Cydia, checkra1n, /etc/apt yoxla."],

        ["BUG-C03", "128 print() statement production-da data leak",
         "32 Swift fayl",
         "128 print() cagiris tapildi. Bunlar production-da Console.app ve MDM vasitesile "
         "gorunur. Sensitiv data (API responses, tokens, errors) loglanir.",
         "os.Logger ve ya custom Logger istifade et. Release build-da disable et."],

        ["BUG-C04", "NewsService hardcoded localhost:8000 URL",
         "NewsService.swift:5",
         "private let baseURL = \"http://localhost:8000\" — Production-da News feature ISLEMIR. "
         "APIService.swift-deki conditional compilation istifade edilmir.",
         "APIService.shared.baseURL istifade et, ve ya eyni #if pattern-i tetbiq et."],

        ["BUG-C05", "Premium status UserDefaults-da (encrypt olunmayib)",
         "SettingsManager.swift:37-50",
         "isPremium flag UserDefaults-da saxlanir. Jailbreak-li cihazda istifadeci "
         "bunu birbaxa deyise biler ve pulsuz premium ala biler.",
         "Premium statusu Keychain-de saxla ve ya her defesinde backend-den yoxla."],

        ["BUG-C06", "userType UserDefaults-da premium bypass imkani",
         "AuthManager.swift:190, SettingsManager.swift:44",
         "userType='trainer' deyeri UserDefaults-da saxlanir. Trainer-ler auto-premium alir. "
         "Istifadeci UserDefaults-da userType-i 'trainer'-e deyisib butun premium feature-lara "
         "pulsuz giris elde ede biler.",
         "userType-i Keychain-e kocur, backend-de her premium API-da yoxla."],

        ["BUG-C07", "userId UserDefaults-da set olunmur amma istifade edilir",
         "PostCardView.swift:43, CommentsView.swift:168, LiveWorkoutView.swift:232",
         "Kod UserDefaults.standard.string(forKey: 'userId') yoxlayir amma bu key "
         "hec vaxt set olunmur. Netice: diger user-lerin comment/post-larini sile bilmez, "
         "ve ya spoofing ile basqasinin olaraq gorune biler.",
         "userId-ni login zamani Keychain-e saxla, UserDefaults-dan istifade etme."],

        ["BUG-C08", "Force unwrap URL initialization — crash riski",
         "LoginView.swift:393,538 + NewsService.swift:16",
         "URL(...) ve URLComponents(...) force unwrap (!) ile yaradilir. "
         "Eger URL invalid olsa app CRASH edecek.",
         "guard let url = URL(...) else { throw } istifade et."],

        ["BUG-C09", "Plaintext password UserDefaults-da (legacy)",
         "SettingsManager.swift:115",
         "Kohne migration kodu app_password key-ini UserDefaults-da plaintext olaraq yoxlayir. "
         "Bu data encrypt olunmayib ve backup vasitesile alinacaq.",
         "Legacy kodu tamamen sil, yalniz Keychain istifade et."],

        ["BUG-C10", "Real odenis sistemi yoxdur (Premium)",
         "PremiumView.swift:202-226",
         "Premium aktivlesme yalniz /api/v1/premium/activate endpoint-ini cagirir. "
         "Hec bir StoreKit subscription, receipt validation ve ya Apple Pay yoxdur. "
         "DEBUG-da 'Premium ol' buttonu var amma real odenis axini yoxdur.",
         "StoreKit 2 subscription sistemi implement et (Android planindaki kimi)."],
    ]

    for bug in bugs_critical:
        story.append(Paragraph(f"<font color='#FF3B30'><b>{bug[0]}</b></font>: {bug[1]}", styles['SubSection']))
        story.append(Paragraph(f"Fayl: {bug[2]}", styles['FileRef']))
        story.append(Paragraph(f"<b>Problem:</b> {bug[3]}", styles['Body2']))
        story.append(Paragraph(f"<b>Hell yolu:</b> {bug[4]}", styles['BulletText']))
        story.append(Spacer(1, 2*mm))

    # ═══════════ HIGH BUGS ═══════════
    story.append(PageBreak())
    story.append(Paragraph("HIGH Bugs (12)", styles['SectionHeader']))
    story.append(HRFlowable(width="100%", thickness=0.5, color=HIGH, spaceAfter=4*mm))

    bugs_high = [
        ["BUG-H01", "JWT token signature dogrulanmir",
         "AuthManager.swift:221-237",
         "isPremiumFromToken property JWT payload-i oxuyur amma signature-u yoxlamir. "
         "Token tamper edile biler."],

        ["BUG-H02", "WebSocket-de token URL query parameter-inde",
         "WebSocketService.swift:49",
         "Bearer token URL-de ?token=xxx olaraq gonderilir. Server loglarinda, proxy-lerde gorune biler. "
         "Authorization header istifade edilmelidir."],

        ["BUG-H03", "Timer memory leak WebSocketService-de",
         "WebSocketService.swift:277",
         "Timer.scheduledTimer yaradilir amma reference saxlanmir ve invalidate olunmur. "
         "Timer deallocate olunana qeder isleyecek — memory leak."],

        ["BUG-H04", "Image cache limitsiz — memory overflow riski",
         "FoodImageManager.swift:11-16, ProfileImageManager.swift:24-26",
         "imageCache dictionary-si hec bir size limit ve ya eviction policy olmadan boyuyur. "
         "Long session-da memory warning ve crash ola biler."],

        ["BUG-H05", "Multipart upload-da 11 force unwrap",
         "APIService.swift:228-281",
         ".data(using: .utf8)! ile 11 force unwrap var. Encode ugursuz olsa app crash edecek."],

        ["BUG-H06", "Staging/Test environment yoxdur",
         "APIService.swift:51-57",
         "DEBUG ve RELEASE build-lar eyni production API-ni istifade edir (api.corevia.life). "
         "Test zamani production data-ya tesir edir."],

        ["BUG-H07", "StoreKit receipt validation natamam",
         "ProductDetailViewModel.swift:84-104",
         "Purchase zamani yalniz transaction ID gonderilir, tam receipt/JWT gonderilmir. "
         "Backend full validation ede bilmir."],

        ["BUG-H08", "Sensitive data decode error-da loglanir",
         "APIService.swift:324-325",
         "RAW JSON (ilk 500 simvol) print ile loglanir. Sensitiv user data expose ola biler."],

        ["BUG-H09", "Speed unit SEHV: 'km/s' evezine 'km/h' olmalidir",
         "LiveTrackingView.swift:123,281 + RouteDetailView.swift:167,194",
         "'km/s' (kilometr/saniye) fiziki cehetden mümkün deyil. 'km/h' olmalidir. "
         "4 yerde eyni sehv var."],

        ["BUG-H10", "TODO: Backend save incomplete — LiveTracking",
         "LiveTrackingView.swift:251",
         "// TODO: Save to backend — mesq bitende data backend-e gonderilmir. "
         "User data itirir."],

        ["BUG-H11", "TODO: Pause workout bos implementation",
         "LiveWorkoutView.swift:163",
         "Pause buttonu var amma funksionalliq bos. User pause ede bilmir."],

        ["BUG-H12", "Premium feature-lar yalniz client-side gate-lenir",
         "ActivitiesView.swift:95, AddFoodView.swift:215, ChatView.swift:27",
         "Backend premium API-lari yoxlamir. User kod deyisiklikleri ile bypass ede biler."],
    ]

    for bug in bugs_high:
        story.append(Paragraph(f"<font color='#FF9500'><b>{bug[0]}</b></font>: {bug[1]}", styles['SubSection']))
        story.append(Paragraph(f"Fayl: {bug[2]}", styles['FileRef']))
        story.append(Paragraph(f"{bug[3]}", styles['Body2']))
        story.append(Spacer(1, 1.5*mm))

    # ═══════════ MEDIUM BUGS ═══════════
    story.append(PageBreak())
    story.append(Paragraph("MEDIUM Bugs (14)", styles['SectionHeader']))
    story.append(HRFlowable(width="100%", thickness=0.5, color=HexColor("#F9A825"), spaceAfter=4*mm))

    bugs_medium = [
        ["BUG-M01", "Hardcoded Azerbaijani text — lokalizasiya yoxdur",
         "LiveTrackingView.swift, RouteDetailView.swift",
         "20+ hardcoded Azerbaijan dilinde metn var (Kalori, Kilometr, Vaxt, Bash, Bitir). "
         "LocalizationManager istifade edilmir."],

        ["BUG-M02", "Camera permission denial handle olunmur",
         "AddFoodView.swift:36, AICalorieAnalysisView.swift:104",
         "Kamera icaze red edilse hec bir feedback gosterilmir. Silent fail."],

        ["BUG-M03", "GPS error yalniz console-a print olunur",
         "LocationManager.swift:132-134",
         "GPS xetasi zamani user-e mesaj gosterilmir, yalniz print() ile loglanir."],

        ["BUG-M04", "Empty state missing — 4+ ekranda",
         "EatingView, ChatView, LiveSessionDetailView, AICalorieHistoryView",
         "Data yoxdursa bos ekran gosterilir, empty state UI yoxdur."],

        ["BUG-M05", "Dark mode problemleri — hardcoded renger",
         "LiveWorkoutView.swift, RouteDetailView.swift",
         "Color.black, Color.white hardcoded istifade edilir. Dark mode-da gorünmür."],

        ["BUG-M06", "Variable shadowing httpResponse",
         "APIService.swift:237-241",
         "guard icinde httpResponse yeniden declare edilir (shadowing). Confusing logic."],

        ["BUG-M07", "Generic NSError login-de",
         "LoginView.swift:409,552",
         "NSError(domain: 'Invalid response', code: 0) — proper error type yoxdur."],

        ["BUG-M08", "Hardcoded default deyerler",
         "LiveTrackingView.swift:335, OnboardingView.swift:220-238",
         "Default ceki 70kg, yas 25, boy 175 hardcoded. Config-den oxunmalıdır."],

        ["BUG-M09", "Accessibility labels eksik",
         "LiveWorkoutView.swift:86,165,195 + RouteDetailView.swift:106",
         "Kritik buttonlar (Close, Pause, Stop) accessibility label-siz. VoiceOver islemir."],

        ["BUG-M10", "Route polyline rengi tema ile uygun deyil",
         "RouteDetailView.swift:388",
         "UIColor.systemRed hardcoded. App theme ile uygun deyil."],

        ["BUG-M11", "Exercise tipi hardcoded 'Squats'",
         "LiveWorkoutView.swift:117",
         "TODO: Dynamic from session exercises — hemise 'Squats' gosterilir."],

        ["BUG-M12", "WebSocket callback-lerde retain cycle riski",
         "WebSocketService.swift:28-31",
         "Optional closure-lar [weak self] olmadan capture ede biler."],

        ["BUG-M13", "Token refresh empty bearer fallback",
         "APIService.swift:141",
         "Refresh ugursuz olsa 'Bearer ' (bos) gonderilir, fail etmek evezine."],

        ["BUG-M14", "FoodImageManager silent fail",
         "FoodImageManager.swift:20",
         "Image resize ugursuz olsa return edir, user-e feedback yoxdur."],
    ]

    for bug in bugs_medium:
        story.append(Paragraph(f"<font color='#F9A825'><b>{bug[0]}</b></font>: {bug[1]}", styles['SubSection']))
        story.append(Paragraph(f"Fayl: {bug[2]}", styles['FileRef']))
        story.append(Paragraph(f"{bug[3]}", styles['Body2']))

    # ═══════════ LOW BUGS ═══════════
    story.append(PageBreak())
    story.append(Paragraph("LOW Bugs (6)", styles['SectionHeader']))
    story.append(HRFlowable(width="100%", thickness=0.5, color=LOW, spaceAfter=4*mm))

    bugs_low = [
        ["BUG-L01", "Magic numbers — hardcoded timeout/distance deyerleri",
         "APIService.swift:65-66, LocationManager.swift:32, WebSocketService.swift:277",
         "30s timeout, 10m distance filter, 30s heartbeat — constant/config olmalidir."],

        ["BUG-L02", "Inconsistent error handling pattern-leri",
         "49 catch block tapildi",
         "Bezi print(), bezi alert, bezi silent fail. Vahid error handling pattern lazimdir."],

        ["BUG-L03", "Preview commented out RouteDetailView",
         "RouteDetailView.swift:305-335",
         "iOS 17+ Preview kodu comment-lenmis. Silmek ve ya aktiv etmek lazimdir."],

        ["BUG-L04", "Development fake data comment",
         "User.swift:63",
         "'Development zamani test etmek ucun fake data' — production-da olmamalidir."],

        ["BUG-L05", "Loading state UI yalniz ProgressView()",
         "LiveSessionDetailView, AICalorieAnalysisView",
         "Loading zamani skeleton/shimmer yoxdur, yalniz spinner gosterilir."],

        ["BUG-L06", "Navigation bar hidden — geri buttonu yoxdur",
         "LiveWorkoutView.swift:70",
         ".navigationBarHidden(true) — yalniz X icon var, accessibility label yoxdur."],
    ]

    for bug in bugs_low:
        story.append(Paragraph(f"<font color='#34C759'><b>{bug[0]}</b></font>: {bug[1]}", styles['SubSection']))
        story.append(Paragraph(f"Fayl: {bug[2]}", styles['FileRef']))
        story.append(Paragraph(f"{bug[3]}", styles['Body2']))

    # ═══════════ ANDROID VS iOS COMPARISON ═══════════
    story.append(PageBreak())
    story.append(Paragraph("Android vs iOS Muqayisesi", styles['SectionHeader']))
    story.append(HRFlowable(width="100%", thickness=0.5, color=PRIMARY, spaceAfter=4*mm))

    story.append(Paragraph(
        "Asagidaki cedvel Android-da artiq hell edilmis amma iOS-da hele movcud olan problemleri gosterir:",
        styles['Body2']))

    comp_data = [
        ["Mesele", "Android", "iOS"],
        ["SSL Certificate Pinning", "HELL OLUNUB", "YOXDUR"],
        ["Root/Jailbreak Detection", "HELL OLUNUB", "YOXDUR"],
        ["Production Logging (print/Log)", "Timber + ProGuard strip", "128 print() MOVCUD"],
        ["Sensitive Data Encryption", "EncryptedSharedPreferences", "UserDefaults (plain)"],
        ["ProGuard/Obfuscation", "Aggressiv R8 rules", "Yoxdur (Swift default)"],
        ["API Key Security", "local.properties + gitignore", "Yoxlanmali"],
        ["Premium Payment", "Plan hazir (Billing Library)", "StoreKit 2 natamam"],
        ["Maps API Key", "BuildConfig + manifest", "Yoxlanmali"],
        ["Unit Error (km/s)", "HELL OLUNUB (deq/km)", "MOVCUDDUR (4 yer)"],
        ["Background Location", "ACTIVITY_RECOGNITION", "Yoxlanmali"],
        ["Privacy Policy", "Lazimdir", "Lazimdir"],
        ["Crash Reporting", "Lazimdir (Crashlytics)", "Lazimdir"],
    ]
    comp_t = Table(comp_data, colWidths=[55*mm, 45*mm, 45*mm])
    comp_t.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), PRIMARY), ('TEXTCOLOR', (0,0), (-1,0), white),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'), ('FONTNAME', (0,1), (-1,-1), 'Helvetica'),
        ('FONTSIZE', (0,0), (-1,-1), 8.5), ('GRID', (0,0), (-1,-1), 0.5, BORDER),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2.5*mm), ('TOPPADDING', (0,0), (-1,-1), 2.5*mm),
        ('LEFTPADDING', (0,0), (-1,-1), 3*mm),
        ('ALIGN', (1,0), (2,-1), 'CENTER'), ('VALIGN', (0,0), (-1,-1), 'MIDDLE'),
        ('ROWBACKGROUNDS', (0,1), (-1,-1), [white, BG_LIGHT]),
    ]))

    # Color Android column green where fixed
    for i in range(1, len(comp_data)):
        if "HELL" in comp_data[i][1] or "Timber" in comp_data[i][1] or "Aggressiv" in comp_data[i][1] or "Billing" in comp_data[i][1] or "BuildConfig" in comp_data[i][1] or "Encrypted" in comp_data[i][1]:
            comp_t.setStyle(TableStyle([
                ('TEXTCOLOR', (1,i), (1,i), LOW),
                ('FONTNAME', (1,i), (1,i), 'Helvetica-Bold'),
            ]))
        if "YOXDUR" in comp_data[i][2] or "MOVCUD" in comp_data[i][2] or "plain" in comp_data[i][2] or "natamam" in comp_data[i][2]:
            comp_t.setStyle(TableStyle([
                ('TEXTCOLOR', (2,i), (2,i), CRITICAL),
                ('FONTNAME', (2,i), (2,i), 'Helvetica-Bold'),
            ]))

    story.append(comp_t)

    # ═══════════ PRINT STATEMENT DETAILS ═══════════
    story.append(Spacer(1, 6*mm))
    story.append(Paragraph("print() Statement-lerin Fayl Uzre Bolugusu", styles['SubSection']))

    print_data = [
        ["Fayl", "Say"],
        ["WebSocketService.swift", "19"],
        ["CoreMLFoodClassifier.swift", "17"],
        ["CoreMLFoodDetector.swift", "15"],
        ["TrainingPlanManager.swift", "9"],
        ["MealPlanManager.swift", "9"],
        ["OnDeviceFoodAnalyzer.swift", "7"],
        ["WorkoutManagement.swift", "5"],
        ["AddFoodView.swift", "5"],
        ["RouteManager.swift", "4"],
        ["FoodManager.swift", "4"],
        ["Diger 22 fayl", "34"],
        ["TOTAL", "128"],
    ]
    pt = Table(print_data, colWidths=[60*mm, 20*mm])
    pt.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), PRIMARY), ('TEXTCOLOR', (0,0), (-1,0), white),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'), ('FONTNAME', (0,1), (-1,-1), 'Helvetica'),
        ('FONTSIZE', (0,0), (-1,-1), 9), ('GRID', (0,0), (-1,-1), 0.5, BORDER),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2*mm), ('TOPPADDING', (0,0), (-1,-1), 2*mm),
        ('LEFTPADDING', (0,0), (-1,-1), 3*mm), ('ALIGN', (1,0), (1,-1), 'CENTER'),
        ('BACKGROUND', (0,-1), (-1,-1), BG_LIGHT), ('FONTNAME', (0,-1), (-1,-1), 'Helvetica-Bold'),
    ]))
    story.append(pt)

    # ═══════════ PRIORITY REMEDIATION ═══════════
    story.append(PageBreak())
    story.append(Paragraph("Prioritetli Hell Plani", styles['SectionHeader']))
    story.append(HRFlowable(width="100%", thickness=0.5, color=PRIMARY, spaceAfter=4*mm))

    story.append(Paragraph("<font color='#FF3B30'><b>Faza 1 — DERHAL (Production blocker)</b></font>", styles['SubSection']))
    phase1 = [
        "SSL Certificate Pinning implementasiya et (TrustKit ve ya URLSessionDelegate)",
        "Jailbreak Detection elave et (Cydia, checkra1n, /etc/apt, /bin/bash yoxla)",
        "128 print() statement-i os.Logger ile evez et, Release-de disable et",
        "NewsService localhost URL-i duzelt (APIService.shared.baseURL istifade et)",
        "Force unwrap-lari guard let ile evez et (LoginView, NewsService)",
        "isPremium ve userType-i Keychain-e kocur (UserDefaults-dan)",
        "userId-ni login zamani set et (KeychainManager-de)",
        "Legacy plaintext password kodunu sil",
        "km/s -> km/h duzelt (4 yerde)",
        "StoreKit 2 subscription sistemi tam implement et",
    ]
    for p in phase1:
        story.append(Paragraph(f"- {p}", styles['BulletText']))

    story.append(Paragraph("<font color='#FF9500'><b>Faza 2 — Release-den evvel</b></font>", styles['SubSection']))
    phase2 = [
        "WebSocket token-i Authorization header-e kocur",
        "Timer memory leak-i duzelt (reference saxla + invalidate)",
        "Image cache-e size limit ve eviction policy elave et",
        "Multipart upload force unwrap-larini duzelt",
        "Backend save (TODO) — LiveTrackingView-de implement et",
        "Pause workout funksionalligi implement et",
        "Empty state UI elave et (4+ ekran)",
        "Camera permission denial handle et",
        "GPS error user-e goster (alert/toast)",
        "StoreKit receipt validation tam implement et",
        "Backend-de premium API-lari server-side yoxla",
        "Staging environment yarat",
    ]
    for p in phase2:
        story.append(Paragraph(f"- {p}", styles['BulletText']))

    story.append(Paragraph("<font color='#F9A825'><b>Faza 3 — Novbeti sprint</b></font>", styles['SubSection']))
    phase3 = [
        "Hardcoded Azerbaijani text-leri LocalizationManager-e kocur",
        "Dark mode uygunlugu — hardcoded reng-leri duzelt",
        "Accessibility labels elave et",
        "Error handling pattern-lerini standartlasdir",
        "Loading skeleton/shimmer UI elave et",
        "Route polyline rengini app theme-e uygunlasdir",
        "Magic number-leri constant-lara cevir",
        "Variable shadowing-i duzelt",
        "Generic NSError-lari custom error type-lara cevir",
    ]
    for p in phase3:
        story.append(Paragraph(f"- {p}", styles['BulletText']))

    # ═══════════ USERDEFAULTS AUDIT ═══════════
    story.append(Spacer(1, 6*mm))
    story.append(Paragraph("UserDefaults Audit — Sensitiv Data", styles['SubSection']))

    ud_data = [
        ["Key", "Fayl", "Risk"],
        ["app_settings (isPremium)", "SettingsManager.swift", "CRITICAL"],
        ["userType", "AuthManager.swift", "CRITICAL"],
        ["app_password (legacy)", "SettingsManager.swift", "CRITICAL"],
        ["userId (missing!)", "PostCardView, CommentsView", "CRITICAL"],
        ["daily_calorie_goal", "FoodManager.swift", "LOW"],
        ["app_language", "LocalizationManager.swift", "LOW"],
        ["onboarding_completed", "OnboardingModels.swift", "LOW"],
        ["hasSeenPermissions", "PermissionsView.swift", "LOW"],
        ["waterGlasses_<date>", "EatingView.swift", "LOW"],
    ]
    ud_t = Table(ud_data, colWidths=[45*mm, 55*mm, 25*mm])
    ud_t.setStyle(TableStyle([
        ('BACKGROUND', (0,0), (-1,0), PRIMARY), ('TEXTCOLOR', (0,0), (-1,0), white),
        ('FONTNAME', (0,0), (-1,0), 'Helvetica-Bold'), ('FONTNAME', (0,1), (-1,-1), 'Helvetica'),
        ('FONTSIZE', (0,0), (-1,-1), 8.5), ('GRID', (0,0), (-1,-1), 0.5, BORDER),
        ('BOTTOMPADDING', (0,0), (-1,-1), 2.5*mm), ('TOPPADDING', (0,0), (-1,-1), 2.5*mm),
        ('LEFTPADDING', (0,0), (-1,-1), 3*mm), ('ALIGN', (2,0), (2,-1), 'CENTER'),
    ]))
    for i in range(1, len(ud_data)):
        if ud_data[i][2] == "CRITICAL":
            ud_t.setStyle(TableStyle([
                ('TEXTCOLOR', (2,i), (2,i), CRITICAL), ('FONTNAME', (2,i), (2,i), 'Helvetica-Bold'),
                ('BACKGROUND', (2,i), (2,i), HexColor("#FFEBEE")),
            ]))
        else:
            ud_t.setStyle(TableStyle([
                ('TEXTCOLOR', (2,i), (2,i), LOW),
                ('BACKGROUND', (2,i), (2,i), HexColor("#E8F5E9")),
            ]))
    story.append(ud_t)

    # ═══════════ FOOTER ═══════════
    story.append(Spacer(1, 10*mm))
    story.append(HRFlowable(width="100%", thickness=1, color=PRIMARY, spaceAfter=4*mm))
    story.append(Paragraph(
        "<i>Bu hesabat CoreVia iOS app-in tam QA/BA auditini ehtiva edir. "
        "111 Swift fayl analiz olunub, 42 problem askar edilib. "
        "Production-a cixmazdan evvel en azi Faza 1 meselelerinin hell edilmesi MUTLEQDIR.</i>",
        ParagraphStyle('Footer', parent=styles['Body2'], fontSize=8.5, textColor=TEXT_SECONDARY,
                       fontName='Helvetica-Oblique')))

    doc.build(story, onFirstPage=add_header_footer, onLaterPages=add_header_footer)
    print(f"PDF ugurla yaradildi: {OUTPUT_PATH}")


if __name__ == "__main__":
    build_pdf()
