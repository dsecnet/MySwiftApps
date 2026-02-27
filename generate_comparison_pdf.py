#!/usr/bin/env python3
"""
CoreVia iOS vs Android Comparison Report Generator
"""

from reportlab.lib import colors
from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.units import mm, cm
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle,
    PageBreak, HRFlowable
)
from reportlab.lib.enums import TA_LEFT, TA_CENTER, TA_RIGHT
from datetime import datetime

# ── Page setup ──────────────────────────────────────────────
pdf_path = "/Users/vusaldadashov/Desktop/ConsoleApp/CoreVia_iOS_vs_Android_Comparison.pdf"
doc = SimpleDocTemplate(
    pdf_path,
    pagesize=A4,
    leftMargin=18*mm,
    rightMargin=18*mm,
    topMargin=20*mm,
    bottomMargin=20*mm,
)

styles = getSampleStyleSheet()

# Custom styles
styles.add(ParagraphStyle(
    name='ReportTitle',
    parent=styles['Title'],
    fontSize=22,
    textColor=colors.HexColor('#1A1A2E'),
    spaceAfter=6,
    alignment=TA_CENTER,
))
styles.add(ParagraphStyle(
    name='ReportSubtitle',
    parent=styles['Normal'],
    fontSize=11,
    textColor=colors.HexColor('#666666'),
    alignment=TA_CENTER,
    spaceAfter=20,
))
styles.add(ParagraphStyle(
    name='SectionTitle',
    parent=styles['Heading1'],
    fontSize=16,
    textColor=colors.HexColor('#16213E'),
    spaceBefore=14,
    spaceAfter=8,
    borderWidth=0,
    borderColor=colors.HexColor('#4ECDC4'),
    borderPadding=4,
))
styles.add(ParagraphStyle(
    name='SubSection',
    parent=styles['Heading2'],
    fontSize=13,
    textColor=colors.HexColor('#0F3460'),
    spaceBefore=10,
    spaceAfter=6,
))
styles.add(ParagraphStyle(
    name='BodyText2',
    parent=styles['Normal'],
    fontSize=9,
    textColor=colors.HexColor('#333333'),
    spaceAfter=4,
    leading=13,
))
styles.add(ParagraphStyle(
    name='StatusDone',
    parent=styles['Normal'],
    fontSize=9,
    textColor=colors.HexColor('#27AE60'),
))
styles.add(ParagraphStyle(
    name='StatusPartial',
    parent=styles['Normal'],
    fontSize=9,
    textColor=colors.HexColor('#F39C12'),
))
styles.add(ParagraphStyle(
    name='StatusMissing',
    parent=styles['Normal'],
    fontSize=9,
    textColor=colors.HexColor('#E74C3C'),
))
styles.add(ParagraphStyle(
    name='SmallNote',
    parent=styles['Normal'],
    fontSize=8,
    textColor=colors.HexColor('#999999'),
    spaceAfter=2,
))

story = []

# ── Colors for tables ──
GREEN = colors.HexColor('#27AE60')
ORANGE = colors.HexColor('#F39C12')
RED = colors.HexColor('#E74C3C')
HEADER_BG = colors.HexColor('#1A1A2E')
ROW_ALT = colors.HexColor('#F8F9FA')
WHITE = colors.white

def status_color(status):
    if status == "FULL":
        return GREEN
    elif status == "PARTIAL":
        return ORANGE
    else:
        return RED

def hr():
    return HRFlowable(width="100%", thickness=1, color=colors.HexColor('#E0E0E0'), spaceAfter=8, spaceBefore=4)

# ══════════════════════════════════════════════════════════════
# COVER PAGE
# ══════════════════════════════════════════════════════════════
story.append(Spacer(1, 60))
story.append(Paragraph("CoreVia", styles['ReportTitle']))
story.append(Paragraph("iOS vs Android - Feature Comparison Report", ParagraphStyle(
    'coverSub', parent=styles['Normal'], fontSize=14, textColor=colors.HexColor('#4ECDC4'),
    alignment=TA_CENTER, spaceAfter=30,
)))
story.append(hr())
story.append(Spacer(1, 20))

# Summary stats table
summary_data = [
    ['Metrik', 'iOS (Swift)', 'Android (Kotlin)'],
    ['Fayl sayi', '111', '145'],
    ['Tam implement', '~111', '58 (40%)'],
    ['Partial', '-', '24 (17%)'],
    ['Bos / Stub', '-', '53 (37%)'],
    ['Ekranlar', '~30', '~30 (17 bos)'],
    ['Servislor', '~15', '21 repository'],
    ['Data modeller', '~40+', '19 fayl (5 bos)'],
    ['Dil destyi', '3 (AZ, TR, EN)', '1 (AZ)'],
    ['ML Modeller', '2 (YOLOv8, EfficientNet)', '0 (backend API)'],
    ['Arxitektura', 'MVVM + Manager', 'MVVM + Hilt DI'],
]
t = Table(summary_data, colWidths=[140, 170, 170])
t.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (-1, 0), HEADER_BG),
    ('TEXTCOLOR', (0, 0), (-1, 0), WHITE),
    ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
    ('FONTSIZE', (0, 0), (-1, -1), 9),
    ('ALIGN', (0, 0), (-1, -1), 'LEFT'),
    ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#DEE2E6')),
    ('ROWBACKGROUNDS', (0, 1), (-1, -1), [WHITE, ROW_ALT]),
    ('TOPPADDING', (0, 0), (-1, -1), 5),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
    ('LEFTPADDING', (0, 0), (-1, -1), 8),
]))
story.append(t)
story.append(Spacer(1, 20))
story.append(Paragraph(f"Tarix: {datetime.now().strftime('%d %B %Y')}", styles['ReportSubtitle']))
story.append(PageBreak())

# ══════════════════════════════════════════════════════════════
# FEATURE-BY-FEATURE COMPARISON
# ══════════════════════════════════════════════════════════════
story.append(Paragraph("1. Feature-by-Feature Muqayise", styles['SectionTitle']))
story.append(hr())

# Define all features
features = [
    # (Feature, iOS Status, Android Status, iOS Files, Android Files, Notes)
    {
        "name": "Authentication - Login",
        "ios": "FULL",
        "android": "FULL",
        "ios_files": "LoginView.swift",
        "android_files": "LoginScreen.kt, LoginViewModel.kt",
        "notes": "Her iki platformada tam. OTP verifikasiya, user type secimi, dil secimi (iOS-da 3 dil, Android-da 1)."
    },
    {
        "name": "Authentication - Register",
        "ios": "FULL",
        "android": "FULL",
        "ios_files": "RegisterView.swift",
        "android_files": "RegisterScreen.kt, RegisterViewModel.kt",
        "notes": "Tam port edilib. Client OTP + Trainer birba\u015fa qeydiyyat. Trainer extra fields (instagram, specialization, experience, bio)."
    },
    {
        "name": "Authentication - Forgot Password",
        "ios": "FULL",
        "android": "PARTIAL",
        "ios_files": "ForgotPasswordView.swift",
        "android_files": "ForgotPasswordScreen.kt (UI), ForgotPasswordViewModel.kt (BOS)",
        "notes": "Android-da UI var amma ViewModel bos. Backend baglantisi yoxdur."
    },
    {
        "name": "Authentication - Trainer Verification",
        "ios": "FULL",
        "android": "EMPTY",
        "ios_files": "TrainerVerificationView.swift",
        "android_files": "TrainerVerificationScreen.kt (BOS)",
        "notes": "iOS-da deaktiv edilib amma kod var. Android-da hec ne yoxdur."
    },
    {
        "name": "Home - Client Dashboard",
        "ios": "FULL",
        "android": "FULL",
        "ios_files": "HomeView.swift",
        "android_files": "HomeScreen.kt, HomeViewModel.kt",
        "notes": "Her iki platformada tam. Greeting, workout stats, AI recommendations, daily survey prompt."
    },
    {
        "name": "Home - Trainer Dashboard",
        "ios": "FULL",
        "android": "FULL",
        "ios_files": "TrainerHomeView.swift",
        "android_files": "TrainerHomeScreen.kt, TrainerHomeViewModel.kt",
        "notes": "Tam port edilib. Student overview, stats, earnings, quick actions."
    },
    {
        "name": "Profile - View/Edit",
        "ios": "FULL",
        "android": "FULL",
        "ios_files": "ProfileViewDynamic.swift, UserProfileView.swift, Teacher Profile View.swift, EditProfileViews.swift",
        "android_files": "ProfileScreen.kt, ProfileViewModel.kt, EditProfileScreen.kt",
        "notes": "Tam. Dinamik trainer/client profili, verification badge, edit form."
    },
    {
        "name": "Workout Tracking",
        "ios": "FULL",
        "android": "FULL",
        "ios_files": "WorkoutView.swift, AddWorkoutView.swift, LiveTrackingView.swift",
        "android_files": "WorkoutScreen.kt, WorkoutViewModel.kt",
        "notes": "Workout list ve stats tam. Amma AddWorkoutScreen.kt ve AddWorkoutViewModel.kt BOS."
    },
    {
        "name": "Add Workout Form",
        "ios": "FULL",
        "android": "EMPTY",
        "ios_files": "AddWorkoutView.swift",
        "android_files": "AddWorkoutScreen.kt (BOS), AddWorkoutViewModel.kt (BOS)",
        "notes": "iOS-da title, category, duration, calories, notes. Android-da hec ne yoxdur."
    },
    {
        "name": "Food & Nutrition Tracking",
        "ios": "FULL",
        "android": "FULL",
        "ios_files": "EatingView.swift",
        "android_files": "FoodScreen.kt, FoodViewModel.kt",
        "notes": "Daily macros, meal sections, water tracking tam port edilib."
    },
    {
        "name": "Add Food Entry",
        "ios": "FULL",
        "android": "EMPTY",
        "ios_files": "AddFoodView.swift",
        "android_files": "AddFoodScreen.kt (BOS), AddFoodViewModel.kt (BOS)",
        "notes": "iOS-da food name, calories, macros, meal type, portion, image. Android-da BOS."
    },
    {
        "name": "AI Calorie Analysis",
        "ios": "FULL",
        "android": "FULL",
        "ios_files": "AICalorieAnalysisView.swift, AICalorieHistoryView.swift + 6 ML service",
        "android_files": "AICalorieScreen.kt, AICalorieViewModel.kt",
        "notes": "iOS: On-device ML (YOLOv8 + EfficientNet). Android: Backend API. Tarix ekrani (AICalorieHistoryScreen.kt) BOS."
    },
    {
        "name": "AI Calorie History",
        "ios": "FULL",
        "android": "EMPTY",
        "ios_files": "AICalorieHistoryView.swift",
        "android_files": "AICalorieHistoryScreen.kt (BOS), AICalorieResultScreen.kt (BOS)",
        "notes": "iOS-da analiz tarixi paginated. Android-da BOS."
    },
    {
        "name": "AI Recommendations",
        "ios": "FULL",
        "android": "PARTIAL",
        "ios_files": "AIRecommendationView.swift, AIRecommendationService.swift",
        "android_files": "HomeScreen.kt icinde gosterilir",
        "notes": "iOS-da ayri ekran + filter. Android-da yalniz Home ekraninda kicik bolme."
    },
    {
        "name": "Chat - Conversations",
        "ios": "FULL",
        "android": "FULL",
        "ios_files": "ChatView.swift",
        "android_files": "ConversationsScreen.kt, ConversationsViewModel.kt",
        "notes": "Sohbet siyahisi, son mesaj, premium gate tam port edilib."
    },
    {
        "name": "Chat - Detail (Messages)",
        "ios": "FULL",
        "android": "EMPTY",
        "ios_files": "ChatDetailScreen (ChatView icinde)",
        "android_files": "ChatDetailScreen.kt (BOS), ChatDetailViewModel.kt (BOS)",
        "notes": "Android-da ferdi sohbet ekrani BOS. Mesaj gonderme yoxdur."
    },
    {
        "name": "Meal Plans",
        "ios": "FULL",
        "android": "FULL",
        "ios_files": "MealPlanView.swift, AddMealPlanView.swift",
        "android_files": "MealPlanScreen.kt, AddMealPlanScreen.kt, MealPlanViewModel.kt",
        "notes": "Tam port edilib. Siyahi, yaratma, makro hesablama."
    },
    {
        "name": "Training Plans",
        "ios": "FULL",
        "android": "EMPTY",
        "ios_files": "TrainingPlanView.swift, AddTrainingPlanView.swift",
        "android_files": "TrainingPlanScreen.kt (BOS), AddTrainingPlanScreen.kt (BOS), TrainingPlanViewModel.kt (BOS)",
        "notes": "iOS-da tam CRUD. Android-da butun fayllar BOS. Model ve Repository var."
    },
    {
        "name": "Route / GPS Tracking",
        "ios": "FULL",
        "android": "FULL",
        "ios_files": "ActivitiesView.swift, LocationManager.swift",
        "android_files": "RouteTrackingScreen.kt, GPSTrackingScreen.kt, RouteViewModel.kt",
        "notes": "Tam port edilib. GPS tracking, map, stats, route history."
    },
    {
        "name": "Daily Survey",
        "ios": "FULL",
        "android": "FULL",
        "ios_files": "DailySurveyView.swift",
        "android_files": "DailySurveyScreen.kt, DailySurveyViewModel.kt",
        "notes": "Tam port edilib. Enerji, yuxu, stress, emzele agrisi, mood."
    },
    {
        "name": "Social Feed",
        "ios": "FULL",
        "android": "PARTIAL",
        "ios_files": "SocialFeedView.swift, CreatePostView.swift, PostCardView.swift, CommentsView.swift",
        "android_files": "SocialFeedScreen.kt (PARTIAL), SocialFeedViewModel.kt (PARTIAL)",
        "notes": "iOS-da tam: feed, post yaratma, like, comment. Android-da yalniz feed UI var, ViewModel minimal."
    },
    {
        "name": "Social - Create Post",
        "ios": "FULL",
        "android": "EMPTY",
        "ios_files": "CreatePostView.swift",
        "android_files": "CreatePostScreen.kt (BOS)",
        "notes": "Post yaratma ekrani Android-da BOS."
    },
    {
        "name": "Social - Comments",
        "ios": "FULL",
        "android": "EMPTY",
        "ios_files": "CommentsView.swift",
        "android_files": "CommentsScreen.kt (BOS)",
        "notes": "Comment ekrani Android-da BOS."
    },
    {
        "name": "Analytics Dashboard",
        "ios": "FULL",
        "android": "EMPTY",
        "ios_files": "AnalyticsDashboardView.swift, OverallStatisticsView.swift",
        "android_files": "AnalyticsDashboardScreen.kt (BOS), AnalyticsViewModel.kt (BOS), OverallStatsScreen.kt (BOS)",
        "notes": "iOS-da Charts framework ile weight/workout/nutrition trendleri. Android-da TAMAMEN BOS."
    },
    {
        "name": "Live Sessions - Browse",
        "ios": "FULL",
        "android": "EMPTY",
        "ios_files": "LiveSessionListView.swift, LiveSessionDetailView.swift",
        "android_files": "LiveSessionListScreen.kt (BOS), LiveSessionDetailScreen.kt (BOS)",
        "notes": "Canli seans siyahisi, detallari, qosulma. Android-da TAMAMEN BOS."
    },
    {
        "name": "Live Sessions - Workout/Pose",
        "ios": "FULL",
        "android": "EMPTY",
        "ios_files": "LiveWorkoutView.swift, PoseDetectionService.swift, WebSocketService.swift",
        "android_files": "LiveWorkoutScreen.kt (BOS), LiveSessionViewModel.kt (BOS)",
        "notes": "iOS-da camera + Vision pose detection + WebSocket. Android-da TAMAMEN BOS. EN MURAKKAB FEATURE."
    },
    {
        "name": "Live Sessions - Create (Trainer)",
        "ios": "FULL",
        "android": "EMPTY",
        "ios_files": "CreateLiveSessionView.swift",
        "android_files": "CreateLiveSessionScreen.kt (BOS)",
        "notes": "Trainer canli seans yaratma. Android-da BOS."
    },
    {
        "name": "Marketplace - Browse",
        "ios": "FULL",
        "android": "EMPTY",
        "ios_files": "MarketplaceView.swift, ProductDetailView.swift",
        "android_files": "MarketplaceScreen.kt (BOS), ProductDetailScreen.kt (BOS)",
        "notes": "Mehsul siyahisi, filter, detallari. Android-da TAMAMEN BOS."
    },
    {
        "name": "Marketplace - Reviews",
        "ios": "FULL",
        "android": "EMPTY",
        "ios_files": "WriteReviewView.swift",
        "android_files": "WriteReviewScreen.kt (BOS)",
        "notes": "Mehsul revyu yazma. Android-da BOS."
    },
    {
        "name": "Marketplace - Create Product (Trainer)",
        "ios": "FULL",
        "android": "EMPTY",
        "ios_files": "CreateProductView.swift (TrainerHub icinde)",
        "android_files": "CreateProductScreen.kt (BOS)",
        "notes": "Trainer mehsul yaratma formu. Android-da BOS."
    },
    {
        "name": "Trainer Browse & Discovery",
        "ios": "FULL",
        "android": "EMPTY",
        "ios_files": "Teachers.swift",
        "android_files": "TrainerBrowseScreen.kt (BOS), TrainerBrowseViewModel.kt (BOS)",
        "notes": "Trainer axtarma, filter, rating. Android-da BOS. Repository (TrainerRepository.kt) tam."
    },
    {
        "name": "Trainer Hub (Management)",
        "ios": "FULL",
        "android": "EMPTY",
        "ios_files": "TrainerHubView.swift, TrainerSessionsView.swift, TrainerMarketplaceView.swift",
        "android_files": "TrainerHubScreen.kt (BOS) + 4 diger BOS fayl",
        "notes": "Trainer-in sessialarini ve mehsullarini idare etmesi. Android-da 5 fayl hamisi BOS."
    },
    {
        "name": "Trainer Content",
        "ios": "FULL",
        "android": "EMPTY",
        "ios_files": "Feature icinde",
        "android_files": "TrainerContentScreen.kt (BOS), ContentViewModel.kt (BOS)",
        "notes": "Trainer content paylasma. Android-da BOS. Amma ContentRepository.kt tam."
    },
    {
        "name": "Onboarding",
        "ios": "FULL",
        "android": "EMPTY",
        "ios_files": "OnboardingView.swift, PermissionsView.swift",
        "android_files": "OnboardingScreen.kt (BOS), OnboardingViewModel.kt (BOS)",
        "notes": "iOS-da multi-step (goal, level, body measurements). Android-da BOS. OnboardingRepository.kt tam."
    },
    {
        "name": "Premium / Subscription",
        "ios": "FULL",
        "android": "PARTIAL",
        "ios_files": "PremiumView.swift",
        "android_files": "PremiumScreen.kt (UI tam), PremiumViewModel.kt (PARTIAL)",
        "notes": "iOS-da StoreKit. Android-da UI var amma odenis entegrasyasi yoxdur."
    },
    {
        "name": "Settings",
        "ios": "FULL",
        "android": "FULL",
        "ios_files": "SettingsView.swift",
        "android_files": "SettingsScreen.kt, SettingsViewModel.kt",
        "notes": "Tam port edilib. Dil, bildiris, tema, hesab, cixis."
    },
    {
        "name": "Fitness News",
        "ios": "FULL",
        "android": "FULL",
        "ios_files": "NewsService.swift",
        "android_files": "HomeScreen icinde + NewsRepository.kt",
        "notes": "Xeber yuklemesi tam. Android-da Home ekraninda gosterilir."
    },
    {
        "name": "Localization (Multi-language)",
        "ios": "FULL",
        "android": "EMPTY",
        "ios_files": "LocalizationManager.swift",
        "android_files": "LocalizationManager.kt (BOS)",
        "notes": "iOS-da AZ/TR/EN destyi. Android-da yalniz Azerbaycan dili, LocalizationManager BOS."
    },
    {
        "name": "Shared Components",
        "ios": "FULL",
        "android": "PARTIAL",
        "ios_files": "FilterChip.swift, ProfileComponents.swift, CameraPicker.swift, ImagePicker.swift, ProfileImageManager.swift",
        "android_files": "CoreViaButton.kt, CoreViaCard.kt, FilterChip.kt, ImagePicker.kt, LoadingIndicator.kt, ProfileComponents.kt",
        "notes": "Esaslari var. Amma CoreViaTextField.kt, RatingStars.kt, ErrorDialog.kt, LanguageSelector.kt BOS."
    },
]

# Build comparison table
story.append(Paragraph("1.1 Butun Feature Statusu", styles['SubSection']))

table_data = [['#', 'Feature', 'iOS', 'Android', 'Qeyd']]
for i, f in enumerate(features, 1):
    ios_mark = '\u2705' if f['ios'] == 'FULL' else ('\u26a0\ufe0f' if f['ios'] == 'PARTIAL' else '\u274c')
    and_mark = '\u2705' if f['android'] == 'FULL' else ('\u26a0\ufe0f' if f['android'] == 'PARTIAL' else '\u274c')

    table_data.append([
        str(i),
        Paragraph(f['name'], ParagraphStyle('tcell', parent=styles['Normal'], fontSize=7.5, leading=9)),
        f['android'],
        Paragraph(f['notes'][:120], ParagraphStyle('tnote', parent=styles['Normal'], fontSize=6.5, leading=8, textColor=colors.HexColor('#555555'))),
    ])

# Simpler table - Feature | Status | Short Note
table_data2 = [['#', 'Feature', 'iOS', 'Android', 'Status']]
for i, f in enumerate(features, 1):
    status = ""
    if f['android'] == 'FULL':
        status = "Tam"
    elif f['android'] == 'PARTIAL':
        status = "Yarimciq"
    else:
        status = "BOS"
    table_data2.append([str(i), f['name'], f['ios'], f['android'], status])

col_widths = [22, 160, 40, 50, 55]
t2 = Table(table_data2, colWidths=col_widths, repeatRows=1)
style_cmds = [
    ('BACKGROUND', (0, 0), (-1, 0), HEADER_BG),
    ('TEXTCOLOR', (0, 0), (-1, 0), WHITE),
    ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
    ('FONTSIZE', (0, 0), (-1, 0), 8),
    ('FONTSIZE', (0, 1), (-1, -1), 7),
    ('ALIGN', (0, 0), (0, -1), 'CENTER'),
    ('ALIGN', (2, 0), (-1, -1), 'CENTER'),
    ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ('GRID', (0, 0), (-1, -1), 0.4, colors.HexColor('#DEE2E6')),
    ('TOPPADDING', (0, 0), (-1, -1), 3),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 3),
    ('LEFTPADDING', (0, 0), (-1, -1), 4),
]

for i, f in enumerate(features, 1):
    row = i
    # Color the Android column based on status
    if f['android'] == 'FULL':
        style_cmds.append(('TEXTCOLOR', (3, row), (3, row), GREEN))
        style_cmds.append(('TEXTCOLOR', (4, row), (4, row), GREEN))
    elif f['android'] == 'PARTIAL':
        style_cmds.append(('TEXTCOLOR', (3, row), (3, row), ORANGE))
        style_cmds.append(('TEXTCOLOR', (4, row), (4, row), ORANGE))
    else:
        style_cmds.append(('TEXTCOLOR', (3, row), (3, row), RED))
        style_cmds.append(('TEXTCOLOR', (4, row), (4, row), RED))

    if row % 2 == 0:
        style_cmds.append(('BACKGROUND', (0, row), (-1, row), ROW_ALT))

t2.setStyle(TableStyle(style_cmds))
story.append(t2)

story.append(PageBreak())

# ══════════════════════════════════════════════════════════════
# DETAILED NOTES PER FEATURE
# ══════════════════════════════════════════════════════════════
story.append(Paragraph("2. Detalli Qeydler (Her Feature Ucun)", styles['SectionTitle']))
story.append(hr())

for i, f in enumerate(features, 1):
    color = '#27AE60' if f['android'] == 'FULL' else ('#F39C12' if f['android'] == 'PARTIAL' else '#E74C3C')
    badge = "TAM" if f['android'] == 'FULL' else ("YARIMCIQ" if f['android'] == 'PARTIAL' else "BOS")

    story.append(Paragraph(
        f"<b>{i}. {f['name']}</b> &nbsp; <font color='{color}'>[{badge}]</font>",
        ParagraphStyle('feat', parent=styles['Normal'], fontSize=10, spaceBefore=8, spaceAfter=2)
    ))
    story.append(Paragraph(f"<b>iOS:</b> {f['ios_files']}", styles['SmallNote']))
    story.append(Paragraph(f"<b>Android:</b> {f['android_files']}", styles['SmallNote']))
    story.append(Paragraph(f['notes'], styles['BodyText2']))

story.append(PageBreak())

# ══════════════════════════════════════════════════════════════
# EMPTY FILES LIST
# ══════════════════════════════════════════════════════════════
story.append(Paragraph("3. Android-da BOS Olan Butun Fayllar", styles['SectionTitle']))
story.append(hr())

empty_files = [
    # UI
    ("ui/auth/ForgotPasswordViewModel.kt", "Forgot password backend logic"),
    ("ui/auth/TrainerVerificationScreen.kt", "Trainer verification flow"),
    ("ui/workout/AddWorkoutScreen.kt", "Add workout form UI"),
    ("ui/workout/AddWorkoutViewModel.kt", "Add workout logic"),
    ("ui/food/AddFoodScreen.kt", "Add food entry form UI"),
    ("ui/food/AddFoodViewModel.kt", "Add food entry logic"),
    ("ui/food/AICalorieHistoryScreen.kt", "AI calorie analysis history"),
    ("ui/food/AICalorieResultScreen.kt", "AI calorie result display"),
    ("ui/food/AICalorieViewModel.kt", "AI calorie in food module"),
    ("ui/chat/ChatDetailScreen.kt", "Individual chat messages"),
    ("ui/chat/ChatDetailViewModel.kt", "Chat detail logic"),
    ("ui/plans/TrainingPlanScreen.kt", "Training plan list"),
    ("ui/plans/AddTrainingPlanScreen.kt", "Create training plan"),
    ("ui/plans/TrainingPlanViewModel.kt", "Training plan logic"),
    ("ui/livesession/LiveSessionListScreen.kt", "Live session browse"),
    ("ui/livesession/LiveSessionDetailScreen.kt", "Live session details"),
    ("ui/livesession/LiveWorkoutScreen.kt", "Live workout with pose"),
    ("ui/livesession/LiveSessionViewModel.kt", "Live session logic"),
    ("ui/trainers/TrainerBrowseScreen.kt", "Trainer discovery"),
    ("ui/trainers/TrainerBrowseViewModel.kt", "Trainer browse logic"),
    ("ui/trainerhub/TrainerHubScreen.kt", "Trainer management hub"),
    ("ui/trainerhub/CreateProductScreen.kt", "Create marketplace product"),
    ("ui/trainerhub/CreateLiveSessionScreen.kt", "Create live session"),
    ("ui/trainerhub/TrainerProductsScreen.kt", "Trainer products list"),
    ("ui/trainerhub/TrainerSessionsScreen.kt", "Trainer sessions list"),
    ("ui/social/CommentsScreen.kt", "Post comments"),
    ("ui/social/CreatePostScreen.kt", "Create social post"),
    ("ui/analytics/AnalyticsDashboardScreen.kt", "Analytics charts"),
    ("ui/analytics/AnalyticsViewModel.kt", "Analytics logic"),
    ("ui/analytics/OverallStatsScreen.kt", "Overall statistics"),
    ("ui/marketplace/MarketplaceScreen.kt", "Product browse"),
    ("ui/marketplace/MarketplaceViewModel.kt", "Marketplace logic"),
    ("ui/marketplace/ProductDetailScreen.kt", "Product details"),
    ("ui/marketplace/ProductDetailViewModel.kt", "Product detail logic"),
    ("ui/marketplace/WriteReviewScreen.kt", "Write product review"),
    ("ui/onboarding/OnboardingScreen.kt", "Onboarding flow"),
    ("ui/onboarding/OnboardingViewModel.kt", "Onboarding logic"),
    ("ui/content/TrainerContentScreen.kt", "Trainer content"),
    ("ui/content/ContentViewModel.kt", "Content logic"),
    ("ui/components/CoreViaTextField.kt", "Custom text field"),
    ("ui/components/RatingStars.kt", "Star rating component"),
    ("ui/components/ErrorDialog.kt", "Error dialog"),
    ("ui/components/LanguageSelector.kt", "Language picker"),
    # Data
    ("data/models/AnalyticsModels.kt", "Analytics data models"),
    ("data/models/LiveSessionModels.kt", "Live session models"),
    ("data/models/MarketplaceModels.kt", "Marketplace models"),
    ("data/models/SocialModels.kt", "Social feed models"),
    ("data/repositories/SocialRepository.kt", "Social API calls"),
    ("data/repositories/MarketplaceRepository.kt", "Marketplace API"),
    ("data/repositories/LiveSessionRepository.kt", "Live session API"),
    ("data/repositories/PremiumRepository.kt", "Premium/billing"),
    ("data/repositories/AnalyticsRepository.kt", "Analytics API"),
    # Util
    ("util/LocalizationManager.kt", "Multi-language support"),
]

empty_data = [['#', 'Fayl yolu', 'Tesvir']]
for i, (path, desc) in enumerate(empty_files, 1):
    empty_data.append([str(i), path, desc])

t3 = Table(empty_data, colWidths=[22, 260, 180], repeatRows=1)
t3.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#E74C3C')),
    ('TEXTCOLOR', (0, 0), (-1, 0), WHITE),
    ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
    ('FONTSIZE', (0, 0), (-1, 0), 8),
    ('FONTSIZE', (0, 1), (-1, -1), 6.5),
    ('ALIGN', (0, 0), (0, -1), 'CENTER'),
    ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ('GRID', (0, 0), (-1, -1), 0.4, colors.HexColor('#DEE2E6')),
    ('TOPPADDING', (0, 0), (-1, -1), 2.5),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 2.5),
    ('LEFTPADDING', (0, 0), (-1, -1), 4),
    ('ROWBACKGROUNDS', (0, 1), (-1, -1), [WHITE, ROW_ALT]),
]))
story.append(t3)

story.append(PageBreak())

# ══════════════════════════════════════════════════════════════
# PRIORITY RECOMMENDATIONS
# ══════════════════════════════════════════════════════════════
story.append(Paragraph("4. Prioritet Siralamasi (Implement Ardicirligi)", styles['SectionTitle']))
story.append(hr())

priorities = [
    ("YUKSEK", "#E74C3C", [
        ("Onboarding Flow", "Yeni istifadeci tecrubesi ucun vacibdir. OnboardingRepository hazirdir, yalniz UI lazimdir."),
        ("Add Workout Form", "Istifadeciler workout elaye ede bilmir. WorkoutRepository hazirdir."),
        ("Add Food Entry Form", "Istifadeciler food elaye ede bilmir. FoodRepository hazirdir."),
        ("Chat Detail Screen", "Chat acilir amma mesaj gostermir/gondermez. ChatRepository hazirdir."),
        ("Training Plans", "Meal Plans var, Training Plans yoxdur. TrainingPlanRepository ve Models tam hazirdir."),
        ("Trainer Browse & Discovery", "Clientler trainer tapa bilmir. TrainerRepository tam hazirdir."),
    ]),
    ("ORTA", "#F39C12", [
        ("Analytics Dashboard", "Istifadeci progressini gormek ucun. AnalyticsModels ve Repository lazimdir."),
        ("Social Feed (Tamamla)", "UI var, amma ViewModel minimal. CreatePost ve Comments BOS. SocialModels ve Repository lazimdir."),
        ("Forgot Password (Backend)", "UI var, ViewModel BOS. Backend baglantisi lazimdir."),
        ("Marketplace", "Trainer mehsullari ucun. Butun 5 fayl BOS. MarketplaceModels ve Repository lazimdir."),
        ("AI Calorie History", "Kecmis analizleri gormek ucun. AICalorieRepository hazirdir."),
        ("Multi-language Support", "iOS-da 3 dil var, Android-da 1. LocalizationManager lazimdir."),
    ]),
    ("ASAGI", "#3498DB", [
        ("Live Sessions", "En murakkeb feature - Camera + Pose Detection + WebSocket. 4 BOS fayl + LiveSessionModels + Repository lazimdir."),
        ("Trainer Hub (Management)", "Trainer-in oz sessialarini ve mehsullarini idare etmesi. 5 BOS fayl."),
        ("Trainer Content", "Trainer content paylasma. ContentRepository tam."),
        ("Premium (Billing)", "UI var, odenis sistemi (Google Play Billing) lazimdir."),
        ("Trainer Verification", "Hal-hazirda iOS-da da deaktivdir."),
        ("Shared Components", "CoreViaTextField, RatingStars, ErrorDialog, LanguageSelector."),
    ]),
]

for priority_name, color, items in priorities:
    story.append(Paragraph(
        f"<font color='{color}'><b>{priority_name} PRIORITET</b></font>",
        ParagraphStyle('pri', parent=styles['Normal'], fontSize=12, spaceBefore=12, spaceAfter=6)
    ))

    pri_data = [['Feature', 'Sebebi']]
    for feat, reason in items:
        pri_data.append([feat, Paragraph(reason, ParagraphStyle('prr', parent=styles['Normal'], fontSize=7.5, leading=10))])

    t_pri = Table(pri_data, colWidths=[130, 350], repeatRows=1)
    t_pri.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor(color)),
        ('TEXTCOLOR', (0, 0), (-1, 0), WHITE),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 8),
        ('FONTSIZE', (0, 1), (-1, -1), 7.5),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('GRID', (0, 0), (-1, -1), 0.4, colors.HexColor('#DEE2E6')),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('LEFTPADDING', (0, 0), (-1, -1), 6),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [WHITE, ROW_ALT]),
    ]))
    story.append(t_pri)

story.append(PageBreak())

# ══════════════════════════════════════════════════════════════
# COMPLETION PERCENTAGE
# ══════════════════════════════════════════════════════════════
story.append(Paragraph("5. Tamamlanma Faizi (Feature Bazinda)", styles['SectionTitle']))
story.append(hr())

completion = [
    ("Authentication", 85, "Login/Register tam, ForgotPassword yarimciq, Verification BOS"),
    ("Home & Dashboard", 100, "Client ve Trainer home tam port edilib"),
    ("Profile", 100, "View, Edit, Trainer/Client dynamic tam"),
    ("Workout Tracking", 60, "List/Stats tam, AddWorkout BOS"),
    ("Food & Nutrition", 50, "List/Stats tam, AddFood BOS, AI History BOS"),
    ("AI Features", 60, "AI Calorie Screen tam, History BOS, Recommendation partial"),
    ("Chat", 50, "Conversations tam, ChatDetail BOS"),
    ("Plans", 50, "MealPlan tam, TrainingPlan BOS"),
    ("Route / GPS", 100, "Tam port edilib"),
    ("Daily Survey", 100, "Tam port edilib"),
    ("Social", 15, "Feed partial, Create/Comments BOS"),
    ("Analytics", 0, "Butun 3 fayl BOS"),
    ("Live Sessions", 0, "Butun 4 fayl BOS"),
    ("Marketplace", 0, "Butun 5 fayl BOS"),
    ("Trainer Browse", 0, "Her 2 fayl BOS"),
    ("Trainer Hub", 0, "Butun 5 fayl BOS"),
    ("Onboarding", 0, "Her 2 fayl BOS"),
    ("Premium", 70, "UI tam, billing yoxdur"),
    ("Settings", 100, "Tam port edilib"),
    ("Localization", 0, "BOS - yalniz AZ dili"),
]

comp_data = [['Feature', '%', 'Qeyd']]
for feat, pct, note in completion:
    bar_full = int(pct / 10)
    bar_empty = 10 - bar_full
    bar = '\u2588' * bar_full + '\u2591' * bar_empty

    comp_data.append([
        feat,
        f"{bar} {pct}%",
        Paragraph(note, ParagraphStyle('cnote', parent=styles['Normal'], fontSize=7, leading=9, textColor=colors.HexColor('#555555'))),
    ])

t_comp = Table(comp_data, colWidths=[110, 100, 270], repeatRows=1)
comp_styles = [
    ('BACKGROUND', (0, 0), (-1, 0), HEADER_BG),
    ('TEXTCOLOR', (0, 0), (-1, 0), WHITE),
    ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
    ('FONTSIZE', (0, 0), (-1, 0), 8),
    ('FONTSIZE', (0, 1), (-1, -1), 7.5),
    ('FONTNAME', (1, 1), (1, -1), 'Courier'),
    ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ('GRID', (0, 0), (-1, -1), 0.4, colors.HexColor('#DEE2E6')),
    ('TOPPADDING', (0, 0), (-1, -1), 3),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 3),
    ('LEFTPADDING', (0, 0), (-1, -1), 5),
    ('ROWBACKGROUNDS', (0, 1), (-1, -1), [WHITE, ROW_ALT]),
]

for i, (_, pct, _) in enumerate(completion, 1):
    if pct == 100:
        comp_styles.append(('TEXTCOLOR', (1, i), (1, i), GREEN))
    elif pct >= 50:
        comp_styles.append(('TEXTCOLOR', (1, i), (1, i), ORANGE))
    else:
        comp_styles.append(('TEXTCOLOR', (1, i), (1, i), RED))

t_comp.setStyle(TableStyle(comp_styles))
story.append(t_comp)

story.append(Spacer(1, 20))

# Overall percentage
total_pct = sum(p for _, p, _ in completion) / len(completion)
story.append(Paragraph(
    f"<b>Umumi Tamamlanma: {total_pct:.0f}%</b>",
    ParagraphStyle('overall', parent=styles['Normal'], fontSize=14, textColor=colors.HexColor('#1A1A2E'),
                   alignment=TA_CENTER, spaceBefore=10, spaceAfter=6)
))

color_overall = '#27AE60' if total_pct >= 70 else ('#F39C12' if total_pct >= 40 else '#E74C3C')
story.append(Paragraph(
    f"<font color='{color_overall}'>20 feature-den {sum(1 for _, p, _ in completion if p == 100)} tam, "
    f"{sum(1 for _, p, _ in completion if 0 < p < 100)} yarimciq, "
    f"{sum(1 for _, p, _ in completion if p == 0)} BOS</font>",
    ParagraphStyle('ovdet', parent=styles['Normal'], fontSize=10, alignment=TA_CENTER, spaceAfter=20)
))

story.append(PageBreak())

# ══════════════════════════════════════════════════════════════
# ARCHITECTURAL DIFFERENCES
# ══════════════════════════════════════════════════════════════
story.append(Paragraph("6. Arxitektura Ferqleri", styles['SectionTitle']))
story.append(hr())

arch_data = [
    ['Meqam', 'iOS (Swift)', 'Android (Kotlin)'],
    ['UI Framework', 'SwiftUI', 'Jetpack Compose (Material3)'],
    ['State Management', 'ObservableObject + @Published', 'StateFlow + MutableStateFlow'],
    ['DI', 'Yoxdur (Singleton pattern)', 'Hilt (@HiltViewModel, @Inject)'],
    ['Networking', 'URLSession + custom APIService', 'Retrofit2 + OkHttp'],
    ['Serialization', 'Codable (Swift native)', 'Kotlinx Serialization'],
    ['Token Storage', 'Keychain (KeychainManager)', 'EncryptedSharedPreferences'],
    ['Navigation', 'NavigationStack + custom routing', 'Compose Navigation'],
    ['ML / AI', 'CoreML (on-device YOLOv8, EfficientNet)', 'Backend API only'],
    ['Camera', 'AVFoundation', 'CameraX (planned)'],
    ['Maps', 'MapKit', 'Google Maps Compose'],
    ['Pose Detection', 'Apple Vision framework', 'ML Kit (planned)'],
    ['WebSocket', 'URLSessionWebSocketTask', 'OkHttp WebSocket (planned)'],
    ['Payments', 'StoreKit', 'Google Play Billing (planned)'],
    ['Charts', 'SwiftUI Charts', 'Compose Charts lib (planned)'],
    ['Localization', 'Custom LocalizationManager (3 dil)', 'Yoxdur (yalniz AZ)'],
]

t_arch = Table(arch_data, colWidths=[110, 180, 190], repeatRows=1)
t_arch.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (-1, 0), HEADER_BG),
    ('TEXTCOLOR', (0, 0), (-1, 0), WHITE),
    ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
    ('FONTSIZE', (0, 0), (-1, 0), 8),
    ('FONTSIZE', (0, 1), (-1, -1), 7.5),
    ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ('GRID', (0, 0), (-1, -1), 0.4, colors.HexColor('#DEE2E6')),
    ('TOPPADDING', (0, 0), (-1, -1), 4),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
    ('LEFTPADDING', (0, 0), (-1, -1), 6),
    ('ROWBACKGROUNDS', (0, 1), (-1, -1), [WHITE, ROW_ALT]),
]))
story.append(t_arch)

story.append(Spacer(1, 20))

# ══════════════════════════════════════════════════════════════
# WHAT'S READY IN BACKEND (REPOS)
# ══════════════════════════════════════════════════════════════
story.append(Paragraph("7. Backend Baglantisi Hazir Olan Feature-ler", styles['SectionTitle']))
story.append(hr())
story.append(Paragraph(
    "Asagidaki feature-lerin Repository ve API endpoint-leri artiq implement edilib. "
    "Yalniz UI (Screen + ViewModel) lazimdir:",
    styles['BodyText2']
))

ready_data = [
    ['Feature', 'Repository', 'API Endpoint', 'UI Status'],
    ['Training Plans', 'TrainingPlanRepository.kt (112 line)', 'GET/POST/PUT/DELETE /plans/training', 'BOS'],
    ['Trainer Browse', 'TrainerRepository.kt (99 line)', 'GET /users/trainers', 'BOS'],
    ['Onboarding', 'OnboardingRepository.kt (100 line)', 'GET/POST /onboarding/*', 'BOS'],
    ['Trainer Content', 'ContentRepository.kt (123 line)', 'GET/POST/DELETE /content/*', 'BOS'],
    ['AI Calorie History', 'AICalorieRepository.kt (156 line)', 'GET /aicalorie/history', 'BOS'],
    ['Trainer Dashboard', 'TrainerDashboardRepo.kt (32 line)', 'GET /trainer/stats', 'TAM (Profile icinde)'],
]

t_ready = Table(ready_data, colWidths=[100, 130, 140, 80], repeatRows=1)
t_ready.setStyle(TableStyle([
    ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#27AE60')),
    ('TEXTCOLOR', (0, 0), (-1, 0), WHITE),
    ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
    ('FONTSIZE', (0, 0), (-1, 0), 8),
    ('FONTSIZE', (0, 1), (-1, -1), 7.5),
    ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ('GRID', (0, 0), (-1, -1), 0.4, colors.HexColor('#DEE2E6')),
    ('TOPPADDING', (0, 0), (-1, -1), 4),
    ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
    ('LEFTPADDING', (0, 0), (-1, -1), 6),
    ('ROWBACKGROUNDS', (0, 1), (-1, -1), [WHITE, ROW_ALT]),
]))
story.append(t_ready)

story.append(Spacer(1, 30))
story.append(hr())
story.append(Paragraph(
    "Bu hesabat CoreVia iOS ve Android proyektlerinin muqayisesini ehtiva edir. "
    "Prioritet siralamasi ile isleyerek Android versiyasini iOS ile eyni seviyyeye getirmek mumkundur.",
    ParagraphStyle('footer', parent=styles['Normal'], fontSize=9, textColor=colors.HexColor('#999999'),
                   alignment=TA_CENTER, spaceBefore=10)
))

# ── Build PDF ──
doc.build(story)
print(f"PDF created: {pdf_path}")
