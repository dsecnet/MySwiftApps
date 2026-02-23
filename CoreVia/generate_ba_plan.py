from reportlab.lib.pagesizes import A4
from reportlab.lib.units import mm
from reportlab.pdfgen.canvas import Canvas
from reportlab.lib.colors import HexColor
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
import textwrap, os

# ── Register Arial (supports Azerbaijani ə, ö, ü, ş, ç, ı, ğ)
pdfmetrics.registerFont(TTFont("Arial", "/System/Library/Fonts/Supplemental/Arial.ttf"))
pdfmetrics.registerFont(TTFont("Arial-Bold", "/System/Library/Fonts/Supplemental/Arial Bold.ttf"))

FONT = "Arial"
FONT_B = "Arial-Bold"

# ── Colors
BG = HexColor("#FFFFFF")
CARD = HexColor("#F7F8FA")
ACCENT = HexColor("#4F46E5")
ACCENT2 = HexColor("#7C3AED")
DARK = HexColor("#1a1a2e")
TEXT = HexColor("#333333")
MUTED = HexColor("#666666")
LIGHT_ACCENT = HexColor("#EEF2FF")
GREEN = HexColor("#059669")
ORANGE = HexColor("#D97706")
RED = HexColor("#DC2626")
BLUE = HexColor("#2563EB")
BORDER = HexColor("#E5E7EB")

W, H = A4
output = os.path.expanduser("~/Desktop/CoreVia_BA_Texniki_Plan.pdf")
c = Canvas(output, pagesize=A4)

def draw_bg():
    c.setFillColor(BG)
    c.rect(0, 0, W, H, fill=1, stroke=0)

def draw_header_bar():
    c.setFillColor(ACCENT)
    c.rect(0, H-18*mm, W, 18*mm, fill=1, stroke=0)
    c.setFillColor(HexColor("#FFFFFF"))
    c.setFont(FONT_B, 9)
    c.drawString(15*mm, H-12*mm, "CoreVia — Texniki BA Plan")
    c.setFont(FONT, 8)
    c.drawRightString(W-15*mm, H-12*mm, "Konfidensial | 2025")

def draw_card(x, y, w, h, fill=CARD, radius=4*mm):
    c.setFillColor(fill)
    c.setStrokeColor(BORDER)
    c.setLineWidth(0.5)
    c.roundRect(x, y, w, h, radius, fill=1, stroke=1)

def draw_bullet(text, x, y, font=FONT, size=9, color=TEXT, max_w=160*mm, bullet="\u2022"):
    c.setFont(font, size)
    c.setFillColor(ACCENT)
    c.drawString(x, y, bullet)
    c.setFillColor(color)
    chars_per_line = int(max_w / (size * 0.45))
    wrapped = textwrap.wrap(text, chars_per_line)
    for i, line in enumerate(wrapped):
        c.drawString(x + 4*mm, y - i*size*1.5, line)
    return y - len(wrapped)*size*1.5

def draw_section_title(text, y):
    c.setFillColor(ACCENT)
    c.setFont(FONT_B, 13)
    c.drawString(15*mm, y, text)
    c.setStrokeColor(ACCENT)
    c.setLineWidth(1.5)
    c.line(15*mm, y-3, W-15*mm, y-3)
    return y - 10*mm

def draw_sub_title(text, y):
    c.setFillColor(DARK)
    c.setFont(FONT_B, 10)
    c.drawString(18*mm, y, text)
    return y - 6*mm

def new_page():
    c.showPage()
    draw_bg()
    draw_header_bar()

# ═══════════════════════════════════════════════════════════
# PAGE 1 — COVER
# ═══════════════════════════════════════════════════════════
draw_bg()
c.setFillColor(ACCENT)
c.rect(0, H-280, W, 280, fill=1, stroke=0)
c.setFillColor(ACCENT2)
c.rect(0, H-280, W/2, 280, fill=1, stroke=0)

c.setFillColor(HexColor("#FFFFFF"))
c.setFont(FONT_B, 36)
c.drawString(25*mm, H-55*mm, "CoreVia")
c.setFont(FONT, 14)
c.drawString(25*mm, H-63*mm, "iOS Mobil T\u0259tbiq \u2014 Texniki BA Plan")

c.setFont(FONT, 11)
c.drawString(25*mm, H-78*mm, "M\u00fc\u0259llim (Trainer) Paneli Yenid\u0259nqurmas\u0131:")
c.setFont(FONT_B, 13)
c.drawString(25*mm, H-86*mm, "Market + Canl\u0131 Sessiyalar Modulu")

# Info card
y_info = H - 130*mm
draw_card(20*mm, y_info, W-40*mm, 55*mm, fill=CARD)
c.setFillColor(DARK)
c.setFont(FONT_B, 10)
c.drawString(28*mm, y_info+42*mm, "S\u0259n\u0259d M\u0259lumatlar\u0131")
info_lines = [
    ("Layih\u0259:", "CoreVia iOS App"),
    ("Modul:", "Trainer Panel \u2014 Market & Canl\u0131 Sessiyalar"),
    ("S\u0259n\u0259d tipi:", "Business Analysis (BA) Texniki Plan"),
    ("Tarix:", "Fevral 2025"),
    ("Versiya:", "1.0"),
    ("Haz\u0131rlayan:", "CoreVia Development Team"),
]
for i, (label, val) in enumerate(info_lines):
    yy = y_info + 33*mm - i*6.5*mm
    c.setFont(FONT_B, 9)
    c.setFillColor(MUTED)
    c.drawString(28*mm, yy, label)
    c.setFont(FONT, 9)
    c.setFillColor(DARK)
    c.drawString(62*mm, yy, val)

# Scope
y_scope = y_info - 15*mm
draw_card(20*mm, y_scope-48*mm, W-40*mm, 55*mm, fill=LIGHT_ACCENT)
c.setFillColor(ACCENT)
c.setFont(FONT_B, 10)
c.drawString(28*mm, y_scope+33*mm-7*mm, "\u018ehat\u0259 dair\u0259si (Scope)")
c.setFillColor(TEXT)
c.setFont(FONT, 9)
scope_items = [
    "1. Trainer profilind\u0259ki 'M\u0259zmun' b\u00f6lm\u0259sini silm\u0259k \u2192 'Trainer Hub' il\u0259 \u0259v\u0259zl\u0259m\u0259k",
    "2. Trainer Hub: 2 alt b\u00f6lm\u0259 \u2014 Canl\u0131 Sessiyalar + Market",
    "3. Trainer t\u0259r\u0259find\u0259n Canl\u0131 Sessiya yaratma, tarix t\u0259yin etm\u0259",
    "4. Trainer t\u0259r\u0259find\u0259n Market m\u0259hsul yaratma (\u015f\u0259kil, qiym\u0259t, tip)",
    "5. T\u0259l\u0259b\u0259 t\u0259r\u0259find\u0259n sessiyalar\u0131 g\u00f6rm\u0259, \u00f6d\u0259ni\u015f, qo\u015fulma",
    "6. T\u0259l\u0259b\u0259 t\u0259r\u0259find\u0259n marketd\u0259n m\u0259hsul sifari\u015f/al\u0131\u015f",
    "7. Backend API endpoint-l\u0259ri (m\u00f6vcud + yeni)",
]
for i, item in enumerate(scope_items):
    c.drawString(28*mm, y_scope+22*mm-7*mm - i*5.5*mm, item)

new_page()

# ═══════════════════════════════════════════════════════════
# PAGE 2 — CARİ VƏZİYYƏT
# ═══════════════════════════════════════════════════════════
y = H - 28*mm
y = draw_section_title("1. Cari V\u0259ziyy\u0259t Analizi (AS-IS)", y)

y = draw_sub_title("1.1 Trainer Tab Strukturu (Haz\u0131rk\u0131)", y)
draw_card(18*mm, y-52*mm, W-36*mm, 52*mm, fill=CARD)
trainer_tabs = [
    ("Tab 1:", "Home \u2014 TrainerHomeView (dashboard, statistika)"),
    ("Tab 2:", "Plans \u2014 TrainingPlanView (m\u0259\u015fq planlar\u0131)"),
    ("Tab 3:", "Meal Plans \u2014 MealPlanView (qida planlar\u0131)"),
    ("Tab 4:", "Chat \u2014 ConversationsView (mesajla\u015fma)"),
    ("Tab 5:", "More \u2192 M\u0259zmun (TrainerContentView) + Profil"),
]
for i, (tab, desc) in enumerate(trainer_tabs):
    yy = y - 7*mm - i*9*mm
    c.setFont(FONT_B, 9)
    c.setFillColor(ACCENT)
    c.drawString(24*mm, yy, tab)
    c.setFont(FONT, 9)
    c.setFillColor(TEXT)
    c.drawString(42*mm, yy, desc)
y -= 58*mm

y = draw_sub_title("1.2 M\u00f6vcud 'M\u0259zmun' (TrainerContentView) \u2014 S\u0130L\u0130N\u018eC\u018eK", y)
y = draw_bullet("Trainer text post + \u015f\u0259kil payla\u015f\u0131r, premium-only se\u00e7imi var", 20*mm, y)
y -= 2*mm
y = draw_bullet("API: POST /api/v1/content/, GET /api/v1/content/my, DELETE", 20*mm, y)
y -= 2*mm
y = draw_bullet("Bu b\u00f6lm\u0259 silin\u0259c\u0259k \u2192 yerin\u0259 'Trainer Hub' g\u0259l\u0259c\u0259k", 20*mm, y, color=RED)
y -= 8*mm

y = draw_sub_title("1.3 M\u00f6vcud Market (User t\u0259r\u0259f) \u2014 GEN\u0130\u015eL\u018eND\u0130R\u0130L\u018eC\u018eK", y)
y = draw_bullet("T\u0259l\u0259b\u0259 Market-\u0259 gir\u0259 bilir, m\u0259hsullar\u0131 g\u00f6r\u00fcr, filtr edir", 20*mm, y)
y -= 2*mm
y = draw_bullet("M\u0259hsul tipl\u0259ri: workout_plan, meal_plan, ebook, consultation", 20*mm, y)
y -= 2*mm
y = draw_bullet("Al\u0131\u015f (purchase) v\u0259 r\u0259y (review) sistemi m\u00f6vcuddur", 20*mm, y)
y -= 2*mm
y = draw_bullet("Trainer t\u0259r\u0259fd\u0259 m\u0259hsul yaratma UI yoxdur \u2014 \u0259lav\u0259 edil\u0259c\u0259k", 20*mm, y, color=ORANGE)
y -= 8*mm

y = draw_sub_title("1.4 M\u00f6vcud Canl\u0131 Sessiyalar \u2014 GEN\u0130\u015eL\u018eND\u0130R\u0130L\u018eC\u018eK", y)
y = draw_bullet("LiveSession model: ba\u015fl\u0131q, tarix, tip, qiym\u0259t, status, i\u015ftirak\u00e7\u0131lar", 20*mm, y)
y -= 2*mm
y = draw_bullet("CreateLiveSessionView m\u00f6vcuddur (trainer yarada bilir)", 20*mm, y)
y -= 2*mm
y = draw_bullet("WebSocket il\u0259 real-time \u0259laq\u0259, PoseDetection xidm\u0259ti var", 20*mm, y)
y -= 2*mm
y = draw_bullet("T\u0259l\u0259b\u0259 sessiyalara qo\u015fula bilir, formunu izl\u0259yir", 20*mm, y)
y -= 2*mm
y = draw_bullet("Trainer Hub-a inteqrasiya edil\u0259c\u0259k, \u00f6d\u0259ni\u015f ax\u0131n\u0131 g\u00fccl\u0259n\u0259c\u0259k", 20*mm, y, color=ORANGE)

new_page()

# ═══════════════════════════════════════════════════════════
# PAGE 3 — TO-BE
# ═══════════════════════════════════════════════════════════
y = H - 28*mm
y = draw_section_title("2. Yeni Arxitektura (TO-BE)", y)

y = draw_sub_title("2.1 Trainer Tab Strukturu (Yeni)", y)
draw_card(18*mm, y-56*mm, W-36*mm, 56*mm, fill=LIGHT_ACCENT)
new_tabs = [
    ("Tab 1:", "Home \u2014 TrainerHomeView (dashboard) \u2014 D\u018eY\u0130\u015eM\u018eZ"),
    ("Tab 2:", "Plans \u2014 TrainingPlanView \u2014 D\u018eY\u0130\u015eM\u018eZ"),
    ("Tab 3:", "Meal Plans \u2014 MealPlanView \u2014 D\u018eY\u0130\u015eM\u018eZ"),
    ("Tab 4:", "Chat \u2014 ConversationsView \u2014 D\u018eY\u0130\u015eM\u018eZ"),
    ("Tab 5:", "More \u2192 Trainer Hub (YEN\u0130) + Profil"),
    ("", "    \u251c\u2500\u2500 Canl\u0131 Sessiyalar (yaratma/idar\u0259)"),
    ("", "    \u2514\u2500\u2500 Market (m\u0259hsul yaratma/idar\u0259)"),
]
for i, (tab, desc) in enumerate(new_tabs):
    yy = y - 5*mm - i*7*mm
    if tab:
        c.setFont(FONT_B, 9)
        c.setFillColor(ACCENT)
        c.drawString(24*mm, yy, tab)
        c.setFont(FONT, 9)
        c.setFillColor(DARK)
        c.drawString(42*mm, yy, desc)
    else:
        c.setFont(FONT, 9)
        c.setFillColor(GREEN)
        c.drawString(42*mm, yy, desc)
y -= 62*mm

y = draw_sub_title("2.2 Trainer Hub \u2014 Yeni Ekran Strukturu", y)
draw_card(18*mm, y-75*mm, W-36*mm, 75*mm, fill=CARD)

c.setFont(FONT_B, 10)
c.setFillColor(ACCENT)
c.drawString(24*mm, y-7*mm, "TrainerHubView")
c.setFont(FONT, 9)
c.setFillColor(TEXT)
hub_desc = [
    "Segmented Picker: [Canl\u0131 Sessiyalar] | [Market]",
    "",
    "\u2500\u2500 Canl\u0131 Sessiyalar Tab \u2500\u2500",
    "  \u2022 G\u0259l\u0259c\u0259k sessiyalar\u0131n siyah\u0131s\u0131 (tarix s\u0131ras\u0131 il\u0259)",
    "  \u2022 + Yeni Sessiya Yarat d\u00fcym\u0259si \u2192 CreateLiveSessionView",
    "  \u2022 H\u0259r sessiya kart\u0131: ba\u015fl\u0131q, tarix, qiym\u0259t, status, i\u015ftirak\u00e7\u0131 say\u0131",
    "  \u2022 Sessiya redakt\u0259 / l\u0259\u011fv etm\u0259 funksiyas\u0131",
    "",
    "\u2500\u2500 Market Tab \u2500\u2500",
    "  \u2022 Trainer-in \u00f6z m\u0259hsullar\u0131n\u0131n siyah\u0131s\u0131",
    "  \u2022 + Yeni M\u0259hsul Yarat d\u00fcym\u0259si \u2192 CreateProductView (YEN\u0130)",
    "  \u2022 H\u0259r m\u0259hsul kart\u0131: \u015f\u0259kil, ad, qiym\u0259t, tip, status",
    "  \u2022 M\u0259hsul redakt\u0259 / deaktiv etm\u0259 funksiyas\u0131",
]
for i, line in enumerate(hub_desc):
    yy = y - 14*mm - i*4.5*mm
    if line.startswith("\u2500\u2500"):
        c.setFont(FONT_B, 9)
        c.setFillColor(ACCENT2)
    elif line.startswith("  \u2022"):
        c.setFont(FONT, 8.5)
        c.setFillColor(TEXT)
    else:
        c.setFont(FONT, 9)
        c.setFillColor(DARK)
    c.drawString(24*mm, yy, line)
y -= 82*mm

y = draw_sub_title("2.3 T\u0259l\u0259b\u0259 (User) T\u0259r\u0259fi \u2014 D\u0259yi\u015fiklikl\u0259r", y)
y = draw_bullet("HomeView-dak\u0131 Market butonu \u2192 MarketplaceView (m\u00f6vcud, geni\u015fl\u0259n\u0259c\u0259k)", 20*mm, y)
y -= 2*mm
y = draw_bullet("HomeView-dak\u0131 Live Sessions butonu \u2192 LiveSessionListView (m\u00f6vcud)", 20*mm, y)
y -= 2*mm
y = draw_bullet("M\u0259hsul al\u0131\u015f ax\u0131n\u0131: M\u0259hsul se\u00e7 \u2192 Detallar \u2192 \u00d6d\u0259ni\u015f \u2192 Sifari\u015f t\u0259sdiqi", 20*mm, y)
y -= 2*mm
y = draw_bullet("Sessiya qo\u015fulma ax\u0131n\u0131: Sessiya se\u00e7 \u2192 Detallar \u2192 \u00d6d\u0259ni\u015f (\u0259g\u0259r \u00f6d\u0259ni\u015fli) \u2192 Qo\u015ful", 20*mm, y)
y -= 2*mm
y = draw_bullet("M\u0259hsul tipl\u0259ri geni\u015fl\u0259nir: qida, d\u0259rs plan\u0131, e-kitab, konsultasiya", 20*mm, y)

new_page()

# ═══════════════════════════════════════════════════════════
# PAGE 4 — CANLI SESSİYALAR
# ═══════════════════════════════════════════════════════════
y = H - 28*mm
y = draw_section_title("3. Canl\u0131 Sessiyalar \u2014 Detall\u0131 Ax\u0131n", y)

y = draw_sub_title("3.1 Trainer: Sessiya Yaratma Ax\u0131n\u0131", y)
draw_card(18*mm, y-60*mm, W-36*mm, 60*mm, fill=CARD)
steps_trainer = [
    "1. Trainer Hub \u2192 Canl\u0131 Sessiyalar tab \u2192 '+ Yeni Sessiya' bas\u0131r",
    "2. CreateLiveSessionView a\u00e7\u0131l\u0131r (m\u00f6vcud form):",
    "   \u2022 Ba\u015fl\u0131q, T\u0259svir, Sessiya tipi (group/one_on_one/open)",
    "   \u2022 Tarix v\u0259 saat se\u00e7imi (DatePicker)",
    "   \u2022 M\u00fcdd\u0259t (d\u0259qiq\u0259), \u00c7\u0259tinlik s\u0259viyy\u0259si",
    "   \u2022 \u00d6d\u0259ni\u015fli/Pulsuz toggle + Qiym\u0259t (\u0259g\u0259r \u00f6d\u0259ni\u015fli)",
    "   \u2022 Maksimum i\u015ftirak\u00e7\u0131 say\u0131",
    "   \u2022 M\u0259\u015fq plan\u0131 (h\u0259r\u0259k\u0259tl\u0259r \u0259lav\u0259 etm\u0259)",
    "3. 'Yarat' \u2192 POST /api/v1/live-sessions \u2192 Backend-\u0259 yaz\u0131l\u0131r",
    "4. Sessiya 'scheduled' statusu il\u0259 siyah\u0131da g\u00f6r\u00fcn\u00fcr",
    "5. Tarix g\u0259ldikd\u0259 trainer 'Ba\u015flat' bas\u0131r \u2192 status: 'live'",
]
for i, step in enumerate(steps_trainer):
    yy = y - 6*mm - i*5*mm
    c.setFont(FONT, 8.5)
    c.setFillColor(DARK if not step.startswith("   ") else TEXT)
    if step[0].isdigit():
        c.setFont(FONT_B, 8.5)
        c.setFillColor(ACCENT)
    c.drawString(24*mm, yy, step)
y -= 67*mm

y = draw_sub_title("3.2 T\u0259l\u0259b\u0259: Sessiyaya Qo\u015fulma Ax\u0131n\u0131", y)
draw_card(18*mm, y-52*mm, W-36*mm, 52*mm, fill=CARD)
steps_student = [
    "1. User Home \u2192 'Canl\u0131 Sessiyalar' butonu \u2192 LiveSessionListView",
    "2. Siyah\u0131da g\u0259l\u0259c\u0259k sessiyalar g\u00f6r\u00fcn\u00fcr (filtr: upcoming/live/all)",
    "3. Sessiya kart\u0131na bas\u0131r \u2192 LiveSessionDetailView a\u00e7\u0131l\u0131r",
    "4. Sessiya detallar\u0131: trainer, tarix, qiym\u0259t, i\u015ftirak\u00e7\u0131 say\u0131",
    "5. \u018eg\u0259r \u00f6d\u0259ni\u015fli: '\u00d6d\u0259 v\u0259 Qo\u015ful' \u2192 \u00d6d\u0259ni\u015f ax\u0131n\u0131",
    "6. \u018eg\u0259r pulsuz: 'Qo\u015ful' \u2192 POST /api/v1/live-sessions/{id}/register",
    "7. Sessiya ba\u015flayanda: WebSocket ba\u011flant\u0131s\u0131, canl\u0131 m\u0259\u015fq ekran\u0131",
    "8. Real-time: forma izl\u0259m\u0259, d\u00fcz\u0259li\u015fl\u0259r, kalori, performans",
    "9. Sessiya bitdikd\u0259: n\u0259tic\u0259 ekran\u0131, r\u0259y yazma imkan\u0131",
]
for i, step in enumerate(steps_student):
    yy = y - 6*mm - i*5*mm
    c.setFont(FONT, 8.5)
    c.setFillColor(TEXT)
    if step[0].isdigit():
        c.setFont(FONT_B, 8.5)
        c.setFillColor(BLUE)
    c.drawString(24*mm, yy, step)
y -= 58*mm

y = draw_sub_title("3.3 Sessiya Statuslar\u0131", y)
draw_card(18*mm, y-28*mm, W-36*mm, 28*mm, fill=CARD)
statuses = [
    ("scheduled", "Planla\u015fd\u0131r\u0131l\u0131b \u2014 g\u00f6zl\u0259yir", ORANGE),
    ("live", "Canl\u0131 \u2014 haz\u0131rda davam edir", GREEN),
    ("completed", "Tamamlan\u0131b", MUTED),
    ("cancelled", "L\u0259\u011fv edilib", RED),
]
for i, (st, desc, color) in enumerate(statuses):
    yy = y - 7*mm - i*5*mm
    c.setFont(FONT_B, 8.5)
    c.setFillColor(color)
    c.drawString(24*mm, yy, st)
    c.setFont(FONT, 8.5)
    c.setFillColor(TEXT)
    c.drawString(55*mm, yy, f"\u2014 {desc}")

new_page()

# ═══════════════════════════════════════════════════════════
# PAGE 5 — MARKET
# ═══════════════════════════════════════════════════════════
y = H - 28*mm
y = draw_section_title("4. Market \u2014 Detall\u0131 Ax\u0131n", y)

y = draw_sub_title("4.1 M\u0259hsul Tipl\u0259ri (Geni\u015fl\u0259ndirilmi\u015f)", y)
draw_card(18*mm, y-38*mm, W-36*mm, 38*mm, fill=CARD)
ptypes = [
    ("workout_plan", "M\u0259\u015fq Plan\u0131", "Haz\u0131r m\u0259\u015fq proqramlar\u0131, PDF/video"),
    ("meal_plan", "Qida Plan\u0131", "P\u0259hriz, qidalanma proqramlar\u0131"),
    ("ebook", "E-Kitab", "Fitness/sa\u011flaml\u0131q m\u00f6vzusunda kitablar"),
    ("consultation", "Konsultasiya", "1:1 f\u0259rdi m\u0259sl\u0259h\u0259t sessiyas\u0131"),
    ("supplement", "\u018elav\u0259 qida (YEN\u0130)", "Protein, vitamin, kreatin v\u0259 s."),
    ("equipment", "Avadanl\u0131q (YEN\u0130)", "Fitness avadanl\u0131\u011f\u0131, aksesuarlar"),
]
for i, (code, name, desc) in enumerate(ptypes):
    yy = y - 6*mm - i*5*mm
    c.setFont(FONT_B, 8.5)
    c.setFillColor(ACCENT)
    c.drawString(24*mm, yy, code)
    c.setFont(FONT_B, 8.5)
    c.setFillColor(DARK)
    c.drawString(58*mm, yy, name)
    c.setFont(FONT, 8)
    c.setFillColor(MUTED)
    c.drawString(90*mm, yy, desc)
y -= 44*mm

y = draw_sub_title("4.2 Trainer: M\u0259hsul Yaratma Ax\u0131n\u0131", y)
draw_card(18*mm, y-55*mm, W-36*mm, 55*mm, fill=CARD)
market_trainer = [
    "1. Trainer Hub \u2192 Market tab \u2192 '+ Yeni M\u0259hsul' bas\u0131r",
    "2. CreateProductView (YEN\u0130 ekran) a\u00e7\u0131l\u0131r:",
    "   \u2022 M\u0259hsul tipi se\u00e7imi (Picker: workout_plan, meal_plan, ...)",
    "   \u2022 Ad (title), T\u0259svir (description) \u2014 text sah\u0259l\u0259ri",
    "   \u2022 Qiym\u0259t (price) + Valyuta (AZN/USD/EUR)",
    "   \u2022 \u00dcz \u015f\u0259kli (cover image) \u2014 ImagePicker il\u0259 y\u00fckl\u0259m\u0259",
    "   \u2022 Aktiv/Deaktiv toggle",
    "3. 'Yarat' \u2192 POST /api/v1/marketplace/products \u2192 Backend-\u0259 yaz\u0131l\u0131r",
    "4. \u00dcz \u015f\u0259kli \u2192 POST /api/v1/marketplace/products/{id}/image",
    "5. M\u0259hsul trainer-in siyah\u0131s\u0131nda g\u00f6r\u00fcn\u00fcr",
    "6. Redakt\u0259: PUT /api/v1/marketplace/products/{id}",
    "7. Silm\u0259/Deaktiv: DELETE /api/v1/marketplace/products/{id}",
]
for i, step in enumerate(market_trainer):
    yy = y - 5*mm - i*4.3*mm
    c.setFont(FONT, 8.5)
    c.setFillColor(DARK if not step.startswith("   ") else TEXT)
    if step[0].isdigit():
        c.setFont(FONT_B, 8.5)
        c.setFillColor(ACCENT)
    c.drawString(24*mm, yy, step)
y -= 61*mm

y = draw_sub_title("4.3 T\u0259l\u0259b\u0259: M\u0259hsul Al\u0131\u015f Ax\u0131n\u0131", y)
draw_card(18*mm, y-45*mm, W-36*mm, 45*mm, fill=CARD)
market_student = [
    "1. User Home \u2192 'Market' butonu \u2192 MarketplaceView",
    "2. M\u0259hsullar siyah\u0131s\u0131 (filtr: ham\u0131s\u0131, m\u0259\u015fq, qida, ...)",
    "3. M\u0259hsul kart\u0131na bas\u0131r \u2192 ProductDetailView",
    "4. Detallar: \u015f\u0259kil, ad, t\u0259svir, qiym\u0259t, trainer, r\u0259yl\u0259r, reytinq",
    "5. 'Sat\u0131n Al' d\u00fcym\u0259si \u2192 \u00d6d\u0259ni\u015f ax\u0131n\u0131 (Apple Pay / kart)",
    "6. POST /api/v1/marketplace/products/{id}/purchase",
    "7. U\u011furlu al\u0131\u015fdan sonra: t\u0259sdiq ekran\u0131 + m\u0259hsula \u00e7\u0131x\u0131\u015f",
    "8. T\u0259l\u0259b\u0259 r\u0259y yaza bilir: POST /.../{id}/reviews",
]
for i, step in enumerate(market_student):
    yy = y - 5*mm - i*5*mm
    c.setFont(FONT, 8.5)
    c.setFillColor(TEXT)
    if step[0].isdigit():
        c.setFont(FONT_B, 8.5)
        c.setFillColor(BLUE)
    c.drawString(24*mm, yy, step)

new_page()

# ═══════════════════════════════════════════════════════════
# PAGE 6 — API
# ═══════════════════════════════════════════════════════════
y = H - 28*mm
y = draw_section_title("5. Backend API Endpoint-l\u0259ri", y)

y = draw_sub_title("5.1 Canl\u0131 Sessiyalar API (M\u00f6vcud)", y)
draw_card(18*mm, y-42*mm, W-36*mm, 42*mm, fill=CARD)
api_session = [
    ("GET", "/api/v1/live-sessions", "Sessiya siyah\u0131s\u0131 (filtr+pagination)", GREEN),
    ("POST", "/api/v1/live-sessions", "Yeni sessiya yarat (trainer)", ORANGE),
    ("GET", "/api/v1/live-sessions/{id}", "Sessiya detallar\u0131", GREEN),
    ("POST", "/api/v1/live-sessions/{id}/register", "Sessiyaya qo\u015ful", ORANGE),
    ("GET", "/api/v1/live-sessions/{id}/participants", "\u0130\u015ftirak\u00e7\u0131 siyah\u0131s\u0131", GREEN),
    ("GET", "/api/v1/live-sessions/{id}/stats", "Sessiya statistikas\u0131", GREEN),
    ("WSS", "wss://api.corevia.life/ws/live-session/{id}", "Real-time WebSocket", BLUE),
]
for i, (method, path, desc, color) in enumerate(api_session):
    yy = y - 6*mm - i*5*mm
    c.setFont(FONT_B, 7.5)
    c.setFillColor(color)
    c.drawString(24*mm, yy, method)
    c.setFont(FONT, 7.5)
    c.setFillColor(DARK)
    c.drawString(38*mm, yy, path)
    c.setFillColor(MUTED)
    c.drawString(120*mm, yy, desc)
y -= 48*mm

y = draw_sub_title("5.2 Canl\u0131 Sessiyalar API (YEN\u0130 \u2014 \u0259lav\u0259 edil\u0259c\u0259k)", y)
draw_card(18*mm, y-25*mm, W-36*mm, 25*mm, fill=HexColor("#FFF7ED"))
api_new_session = [
    ("PUT", "/api/v1/live-sessions/{id}", "Sessiya redakt\u0259 et (trainer)", ORANGE),
    ("DELETE", "/api/v1/live-sessions/{id}", "Sessiya l\u0259\u011fv et (trainer)", RED),
    ("POST", "/api/v1/live-sessions/{id}/start", "Sessiya ba\u015flat (trainer)", ORANGE),
    ("GET", "/api/v1/live-sessions/my", "Trainer-in \u00f6z sessiyalar\u0131", GREEN),
]
for i, (method, path, desc, color) in enumerate(api_new_session):
    yy = y - 6*mm - i*4.5*mm
    c.setFont(FONT_B, 7.5)
    c.setFillColor(color)
    c.drawString(24*mm, yy, method)
    c.setFont(FONT, 7.5)
    c.setFillColor(DARK)
    c.drawString(42*mm, yy, path)
    c.setFillColor(MUTED)
    c.drawString(115*mm, yy, desc)
y -= 32*mm

y = draw_sub_title("5.3 Market API (M\u00f6vcud)", y)
draw_card(18*mm, y-30*mm, W-36*mm, 30*mm, fill=CARD)
api_market = [
    ("GET", "/api/v1/marketplace/products", "M\u0259hsul siyah\u0131s\u0131 (filtr+pagination)", GREEN),
    ("POST", "/api/v1/marketplace/products", "Yeni m\u0259hsul yarat (trainer)", ORANGE),
    ("GET", "/api/v1/marketplace/products/{id}", "M\u0259hsul detallar\u0131", GREEN),
    ("POST", "/api/v1/marketplace/products/{id}/purchase", "M\u0259hsul al (user)", ORANGE),
    ("POST", "/api/v1/marketplace/products/{id}/reviews", "R\u0259y yaz (user)", ORANGE),
]
for i, (method, path, desc, color) in enumerate(api_market):
    yy = y - 6*mm - i*4.5*mm
    c.setFont(FONT_B, 7.5)
    c.setFillColor(color)
    c.drawString(24*mm, yy, method)
    c.setFont(FONT, 7.5)
    c.setFillColor(DARK)
    c.drawString(42*mm, yy, path)
    c.setFillColor(MUTED)
    c.drawString(118*mm, yy, desc)
y -= 36*mm

y = draw_sub_title("5.4 Market API (YEN\u0130 \u2014 \u0259lav\u0259 edil\u0259c\u0259k)", y)
draw_card(18*mm, y-25*mm, W-36*mm, 25*mm, fill=HexColor("#FFF7ED"))
api_new_market = [
    ("GET", "/api/v1/marketplace/products/my", "Trainer-in \u00f6z m\u0259hsullar\u0131", GREEN),
    ("PUT", "/api/v1/marketplace/products/{id}", "M\u0259hsul redakt\u0259 et (trainer)", ORANGE),
    ("DELETE", "/api/v1/marketplace/products/{id}", "M\u0259hsul sil (trainer)", RED),
    ("POST", "/api/v1/marketplace/products/{id}/image", "M\u0259hsul \u015f\u0259kli y\u00fckl\u0259", ORANGE),
]
for i, (method, path, desc, color) in enumerate(api_new_market):
    yy = y - 6*mm - i*4.5*mm
    c.setFont(FONT_B, 7.5)
    c.setFillColor(color)
    c.drawString(24*mm, yy, method)
    c.setFont(FONT, 7.5)
    c.setFillColor(DARK)
    c.drawString(42*mm, yy, path)
    c.setFillColor(MUTED)
    c.drawString(118*mm, yy, desc)

new_page()

# ═══════════════════════════════════════════════════════════
# PAGE 7 — MODELLƏRİ + FAYL PLANI
# ═══════════════════════════════════════════════════════════
y = H - 28*mm
y = draw_section_title("6. Data Modell\u0259ri v\u0259 iOS Fayl Plan\u0131", y)

y = draw_sub_title("6.1 M\u00f6vcud Modell\u0259r (d\u0259yi\u015fm\u0259y\u0259c\u0259k)", y)
draw_card(18*mm, y-32*mm, W-36*mm, 32*mm, fill=CARD)
models_existing = [
    "MarketplaceProduct { id, sellerId, productType, title, description, price, currency, coverImageUrl, isActive }",
    "LiveSession { id, trainerId, title, description, sessionType, scheduledStart, status, isPaid, price, ... }",
    "CreateProductRequest { productType, title, description, price, currency, isActive }",
    "CreateSessionRequest { title, sessionType, scheduledStart, isPaid, price, workoutPlan, ... }",
    "ProductPurchase, ProductReview, SessionParticipant, SessionStats \u2014 HAMISI M\u00d6VCUD",
]
for i, m in enumerate(models_existing):
    yy = y - 6*mm - i*5*mm
    c.setFont(FONT, 7.5)
    c.setFillColor(TEXT)
    c.drawString(24*mm, yy, m)
y -= 38*mm

y = draw_sub_title("6.2 iOS Fayl D\u0259yi\u015fiklikl\u0259ri Plan\u0131", y)
draw_card(18*mm, y-80*mm, W-36*mm, 80*mm, fill=LIGHT_ACCENT)

files_plan = [
    ("S\u0130L\u0130N\u018eC\u018eK:", RED),
    ("  TrainerContentView.swift \u2014 M\u0259zmun ekran\u0131 (silinir, hub il\u0259 \u0259v\u0259z)", TEXT),
    ("  ContentModels.swift \u2014 Content modell\u0259ri (art\u0131q laz\u0131m deyil)", TEXT),
    ("", None),
    ("YEN\u0130 YARADILACAQ:", GREEN),
    ("  TrainerHubView.swift \u2014 Hub ekran\u0131 (Segmented: Sessiyalar | Market)", TEXT),
    ("  CreateProductView.swift \u2014 M\u0259hsul yaratma formu (trainer)", TEXT),
    ("  TrainerProductsViewModel.swift \u2014 Trainer m\u0259hsullar\u0131 idar\u0259si", TEXT),
    ("  TrainerSessionsViewModel.swift \u2014 Trainer sessiyalar\u0131 idar\u0259si", TEXT),
    ("", None),
    ("D\u018eY\u0130\u015eD\u0130R\u0130L\u018eC\u018eK:", ORANGE),
    ("  CustomTabBar.swift \u2014 'M\u0259zmun' \u2192 'Trainer Hub' d\u0259yi\u015fikliyi", TEXT),
    ("  ContentView.swift \u2014 Navigation yenil\u0259m\u0259", TEXT),
    ("  MarketplaceView.swift \u2014 Yeni m\u0259hsul tipl\u0259ri \u0259lav\u0259si", TEXT),
    ("  MarketplaceModels.swift \u2014 supplement, equipment tipl\u0259ri", TEXT),
    ("  ProductDetailView.swift \u2014 \u00d6d\u0259ni\u015f ax\u0131n\u0131 g\u00fccl\u0259ndirilm\u0259si", TEXT),
]
for i, (line, color) in enumerate(files_plan):
    if color is None:
        continue
    yy = y - 6*mm - i*4.5*mm
    c.setFont(FONT_B if line and not line.startswith("  ") else FONT, 8)
    c.setFillColor(color)
    c.drawString(24*mm, yy, line)
y -= 86*mm

y = draw_sub_title("6.3 Backend T\u0259l\u0259bl\u0259ri", y)
y = draw_bullet("Yeni endpoint-l\u0259r: PUT/DELETE sessions, GET /my sessions, GET /my products", 20*mm, y, size=8.5)
y -= 2*mm
y = draw_bullet("M\u0259hsul \u015f\u0259kil upload endpoint (\u0259g\u0259r yoxdursa \u0259lav\u0259 et)", 20*mm, y, size=8.5)
y -= 2*mm
y = draw_bullet("\u00d6d\u0259ni\u015f inteqrasiyas\u0131: Apple In-App Purchase v\u0259 ya Stripe", 20*mm, y, size=8.5)
y -= 2*mm
y = draw_bullet("Bildiri\u015f: Sessiya xat\u0131rlatmas\u0131 (push notification 30 d\u0259q \u0259vv\u0259l)", 20*mm, y, size=8.5)

new_page()

# ═══════════════════════════════════════════════════════════
# PAGE 8 — İCRA PLANI
# ═══════════════════════════════════════════════════════════
y = H - 28*mm
y = draw_section_title("7. \u0130cra Plan\u0131 v\u0259 Prioritetl\u0259r", y)

y = draw_sub_title("7.1 Fazalar (Sprint Plan\u0131)", y)

# Phase 1
draw_card(18*mm, y-38*mm, (W-42*mm)/2, 38*mm, fill=CARD)
c.setFont(FONT_B, 10)
c.setFillColor(ACCENT)
c.drawString(24*mm, y-7*mm, "Faza 1: Trainer Hub (3-4 g\u00fcn)")
c.setFont(FONT, 8)
c.setFillColor(TEXT)
p1 = [
    "\u2713 TrainerContentView silinir",
    "\u2713 TrainerHubView yarad\u0131l\u0131r",
    "\u2713 Segmented Picker: Sessiyalar | Market",
    "\u2713 CustomTabBar yenil\u0259nir",
    "\u2713 M\u00f6vcud sessiya siyah\u0131s\u0131 hub-a ke\u00e7ir",
]
for i, item in enumerate(p1):
    c.drawString(24*mm, y-14*mm - i*4.5*mm, item)

# Phase 2
x2 = 18*mm + (W-42*mm)/2 + 6*mm
draw_card(x2, y-38*mm, (W-42*mm)/2, 38*mm, fill=CARD)
c.setFont(FONT_B, 10)
c.setFillColor(GREEN)
c.drawString(x2+6*mm, y-7*mm, "Faza 2: Market CRUD (3-4 g\u00fcn)")
c.setFont(FONT, 8)
c.setFillColor(TEXT)
p2 = [
    "\u2713 CreateProductView yarad\u0131l\u0131r",
    "\u2713 ImagePicker inteqrasiyas\u0131",
    "\u2713 M\u0259hsul siyah\u0131s\u0131 (trainer \u00f6z)",
    "\u2713 Redakt\u0259/silm\u0259 funksiyas\u0131",
    "\u2713 Yeni m\u0259hsul tipl\u0259ri \u0259lav\u0259si",
]
for i, item in enumerate(p2):
    c.drawString(x2+6*mm, y-14*mm - i*4.5*mm, item)

y -= 45*mm

# Phase 3
draw_card(18*mm, y-38*mm, (W-42*mm)/2, 38*mm, fill=CARD)
c.setFont(FONT_B, 10)
c.setFillColor(BLUE)
c.drawString(24*mm, y-7*mm, "Faza 3: \u00d6d\u0259ni\u015f Ax\u0131n\u0131 (2-3 g\u00fcn)")
c.setFont(FONT, 8)
c.setFillColor(TEXT)
p3 = [
    "\u2713 M\u0259hsul al\u0131\u015f \u00f6d\u0259ni\u015f ekran\u0131",
    "\u2713 Sessiya \u00f6d\u0259ni\u015f ax\u0131n\u0131",
    "\u2713 Al\u0131\u015f t\u0259sdiq ekran\u0131",
    "\u2713 Al\u0131nm\u0131\u015f m\u0259hsullar siyah\u0131s\u0131",
    "\u2713 X\u0259ta idar\u0259etm\u0259si",
]
for i, item in enumerate(p3):
    c.drawString(24*mm, y-14*mm - i*4.5*mm, item)

# Phase 4
draw_card(x2, y-38*mm, (W-42*mm)/2, 38*mm, fill=CARD)
c.setFont(FONT_B, 10)
c.setFillColor(ORANGE)
c.drawString(x2+6*mm, y-7*mm, "Faza 4: Test & Cila (2 g\u00fcn)")
c.setFont(FONT, 8)
c.setFillColor(TEXT)
p4 = [
    "\u2713 B\u00fct\u00fcn ax\u0131nlar\u0131n end-to-end testi",
    "\u2713 Bo\u015f siyah\u0131, x\u0259ta hallar\u0131",
    "\u2713 UI/UX yax\u015f\u0131la\u015fd\u0131rma",
    "\u2713 Y\u00fckl\u0259nm\u0259 animasiyalar\u0131, skeleton-lar",
    "\u2713 Lokalizasiya (AZ/EN/DE)",
]
for i, item in enumerate(p4):
    c.drawString(x2+6*mm, y-14*mm - i*4.5*mm, item)

y -= 50*mm

y = draw_sub_title("7.2 \u00dcmumi M\u00fcdd\u0259t", y)
draw_card(18*mm, y-18*mm, W-36*mm, 18*mm, fill=ACCENT)
c.setFillColor(HexColor("#FFFFFF"))
c.setFont(FONT_B, 14)
c.drawCentredString(W/2, y-12*mm, "T\u0259xmini m\u00fcdd\u0259t: 10-13 i\u015f g\u00fcn\u00fc")
y -= 26*mm

y = draw_sub_title("7.3 Riskl\u0259r v\u0259 As\u0131l\u0131l\u0131qlar", y)
y = draw_bullet("Backend endpoint-l\u0259ri haz\u0131r olmal\u0131d\u0131r (PUT/DELETE sessions, GET /my)", 20*mm, y, size=8.5)
y -= 2*mm
y = draw_bullet("Apple In-App Purchase inteqrasiyas\u0131 \u0259lav\u0259 vaxt t\u0259l\u0259b ed\u0259 bil\u0259r", 20*mm, y, size=8.5)
y -= 2*mm
y = draw_bullet("WebSocket sessiya idar\u0259etm\u0259si m\u00f6vcuddur \u2014 yeni risk yoxdur", 20*mm, y, size=8.5)
y -= 2*mm
y = draw_bullet("Push notification servisi laz\u0131md\u0131r (sessiya xat\u0131rlatmas\u0131 \u00fc\u00e7\u00fcn)", 20*mm, y, size=8.5)

new_page()

# ═══════════════════════════════════════════════════════════
# PAGE 9 — USER FLOW
# ═══════════════════════════════════════════════════════════
y = H - 28*mm
y = draw_section_title("8. User Flow Diaqramlar\u0131", y)

y = draw_sub_title("8.1 Trainer \u2192 Canl\u0131 Sessiya Yaratma Flow", y)
draw_card(18*mm, y-32*mm, W-36*mm, 32*mm, fill=CARD)
boxes_t = ["Trainer Hub", "Sessiyalar Tab", "+ Yeni Sessiya", "Form Doldur", "POST API", "Siyah\u0131da g\u00f6r\u00fcn\u00fcr"]
bw = 26*mm
for i, box in enumerate(boxes_t):
    bx = 22*mm + i*(bw+4*mm)
    by = y - 15*mm
    c.setFillColor(ACCENT if i < 3 else GREEN)
    c.roundRect(bx, by, bw, 10*mm, 2*mm, fill=1, stroke=0)
    c.setFillColor(HexColor("#FFFFFF"))
    c.setFont(FONT_B, 6.5)
    c.drawCentredString(bx + bw/2, by + 3.5*mm, box)
    if i < len(boxes_t)-1:
        c.setStrokeColor(ACCENT)
        c.setLineWidth(1.5)
        c.line(bx+bw+1, by+5*mm, bx+bw+3*mm, by+5*mm)
        c.line(bx+bw+2.5*mm, by+6.5*mm, bx+bw+3.5*mm, by+5*mm)
        c.line(bx+bw+2.5*mm, by+3.5*mm, bx+bw+3.5*mm, by+5*mm)
y -= 38*mm

y = draw_sub_title("8.2 T\u0259l\u0259b\u0259 \u2192 Sessiyaya Qo\u015fulma Flow", y)
draw_card(18*mm, y-32*mm, W-36*mm, 32*mm, fill=CARD)
boxes_s = ["Home Ekran", "Canl\u0131 Sessiyalar", "Sessiya Se\u00e7", "\u00d6d\u0259ni\u015f", "Qo\u015ful", "Canl\u0131 M\u0259\u015fq"]
for i, box in enumerate(boxes_s):
    bx = 22*mm + i*(bw+4*mm)
    by = y - 15*mm
    c.setFillColor(BLUE if i < 3 else GREEN)
    c.roundRect(bx, by, bw, 10*mm, 2*mm, fill=1, stroke=0)
    c.setFillColor(HexColor("#FFFFFF"))
    c.setFont(FONT_B, 6.5)
    c.drawCentredString(bx + bw/2, by + 3.5*mm, box)
    if i < len(boxes_s)-1:
        c.setStrokeColor(BLUE)
        c.setLineWidth(1.5)
        c.line(bx+bw+1, by+5*mm, bx+bw+3*mm, by+5*mm)
        c.line(bx+bw+2.5*mm, by+6.5*mm, bx+bw+3.5*mm, by+5*mm)
        c.line(bx+bw+2.5*mm, by+3.5*mm, bx+bw+3.5*mm, by+5*mm)
y -= 38*mm

y = draw_sub_title("8.3 Trainer \u2192 M\u0259hsul Yaratma Flow", y)
draw_card(18*mm, y-32*mm, W-36*mm, 32*mm, fill=CARD)
boxes_p = ["Trainer Hub", "Market Tab", "+ Yeni M\u0259hsul", "Form + \u015e\u0259kil", "POST API", "Marketd\u0259 g\u00f6r\u00fcn\u00fcr"]
for i, box in enumerate(boxes_p):
    bx = 22*mm + i*(bw+4*mm)
    by = y - 15*mm
    c.setFillColor(ACCENT2 if i < 3 else GREEN)
    c.roundRect(bx, by, bw, 10*mm, 2*mm, fill=1, stroke=0)
    c.setFillColor(HexColor("#FFFFFF"))
    c.setFont(FONT_B, 6.5)
    c.drawCentredString(bx + bw/2, by + 3.5*mm, box)
    if i < len(boxes_p)-1:
        c.setStrokeColor(ACCENT2)
        c.setLineWidth(1.5)
        c.line(bx+bw+1, by+5*mm, bx+bw+3*mm, by+5*mm)
        c.line(bx+bw+2.5*mm, by+6.5*mm, bx+bw+3.5*mm, by+5*mm)
        c.line(bx+bw+2.5*mm, by+3.5*mm, bx+bw+3.5*mm, by+5*mm)
y -= 38*mm

y = draw_sub_title("8.4 T\u0259l\u0259b\u0259 \u2192 M\u0259hsul Al\u0131\u015f Flow", y)
draw_card(18*mm, y-32*mm, W-36*mm, 32*mm, fill=CARD)
boxes_b = ["Home Ekran", "Market", "M\u0259hsul Se\u00e7", "Detallar", "\u00d6d\u0259 & Al", "Sifari\u015f T\u0259sdiqi"]
for i, box in enumerate(boxes_b):
    bx = 22*mm + i*(bw+4*mm)
    by = y - 15*mm
    c.setFillColor(BLUE if i < 4 else GREEN)
    c.roundRect(bx, by, bw, 10*mm, 2*mm, fill=1, stroke=0)
    c.setFillColor(HexColor("#FFFFFF"))
    c.setFont(FONT_B, 6.5)
    c.drawCentredString(bx + bw/2, by + 3.5*mm, box)
    if i < len(boxes_b)-1:
        c.setStrokeColor(BLUE)
        c.setLineWidth(1.5)
        c.line(bx+bw+1, by+5*mm, bx+bw+3*mm, by+5*mm)
        c.line(bx+bw+2.5*mm, by+6.5*mm, bx+bw+3.5*mm, by+5*mm)
        c.line(bx+bw+2.5*mm, by+3.5*mm, bx+bw+3.5*mm, by+5*mm)

# ═══════════════════════════════════════════════════════════
# SAVE
# ═══════════════════════════════════════════════════════════
c.save()
print(f"PDF yaradildi: {output}")
print(f"Olcu: {os.path.getsize(output) / 1024:.0f} KB")
