#!/usr/bin/env python3
"""
CoreVia — Google Play Billing Plan PDF Generator
"""

from reportlab.lib.pagesizes import A4
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.colors import HexColor, black, white
from reportlab.lib.units import mm, cm
from reportlab.lib.enums import TA_LEFT, TA_CENTER, TA_JUSTIFY
from reportlab.platypus import (
    SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle,
    PageBreak, HRFlowable, KeepTogether, ListFlowable, ListItem
)
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
import os
from datetime import datetime

# ── Colors ──────────────────────────────────────────────────────
PRIMARY = HexColor("#4CAF50")
PRIMARY_DARK = HexColor("#2E7D32")
SECONDARY = HexColor("#1976D2")
ACCENT = HexColor("#FF9800")
BG_LIGHT = HexColor("#F5F5F5")
BG_CODE = HexColor("#F8F9FA")
BORDER = HexColor("#E0E0E0")
TEXT_PRIMARY = HexColor("#212121")
TEXT_SECONDARY = HexColor("#757575")
WARNING = HexColor("#FF5722")
SUCCESS = HexColor("#4CAF50")

OUTPUT_PATH = os.path.expanduser("~/Desktop/CoreVia_Google_Play_Billing_Plan.pdf")

def create_styles():
    styles = getSampleStyleSheet()

    styles.add(ParagraphStyle(
        name='DocTitle',
        fontSize=24,
        leading=30,
        textColor=PRIMARY_DARK,
        spaceAfter=4*mm,
        alignment=TA_CENTER,
        fontName='Helvetica-Bold'
    ))

    styles.add(ParagraphStyle(
        name='DocSubtitle',
        fontSize=12,
        leading=16,
        textColor=TEXT_SECONDARY,
        spaceAfter=8*mm,
        alignment=TA_CENTER,
        fontName='Helvetica'
    ))

    styles.add(ParagraphStyle(
        name='SectionHeader',
        fontSize=16,
        leading=22,
        textColor=PRIMARY_DARK,
        spaceBefore=10*mm,
        spaceAfter=4*mm,
        fontName='Helvetica-Bold',
        borderWidth=0,
        borderPadding=0,
    ))

    styles.add(ParagraphStyle(
        name='SubSection',
        fontSize=13,
        leading=18,
        textColor=SECONDARY,
        spaceBefore=6*mm,
        spaceAfter=3*mm,
        fontName='Helvetica-Bold'
    ))

    styles.add(ParagraphStyle(
        name='SubSubSection',
        fontSize=11,
        leading=15,
        textColor=TEXT_PRIMARY,
        spaceBefore=4*mm,
        spaceAfter=2*mm,
        fontName='Helvetica-Bold'
    ))

    styles.add(ParagraphStyle(
        name='BodyText2',
        fontSize=10,
        leading=15,
        textColor=TEXT_PRIMARY,
        spaceAfter=3*mm,
        fontName='Helvetica',
        alignment=TA_JUSTIFY
    ))

    styles.add(ParagraphStyle(
        name='BulletText',
        fontSize=10,
        leading=15,
        textColor=TEXT_PRIMARY,
        spaceAfter=2*mm,
        fontName='Helvetica',
        leftIndent=8*mm,
        bulletIndent=3*mm,
    ))

    styles.add(ParagraphStyle(
        name='CodeBlock',
        fontSize=8.5,
        leading=12,
        textColor=HexColor("#333333"),
        fontName='Courier',
        backColor=BG_CODE,
        leftIndent=5*mm,
        rightIndent=5*mm,
        spaceBefore=2*mm,
        spaceAfter=3*mm,
        borderWidth=0.5,
        borderColor=BORDER,
        borderPadding=4*mm,
    ))

    styles.add(ParagraphStyle(
        name='FileRef',
        fontSize=9,
        leading=13,
        textColor=SECONDARY,
        fontName='Courier',
        spaceBefore=1*mm,
        spaceAfter=1*mm,
    ))

    styles.add(ParagraphStyle(
        name='WarningText',
        fontSize=10,
        leading=15,
        textColor=WARNING,
        fontName='Helvetica-Bold',
        spaceAfter=2*mm,
        leftIndent=5*mm,
    ))

    styles.add(ParagraphStyle(
        name='NoteText',
        fontSize=9.5,
        leading=14,
        textColor=TEXT_SECONDARY,
        fontName='Helvetica-Oblique',
        spaceAfter=3*mm,
        leftIndent=5*mm,
    ))

    return styles


def add_header_footer(canvas, doc):
    canvas.saveState()
    # Header line
    canvas.setStrokeColor(PRIMARY)
    canvas.setLineWidth(2)
    canvas.line(20*mm, A4[1] - 15*mm, A4[0] - 20*mm, A4[1] - 15*mm)
    # Header text
    canvas.setFont('Helvetica-Bold', 8)
    canvas.setFillColor(PRIMARY_DARK)
    canvas.drawString(20*mm, A4[1] - 13*mm, "CoreVia Android")
    canvas.setFont('Helvetica', 8)
    canvas.setFillColor(TEXT_SECONDARY)
    canvas.drawRightString(A4[0] - 20*mm, A4[1] - 13*mm, "Google Play Billing Integration Plan")

    # Footer
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
    doc = SimpleDocTemplate(
        OUTPUT_PATH,
        pagesize=A4,
        topMargin=22*mm,
        bottomMargin=22*mm,
        leftMargin=20*mm,
        rightMargin=20*mm,
        title="CoreVia — Google Play Billing Plan",
        author="CoreVia Development Team"
    )

    styles = create_styles()
    story = []

    # ════════════════════════════════════════════════════════════
    # TITLE PAGE
    # ════════════════════════════════════════════════════════════
    story.append(Spacer(1, 40*mm))
    story.append(Paragraph("CoreVia Android", styles['DocTitle']))
    story.append(Paragraph("Google Play Billing Integration Plan", ParagraphStyle(
        'BigSubtitle', parent=styles['DocSubtitle'], fontSize=16, leading=22, spaceAfter=15*mm
    )))

    story.append(HRFlowable(width="60%", thickness=1, color=PRIMARY, spaceAfter=10*mm))

    # Info table
    info_data = [
        ["Layihe:", "CoreVia - Fitness & Wellness App"],
        ["Paket:", "life.corevia.app"],
        ["Model:", "Subscription (Aylik / Illik)"],
        ["Tarix:", datetime.now().strftime("%d %B %Y")],
        ["Versiya:", "1.0"],
        ["Status:", "Plan - Tesdiq gozleyir"],
    ]
    info_table = Table(info_data, colWidths=[35*mm, 100*mm])
    info_table.setStyle(TableStyle([
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTNAME', (1, 0), (1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 0), (-1, -1), 10),
        ('TEXTCOLOR', (0, 0), (0, -1), TEXT_SECONDARY),
        ('TEXTCOLOR', (1, 0), (1, -1), TEXT_PRIMARY),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4*mm),
        ('TOPPADDING', (0, 0), (-1, -1), 2*mm),
        ('ALIGN', (0, 0), (0, -1), 'RIGHT'),
        ('ALIGN', (1, 0), (1, -1), 'LEFT'),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ]))
    story.append(info_table)
    story.append(PageBreak())

    # ════════════════════════════════════════════════════════════
    # TABLE OF CONTENTS
    # ════════════════════════════════════════════════════════════
    story.append(Paragraph("Mundericat", styles['SectionHeader']))
    story.append(HRFlowable(width="100%", thickness=0.5, color=BORDER, spaceAfter=5*mm))

    toc_items = [
        ("1.", "Kontekst ve Meqsed"),
        ("2.", "Arxitektura Diaqrami"),
        ("3.", "Addim 1: Google Play Console Hazirligi"),
        ("4.", "Addim 2: Android Kod Deyisiklikleri"),
        ("5.", "Addim 3: Backend Deyisiklikleri"),
        ("6.", "Tam Odenis Axini (End-to-End)"),
        ("7.", "Deyisdirileeck Fayllar"),
        ("8.", "Verifikasiya ve Test"),
        ("9.", "Vacib Qeydler"),
        ("10.", "Production-a Cixmaq Ucun Kritik Meseleler"),
    ]
    for num, title in toc_items:
        story.append(Paragraph(f"<b>{num}</b>  {title}", ParagraphStyle(
            'TOCItem', parent=styles['BodyText2'], fontSize=11, leading=18, spaceAfter=2*mm
        )))

    story.append(PageBreak())

    # ════════════════════════════════════════════════════════════
    # 1. CONTEXT
    # ════════════════════════════════════════════════════════════
    story.append(Paragraph("1. Kontekst ve Meqsed", styles['SectionHeader']))
    story.append(HRFlowable(width="100%", thickness=0.5, color=PRIMARY, spaceAfter=5*mm))

    story.append(Paragraph(
        "CoreVia Android app-da premium funksionalliq movcuddur (GPS tracking, AI food analysis, AI trainer chat), "
        "lakin odenis sistemi yoxdur. Hazirda yalniz backend-de <font color='#1976D2'><b>/api/v1/premium/activate</b></font> "
        "endpoint-i var ki, sadece isPremium=true qoyur. Real odenis (Google Play Billing) ve server-side receipt "
        "validation elave edilmelidir.",
        styles['BodyText2']
    ))

    story.append(Spacer(1, 3*mm))

    model_data = [
        ["Model", "Abonelik (Subscription)"],
        ["Aylik Qiymet", "9.99 AZN / ay"],
        ["Illik Qiymet", "89.99 AZN / il (25% endirim)"],
        ["Platform", "Google Play Billing Library v7.1.1"],
    ]
    model_table = Table(model_data, colWidths=[45*mm, 110*mm])
    model_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (0, -1), BG_LIGHT),
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTNAME', (1, 0), (1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 0), (-1, -1), 10),
        ('TEXTCOLOR', (0, 0), (-1, -1), TEXT_PRIMARY),
        ('GRID', (0, 0), (-1, -1), 0.5, BORDER),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3*mm),
        ('TOPPADDING', (0, 0), (-1, -1), 3*mm),
        ('LEFTPADDING', (0, 0), (-1, -1), 4*mm),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ]))
    story.append(model_table)

    story.append(Spacer(1, 5*mm))
    story.append(Paragraph(
        "<b>Axin:</b> User -> 'Premium ol' -> Google Play dialog -> odenis -> purchase token -> backend dogrulama -> premium aktiv",
        styles['BodyText2']
    ))

    # ════════════════════════════════════════════════════════════
    # 2. ARCHITECTURE DIAGRAM
    # ════════════════════════════════════════════════════════════
    story.append(Paragraph("2. Arxitektura Diaqrami", styles['SectionHeader']))
    story.append(HRFlowable(width="100%", thickness=0.5, color=PRIMARY, spaceAfter=5*mm))

    arch_text = """Android App          Google Play           Google Play API
(Billing Client) --> (Billing Dialog) --> (receipt validate)
      |                                         |
      | purchase token                          |
      v                                         v
CoreVia Backend  <------------------------------+
/api/v1/premium/verify-purchase
  - validate purchase token with Google
  - isPremium = true
  - return JWT token"""

    story.append(Paragraph(arch_text.replace('\n', '<br/>'), styles['CodeBlock']))

    story.append(Spacer(1, 3*mm))
    story.append(Paragraph(
        "Sistem 3 komponetden ibaretdir: Android app (BillingClient), Google Play (odenis prosessoru), "
        "ve CoreVia Backend (purchase token dogrulama). Teshlukesizlik ucun her odenis backend terefinden dogrulanir.",
        styles['BodyText2']
    ))

    # ════════════════════════════════════════════════════════════
    # 3. GOOGLE PLAY CONSOLE SETUP
    # ════════════════════════════════════════════════════════════
    story.append(Paragraph("3. Addim 1: Google Play Console Hazirligi", styles['SectionHeader']))
    story.append(HRFlowable(width="100%", thickness=0.5, color=PRIMARY, spaceAfter=5*mm))

    story.append(Paragraph(
        "<i>Bu addimlar Google Play Console-da (https://play.google.com/console) manual edilmelidir.</i>",
        styles['NoteText']
    ))

    story.append(Paragraph("<b>3.1 App yaratmaq</b>", styles['SubSubSection']))
    story.append(Paragraph("- <b>life.corevia.app</b> package name ile yeni app yaradilmalidir", styles['BulletText']))
    story.append(Paragraph("- Internal testing track-a APK/AAB yuklenmelidir", styles['BulletText']))

    story.append(Paragraph("<b>3.2 Subscription Products yaratmaq</b>", styles['SubSubSection']))

    sub_data = [
        ["Product ID", "Ad", "Qiymet", "Muddeti"],
        ["corevia_premium_monthly", "CoreVia Premium Aylik", "9.99 AZN", "1 ay"],
        ["corevia_premium_yearly", "CoreVia Premium Illik", "89.99 AZN", "1 il"],
    ]
    sub_table = Table(sub_data, colWidths=[42*mm, 45*mm, 25*mm, 20*mm])
    sub_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), PRIMARY),
        ('TEXTCOLOR', (0, 0), (-1, 0), white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTNAME', (0, 1), (-1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('GRID', (0, 0), (-1, -1), 0.5, BORDER),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3*mm),
        ('TOPPADDING', (0, 0), (-1, -1), 3*mm),
        ('LEFTPADDING', (0, 0), (-1, -1), 3*mm),
        ('ALIGN', (2, 0), (3, -1), 'CENTER'),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ]))
    story.append(sub_table)

    story.append(Spacer(1, 3*mm))
    story.append(Paragraph("<b>3.3 API Access - Service Account</b>", styles['SubSubSection']))
    story.append(Paragraph("- Google Cloud Console-dan Service Account yaradilmalidir", styles['BulletText']))
    story.append(Paragraph("- JSON key fayli elde edilmelidir", styles['BulletText']))
    story.append(Paragraph("- Bu key backend-e verilmelidir (receipt validation ucun)", styles['BulletText']))
    story.append(Paragraph("- Play Console-da API Access bolmesinden Service Account link edilmelidir", styles['BulletText']))

    # ════════════════════════════════════════════════════════════
    # 4. ANDROID CODE CHANGES
    # ════════════════════════════════════════════════════════════
    story.append(PageBreak())
    story.append(Paragraph("4. Addim 2: Android Kod Deyisiklikleri", styles['SectionHeader']))
    story.append(HRFlowable(width="100%", thickness=0.5, color=PRIMARY, spaceAfter=5*mm))

    # 4.1 Dependencies
    story.append(Paragraph("4.1 Dependencies elave et", styles['SubSection']))
    story.append(Paragraph("Fayl: gradle/libs.versions.toml", styles['FileRef']))
    story.append(Paragraph(
        'billingKtx = "7.1.1"<br/>'
        'billing-ktx = { group = "com.android.billingclient", name = "billing-ktx", version.ref = "billingKtx" }',
        styles['CodeBlock']
    ))
    story.append(Paragraph("Fayl: app/build.gradle.kts", styles['FileRef']))
    story.append(Paragraph('implementation(libs.billing.ktx)', styles['CodeBlock']))

    # 4.2 BillingManager
    story.append(Paragraph("4.2 BillingManager yaratmaq (YENI fayl)", styles['SubSection']))
    story.append(Paragraph("Fayl: app/src/main/java/life/corevia/app/data/billing/BillingManager.kt", styles['FileRef']))

    story.append(Paragraph(
        "Bu sinif Google Play Billing Client-i idare edir. Asagidaki funksiyalar olacaq:",
        styles['BodyText2']
    ))

    funcs = [
        ("<b>connectToGooglePlay()</b> - BillingClient baglantisi qurur",),
        ("<b>querySubscriptions()</b> - Movcud planlari sorgu edir (monthly/yearly)",),
        ("<b>launchPurchaseFlow(activity, productDetails)</b> - Google Play odenis dialogunu acir",),
        ("<b>handlePurchase(purchase)</b> - Odenis neticesi emal edir",),
        ("<b>acknowledgePurchase(purchaseToken)</b> - Odenisi tesdiqleyir (3 gun erzinde lazimdir)",),
        ("<b>queryExistingPurchases()</b> - App acilinda movcud abonelikleri yoxlayir",),
    ]
    for f in funcs:
        story.append(Paragraph(f"- {f[0]}", styles['BulletText']))

    # 4.3 PremiumModels
    story.append(Paragraph("4.3 Data Model-ler (YENI fayl)", styles['SubSection']))
    story.append(Paragraph("Fayl: app/src/main/java/life/corevia/app/data/model/PremiumModels.kt", styles['FileRef']))

    code = """@Serializable
data class VerifyPurchaseRequest(
    @SerialName("purchase_token") val purchaseToken: String,
    @SerialName("product_id") val productId: String,
    val platform: String = "android"
)

@Serializable
data class PremiumResponse(
    @SerialName("is_premium") val isPremium: Boolean,
    val message: String,
    @SerialName("expires_at") val expiresAt: String? = null
)"""
    story.append(Paragraph(code.replace('\n', '<br/>').replace(' ', '&nbsp;'), styles['CodeBlock']))

    # 4.4 ApiService
    story.append(Paragraph("4.4 ApiService-e yeni endpoint", styles['SubSection']))
    story.append(Paragraph("Fayl: app/src/main/java/life/corevia/app/data/remote/ApiService.kt", styles['FileRef']))
    story.append(Paragraph(
        '@POST("/api/v1/premium/verify-purchase")<br/>'
        'suspend fun verifyPurchase(@Body request: VerifyPurchaseRequest): Response&lt;PremiumResponse&gt;',
        styles['CodeBlock']
    ))

    # 4.5 PremiumRepository
    story.append(Paragraph("4.5 PremiumRepository yenile", styles['SubSection']))
    story.append(Paragraph("Fayl: app/src/main/java/life/corevia/app/data/repository/PremiumRepository.kt", styles['FileRef']))
    story.append(Paragraph("Yeni funksiyalar:", styles['BodyText2']))
    story.append(Paragraph("- <b>verifyPurchase(purchaseToken, productId)</b> - Backend-e purchase token gonderir", styles['BulletText']))
    story.append(Paragraph("- Backend cavabini emal edir (isPremium token yenileme)", styles['BulletText']))

    # 4.6 PremiumViewModel
    story.append(Paragraph("4.6 PremiumViewModel yenile", styles['SubSection']))
    story.append(Paragraph("Fayl: app/src/main/java/life/corevia/app/ui/premium/PremiumViewModel.kt", styles['FileRef']))

    story.append(Paragraph("- BillingManager inject edilecek", styles['BulletText']))
    story.append(Paragraph("- <b>loadSubscriptionPlans()</b> - Google Play-den real qiymetleri yukleyecek", styles['BulletText']))
    story.append(Paragraph("- <b>purchaseSubscription(activity, isYearly)</b> - Odenis axinini basladacaq", styles['BulletText']))
    story.append(Paragraph("- <b>onPurchaseComplete(purchase)</b> - Purchase token-i backend-e gonderecek", styles['BulletText']))
    story.append(Paragraph("- <b>restorePurchases()</b> - Movcud abonelikleri berpa edecek", styles['BulletText']))

    # 4.7 PremiumScreen
    story.append(Paragraph("4.7 PremiumScreen yenile", styles['SubSection']))
    story.append(Paragraph("Fayl: app/src/main/java/life/corevia/app/ui/premium/PremiumScreen.kt", styles['FileRef']))

    story.append(Paragraph("- 'Premium ol' duymesi purchaseSubscription cagiracaq", styles['BulletText']))
    story.append(Paragraph("- Google Play-den real qiymetler gosterilecek (hardcode yox)", styles['BulletText']))
    story.append(Paragraph("- Loading/error state-ler elave edilecek", styles['BulletText']))
    story.append(Paragraph("- 'Aboneliyi berpa et' duymesi elave edilecek", styles['BulletText']))

    # 4.8 DI Module
    story.append(Paragraph("4.8 DI Module yenile", styles['SubSection']))
    story.append(Paragraph("Fayl: app/src/main/java/life/corevia/app/di/RepositoryModule.kt", styles['FileRef']))
    story.append(Paragraph("- BillingManager-i @Singleton olaraq provide edecek", styles['BulletText']))

    # ════════════════════════════════════════════════════════════
    # 5. BACKEND CHANGES
    # ════════════════════════════════════════════════════════════
    story.append(PageBreak())
    story.append(Paragraph("5. Addim 3: Backend Deyisiklikleri", styles['SectionHeader']))
    story.append(HRFlowable(width="100%", thickness=0.5, color=PRIMARY, spaceAfter=5*mm))

    story.append(Paragraph(
        "<font color='#FF5722'><b>CRITICAL:</b></font> Backend deyisiklikleri olmadan odenis sistemi "
        "teshlukesiz isleye bilmez. Her odenis mutleq server terefinden dogrulanmalidir.",
        styles['WarningText']
    ))

    # Endpoint 1
    story.append(Paragraph("5.1 POST /api/v1/premium/verify-purchase (YENI)", styles['SubSection']))

    story.append(Paragraph("<b>Request body:</b>", styles['BodyText2']))
    req_code = """{
  "purchase_token": "...",
  "product_id": "corevia_premium_monthly",
  "platform": "android"
}"""
    story.append(Paragraph(req_code.replace('\n', '<br/>').replace(' ', '&nbsp;'), styles['CodeBlock']))

    story.append(Paragraph("<b>Backend Logic:</b>", styles['BodyText2']))
    logic_items = [
        "Google Play Developer API ile purchase token-i dogrula",
        "google.androidpublisher.purchases.subscriptions.get API istifade et",
        "Service Account JSON key lazimdir",
        "Odenisin valid oldugunu yoxla (status, expiry)",
        "User-in is_premium = true qoy",
        "Subscription expiry tarixini saxla",
        "Premium JWT token yenile",
        "Cavab qaytar",
    ]
    for i, item in enumerate(logic_items):
        story.append(Paragraph(f"  {i+1}. {item}", styles['BulletText']))

    story.append(Paragraph("<b>Response body:</b>", styles['BodyText2']))
    resp_code = """{
  "is_premium": true,
  "message": "Premium ugurla aktivlesdirildi",
  "expires_at": "2026-03-27T00:00:00"
}"""
    story.append(Paragraph(resp_code.replace('\n', '<br/>').replace(' ', '&nbsp;'), styles['CodeBlock']))

    # Endpoint 2
    story.append(Paragraph("5.2 Google Play Real-time Developer Notifications (RTDN)", styles['SubSection']))

    story.append(Paragraph(
        "Google-dan webhook qebul etmek ucun endpoint lazimdir:",
        styles['BodyText2']
    ))
    story.append(Paragraph("POST /api/v1/webhooks/google-play", styles['CodeBlock']))

    story.append(Paragraph("Bu endpoint asagidaki hadiseleri emal edecek:", styles['BodyText2']))
    story.append(Paragraph("- Abonelik yenilenme (renewal)", styles['BulletText']))
    story.append(Paragraph("- Abonelik legv etme (cancellation)", styles['BulletText']))
    story.append(Paragraph("- Odenis xetasi (payment failure)", styles['BulletText']))
    story.append(Paragraph("- Grace period baslama", styles['BulletText']))

    story.append(Spacer(1, 3*mm))
    story.append(Paragraph(
        "<i>Bu olmadan backend user-in abonelik statusunu real-vaxtda bilmeyecek. "
        "Yalniz user app-i acanda status yoxlanacaq.</i>",
        styles['NoteText']
    ))

    # ════════════════════════════════════════════════════════════
    # 6. END-TO-END FLOW
    # ════════════════════════════════════════════════════════════
    story.append(Paragraph("6. Tam Odenis Axini (End-to-End)", styles['SectionHeader']))
    story.append(HRFlowable(width="100%", thickness=0.5, color=PRIMARY, spaceAfter=5*mm))

    flow_data = [
        ["#", "Addim", "Komponent"],
        ["1", "User PremiumScreen-e daxil olur", "Android"],
        ["2", "App Google Play-den subscription plan-lari yukleyir", "Android"],
        ["3", "User 'Aylik 9.99' ve ya 'Illik 89.99' secir", "Android"],
        ["4", "Google Play Billing dialog acilir", "Google Play"],
        ["5", "User Google Pay / kredit karti ile odeyir", "Google Play"],
        ["6", "Google Play purchase token qaytarir", "Google Play"],
        ["7", "App purchase token-i backend-e gonderir", "Android"],
        ["8", "Backend Google Play API ile token-i dogrulayir", "Backend"],
        ["9", "Backend isPremium=true qoyur, JWT qaytarir", "Backend"],
        ["10", "App isPremium state-i yenileyir", "Android"],
        ["11", "User premium feature-lari gorur", "Android"],
        ["12", "Her ay Google Play avtomatik odenis edir", "Google Play"],
        ["13", "Google webhook ile backend-e status gonderir", "Google Play"],
    ]
    flow_table = Table(flow_data, colWidths=[8*mm, 100*mm, 30*mm])
    flow_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), PRIMARY),
        ('TEXTCOLOR', (0, 0), (-1, 0), white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTNAME', (0, 1), (-1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('GRID', (0, 0), (-1, -1), 0.5, BORDER),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 2.5*mm),
        ('TOPPADDING', (0, 0), (-1, -1), 2.5*mm),
        ('LEFTPADDING', (0, 0), (-1, -1), 3*mm),
        ('ALIGN', (0, 0), (0, -1), 'CENTER'),
        ('ALIGN', (2, 0), (2, -1), 'CENTER'),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [white, BG_LIGHT]),
    ]))
    story.append(flow_table)

    # ════════════════════════════════════════════════════════════
    # 7. FILES TO CHANGE
    # ════════════════════════════════════════════════════════════
    story.append(PageBreak())
    story.append(Paragraph("7. Deyisdirileeck Fayllar", styles['SectionHeader']))
    story.append(HRFlowable(width="100%", thickness=0.5, color=PRIMARY, spaceAfter=5*mm))

    files_data = [
        ["Fayl", "Emeliyyat", "Status"],
        ["gradle/libs.versions.toml", "Billing dependency version", "MODIFY"],
        ["app/build.gradle.kts", "Billing dependency", "MODIFY"],
        ["data/billing/BillingManager.kt", "Google Play Billing client", "NEW"],
        ["data/model/PremiumModels.kt", "Request/response models", "NEW"],
        ["data/remote/ApiService.kt", "verify-purchase endpoint", "MODIFY"],
        ["data/repository/PremiumRepository.kt", "verifyPurchase funksiyasi", "MODIFY"],
        ["di/RepositoryModule.kt", "BillingManager DI", "MODIFY"],
        ["ui/premium/PremiumViewModel.kt", "Billing logic", "MODIFY"],
        ["ui/premium/PremiumScreen.kt", "Real qiymetler, purchase button", "MODIFY"],
    ]
    files_table = Table(files_data, colWidths=[65*mm, 55*mm, 20*mm])
    files_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), SECONDARY),
        ('TEXTCOLOR', (0, 0), (-1, 0), white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTNAME', (0, 1), (0, -1), 'Courier'),
        ('FONTNAME', (1, 1), (1, -1), 'Helvetica'),
        ('FONTNAME', (2, 1), (2, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 8.5),
        ('GRID', (0, 0), (-1, -1), 0.5, BORDER),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 2.5*mm),
        ('TOPPADDING', (0, 0), (-1, -1), 2.5*mm),
        ('LEFTPADDING', (0, 0), (-1, -1), 3*mm),
        ('ALIGN', (2, 0), (2, -1), 'CENTER'),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('TEXTCOLOR', (2, 1), (2, 2), SUCCESS),   # NEW = green
        ('TEXTCOLOR', (2, 3), (2, 4), SUCCESS),    # NEW
    ]))

    # Color NEW rows green and MODIFY rows blue
    for i in range(1, len(files_data)):
        if files_data[i][2] == "NEW":
            files_table.setStyle(TableStyle([
                ('TEXTCOLOR', (2, i), (2, i), SUCCESS),
                ('BACKGROUND', (2, i), (2, i), HexColor("#E8F5E9")),
            ]))
        else:
            files_table.setStyle(TableStyle([
                ('TEXTCOLOR', (2, i), (2, i), SECONDARY),
                ('BACKGROUND', (2, i), (2, i), HexColor("#E3F2FD")),
            ]))

    story.append(files_table)

    # Backend files
    story.append(Spacer(1, 5*mm))
    story.append(Paragraph("<b>Backend terefinde:</b>", styles['SubSubSection']))
    backend_files = [
        ["Endpoint", "Emeliyyat", "Status"],
        ["POST /api/v1/premium/verify-purchase", "Purchase token validation", "NEW"],
        ["POST /api/v1/webhooks/google-play", "RTDN webhook handler", "NEW"],
    ]
    bt = Table(backend_files, colWidths=[65*mm, 55*mm, 20*mm])
    bt.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), WARNING),
        ('TEXTCOLOR', (0, 0), (-1, 0), white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTNAME', (0, 1), (0, -1), 'Courier'),
        ('FONTNAME', (1, 1), (-1, -1), 'Helvetica'),
        ('FONTNAME', (2, 1), (2, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 8.5),
        ('GRID', (0, 0), (-1, -1), 0.5, BORDER),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 2.5*mm),
        ('TOPPADDING', (0, 0), (-1, -1), 2.5*mm),
        ('LEFTPADDING', (0, 0), (-1, -1), 3*mm),
        ('ALIGN', (2, 0), (2, -1), 'CENTER'),
        ('TEXTCOLOR', (2, 1), (2, -1), WARNING),
        ('BACKGROUND', (2, 1), (2, -1), HexColor("#FFF3E0")),
    ]))
    story.append(bt)

    # ════════════════════════════════════════════════════════════
    # 8. VERIFICATION
    # ════════════════════════════════════════════════════════════
    story.append(Paragraph("8. Verifikasiya ve Test", styles['SectionHeader']))
    story.append(HRFlowable(width="100%", thickness=0.5, color=PRIMARY, spaceAfter=5*mm))

    tests = [
        ("Debug test", "Google Play Billing sandbox ile test odenisi et. License testing hesabi lazimdir."),
        ("Backend test", "verify-purchase endpoint-inin dogru cavab qaytardigini yoxla (Postman/curl ile)."),
        ("UI test", "Premium ekranda real qiymetler gorundugunyu yoxla (hardcode yox, Google Play-den)."),
        ("Restore test", "App-i sil-yukle, aboneliyin berpa oldugunu yoxla (queryExistingPurchases)."),
        ("Cancel test", "Aboneliyi legv et, premium-un sonduyunu yoxla (RTDN webhook ile)."),
    ]

    test_data = [["#", "Test", "Tesvir"]]
    for i, (name, desc) in enumerate(tests):
        test_data.append([str(i+1), name, desc])

    test_table = Table(test_data, colWidths=[8*mm, 30*mm, 110*mm])
    test_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), PRIMARY),
        ('TEXTCOLOR', (0, 0), (-1, 0), white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTNAME', (1, 1), (1, -1), 'Helvetica-Bold'),
        ('FONTNAME', (0, 1), (0, -1), 'Helvetica'),
        ('FONTNAME', (2, 1), (2, -1), 'Helvetica'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('GRID', (0, 0), (-1, -1), 0.5, BORDER),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3*mm),
        ('TOPPADDING', (0, 0), (-1, -1), 3*mm),
        ('LEFTPADDING', (0, 0), (-1, -1), 3*mm),
        ('ALIGN', (0, 0), (0, -1), 'CENTER'),
        ('VALIGN', (0, 0), (-1, -1), 'TOP'),
        ('ROWBACKGROUNDS', (0, 1), (-1, -1), [white, BG_LIGHT]),
    ]))
    story.append(test_table)

    # ════════════════════════════════════════════════════════════
    # 9. IMPORTANT NOTES
    # ════════════════════════════════════════════════════════════
    story.append(Paragraph("9. Vacib Qeydler", styles['SectionHeader']))
    story.append(HRFlowable(width="100%", thickness=0.5, color=PRIMARY, spaceAfter=5*mm))

    warnings = [
        ("<font color='#FF5722'><b>Google Play Console:</b></font> App hele yoxdursa - evvelce app yaradilmali, "
         "internal testing track-a APK/AAB yuklenmeli, sonra subscription product-lar elave edilmelidir."),
        ("<font color='#FF5722'><b>Backend Endpoint:</b></font> verify-purchase endpoint-i olmadan app odenis "
         "qebul edecek amma backend dogrulamayacaq. Bu teshlukesizlik riski yaradir. Backend endpoint <b>mutleq</b> lazimdir."),
        ("<font color='#FF5722'><b>Test Hesabi:</b></font> Google Play license testing hesabi lazimdir "
         "(Google Play Console -> Settings -> License testing)."),
        ("<font color='#FF5722'><b>Billing Library:</b></font> Yalniz Google Play-den yuklenm app-larda isleyir. "
         "Debug build-da test etmek ucun internal testing track-a yuklenmelidir."),
        ("<font color='#1976D2'><b>Service Account Key:</b></font> Google Cloud Console-dan alinacaq JSON key "
         "fayli backend server-de saxlanmalidir. Bu fayl HECH VAXT git-e push edilmemelidir."),
    ]

    for w in warnings:
        story.append(Paragraph(f"- {w}", styles['BulletText']))
        story.append(Spacer(1, 2*mm))

    # ════════════════════════════════════════════════════════════
    # 10. PRODUCTION BLOCKERS
    # ════════════════════════════════════════════════════════════
    story.append(PageBreak())
    story.append(Paragraph("10. Production-a Cixmaq Ucun Kritik Meseleler", styles['SectionHeader']))
    story.append(HRFlowable(width="100%", thickness=0.5, color=WARNING, spaceAfter=5*mm))

    story.append(Paragraph(
        "<font color='#FF5722' size='12'><b>DIQQET:</b> Asagidaki 3 mesele hell edilmeden "
        "app Google Play Store-a yuklenile bilmez!</font>",
        styles['WarningText']
    ))
    story.append(Spacer(1, 5*mm))

    # Blocker 1: Release Keystore
    story.append(Paragraph("10.1 Release Keystore (KRITIK)", styles['SubSection']))
    story.append(Paragraph(
        "Google Play-e app yuklemek ucun release signing keystore (.jks fayli) lazimdir. "
        "Debug keystore ile imzalanmis APK/AAB Google Play terefinden qebul olunmur.",
        styles['BodyText2']
    ))
    story.append(Paragraph("<b>Edilmeli:</b>", styles['BodyText2']))
    story.append(Paragraph("- keytool ile yeni release keystore yaradilmalidir", styles['BulletText']))
    story.append(Paragraph("- app/build.gradle.kts-de signingConfigs blokundan release konfiqurasiyasi elave edilmelidir", styles['BulletText']))
    story.append(Paragraph("- Keystore fayli ve parol TEHLUKESIZ saxlanmalidir (git-e PUSH ETME!)", styles['BulletText']))
    story.append(Paragraph("- Google Play App Signing aktivlesdirilmelidir (Play Console-da)", styles['BulletText']))

    keystore_code = """keytool -genkey -v -keystore corevia-release.jks \\
  -keyalg RSA -keysize 2048 -validity 10000 \\
  -alias corevia -storepass [PASSWORD] \\
  -dname "CN=CoreVia, OU=Mobile, O=CoreVia, L=Baku, ST=Baku, C=AZ" """
    story.append(Paragraph(keystore_code.replace('\n', '<br/>').replace(' ', '&nbsp;'), styles['CodeBlock']))

    story.append(Spacer(1, 3*mm))

    # Blocker 2: Privacy Policy
    story.append(Paragraph("10.2 Privacy Policy (KRITIK)", styles['SubSection']))
    story.append(Paragraph(
        "Google Play Store teleb edir ki, her app-in Privacy Policy linki olsun. "
        "Xususile GPS mekan, kamera, saglamliq datalari toplayan app-lar ucun bu MECBURIDIR.",
        styles['BodyText2']
    ))
    story.append(Paragraph("<b>Edilmeli:</b>", styles['BodyText2']))
    story.append(Paragraph("- Privacy Policy sehifesi yaradilmalidir (web URL)", styles['BulletText']))
    story.append(Paragraph("- Google Play Console-da Store Listing bolmesine Privacy Policy URL elave edilmelidir", styles['BulletText']))
    story.append(Paragraph("- App daxilinde Settings/About ekraninda Privacy Policy linki gosterilmelidir", styles['BulletText']))
    story.append(Paragraph("- Privacy Policy-de toplanan datalar (GPS, kamera, saglamliq) aciq yazilmalidir", styles['BulletText']))
    story.append(Paragraph("- GDPR/KVKK uygunlugu nezere alinmalidir", styles['BulletText']))

    story.append(Spacer(1, 3*mm))

    # Blocker 3: Crash Reporting
    story.append(Paragraph("10.3 Firebase Crashlytics (KRITIK)", styles['SubSection']))
    story.append(Paragraph(
        "Production-da crash-lari gormek ucun crash reporting sistemi MUTLEQ lazimdir. "
        "Crashlytics olmadan user-lerin yasadigi xetalari bilmeyeceksiz.",
        styles['BodyText2']
    ))
    story.append(Paragraph("<b>Edilmeli:</b>", styles['BodyText2']))
    story.append(Paragraph("- Firebase Console-da layihe yaradilmalidir", styles['BulletText']))
    story.append(Paragraph("- google-services.json fayli app/ qovluguna elave edilmelidir", styles['BulletText']))
    story.append(Paragraph("- Firebase Crashlytics SDK elave edilmelidir (build.gradle)", styles['BulletText']))
    story.append(Paragraph("- ProGuard mapping fayllari Firebase-e yuklenmelidir (obfuscated stack traces ucun)", styles['BulletText']))
    story.append(Paragraph("- Non-fatal error-lar da loglanmalidir", styles['BulletText']))

    crashlytics_code = """// project build.gradle.kts
classpath("com.google.gms:google-services:4.4.2")
classpath("com.google.firebase:firebase-crashlytics-gradle:3.0.3")

// app/build.gradle.kts
plugins {
    id("com.google.gms.google-services")
    id("com.google.firebase.crashlytics")
}
dependencies {
    implementation(platform("com.google.firebase:firebase-bom:33.7.0"))
    implementation("com.google.firebase:firebase-crashlytics-ktx")
    implementation("com.google.firebase:firebase-analytics-ktx")
}"""
    story.append(Paragraph(crashlytics_code.replace('\n', '<br/>').replace(' ', '&nbsp;'), styles['CodeBlock']))

    story.append(Spacer(1, 5*mm))

    # Production Checklist Summary
    story.append(Paragraph("10.4 Production Checklist Xulasesi", styles['SubSection']))

    checklist_data = [
        ["#", "Mesele", "Prioritet", "Status"],
        ["1", "Release Keystore (.jks) yaratmaq", "KRITIK", "Gozleyir"],
        ["2", "Privacy Policy URL yaratmaq", "KRITIK", "Gozleyir"],
        ["3", "Firebase Crashlytics inteqrasiyasi", "KRITIK", "Gozleyir"],
        ["4", "Google Play Billing inteqrasiyasi", "YUKSEK", "Bu sened"],
        ["5", "Backend verify-purchase endpoint", "YUKSEK", "Gozleyir"],
        ["6", "Splash Screen elave etmek", "ORTA", "Optional"],
    ]
    cl_table = Table(checklist_data, colWidths=[8*mm, 70*mm, 25*mm, 25*mm])
    cl_table.setStyle(TableStyle([
        ('BACKGROUND', (0, 0), (-1, 0), HexColor("#D32F2F")),
        ('TEXTCOLOR', (0, 0), (-1, 0), white),
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTNAME', (0, 1), (-1, -1), 'Helvetica'),
        ('FONTNAME', (2, 1), (2, -1), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('GRID', (0, 0), (-1, -1), 0.5, BORDER),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 3*mm),
        ('TOPPADDING', (0, 0), (-1, -1), 3*mm),
        ('LEFTPADDING', (0, 0), (-1, -1), 3*mm),
        ('ALIGN', (0, 0), (0, -1), 'CENTER'),
        ('ALIGN', (2, 0), (3, -1), 'CENTER'),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ]))
    # Color priority column
    for i in range(1, len(checklist_data)):
        priority = checklist_data[i][2]
        if priority == "KRITIK":
            cl_table.setStyle(TableStyle([
                ('TEXTCOLOR', (2, i), (2, i), WARNING),
                ('BACKGROUND', (2, i), (2, i), HexColor("#FFEBEE")),
                ('BACKGROUND', (3, i), (3, i), HexColor("#FFEBEE")),
            ]))
        elif priority == "YUKSEK":
            cl_table.setStyle(TableStyle([
                ('TEXTCOLOR', (2, i), (2, i), ACCENT),
                ('BACKGROUND', (2, i), (2, i), HexColor("#FFF3E0")),
            ]))
        else:
            cl_table.setStyle(TableStyle([
                ('TEXTCOLOR', (2, i), (2, i), SECONDARY),
                ('BACKGROUND', (2, i), (2, i), HexColor("#E3F2FD")),
            ]))
    story.append(cl_table)

    # ════════════════════════════════════════════════════════════
    # FOOTER NOTE
    # ════════════════════════════════════════════════════════════
    story.append(Spacer(1, 15*mm))
    story.append(HRFlowable(width="100%", thickness=1, color=PRIMARY, spaceAfter=5*mm))
    story.append(Paragraph(
        "<i>Bu sened CoreVia Android app ucun Google Play Billing inteqrasiya planini ve production-a cixmaq ucun "
        "kritik meseloleri ehtiva edir. Implementation baslamazdan evvel hem Android hem de Backend terefinin "
        "hazirligi tamamlanmalidir. Keystore, Privacy Policy ve Crashlytics meseloleri MUTLEQ hell edilmelidir.</i>",
        styles['NoteText']
    ))

    # BUILD
    doc.build(story, onFirstPage=add_header_footer, onLaterPages=add_header_footer)
    print(f"PDF ugurla yaradildi: {OUTPUT_PATH}")


if __name__ == "__main__":
    build_pdf()
