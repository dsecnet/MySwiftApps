from reportlab.lib.pagesizes import A4
from reportlab.lib.units import mm
from reportlab.pdfgen.canvas import Canvas
from reportlab.lib.colors import HexColor
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
import textwrap, os

pdfmetrics.registerFont(TTFont("Arial", "/System/Library/Fonts/Supplemental/Arial.ttf"))
pdfmetrics.registerFont(TTFont("ArialB", "/System/Library/Fonts/Supplemental/Arial Bold.ttf"))
F = "Arial"
B = "ArialB"

BG = HexColor("#FFFFFF"); CARD = HexColor("#F7F8FA"); ACCENT = HexColor("#4F46E5")
ACCENT2 = HexColor("#7C3AED"); DARK = HexColor("#1a1a2e"); TXT = HexColor("#333333")
MUT = HexColor("#666666"); LA = HexColor("#EEF2FF"); GRN = HexColor("#059669")
ORG = HexColor("#D97706"); RED = HexColor("#DC2626"); BLU = HexColor("#2563EB")
BRD = HexColor("#E5E7EB"); WHT = HexColor("#FFFFFF"); TEAL = HexColor("#0D9488")

W, H = A4
out = os.path.expanduser("~/Desktop/CoreVia_BA_Texniki_Plan.pdf")
c = Canvas(out, pagesize=A4)
page_num = [0]

def bg():
    c.setFillColor(BG); c.rect(0,0,W,H,fill=1,stroke=0)

def hdr():
    c.setFillColor(ACCENT); c.rect(0,H-16*mm,W,16*mm,fill=1,stroke=0)
    c.setFillColor(WHT); c.setFont(B,8.5)
    c.drawString(15*mm,H-11*mm,"CoreVia \u2014 Texniki BA Plan")
    c.setFont(F,7.5)
    page_num[0] += 1
    c.drawRightString(W-15*mm,H-11*mm,f"S\u0259hif\u0259 {page_num[0]} | Konfidensial | 2025")

def card(x,y,w,h,fl=CARD,r=3.5*mm):
    c.setFillColor(fl); c.setStrokeColor(BRD); c.setLineWidth(0.4)
    c.roundRect(x,y,w,h,r,fill=1,stroke=1)

def bul(t,x,y,sz=8.5,col=TXT,mw=155*mm):
    c.setFont(F,sz); c.setFillColor(ACCENT); c.drawString(x,y,"\u2022")
    c.setFillColor(col)
    for i,ln in enumerate(textwrap.wrap(t,int(mw/(sz*0.44)))):
        c.drawString(x+3.5*mm,y-i*sz*1.45,ln)
    return y-len(textwrap.wrap(t,int(mw/(sz*0.44))))*sz*1.45

def sec(t,y):
    c.setFillColor(ACCENT); c.setFont(B,12.5); c.drawString(15*mm,y,t)
    c.setStrokeColor(ACCENT); c.setLineWidth(1.2); c.line(15*mm,y-2.5,W-15*mm,y-2.5)
    return y-9*mm

def sub(t,y):
    c.setFillColor(DARK); c.setFont(B,9.5); c.drawString(18*mm,y,t); return y-5.5*mm

def np():
    c.showPage(); bg(); hdr()

def flow_boxes(boxes, y, colors_split, color1, color2):
    card(18*mm,y-30*mm,W-36*mm,30*mm,fl=CARD)
    bw=26*mm
    for i,box in enumerate(boxes):
        bx=22*mm+i*(bw+4*mm); by=y-14*mm
        c.setFillColor(color1 if i<colors_split else color2)
        c.roundRect(bx,by,bw,9*mm,2*mm,fill=1,stroke=0)
        c.setFillColor(WHT); c.setFont(B,6.2)
        c.drawCentredString(bx+bw/2,by+3*mm,box)
        if i<len(boxes)-1:
            c.setStrokeColor(color1); c.setLineWidth(1.2)
            c.line(bx+bw+1,by+4.5*mm,bx+bw+3*mm,by+4.5*mm)
            c.line(bx+bw+2.2*mm,by+6*mm,bx+bw+3.2*mm,by+4.5*mm)
            c.line(bx+bw+2.2*mm,by+3*mm,bx+bw+3.2*mm,by+4.5*mm)
    return y-36*mm

# =============================================
# PAGE 1 - COVER
# =============================================
bg()
c.setFillColor(ACCENT); c.rect(0,H-260,W,260,fill=1,stroke=0)
c.setFillColor(ACCENT2); c.rect(0,H-260,W/2,260,fill=1,stroke=0)
c.setFillColor(WHT); c.setFont(B,38); c.drawString(25*mm,H-52*mm,"CoreVia")
c.setFont(F,13); c.drawString(25*mm,H-60*mm,"iOS Mobil T\u0259tbiq \u2014 Texniki BA Plan")
c.setFont(F,10.5); c.drawString(25*mm,H-74*mm,"M\u00fc\u0259llim (Trainer) Paneli + AI Sistemi:")
c.setFont(B,12); c.drawString(25*mm,H-82*mm,"Market + Canl\u0131 Sessiyalar + AI Kalori + AI T\u00f6vsiy\u0259l\u0259r")

y_info=H-125*mm
card(20*mm,y_info,W-40*mm,50*mm,fl=CARD)
c.setFillColor(DARK); c.setFont(B,10); c.drawString(28*mm,y_info+38*mm,"S\u0259n\u0259d M\u0259lumatlar\u0131")
for i,(lb,vl) in enumerate([("Layih\u0259:","CoreVia iOS App"),("Modul:","Trainer Hub + AI Kalori + AI T\u00f6vsiy\u0259l\u0259r"),("S\u0259n\u0259d tipi:","Business Analysis (BA) Texniki Plan"),("Tarix:","Fevral 2025"),("Versiya:","3.0 \u2014 Tam Lokal ML"),("Haz\u0131rlayan:","CoreVia Development Team")]):
    yy=y_info+30*mm-i*6*mm
    c.setFont(B,8.5); c.setFillColor(MUT); c.drawString(28*mm,yy,lb)
    c.setFont(F,8.5); c.setFillColor(DARK); c.drawString(60*mm,yy,vl)

y_sc=y_info-15*mm
card(20*mm,y_sc-62*mm,W-40*mm,68*mm,fl=LA)
c.setFillColor(ACCENT); c.setFont(B,10); c.drawString(28*mm,y_sc+48*mm-7*mm,"\u018ehat\u0259 dair\u0259si (Scope)")
c.setFillColor(TXT); c.setFont(F,8.5)
scopes=[
    "1. Trainer profilind\u0259ki 'M\u0259zmun' b\u00f6lm\u0259sini silm\u0259k \u2192 'Trainer Hub' il\u0259 \u0259v\u0259zl\u0259m\u0259k",
    "2. Trainer Hub: 2 alt b\u00f6lm\u0259 \u2014 Canl\u0131 Sessiyalar + Market",
    "3. Trainer t\u0259r\u0259find\u0259n Canl\u0131 Sessiya yaratma, tarix t\u0259yin etm\u0259",
    "4. Trainer t\u0259r\u0259find\u0259n Market m\u0259hsul yaratma (\u015f\u0259kil, qiym\u0259t, tip)",
    "5. T\u0259l\u0259b\u0259 t\u0259r\u0259find\u0259n sessiyalar\u0131 g\u00f6rm\u0259, \u00f6d\u0259ni\u015f, qo\u015fulma",
    "6. T\u0259l\u0259b\u0259 t\u0259r\u0259find\u0259n marketd\u0259n m\u0259hsul sifari\u015f/al\u0131\u015f",
    "7. AI Kalori \u2014 Backend-d\u0259 Python ML il\u0259 qida tan\u0131ma + makro hesablama",
    "8. AI T\u00f6vsiy\u0259 \u2014 Backend-d\u0259 Python ML il\u0259 f\u0259rdi m\u0259\u015fq/qida t\u00f6vsiy\u0259l\u0259ri",
    "9. HE\u00c7 B\u0130R XAR\u0130C\u0130 AI API YOX \u2014 h\u0259r \u015fey backend-in \u00f6z\u00fcnd\u0259!",
]
for i,s in enumerate(scopes):
    c.drawString(28*mm,y_sc+38*mm-7*mm-i*5.2*mm,s)
page_num[0]=1
np()

# =============================================
# PAGE 2 - CARi VEZiYYET
# =============================================
y=H-25*mm
y=sec("1. Cari V\u0259ziyy\u0259t Analizi (AS-IS)",y)
y=sub("1.1 Trainer Tab Strukturu (Haz\u0131rk\u0131)",y)
card(18*mm,y-42*mm,W-36*mm,42*mm)
for i,(t,d) in enumerate([("Tab 1:","Home \u2014 TrainerHomeView (dashboard, statistika)"),("Tab 2:","Plans \u2014 TrainingPlanView (m\u0259\u015fq planlar\u0131)"),("Tab 3:","Meal Plans \u2014 MealPlanView (qida planlar\u0131)"),("Tab 4:","Chat \u2014 ConversationsView (mesajla\u015fma)"),("Tab 5:","More \u2192 M\u0259zmun (TrainerContentView) + Profil")]):
    yy=y-6*mm-i*7*mm
    c.setFont(B,8.5); c.setFillColor(ACCENT); c.drawString(24*mm,yy,t)
    c.setFont(F,8.5); c.setFillColor(TXT); c.drawString(42*mm,yy,d)
y-=48*mm

y=sub("1.2 M\u00f6vcud M\u0259zmun \u2014 S\u0130L\u0130N\u018eC\u018eK",y)
y=bul("Trainer text post + \u015f\u0259kil payla\u015f\u0131r, premium-only se\u00e7imi var",20*mm,y); y-=2*mm
y=bul("Bu b\u00f6lm\u0259 silin\u0259c\u0259k \u2192 yerin\u0259 'Trainer Hub' g\u0259l\u0259c\u0259k",20*mm,y,col=RED); y-=6*mm

y=sub("1.3 M\u00f6vcud Market (User t\u0259r\u0259f)",y)
y=bul("T\u0259l\u0259b\u0259 m\u0259hsullar\u0131 g\u00f6r\u00fcr, filtr edir, al\u0131r, r\u0259y yaz\u0131r",20*mm,y); y-=2*mm
y=bul("Trainer t\u0259r\u0259fd\u0259 m\u0259hsul yaratma UI yoxdur \u2014 \u0259lav\u0259 edil\u0259c\u0259k",20*mm,y,col=ORG); y-=6*mm

y=sub("1.4 M\u00f6vcud AI Sistemi",y)
y=bul("Kalori analizi: /api/v1/food/analyze m\u00f6vcud \u2014 xarici API-y\u0259 g\u00f6nd\u0259rir",20*mm,y); y-=2*mm
y=bul("Problem: xarici AI API-d\u0259n as\u0131l\u0131d\u0131r, x\u0259rc var, kontrol yoxdur",20*mm,y,col=RED); y-=2*mm
y=bul("AI T\u00f6vsiy\u0259l\u0259r: Sad\u0259 if/else rule-based, ML yoxdur",20*mm,y,col=RED); y-=2*mm
y=bul("H\u0259d\u0259f: H\u018eR \u015eEY BACKEND-\u0130N \u00d6Z\u00dcND\u018e Python ML il\u0259 i\u015fl\u0259sin!",20*mm,y,col=GRN)

np()

# =============================================
# PAGE 3 - YENi ARXiTEKTURA
# =============================================
y=H-25*mm
y=sec("2. Yeni Arxitektura (TO-BE)",y)
y=sub("2.1 Trainer Tab Strukturu (Yeni)",y)
card(18*mm,y-48*mm,W-36*mm,48*mm,fl=LA)
for i,(t,d) in enumerate([("Tab 1:","Home \u2014 TrainerHomeView \u2014 D\u018eY\u0130\u015eM\u018eZ"),("Tab 2:","Plans \u2014 TrainingPlanView \u2014 D\u018eY\u0130\u015eM\u018eZ"),("Tab 3:","Meal Plans \u2014 MealPlanView \u2014 D\u018eY\u0130\u015eM\u018eZ"),("Tab 4:","Chat \u2014 ConversationsView \u2014 D\u018eY\u0130\u015eM\u018eZ"),("Tab 5:","More \u2192 Trainer Hub (YEN\u0130) + Profil")]):
    yy=y-6*mm-i*7*mm; c.setFont(B,8.5); c.setFillColor(ACCENT); c.drawString(24*mm,yy,t)
    c.setFont(F,8.5); c.setFillColor(DARK); c.drawString(42*mm,yy,d)
for i,d in enumerate(["\u251c\u2500\u2500 Canl\u0131 Sessiyalar (yaratma/idar\u0259)","\u2514\u2500\u2500 Market (m\u0259hsul yaratma/idar\u0259)"]):
    c.setFont(F,8.5); c.setFillColor(GRN); c.drawString(50*mm,y-6*mm-5*7*mm-i*5.5*mm,d)
y-=54*mm

y=sub("2.2 Trainer Hub \u2014 Yeni Ekran",y)
card(18*mm,y-58*mm,W-36*mm,58*mm)
c.setFont(B,9.5); c.setFillColor(ACCENT); c.drawString(24*mm,y-6*mm,"TrainerHubView")
c.setFont(F,8.5); c.setFillColor(DARK); c.drawString(24*mm,y-12*mm,"Segmented Picker: [Canl\u0131 Sessiyalar] | [Market]")
for i,ln in enumerate(["\u2500\u2500 Canl\u0131 Sessiyalar \u2500\u2500","  \u2022 G\u0259l\u0259c\u0259k sessiyalar\u0131n siyah\u0131s\u0131, + Yeni Sessiya d\u00fcym\u0259si","  \u2022 H\u0259r kart: ba\u015fl\u0131q, tarix, qiym\u0259t, status, i\u015ftirak\u00e7\u0131 say\u0131","  \u2022 Sessiya redakt\u0259 / l\u0259\u011fv etm\u0259","\u2500\u2500 Market \u2500\u2500","  \u2022 Trainer-in \u00f6z m\u0259hsullar\u0131 + Yeni M\u0259hsul d\u00fcym\u0259si","  \u2022 H\u0259r kart: \u015f\u0259kil, ad, qiym\u0259t, tip, status","  \u2022 M\u0259hsul redakt\u0259 / deaktiv etm\u0259"]):
    yy=y-19*mm-i*4.5*mm
    if ln.startswith("\u2500"): c.setFont(B,8.5); c.setFillColor(ACCENT2)
    else: c.setFont(F,8); c.setFillColor(TXT)
    c.drawString(24*mm,yy,ln)
y-=64*mm

y=sub("2.3 T\u0259l\u0259b\u0259 T\u0259r\u0259fi \u2014 D\u0259yi\u015fiklikl\u0259r",y)
y=bul("Market + Canl\u0131 Sessiyalar HomeView-dan \u0259l\u00e7atan (m\u00f6vcud)",20*mm,y); y-=2*mm
y=bul("AI Kalori: \u015f\u0259kil \u00e7\u0259k \u2192 backend ML model qida tan\u0131y\u0131r, kalori hesablay\u0131r",20*mm,y); y-=2*mm
y=bul("AI T\u00f6vsiy\u0259: backend ML alqoritmi f\u0259rdi m\u0259\u015fq/qida t\u00f6vsiy\u0259 verir",20*mm,y)

np()

# =============================================
# PAGE 4 - CANLI SESSiYALAR
# =============================================
y=H-25*mm
y=sec("3. Canl\u0131 Sessiyalar \u2014 Detall\u0131 Ax\u0131n",y)
y=sub("3.1 Trainer: Sessiya Yaratma",y)
card(18*mm,y-50*mm,W-36*mm,50*mm)
for i,s in enumerate(["1. Trainer Hub \u2192 Canl\u0131 Sessiyalar tab \u2192 '+ Yeni Sessiya'","2. Form: ba\u015fl\u0131q, t\u0259svir, tip (group/one_on_one/open)","3. Tarix/saat, m\u00fcdd\u0259t, \u00e7\u0259tinlik, max i\u015ftirak\u00e7\u0131","4. \u00d6d\u0259ni\u015fli/Pulsuz + qiym\u0259t, m\u0259\u015fq plan\u0131","5. POST /api/v1/live-sessions \u2192 sessiya yarad\u0131l\u0131r","6. Tarix g\u0259ldikd\u0259 'Ba\u015flat' \u2192 status: live"]):
    yy=y-6*mm-i*7*mm; c.setFont(B if s[0].isdigit() else F,8.5)
    c.setFillColor(ACCENT if s[0].isdigit() else TXT); c.drawString(24*mm,yy,s)
y-=56*mm

y=sub("3.2 T\u0259l\u0259b\u0259: Sessiyaya Qo\u015fulma",y)
card(18*mm,y-45*mm,W-36*mm,45*mm)
for i,s in enumerate(["1. Home \u2192 Canl\u0131 Sessiyalar \u2192 LiveSessionListView","2. Sessiya se\u00e7 \u2192 detallar: trainer, tarix, qiym\u0259t","3. \u00d6d\u0259ni\u015fli: '\u00d6d\u0259 v\u0259 Qo\u015ful' / Pulsuz: 'Qo\u015ful'","4. POST /api/v1/live-sessions/{id}/register","5. WebSocket ba\u011flant\u0131s\u0131, canl\u0131 m\u0259\u015fq ekran\u0131","6. Bitdikd\u0259: n\u0259tic\u0259 + r\u0259y yazma"]):
    yy=y-6*mm-i*6.5*mm; c.setFont(B if s[0].isdigit() else F,8.5)
    c.setFillColor(BLU if s[0].isdigit() else TXT); c.drawString(24*mm,yy,s)
y-=51*mm

y=sub("3.3 Sessiya Statuslar\u0131",y)
card(18*mm,y-24*mm,W-36*mm,24*mm)
for i,(st,ds,cl) in enumerate([("scheduled","Planla\u015fd\u0131r\u0131l\u0131b",ORG),("live","Canl\u0131 \u2014 davam edir",GRN),("completed","Tamamlan\u0131b",MUT),("cancelled","L\u0259\u011fv edilib",RED)]):
    yy=y-6*mm-i*4.5*mm; c.setFont(B,8); c.setFillColor(cl); c.drawString(24*mm,yy,st)
    c.setFont(F,8); c.setFillColor(TXT); c.drawString(52*mm,yy,f"\u2014 {ds}")

np()

# =============================================
# PAGE 5 - MARKET
# =============================================
y=H-25*mm
y=sec("4. Market \u2014 Detall\u0131 Ax\u0131n",y)
y=sub("4.1 M\u0259hsul Tipl\u0259ri",y)
card(18*mm,y-35*mm,W-36*mm,35*mm)
for i,(cd,nm,ds) in enumerate([("workout_plan","M\u0259\u015fq Plan\u0131","Haz\u0131r m\u0259\u015fq proqramlar\u0131"),("meal_plan","Qida Plan\u0131","P\u0259hriz, qidalanma proqramlar\u0131"),("ebook","E-Kitab","Fitness/sa\u011flaml\u0131q kitablar\u0131"),("consultation","Konsultasiya","1:1 f\u0259rdi m\u0259sl\u0259h\u0259t"),("supplement","\u018elav\u0259 qida (YEN\u0130)","Protein, vitamin, kreatin"),("equipment","Avadanl\u0131q (YEN\u0130)","Fitness avadanl\u0131\u011f\u0131")]):
    yy=y-5*mm-i*4.8*mm; c.setFont(B,7.5); c.setFillColor(ACCENT); c.drawString(24*mm,yy,cd)
    c.setFont(B,7.5); c.setFillColor(DARK); c.drawString(56*mm,yy,nm)
    c.setFont(F,7.5); c.setFillColor(MUT); c.drawString(86*mm,yy,ds)
y-=41*mm

y=sub("4.2 Trainer: M\u0259hsul Yaratma",y)
card(18*mm,y-45*mm,W-36*mm,45*mm)
for i,s in enumerate(["1. Trainer Hub \u2192 Market tab \u2192 '+ Yeni M\u0259hsul'","2. Form: tip, ad, t\u0259svir, qiym\u0259t (AZN/USD/EUR)","3. \u00dcz \u015f\u0259kli \u2014 ImagePicker il\u0259 y\u00fckl\u0259m\u0259","4. POST /api/v1/marketplace/products","5. \u015e\u0259kil: POST /.../{id}/image","6. Redakt\u0259: PUT, Silm\u0259: DELETE"]):
    yy=y-6*mm-i*6*mm; c.setFont(B if s[0].isdigit() else F,8.5)
    c.setFillColor(ACCENT if s[0].isdigit() else TXT); c.drawString(24*mm,yy,s)
y-=51*mm

y=sub("4.3 T\u0259l\u0259b\u0259: M\u0259hsul Al\u0131\u015f",y)
card(18*mm,y-40*mm,W-36*mm,40*mm)
for i,s in enumerate(["1. Home \u2192 Market \u2192 MarketplaceView","2. M\u0259hsul se\u00e7 \u2192 ProductDetailView (detallar, r\u0259yl\u0259r)","3. 'Sat\u0131n Al' \u2192 \u00f6d\u0259ni\u015f ax\u0131n\u0131 (Apple Pay / kart)","4. POST /api/v1/marketplace/products/{id}/purchase","5. T\u0259sdiq ekran\u0131 + m\u0259hsula \u00e7\u0131x\u0131\u015f","6. R\u0259y yazma: POST /.../{id}/reviews"]):
    yy=y-5*mm-i*5.5*mm; c.setFont(B if s[0].isdigit() else F,8.5)
    c.setFillColor(BLU if s[0].isdigit() else TXT); c.drawString(24*mm,yy,s)

np()

# =============================================
# PAGE 6 - AI KALORi ANALiZi (Python ML)
# =============================================
y=H-25*mm
y=sec("5. AI Kalori Analizi \u2014 Python ML Backend",y)

y=sub("5.1 Cari V\u0259ziyy\u0259t v\u0259 Problem",y)
card(18*mm,y-28*mm,W-36*mm,28*mm)
for i,s in enumerate(["M\u00f6vcud: /api/v1/food/analyze \u2014 xarici AI API-y\u0259 g\u00f6nd\u0259rir (Claude Vision)","Problem: h\u0259r sorgu pul x\u0259rcl\u0259yir, xarici API-d\u0259n as\u0131l\u0131d\u0131r, kontrol yoxdur","Problem: t\u0259k qida tan\u0131y\u0131r, porsiya d\u0259qiqliyi a\u015fa\u011f\u0131d\u0131r","H\u018eD\u018eF: Xarici API-ni silm\u0259k, \u00f6z ML modelimizl\u0259 \u0259v\u0259z etm\u0259k"]):
    yy=y-5.5*mm-i*5*mm; c.setFont(F,8.5); c.setFillColor(TXT if i<3 else GRN); c.drawString(24*mm,yy,s)
y-=34*mm

y=sub("5.2 Python ML Texnologiyalar\u0131 (Backend-d\u0259 i\u015fl\u0259y\u0259c\u0259k)",y)
card(18*mm,y-52*mm,W-36*mm,52*mm,fl=LA)
tech_stack=[
    ("TensorFlow / PyTorch","Qida \u015f\u0259kil tan\u0131ma modeli (CNN/ResNet/EfficientNet)"),
    ("YOLOv8","Multi-food detection \u2014 bir \u015f\u0259kild\u0259 bir ne\u00e7\u0259 qida tap\u0131r"),
    ("OpenCV","G\u00f6r\u00fcnt\u00fc i\u015fl\u0259m\u0259, porsiya \u00f6l\u00e7\u00fcs\u00fc t\u0259xmini"),
    ("scikit-learn","Kalori/makro proqnozla\u015fd\u0131rma (regression model)"),
    ("USDA Food DB","101,000+ qida m\u0259lumat bazas\u0131 (offline)"),
    ("Pillow (PIL)","\u015e\u0259kil \u00f6n-i\u015fl\u0259m\u0259, resize, normalizasiya"),
    ("NumPy / Pandas","Data emal\u0131, statistika hesablama"),
    ("ONNX Runtime","Model optimizasiya, s\u00fcr\u0259tli inference"),
]
for i,(lib,desc) in enumerate(tech_stack):
    yy=y-6*mm-i*5.5*mm
    c.setFont(B,8); c.setFillColor(TEAL); c.drawString(24*mm,yy,lib)
    c.setFont(F,7.5); c.setFillColor(TXT); c.drawString(72*mm,yy,desc)
y-=58*mm

y=sub("5.3 AI Kalori Pipeline (\u00d6z Backend-d\u0259)",y)
card(18*mm,y-42*mm,W-36*mm,42*mm)
pipeline_cal=[
    "1. iOS \u015f\u0259kil g\u00f6nd\u0259rir \u2192 POST /api/v1/food/analyze",
    "2. OpenCV: \u015f\u0259kil resize + normalizasiya (224x224)",
    "3. YOLOv8: qida obyektl\u0259rini tap\u0131r (multi-food detection)",
    "4. EfficientNet/ResNet: h\u0259r qidan\u0131 t\u0259snif edir (101+ kateqoriya)",
    "5. USDA DB: qida ad\u0131na g\u00f6r\u0259 kalori/protein/karbohidrat/ya\u011f tap\u0131r",
    "6. Regression model: porsiya \u00f6l\u00e7\u00fcs\u00fcn\u0259 g\u00f6r\u0259 d\u0259qiq kalori hesablay\u0131r",
    "7. JSON cavab iOS-a qaytarılır \u2014 HE\u00c7 B\u0130R XAR\u0130C\u0130 API YOX",
]
for i,s in enumerate(pipeline_cal):
    yy=y-5*mm-i*5*mm; c.setFont(B if s[0].isdigit() else F,8)
    c.setFillColor(ACCENT if s[0].isdigit() else TXT); c.drawString(24*mm,yy,s)
y-=48*mm

y=sub("5.4 Yeni Kalori Funksiyalar\u0131",y)
feats_cal=[
    "\u2713 Multi-food analiz: bir \u015f\u0259kild\u0259 bir ne\u00e7\u0259 qida tan\u0131ma (YOLOv8)",
    "\u2713 Porsiya t\u0259xmini: ki\u00e7ik/orta/b\u00f6y\u00fck + qram bazal\u0131 hesablama",
    "\u2713 Barkod skan: paketl\u0259nmi\u015f m\u0259hsul DB-d\u0259n axtarma",
    "\u2713 Offline qida DB: 101,000+ qida, internet laz\u0131m deyil",
    "\u2713 G\u00fcnl\u00fck makro h\u0259d\u0259f: ML ilə f\u0259rdi h\u0259d\u0259f hesablama",
]
for i,f in enumerate(feats_cal):
    y=bul(f,20*mm,y,sz=8); y-=1*mm

np()

# =============================================
# PAGE 7 - AI TOVSiYE SiSTEMi (Python ML)
# =============================================
y=H-25*mm
y=sec("6. AI T\u00f6vsiy\u0259 Sistemi \u2014 Python ML",y)

y=sub("6.1 Cari V\u0259ziyy\u0259t (Rule-Based)",y)
card(18*mm,y-22*mm,W-36*mm,22*mm)
c.setFont(F,8.5); c.setFillColor(RED)
c.drawString(24*mm,y-6*mm,"Haz\u0131rda: Sad\u0259 if/else m\u0259ntiq \u2014 'm\u0259\u015fq etm\u0259mis\u0259n, ba\u015fla' s\u0259viyy\u0259si")
c.setFillColor(TXT)
c.drawString(24*mm,y-12*mm,"Problem: f\u0259rdi deyil, kontekst ba\u015fa d\u00fc\u015fm\u00fcr, he\u00e7 bir ML istifad\u0259 etmir")
c.drawString(24*mm,y-18*mm,"H\u018eD\u018eF: Python ML il\u0259 real f\u0259rdi t\u00f6vsiy\u0259 sistemi qurmaq")
y-=28*mm

y=sub("6.2 Python ML Texnologiyalar\u0131 (T\u00f6vsiy\u0259 \u00fc\u00e7\u00fcn)",y)
card(18*mm,y-48*mm,W-36*mm,48*mm,fl=LA)
tech_rec=[
    ("scikit-learn","Collaborative Filtering \u2014 ox\u015far istifad\u0259\u00e7il\u0259rin m\u0259\u015fq/qida se\u00e7iml\u0259ri"),
    ("Pandas + NumPy","Data analizi, proqres trend hesablama, anomaliya a\u015fkar\u0131"),
    ("XGBoost / LightGBM","M\u0259\u015fq/qida t\u00f6vsiy\u0259 s\u0131ralamas\u0131 (ranking model)"),
    ("Prophet / statsmodels","Proqres proqnozu \u2014 g\u0259l\u0259c\u0259k \u00e7\u0259ki/kalori trendi"),
    ("TF-IDF + Cosine Sim","M\u0259\u015fq plan ox\u015farl\u0131\u011f\u0131, content-based filtering"),
    ("SQLAlchemy + Redis","Data pipeline, cache, s\u00fcr\u0259tli cavab"),
    ("Celery","Arxa plan ML hesablamalar\u0131 (async task queue)"),
]
for i,(lib,desc) in enumerate(tech_rec):
    yy=y-6*mm-i*5.5*mm
    c.setFont(B,8); c.setFillColor(ACCENT2); c.drawString(24*mm,yy,lib)
    c.setFont(F,7.5); c.setFillColor(TXT); c.drawString(72*mm,yy,desc)
y-=54*mm

y=sub("6.3 ML T\u00f6vsiy\u0259 Alqoritmikalar\u0131",y)
card(18*mm,y-60*mm,W-36*mm,60*mm)
algos=[
    "\u2500\u2500 F\u0259rdi M\u0259\u015fq T\u00f6vsiy\u0259si \u2500\u2500",
    "  \u2022 User-based Collaborative Filtering: ox\u015far profill\u0259rin m\u0259\u015fql\u0259ri",
    "  \u2022 XGBoost ranking: m\u0259\u015fq s\u0259viyy\u0259, h\u0259d\u0259f, ke\u00e7mi\u015f n\u0259tic\u0259y\u0259 g\u00f6r\u0259",
    "  \u2022 Progressive overload alqoritmi: h\u0259ft\u0259lik y\u00fck art\u0131m\u0131",
    "\u2500\u2500 F\u0259rdi Qida T\u00f6vsiy\u0259si \u2500\u2500",
    "  \u2022 Mifflin-St Jeor formulas\u0131 + aktivlik s\u0259viyy\u0259si = g\u00fcnl\u00fck kalori h\u0259d\u0259f",
    "  \u2022 Makro split alqoritmi: h\u0259d\u0259f\u0259 g\u00f6r\u0259 protein/karb/ya\u011f",
    "  \u2022 Content-based filtering: allergiya, diet tipin\u0259 g\u00f6r\u0259 qida se\u00e7imi",
    "\u2500\u2500 Proqres Analizi \u2500\u2500",
    "  \u2022 Prophet/statsmodels: \u00e7\u0259ki trendi proqnozu (2-4 h\u0259ft\u0259 ir\u0259li)",
    "  \u2022 Z-score anomaliya: q\u0259fil \u00e7\u0259ki d\u0259yi\u015fikliyi, kalori anomaliyas\u0131",
    "  \u2022 Streak/motivasiya: ard\u0131c\u0131l m\u0259\u015fq g\u00fcnl\u0259ri + u\u011fur mesajlar\u0131",
]
for i,ln in enumerate(algos):
    yy=y-5*mm-i*4.5*mm
    if ln.startswith("\u2500"): c.setFont(B,8); c.setFillColor(ACCENT2)
    else: c.setFont(F,7.5); c.setFillColor(TXT)
    c.drawString(24*mm,yy,ln)

np()

# =============================================
# PAGE 8 - ML BACKEND ARXiTEKTURASI
# =============================================
y=H-25*mm
y=sec("7. ML Backend Arxitekturas\u0131",y)

y=sub("7.1 ML Pipeline (Qida Tan\u0131ma)",y)
card(18*mm,y-48*mm,W-36*mm,48*mm)
pipe_food=[
    "1. iOS: \u015f\u0259kil \u00e7\u0259kilir \u2192 multipart POST /api/v1/food/analyze",
    "2. FastAPI: \u015f\u0259kil q\u0259bul, Pillow il\u0259 resize (224x224 px)",
    "3. YOLOv8: qida b\u00f6lg\u0259l\u0259rini a\u015fkar edir (bounding boxes)",
    "4. EfficientNet: h\u0259r b\u00f6lg\u0259ni s\u0131n\u0131fland\u0131r\u0131r (qida ad\u0131)",
    "5. USDA Food Database: qida ad\u0131 \u2192 kalori + makrolar",
    "6. Regression: porsiya \u00f6l\u00e7\u00fcs\u00fc t\u0259xmini il\u0259 d\u0259qiql\u0259\u015fdirir",
    "7. JSON cavab: {foods: [{name, calories, protein, carbs, fat, portion}]}",
    "8. N\u0259tic\u0259 DB-d\u0259 saxlan\u0131r (food_entries c\u0259dv\u0259li)",
]
for i,s in enumerate(pipe_food):
    yy=y-5*mm-i*5*mm; c.setFont(B if s[0].isdigit() else F,8)
    c.setFillColor(TEAL if s[0].isdigit() else TXT); c.drawString(24*mm,yy,s)
y-=54*mm

y=sub("7.2 ML Pipeline (T\u00f6vsiy\u0259 Sistemi)",y)
card(18*mm,y-45*mm,W-36*mm,45*mm)
pipe_rec=[
    "1. iOS: GET /api/v1/ai/recommendations (Bearer token)",
    "2. Backend: DB-d\u0259n user context y\u0131\u011f\u0131r (son 30 g\u00fcn data)",
    "   \u2022 M\u0259\u015fq tarix\u00e7\u0259si, qida loqu, \u00e7\u0259ki tarix\u00e7\u0259si, h\u0259d\u0259fl\u0259r",
    "3. scikit-learn: Collaborative Filtering \u2014 ox\u015far userlerin se\u00e7iml\u0259ri",
    "4. XGBoost: m\u0259\u015fq/qida ranking (user profil\u0259 uy\u011funluq skoru)",
    "5. Prophet: proqres trendi + proqnoz hesablama",
    "6. JSON: {recommendations: [{type, title, data, priority}]}",
    "7. Redis cache: eyni user \u00fc\u00e7\u00fcn 6 saatl\u0131q cache",
]
for i,s in enumerate(pipe_rec):
    yy=y-5*mm-i*5*mm; c.setFont(B if s[0].isdigit() else F,8)
    c.setFillColor(ACCENT2 if s[0].isdigit() else TXT); c.drawString(24*mm,yy,s)
y-=51*mm

y=sub("7.3 Model Training (Nec\u0259 \u00f6yr\u0259n\u0259c\u0259k)",y)
card(18*mm,y-30*mm,W-36*mm,30*mm,fl=LA)
training=[
    "\u2022 Qida modeli: Food-101 dataset (101K+ \u015f\u0259kil) + USDA il\u0259 fine-tune",
    "\u2022 T\u00f6vsiy\u0259 modeli: user interaction data il\u0259 h\u0259ft\u0259lik retrain (Celery cron)",
    "\u2022 Proqnoz modeli: h\u0259r userin \u00f6z tarix\u00e7\u0259si il\u0259 Prophet fit",
    "\u2022 A/B test: yeni model vs k\u00f6hn\u0259 model, CTR/conversion m\u00fcqayis\u0259",
    "\u2022 Model versioning: MLflow il\u0259 model saxlama v\u0259 rollback",
]
c.setFont(F,8); c.setFillColor(TXT)
for i,s in enumerate(training):
    c.drawString(24*mm,y-5*mm-i*4.5*mm,s)

np()

# =============================================
# PAGE 9 - TAM API SiYAHISI
# =============================================
y=H-25*mm
y=sec("8. Tam API Endpoint Siyas\u0131s\u0131",y)

y=sub("8.1 Canl\u0131 Sessiyalar (M\u00f6vcud + Yeni)",y)
card(18*mm,y-50*mm,W-36*mm,50*mm)
all_session_api=[
    ("GET","/api/v1/live-sessions","Sessiya siyah\u0131s\u0131",GRN),
    ("POST","/api/v1/live-sessions","Yeni sessiya yarat",ORG),
    ("GET","/api/v1/live-sessions/{id}","Sessiya detallar\u0131",GRN),
    ("PUT","/api/v1/live-sessions/{id}","Redakt\u0259 et (YEN\u0130)",ORG),
    ("DELETE","/api/v1/live-sessions/{id}","L\u0259\u011fv et (YEN\u0130)",RED),
    ("POST","/api/v1/live-sessions/{id}/register","Qo\u015ful",ORG),
    ("POST","/api/v1/live-sessions/{id}/start","Ba\u015flat (YEN\u0130)",ORG),
    ("GET","/api/v1/live-sessions/my","Trainer \u00f6z sessiyalar\u0131 (YEN\u0130)",GRN),
    ("GET","/api/v1/live-sessions/{id}/participants","\u0130\u015ftirak\u00e7\u0131lar",GRN),
    ("GET","/api/v1/live-sessions/{id}/stats","Statistika",GRN),
]
for i,(m,p,d,cl) in enumerate(all_session_api):
    yy=y-5*mm-i*4.3*mm; c.setFont(B,6.8); c.setFillColor(cl); c.drawString(24*mm,yy,m)
    c.setFont(F,6.8); c.setFillColor(DARK); c.drawString(40*mm,yy,p); c.setFillColor(MUT); c.drawString(120*mm,yy,d)
y-=56*mm

y=sub("8.2 Market (M\u00f6vcud + Yeni)",y)
card(18*mm,y-42*mm,W-36*mm,42*mm)
all_market_api=[
    ("GET","/api/v1/marketplace/products","M\u0259hsul siyah\u0131s\u0131",GRN),
    ("POST","/api/v1/marketplace/products","Yeni m\u0259hsul yarat",ORG),
    ("GET","/api/v1/marketplace/products/{id}","Detallar",GRN),
    ("PUT","/api/v1/marketplace/products/{id}","Redakt\u0259 (YEN\u0130)",ORG),
    ("DELETE","/api/v1/marketplace/products/{id}","Sil (YEN\u0130)",RED),
    ("GET","/api/v1/marketplace/products/my","Trainer \u00f6z m\u0259hsullar\u0131 (YEN\u0130)",GRN),
    ("POST","/api/v1/marketplace/products/{id}/purchase","Al\u0131\u015f",ORG),
    ("POST","/api/v1/marketplace/products/{id}/reviews","R\u0259y yaz",ORG),
    ("POST","/api/v1/marketplace/products/{id}/image","\u015e\u0259kil y\u00fckl\u0259",ORG),
]
for i,(m,p,d,cl) in enumerate(all_market_api):
    yy=y-5*mm-i*4*mm; c.setFont(B,6.8); c.setFillColor(cl); c.drawString(24*mm,yy,m)
    c.setFont(F,6.8); c.setFillColor(DARK); c.drawString(40*mm,yy,p); c.setFillColor(MUT); c.drawString(120*mm,yy,d)
y-=48*mm

y=sub("8.3 AI ML Endpoint-l\u0259ri (HAMISI LOKAL ML)",y)
card(18*mm,y-48*mm,W-36*mm,48*mm,fl=HexColor("#F0FDF4"))
all_ai_api=[
    ("POST","/api/v1/food/analyze","Qida \u015f\u0259kli \u2192 ML model (m\u00f6vcud, ML-\u0259 ke\u00e7)",GRN),
    ("POST","/api/v1/food/analyze-multi","Multi-food YOLOv8 detection (YEN\u0130)",ORG),
    ("POST","/api/v1/food/barcode","Barkod \u2192 USDA DB axtarma (YEN\u0130)",ORG),
    ("GET","/api/v1/food/nutrition-report","Pandas h\u0259ft\u0259lik hesabat (YEN\u0130)",ORG),
    ("GET","/api/v1/ai/recommendations","ML f\u0259rdi t\u00f6vsiy\u0259l\u0259r (YEN\u0130)",ORG),
    ("GET","/api/v1/ai/progress-analysis","Prophet proqres proqnozu (YEN\u0130)",ORG),
    ("GET","/api/v1/ai/daily-plan","ML g\u00fcnl\u00fck m\u0259\u015fq+qida (YEN\u0130)",ORG),
    ("POST","/api/v1/ai/generate-plan","ML tam plan generasiya (YEN\u0130)",ORG),
    ("GET","/api/v1/ai/anomalies","Z-score anomaliya a\u015fkar\u0131 (YEN\u0130)",ORG),
    ("GET","/api/v1/ai/motivation","Streak + u\u011fur mesajlar\u0131 (YEN\u0130)",ORG),
]
for i,(m,p,d,cl) in enumerate(all_ai_api):
    yy=y-5*mm-i*4*mm; c.setFont(B,6.8); c.setFillColor(cl); c.drawString(24*mm,yy,m)
    c.setFont(F,6.8); c.setFillColor(DARK); c.drawString(40*mm,yy,p); c.setFillColor(MUT); c.drawString(118*mm,yy,d)

np()

# =============================================
# PAGE 10 - FAYL PLANI
# =============================================
y=H-25*mm
y=sec("9. Fayl D\u0259yi\u015fiklikl\u0259ri Plan\u0131",y)

y=sub("9.1 Backend Python Fayllar\u0131 (YEN\u0130)",y)
card(18*mm,y-50*mm,W-36*mm,50*mm,fl=HexColor("#F0FDF4"))
be_files=[
    "ml/food_detector.py \u2014 YOLOv8 qida detection servisi",
    "ml/food_classifier.py \u2014 EfficientNet qida s\u0131n\u0131fland\u0131rma",
    "ml/calorie_estimator.py \u2014 USDA DB + porsiya regression",
    "ml/recommendation_engine.py \u2014 Collaborative Filtering + XGBoost",
    "ml/progress_analyzer.py \u2014 Prophet + Z-score proqres analizi",
    "ml/daily_planner.py \u2014 G\u00fcnl\u00fck m\u0259\u015fq/qida plan generasiya",
    "ml/models/ \u2014 \u00d6yr\u0259dilmi\u015f model fayllar\u0131 (.onnx, .pkl)",
    "ml/data/usda_foods.db \u2014 USDA qida m\u0259lumat bazas\u0131 (SQLite)",
    "ml/training/ \u2014 Model training scriptl\u0259ri (offline)",
    "requirements-ml.txt \u2014 ML kitabxanalar\u0131 (torch, sklearn, yolo...)",
]
c.setFont(F,7.5); c.setFillColor(GRN)
for i,f in enumerate(be_files):
    c.drawString(24*mm,y-5*mm-i*4.5*mm,f)
y-=56*mm

y=sub("9.2 iOS Yeni Fayllar",y)
card(18*mm,y-36*mm,W-36*mm,36*mm,fl=LA)
new_files=[
    "TrainerHubView.swift \u2014 Hub ekran\u0131 (Sessiyalar | Market)",
    "CreateProductView.swift \u2014 M\u0259hsul yaratma formu",
    "TrainerProductsViewModel.swift \u2014 Trainer m\u0259hsul idar\u0259si",
    "TrainerSessionsViewModel.swift \u2014 Trainer sessiya idar\u0259si",
    "AIRecommendationService.swift \u2014 ML t\u00f6vsiy\u0259 n\u0259tic\u0259l\u0259ri g\u00f6st\u0259rm\u0259",
    "AIRecommendationModels.swift \u2014 ML cavab modell\u0259ri",
    "BarcodeScannerView.swift \u2014 Barkod skan ekran\u0131 (YEN\u0130)",
]
c.setFont(F,8); c.setFillColor(GRN)
for i,f in enumerate(new_files):
    c.drawString(24*mm,y-5*mm-i*4.3*mm,f)
y-=42*mm

y=sub("9.3 D\u0259yi\u015fdril\u0259c\u0259k Fayllar",y)
card(18*mm,y-40*mm,W-36*mm,40*mm)
mod_files=[
    "CustomTabBar.swift \u2014 'M\u0259zmun' \u2192 'Trainer Hub' d\u0259yi\u015fikliyi",
    "ContentView.swift \u2014 Navigation yenil\u0259m\u0259",
    "HomeView.swift \u2014 ML t\u00f6vsiy\u0259 b\u00f6lm\u0259si g\u00f6st\u0259rm\u0259",
    "MarketplaceView.swift \u2014 Yeni m\u0259hsul tipl\u0259ri",
    "AddFoodView.swift \u2014 Multi-food + barkod skan",
    "FoodManager.swift \u2014 Yeni ML endpoint-l\u0259ri inteqrasiya",
    "EatingView.swift \u2014 ML qida t\u00f6vsiy\u0259l\u0259ri b\u00f6lm\u0259si",
    "TrainerContentView.swift \u2014 S\u0130L\u0130N\u018eC\u018eK (hub il\u0259 \u0259v\u0259z)",
]
c.setFont(F,8); c.setFillColor(ORG)
for i,f in enumerate(mod_files):
    c.drawString(24*mm,y-5*mm-i*4.3*mm,f)

np()

# =============================================
# PAGE 11 - iCRA PLANI
# =============================================
y=H-25*mm
y=sec("10. \u0130cra Plan\u0131 v\u0259 Prioritetl\u0259r",y)
y=sub("10.1 Fazalar",y)

phases=[
    ("Faza 1: Trainer Hub","3-4 g\u00fcn",ACCENT,["TrainerContentView silinir","TrainerHubView yarad\u0131l\u0131r","Segmented Picker: Sessiyalar | Market","CustomTabBar yenil\u0259nir"]),
    ("Faza 2: Market CRUD","3-4 g\u00fcn",GRN,["CreateProductView yarad\u0131l\u0131r","ImagePicker inteqrasiyas\u0131","M\u0259hsul siyah\u0131s\u0131, redakt\u0259/silm\u0259","Yeni m\u0259hsul tipl\u0259ri"]),
    ("Faza 3: \u00d6d\u0259ni\u015f Ax\u0131n\u0131","2-3 g\u00fcn",BLU,["M\u0259hsul al\u0131\u015f \u00f6d\u0259ni\u015f","Sessiya \u00f6d\u0259ni\u015f ax\u0131n\u0131","T\u0259sdiq ekran\u0131","X\u0259ta idar\u0259etm\u0259si"]),
    ("Faza 4: ML Kalori","5-6 g\u00fcn",TEAL,["YOLOv8 + EfficientNet setup","USDA DB inteqrasiya","Multi-food + barkod","Model training + deploy"]),
    ("Faza 5: ML T\u00f6vsiy\u0259","5-7 g\u00fcn",ACCENT2,["Collaborative Filtering","XGBoost ranking model","Prophet proqres proqnozu","G\u00fcnl\u00fck plan generator"]),
    ("Faza 6: Test & Cila","2-3 g\u00fcn",ORG,["End-to-end testl\u0259r","ML model accuracy test","UI/UX cila\u015fd\u0131rma","Performance optimizasiya"]),
]
cw=(W-42*mm)/2
for idx,(title,dur,color,items) in enumerate(phases):
    col=idx%2; row=idx//2
    cx=18*mm+col*(cw+6*mm); cy=y-row*36*mm
    card(cx,cy-30*mm,cw,30*mm)
    c.setFont(B,8.5); c.setFillColor(color); c.drawString(cx+5*mm,cy-6*mm,f"{title} ({dur})")
    c.setFont(F,7.5); c.setFillColor(TXT)
    for j,it in enumerate(items):
        c.drawString(cx+5*mm,cy-12*mm-j*4.2*mm,f"\u2713 {it}")

y-=3*36*mm+6*mm

card(18*mm,y-16*mm,W-36*mm,16*mm,fl=ACCENT)
c.setFillColor(WHT); c.setFont(B,13)
c.drawCentredString(W/2,y-11*mm,"T\u0259xmini \u00fcmumi m\u00fcdd\u0259t: 20-27 i\u015f g\u00fcn\u00fc")

np()

# =============================================
# PAGE 12 - USER FLOW
# =============================================
y=H-25*mm
y=sec("11. User Flow Diaqramlar\u0131",y)

y=sub("11.1 Trainer \u2192 Canl\u0131 Sessiya Yaratma",y)
y=flow_boxes(["Trainer Hub","Sessiyalar Tab","+ Yeni Sessiya","Form Doldur","POST API","Siyah\u0131da g\u00f6r\u00fcn\u00fcr"],y,3,ACCENT,GRN)

y=sub("11.2 T\u0259l\u0259b\u0259 \u2192 Sessiyaya Qo\u015fulma",y)
y=flow_boxes(["Home Ekran","Canl\u0131 Sessiyalar","Sessiya Se\u00e7","\u00d6d\u0259ni\u015f","Qo\u015ful","Canl\u0131 M\u0259\u015fq"],y,3,BLU,GRN)

y=sub("11.3 Trainer \u2192 M\u0259hsul Yaratma",y)
y=flow_boxes(["Trainer Hub","Market Tab","+ Yeni M\u0259hsul","Form + \u015e\u0259kil","POST API","Marketd\u0259 g\u00f6r\u00fcn\u00fcr"],y,3,ACCENT2,GRN)

y=sub("11.4 T\u0259l\u0259b\u0259 \u2192 M\u0259hsul Al\u0131\u015f",y)
y=flow_boxes(["Home Ekran","Market","M\u0259hsul Se\u00e7","Detallar","\u00d6d\u0259 & Al","Sifari\u015f T\u0259sdiqi"],y,4,BLU,GRN)

y=sub("11.5 AI Kalori Analiz Flow (ML)",y)
y=flow_boxes(["\u015e\u0259kil \u00c7\u0259k","POST /analyze","YOLOv8 Detect","ML Classify","Kalori Calc","Qida Loqu"],y,3,TEAL,GRN)

np()

# =============================================
# PAGE 13 - RiSKLER + XULASE
# =============================================
y=H-25*mm
y=sec("12. Riskl\u0259r, As\u0131l\u0131l\u0131qlar v\u0259 X\u00fclas\u0259",y)

y=sub("12.1 Riskl\u0259r",y)
y=bul("ML model accuracy: qida tan\u0131ma d\u0259qiqliyi ilkin m\u0259rh\u0259l\u0259d\u0259 ~85%, fine-tune il\u0259 95%+",20*mm,y); y-=2*mm
y=bul("Server resurslar\u0131: ML inference \u00fc\u00e7\u00fcn GPU/CPU g\u00fccl\u00fc server laz\u0131md\u0131r",20*mm,y); y-=2*mm
y=bul("Model \u00f6l\u00e7\u00fcs\u00fc: YOLOv8 + EfficientNet ~200-400 MB disk",20*mm,y); y-=2*mm
y=bul("Training data: ilkin m\u0259rh\u0259l\u0259d\u0259 Food-101, sonra \u00f6z data il\u0259 geni\u015fl\u0259nm\u0259",20*mm,y); y-=2*mm
y=bul("Apple In-App Purchase: App Store review vaxt\u0131 2-5 g\u00fcn",20*mm,y); y-=6*mm

y=sub("12.2 \u00dcst\u00fcnl\u00fckl\u0259r (Xarici API-y\u0259 n\u0259z\u0259r\u0259n)",y)
card(18*mm,y-32*mm,W-36*mm,32*mm,fl=HexColor("#F0FDF4"))
advs=[
    "\u2713 X\u0259rc yoxdur: h\u0259r sorgu \u00fc\u00e7\u00fcn API pulu \u00f6d\u0259nm\u0259z",
    "\u2713 Tam kontrol: model d\u0259qiqliyini \u00f6z\u00fcm\u00fcz art\u0131r\u0131r\u0131q",
    "\u2713 S\u00fcr\u0259t: lokal ML inference ~50-200ms (API 1-3s)",
    "\u2713 M\u0259xfilik: istifad\u0259\u00e7i datas\u0131 xarici servislr\u0259 g\u00f6nd\u0259rilmir",
    "\u2713 Offline potensial: g\u0259l\u0259c\u0259kd\u0259 on-device ML (CoreML)",
    "\u2713 As\u0131l\u0131l\u0131q yoxdur: xarici API down olsa bel\u0259 i\u015fl\u0259y\u0259c\u0259k",
]
c.setFont(F,8); c.setFillColor(GRN)
for i,s in enumerate(advs):
    c.drawString(24*mm,y-5*mm-i*4.3*mm,s)
y-=38*mm

y=sub("12.3 X\u00fclas\u0259",y)
card(18*mm,y-60*mm,W-36*mm,60*mm,fl=LA)
summary=[
    ("Trainer Hub","M\u0259zmun \u2192 Hub, Sessiya + Market idar\u0259si","3-4 g\u00fcn"),
    ("Market CRUD","Trainer m\u0259hsul yaratma/redakt\u0259/silm\u0259","3-4 g\u00fcn"),
    ("\u00d6d\u0259ni\u015f","M\u0259hsul + sessiya \u00f6d\u0259ni\u015f ax\u0131nlar\u0131","2-3 g\u00fcn"),
    ("ML Kalori","YOLOv8 + EfficientNet + USDA \u2014 lokal ML","5-6 g\u00fcn"),
    ("ML T\u00f6vsiy\u0259","sklearn + XGBoost + Prophet \u2014 lokal ML","5-7 g\u00fcn"),
    ("Test & Cila","ML accuracy, E2E test, UI/UX","2-3 g\u00fcn"),
]
c.setFont(B,8); c.setFillColor(ACCENT)
c.drawString(24*mm,y-6*mm,"Modul"); c.drawString(60*mm,y-6*mm,"T\u0259svir"); c.drawString(148*mm,y-6*mm,"M\u00fcdd\u0259t")
c.setStrokeColor(ACCENT); c.setLineWidth(0.5); c.line(24*mm,y-8*mm,W-24*mm,y-8*mm)
for i,(mod,desc,dur) in enumerate(summary):
    yy=y-14*mm-i*7.5*mm
    c.setFont(B,8); c.setFillColor(DARK); c.drawString(24*mm,yy,mod)
    c.setFont(F,7.5); c.setFillColor(TXT); c.drawString(60*mm,yy,desc)
    c.setFont(B,8); c.setFillColor(GRN); c.drawString(148*mm,yy,dur)

c.setFont(B,10); c.setFillColor(ACCENT)
c.drawString(24*mm,y-60*mm+6*mm,"\u00dcmumi: 20-27 i\u015f g\u00fcn\u00fc | HE\u00c7 XAR\u0130C\u0130 AI API YOX!")

# =============================================
# MOCKUP HELPERS — CoreVia Design System
# =============================================

# CoreVia colors
CV_RED = HexColor("#FF3B30")
CV_DKRED = HexColor("#B30000")
CV_BG = HexColor("#F5F5F5")     # light mode bg
CV_CARD = HexColor("#FFFFFF")
CV_DARK_BG = HexColor("#1C1C1E") # dark mode bg
CV_DARK_CARD = HexColor("#2C2C2E")
CV_TXT1 = HexColor("#1A1A1A")
CV_TXT2 = HexColor("#8E8E93")
CV_GREEN = HexColor("#32C823")
CV_BLUE = HexColor("#007AFF")
CV_ORANGE = HexColor("#FF9500")
CV_PURPLE = HexColor("#AF52DE")
CV_TAB_BG = HexColor("#F2F2F7")
CV_SEP = HexColor("#E5E5EA")
CV_SHADOW = HexColor("#00000010")

PH_W = 62*mm   # phone width
PH_H = 128*mm  # phone height
PH_R = 6*mm    # phone corner radius

def phone_frame(x, y, dark=False):
    """Draw an iPhone frame at (x,y) = bottom-left of frame"""
    # Phone body
    c.setFillColor(HexColor("#1A1A1A"))
    c.setStrokeColor(HexColor("#333333")); c.setLineWidth(1.5)
    c.roundRect(x, y, PH_W, PH_H, PH_R, fill=1, stroke=1)
    # Screen area (inset 2mm)
    sc_x = x + 2*mm; sc_y = y + 2*mm
    sc_w = PH_W - 4*mm; sc_h = PH_H - 4*mm
    bg_col = CV_DARK_BG if dark else CV_BG
    c.setFillColor(bg_col); c.setStrokeColor(bg_col)
    c.roundRect(sc_x, sc_y, sc_w, sc_h, 4.5*mm, fill=1, stroke=0)
    # Notch / Dynamic island
    notch_w = 16*mm; notch_h = 3.2*mm
    notch_x = x + (PH_W - notch_w)/2
    notch_y = y + PH_H - 2*mm - notch_h - 1*mm
    c.setFillColor(HexColor("#1A1A1A"))
    c.roundRect(notch_x, notch_y, notch_w, notch_h, 1.6*mm, fill=1, stroke=0)
    # Home indicator
    hi_w = 18*mm; hi_h = 0.8*mm
    c.setFillColor(HexColor("#666666") if dark else HexColor("#CCCCCC"))
    c.roundRect(x+(PH_W-hi_w)/2, y+3.5*mm, hi_w, hi_h, 0.4*mm, fill=1, stroke=0)
    return sc_x, sc_y, sc_w, sc_h

def phone_status_bar(sx, sy, sw, sh, dark=False):
    """Status bar at top of screen"""
    bar_y = sy + sh - 7*mm
    col = WHT if dark else CV_TXT1
    c.setFont(B, 5.5); c.setFillColor(col)
    c.drawString(sx + 4*mm, bar_y, "9:41")
    c.drawRightString(sx + sw - 4*mm, bar_y, "100%")
    # Battery icon
    bx = sx + sw - 12*mm
    c.setStrokeColor(col); c.setLineWidth(0.4)
    c.rect(bx, bar_y - 0.5, 5*mm, 2.5*mm, fill=0, stroke=1)
    c.setFillColor(CV_GREEN)
    c.rect(bx+0.3, bar_y-0.2, 4.4*mm, 1.9*mm, fill=1, stroke=0)
    return bar_y - 2*mm

def phone_tab_bar(sx, sy, sw, dark=False, active=0, tabs=None):
    """Bottom tab bar - glassmorphism style"""
    if tabs is None:
        tabs = [("house.fill","Home"),("figure","Plans"),("fork","Food"),("chat","Chat"),("more","More")]
    tb_h = 10*mm
    tb_y = sy + 5*mm
    # Glass bg
    c.setFillColor(HexColor("#F8F8F8E0") if not dark else HexColor("#2C2C2EE0"))
    c.setStrokeColor(CV_SEP if not dark else HexColor("#3A3A3C")); c.setLineWidth(0.3)
    c.roundRect(sx+1*mm, tb_y, sw-2*mm, tb_h, 3*mm, fill=1, stroke=1)
    # Tab items
    tab_w = (sw - 4*mm) / len(tabs)
    for i, (icon, label) in enumerate(tabs):
        tx = sx + 2*mm + i * tab_w + tab_w/2
        if i == active:
            # Active: red circle + white icon
            c.setFillColor(CV_RED)
            c.circle(tx, tb_y + 6*mm, 3.2*mm, fill=1, stroke=0)
            c.setFillColor(WHT); c.setFont(B, 3.8)
            c.drawCentredString(tx, tb_y + 5.2*mm, icon[0:2].upper())
            c.setFillColor(CV_RED); c.setFont(B, 3.5)
            c.drawCentredString(tx, tb_y + 1.2*mm, label)
        else:
            c.setFillColor(CV_TXT2); c.setFont(F, 3.8)
            c.drawCentredString(tx, tb_y + 5.2*mm, icon[0:2].upper())
            c.setFont(F, 3.5)
            c.drawCentredString(tx, tb_y + 1.2*mm, label)
    return tb_y + tb_h

def phone_nav_bar(sx, sy, sw, top_y, title, dark=False, back=False, right_icon=None):
    """Navigation bar"""
    nb_y = top_y - 5*mm
    col = WHT if dark else CV_TXT1
    c.setFont(B, 7); c.setFillColor(col)
    if back:
        c.setFillColor(CV_RED); c.setFont(F, 7)
        c.drawString(sx + 3*mm, nb_y, "\u2039")
        c.setFont(B, 7); c.setFillColor(col)
        c.drawCentredString(sx + sw/2, nb_y, title)
    else:
        c.drawString(sx + 4*mm, nb_y, title)
    if right_icon:
        c.setFillColor(CV_RED); c.setFont(B, 6)
        c.drawRightString(sx + sw - 4*mm, nb_y, right_icon)
    return nb_y - 4*mm

def phone_card(sx, sy, sw, cx, cy, cw, ch, dark=False, accent=False):
    """Card inside phone"""
    fill = CV_RED if accent else (CV_DARK_CARD if dark else CV_CARD)
    c.setFillColor(fill)
    c.setStrokeColor(HexColor("#3A3A3C") if dark else CV_SEP); c.setLineWidth(0.3)
    c.roundRect(cx, cy, cw, ch, 2.5*mm, fill=1, stroke=0 if accent else 1)
    # Shadow line
    if not dark and not accent:
        c.setFillColor(HexColor("#00000008"))
        c.roundRect(cx+0.2, cy-0.3, cw, ch, 2.5*mm, fill=1, stroke=0)
        c.setFillColor(fill)
        c.roundRect(cx, cy, cw, ch, 2.5*mm, fill=1, stroke=0)

def phone_segmented(sx, top_y, sw, segments, active_idx=0, dark=False):
    """Segmented control"""
    seg_h = 4.5*mm
    seg_y = top_y - seg_h
    seg_x = sx + 3*mm; seg_w = sw - 6*mm
    # Background
    c.setFillColor(HexColor("#3A3A3C") if dark else HexColor("#E5E5EA"))
    c.roundRect(seg_x, seg_y, seg_w, seg_h, 2*mm, fill=1, stroke=0)
    # Segments
    item_w = seg_w / len(segments)
    for i, label in enumerate(segments):
        ix = seg_x + i * item_w
        if i == active_idx:
            c.setFillColor(CV_CARD if not dark else HexColor("#636366"))
            c.roundRect(ix + 0.5, seg_y + 0.5, item_w - 1, seg_h - 1, 1.8*mm, fill=1, stroke=0)
            c.setFillColor(CV_TXT1 if not dark else WHT); c.setFont(B, 4)
        else:
            c.setFillColor(CV_TXT2); c.setFont(F, 4)
        c.drawCentredString(ix + item_w/2, seg_y + 1.5*mm, label)
    return seg_y - 2*mm

def phone_btn(cx, cy, cw, ch, label, primary=True):
    """Button"""
    if primary:
        c.setFillColor(CV_RED)
        c.roundRect(cx, cy, cw, ch, 2*mm, fill=1, stroke=0)
        c.setFillColor(WHT); c.setFont(B, 4.5)
    else:
        c.setStrokeColor(CV_RED); c.setLineWidth(0.5)
        c.setFillColor(WHT)
        c.roundRect(cx, cy, cw, ch, 2*mm, fill=1, stroke=1)
        c.setFillColor(CV_RED); c.setFont(B, 4.5)
    c.drawCentredString(cx + cw/2, cy + ch/2 - 1.5, label)

def phone_input(cx, cy, cw, ch, label, value="", icon="", dark=False):
    """Input field"""
    bg = CV_DARK_CARD if dark else HexColor("#F2F2F7")
    c.setFillColor(bg); c.setStrokeColor(CV_SEP); c.setLineWidth(0.3)
    c.roundRect(cx, cy, cw, ch, 2*mm, fill=1, stroke=1)
    c.setFillColor(CV_TXT2); c.setFont(F, 3.8)
    if icon:
        c.drawString(cx + 1.5*mm, cy + ch/2 - 1.2, icon)
        c.drawString(cx + 5*mm, cy + ch/2 - 1.2, value if value else label)
    else:
        c.drawString(cx + 2*mm, cy + ch/2 - 1.2, value if value else label)
    if value:
        c.setFillColor(CV_TXT1 if not dark else WHT); c.setFont(F, 3.8)
        if icon:
            c.drawString(cx + 5*mm, cy + ch/2 - 1.2, value)
        else:
            c.drawString(cx + 2*mm, cy + ch/2 - 1.2, value)

def phone_session_card(cx, cy, cw, dark=False, title="HIIT Workout", trainer="Ali M.", status="scheduled", price="15 AZN", date="28 Fev, 18:00", count="12/20"):
    """Session card inside phone"""
    ch = 14*mm
    fill = CV_DARK_CARD if dark else CV_CARD
    c.setFillColor(fill); c.setStrokeColor(CV_SEP if not dark else HexColor("#3A3A3C")); c.setLineWidth(0.3)
    c.roundRect(cx, cy, cw, ch, 2.5*mm, fill=1, stroke=1)
    # Status badge
    st_col = {
        "scheduled": CV_BLUE,
        "live": CV_RED,
        "completed": CV_TXT2
    }.get(status, CV_ORANGE)
    c.setFillColor(st_col)
    c.roundRect(cx + 2*mm, cy + ch - 4.5*mm, 10*mm, 2.8*mm, 1.2*mm, fill=1, stroke=0)
    c.setFillColor(WHT); c.setFont(B, 3)
    c.drawString(cx + 3*mm, cy + ch - 3.6*mm, status.upper())
    # Title
    c.setFillColor(CV_TXT1 if not dark else WHT); c.setFont(B, 5)
    c.drawString(cx + 2*mm, cy + ch - 7.5*mm, title)
    # Trainer + date
    c.setFillColor(CV_TXT2); c.setFont(F, 3.5)
    c.drawString(cx + 2*mm, cy + ch - 10.5*mm, f"\ud83d\udc64 {trainer}  \u2022  \ud83d\udcc5 {date}")
    # Price + participants
    c.setFillColor(CV_RED); c.setFont(B, 4)
    c.drawRightString(cx + cw - 2*mm, cy + ch - 7.5*mm, price)
    c.setFillColor(CV_TXT2); c.setFont(F, 3.5)
    c.drawRightString(cx + cw - 2*mm, cy + ch - 10.5*mm, f"\ud83d\udc65 {count}")
    return cy - 1*mm

def phone_product_card(cx, cy, cw, dark=False, title="Full Body Plan", typ="M\u0259\u015fq Plan", price="25 AZN", rating="4.8", seller="Aysel T."):
    """Product card inside phone"""
    ch = 12*mm
    fill = CV_DARK_CARD if dark else CV_CARD
    c.setFillColor(fill); c.setStrokeColor(CV_SEP if not dark else HexColor("#3A3A3C")); c.setLineWidth(0.3)
    c.roundRect(cx, cy, cw, ch, 2.5*mm, fill=1, stroke=1)
    # Image placeholder
    c.setFillColor(HexColor("#E8E8E8") if not dark else HexColor("#3A3A3C"))
    c.roundRect(cx + 1.5*mm, cy + 1.5*mm, 9*mm, ch - 3*mm, 1.5*mm, fill=1, stroke=0)
    c.setFillColor(CV_TXT2); c.setFont(F, 5)
    c.drawCentredString(cx + 6*mm, cy + ch/2 - 1.5, "\ud83d\udcf7")
    # Type badge
    c.setFillColor(CV_RED)
    c.roundRect(cx + 12*mm, cy + ch - 4*mm, 10*mm, 2.5*mm, 1*mm, fill=1, stroke=0)
    c.setFillColor(WHT); c.setFont(B, 2.8)
    c.drawString(cx + 12.5*mm, cy + ch - 3.3*mm, typ)
    # Title + seller
    c.setFillColor(CV_TXT1 if not dark else WHT); c.setFont(B, 4.5)
    c.drawString(cx + 12*mm, cy + ch - 7*mm, title)
    c.setFillColor(CV_TXT2); c.setFont(F, 3.2)
    c.drawString(cx + 12*mm, cy + ch - 9.5*mm, f"\ud83d\udc64 {seller}  \u2b50 {rating}")
    # Price
    c.setFillColor(CV_RED); c.setFont(B, 4.5)
    c.drawRightString(cx + cw - 2*mm, cy + ch - 7*mm, price)
    return cy - 1*mm


# =============================================
# PAGE 14 — UI MOCKUP: TRAINER HUB
# =============================================
np()
y = H - 25*mm
y = sec("13. UI Dizayn N\u00fcmun\u0259l\u0259ri \u2014 Trainer Hub", y)

# ---- PHONE 1: Trainer Hub - Canli Sessiyalar ----
px1 = 15*mm; py1 = y - PH_H - 5*mm
sx, sy, sw, sh = phone_frame(px1, py1)
top = phone_status_bar(sx, sy, sw, sh)
top = phone_nav_bar(sx, sy, sw, top, "Trainer Hub", right_icon="+")
top = phone_segmented(sx, top, sw, ["Canl\u0131 Sessiyalar", "Market"], 0)
# Session cards
cw = sw - 6*mm; cx = sx + 3*mm
phone_session_card(cx, top - 16*mm, cw, title="HIIT M\u0259\u015fq\u0131", trainer="Vusal D.", status="scheduled", price="20 AZN", date="3 Mar, 18:00", count="8/15")
phone_session_card(cx, top - 32*mm, cw, title="Yoga S\u0259h\u0259r", trainer="Vusal D.", status="live", price="Pulsuz", date="Indi canl\u0131", count="14/20")
phone_session_card(cx, top - 48*mm, cw, title="Funksional Trening", trainer="Vusal D.", status="completed", price="15 AZN", date="1 Mar", count="12/12")
# FAB
fab_x = sx + sw - 10*mm; fab_y = sy + 16*mm
c.setFillColor(CV_RED)
c.circle(fab_x, fab_y, 4*mm, fill=1, stroke=0)
c.setFillColor(WHT); c.setFont(B, 8)
c.drawCentredString(fab_x, fab_y - 2.5, "+")
phone_tab_bar(sx, sy, sw, active=4)

# Label
c.setFillColor(ACCENT); c.setFont(B, 8)
c.drawCentredString(px1 + PH_W/2, py1 - 3*mm, "Trainer Hub \u2014 Sessiyalar")

# ---- PHONE 2: Trainer Hub - Market ----
px2 = px1 + PH_W + 12*mm; py2 = py1
sx, sy, sw, sh = phone_frame(px2, py2)
top = phone_status_bar(sx, sy, sw, sh)
top = phone_nav_bar(sx, sy, sw, top, "Trainer Hub", right_icon="+")
top = phone_segmented(sx, top, sw, ["Canl\u0131 Sessiyalar", "Market"], 1)
cw = sw - 6*mm; cx = sx + 3*mm
phone_product_card(cx, top - 14*mm, cw, title="Full Body Plan", typ="M\u0259\u015fq", price="25 AZN", rating="4.8")
phone_product_card(cx, top - 28*mm, cw, title="Prot. P\u0259hriz", typ="Qida", price="18 AZN", rating="4.6", seller="Vusal D.")
phone_product_card(cx, top - 42*mm, cw, title="Ev M\u0259\u015fqi E-book", typ="E-Kitab", price="10 AZN", rating="4.9", seller="Vusal D.")
fab_x = sx + sw - 10*mm; fab_y = sy + 16*mm
c.setFillColor(CV_RED); c.circle(fab_x, fab_y, 4*mm, fill=1, stroke=0)
c.setFillColor(WHT); c.setFont(B, 8); c.drawCentredString(fab_x, fab_y - 2.5, "+")
phone_tab_bar(sx, sy, sw, active=4)
c.setFillColor(ACCENT); c.setFont(B, 8)
c.drawCentredString(px2 + PH_W/2, py2 - 3*mm, "Trainer Hub \u2014 Market")

# Description
desc_x = px2 + PH_W + 8*mm
c.setFillColor(DARK); c.setFont(B, 9)
c.drawString(desc_x, y - 12*mm, "Trainer Hub Ekran\u0131")
c.setFont(F, 7.5); c.setFillColor(TXT)
notes_hub = [
    "\u2022 Segmented Picker: Sessiyalar | Market",
    "\u2022 H\u0259r kartda status badge (canl\u0131/planl\u0131/bitib)",
    "\u2022 Qiym\u0259t, tarix, i\u015ftirak\u00e7\u0131 say\u0131 g\u00f6r\u00fcn\u00fcr",
    "\u2022 '+' FAB d\u00fcym\u0259si il\u0259 yeni yaratma",
    "\u2022 Market tab-da m\u0259hsul kartlar\u0131:",
    "  \u2014 \u015e\u0259kil, tip badge, ad, qiym\u0259t, rating",
    "\u2022 Glassmorphism tab bar (a\u015fa\u011f\u0131da)",
    "\u2022 Active tab: q\u0131rm\u0131z\u0131 dair\u0259 + a\u011f icon",
    "",
    "\u2022 Reng sxemi: CV_RED (#FF3B30) \u2014 iOS Color.red",
    "\u2022 Kart radius: 16px (Constantz.Radius.L)",
    "\u2022 Shadow: subtle, 0.05 opacity",
    "\u2022 Font: System, Bold/Regular",
]
for i, n in enumerate(notes_hub):
    c.setFillColor(TXT); c.setFont(F, 6.5)
    c.drawString(desc_x, y - 20*mm - i * 4*mm, n)


# =============================================
# PAGE 15 — UI MOCKUP: CREATE SESSION + PRODUCT
# =============================================
np()
y = H - 25*mm
y = sec("14. UI N\u00fcmun\u0259 \u2014 Sessiya v\u0259 M\u0259hsul Yaratma", y)

# ---- PHONE 3: Create Session Form ----
px3 = 15*mm; py3 = y - PH_H - 5*mm
sx, sy, sw, sh = phone_frame(px3, py3)
top = phone_status_bar(sx, sy, sw, sh)
top = phone_nav_bar(sx, sy, sw, top, "Yeni Sessiya", back=True, right_icon="Saxla")

cw = sw - 6*mm; cx = sx + 3*mm; iy = top - 1*mm

# Title input
c.setFillColor(CV_TXT1); c.setFont(B, 3.5)
c.drawString(cx, iy, "Ba\u015fl\u0131q")
iy -= 5.5*mm
phone_input(cx, iy, cw, 4.5*mm, "Sessiya ad\u0131...", "HIIT M\u0259\u015fq\u0131")
iy -= 7*mm

# Type selector
c.setFillColor(CV_TXT1); c.setFont(B, 3.5)
c.drawString(cx, iy, "Sessiya Tipi")
iy -= 5.5*mm
types_s = ["Qrup", "1:1", "A\u00e7\u0131q"]
tw = (cw - 2*mm) / 3
for i, t in enumerate(types_s):
    tx = cx + i * (tw + 1*mm)
    if i == 0:
        c.setFillColor(CV_RED)
        c.roundRect(tx, iy, tw, 4*mm, 1.5*mm, fill=1, stroke=0)
        c.setFillColor(WHT); c.setFont(B, 3.5)
    else:
        c.setFillColor(HexColor("#F2F2F7"))
        c.roundRect(tx, iy, tw, 4*mm, 1.5*mm, fill=1, stroke=0)
        c.setFillColor(CV_TXT2); c.setFont(F, 3.5)
    c.drawCentredString(tx + tw/2, iy + 1*mm, t)
iy -= 7*mm

# Date + duration
c.setFillColor(CV_TXT1); c.setFont(B, 3.5)
c.drawString(cx, iy, "Tarix v\u0259 M\u00fcdd\u0259t")
iy -= 5.5*mm
hw = (cw - 2*mm)/2
phone_input(cx, iy, hw, 4.5*mm, "", "\ud83d\udcc5 3 Mar, 18:00")
phone_input(cx + hw + 2*mm, iy, hw, 4.5*mm, "", "\u23f1 45 d\u0259q")
iy -= 7*mm

# Difficulty
c.setFillColor(CV_TXT1); c.setFont(B, 3.5)
c.drawString(cx, iy, "\u00c7\u0259tinlik")
iy -= 5.5*mm
diffs = [("Ba\u015flan\u011f\u0131c", CV_GREEN), ("Orta", CV_ORANGE), ("Q\u0259li", CV_RED)]
dw = (cw - 3*mm) / 3
for i, (dl, dc) in enumerate(diffs):
    dx = cx + i * (dw + 1.5*mm)
    if i == 1:
        c.setFillColor(dc)
        c.roundRect(dx, iy, dw, 4*mm, 1.5*mm, fill=1, stroke=0)
        c.setFillColor(WHT)
    else:
        c.setFillColor(HexColor("#F2F2F7"))
        c.roundRect(dx, iy, dw, 4*mm, 1.5*mm, fill=1, stroke=0)
        c.setFillColor(CV_TXT2)
    c.setFont(F, 3.3)
    c.drawCentredString(dx + dw/2, iy + 1*mm, dl)
iy -= 7*mm

# Price toggle
c.setFillColor(CV_TXT1); c.setFont(B, 3.5)
c.drawString(cx, iy, "\u00d6d\u0259ni\u015fli?")
# Toggle
c.setFillColor(CV_GREEN)
c.roundRect(cx + 18*mm, iy - 0.5, 6*mm, 3.5*mm, 1.7*mm, fill=1, stroke=0)
c.setFillColor(WHT)
c.circle(cx + 22.5*mm, iy + 1.2, 1.3*mm, fill=1, stroke=0)
iy -= 5.5*mm
phone_input(cx, iy, cw, 4.5*mm, "", "\ud83d\udcb0 20 AZN")
iy -= 8*mm

# Create button
phone_btn(cx, iy, cw, 5.5*mm, "Sessiya Yarat")

phone_tab_bar(sx, sy, sw, active=4)
c.setFillColor(ACCENT); c.setFont(B, 8)
c.drawCentredString(px3 + PH_W/2, py3 - 3*mm, "Yeni Sessiya Formu")

# ---- PHONE 4: Create Product Form ----
px4 = px3 + PH_W + 12*mm; py4 = py3
sx, sy, sw, sh = phone_frame(px4, py4)
top = phone_status_bar(sx, sy, sw, sh)
top = phone_nav_bar(sx, sy, sw, top, "Yeni M\u0259hsul", back=True, right_icon="Saxla")

cw = sw - 6*mm; cx = sx + 3*mm; iy = top - 1*mm

# Image upload area
img_h = 16*mm
c.setFillColor(HexColor("#F2F2F7")); c.setStrokeColor(CV_RED); c.setLineWidth(0.4)
# Dashed border effect
c.setDash(2, 2)
c.roundRect(cx, iy - img_h, cw, img_h, 2.5*mm, fill=1, stroke=1)
c.setDash()
c.setFillColor(CV_RED); c.setFont(F, 6)
c.drawCentredString(cx + cw/2, iy - img_h/2 + 1, "\ud83d\udcf7")
c.setFillColor(CV_TXT2); c.setFont(F, 3.5)
c.drawCentredString(cx + cw/2, iy - img_h/2 - 2.5, "\u015e\u0259kil y\u00fckl\u0259")
iy -= img_h + 3*mm

# Product type chips
c.setFillColor(CV_TXT1); c.setFont(B, 3.5)
c.drawString(cx, iy, "M\u0259hsul Tipi")
iy -= 5*mm
ptypes = ["M\u0259\u015fq Plan", "Qida Plan", "E-Kitab", "Konsultasiya"]
ptw = (cw - 3*mm) / 2
for i, pt in enumerate(ptypes):
    row = i // 2; col = i % 2
    px_t = cx + col * (ptw + 2*mm); py_t = iy - row * 5*mm
    if i == 0:
        c.setFillColor(CV_RED)
        c.roundRect(px_t, py_t, ptw, 3.8*mm, 1.5*mm, fill=1, stroke=0)
        c.setFillColor(WHT); c.setFont(B, 3.2)
    else:
        c.setFillColor(HexColor("#F2F2F7"))
        c.roundRect(px_t, py_t, ptw, 3.8*mm, 1.5*mm, fill=1, stroke=0)
        c.setFillColor(CV_TXT2); c.setFont(F, 3.2)
    c.drawCentredString(px_t + ptw/2, py_t + 1*mm, pt)
iy -= 13*mm

# Name + description + price
c.setFillColor(CV_TXT1); c.setFont(B, 3.5)
c.drawString(cx, iy, "M\u0259hsul Ad\u0131")
iy -= 5*mm
phone_input(cx, iy, cw, 4.5*mm, "", "Full Body 30 G\u00fcn Plan\u0131")
iy -= 7*mm

c.setFillColor(CV_TXT1); c.setFont(B, 3.5)
c.drawString(cx, iy, "Qiym\u0259t")
iy -= 5*mm
hw = (cw - 2*mm)/2
phone_input(cx, iy, hw, 4.5*mm, "", "\ud83d\udcb0 25")
phone_input(cx + hw + 2*mm, iy, hw, 4.5*mm, "", "AZN \u25bc")
iy -= 8*mm

phone_btn(cx, iy, cw, 5.5*mm, "M\u0259hsul Yarat")

phone_tab_bar(sx, sy, sw, active=4)
c.setFillColor(ACCENT); c.setFont(B, 8)
c.drawCentredString(px4 + PH_W/2, py4 - 3*mm, "Yeni M\u0259hsul Formu")

# Description notes
desc_x = px4 + PH_W + 8*mm
c.setFillColor(DARK); c.setFont(B, 9)
c.drawString(desc_x, y - 12*mm, "Yaratma Formlar\u0131")
c.setFont(F, 7.5); c.setFillColor(TXT)
notes_form = [
    "\u2022 iOS native formalar, system renglerle",
    "\u2022 Sessiya formu:",
    "  \u2014 Tip se\u00e7imi: chips (Qrup/1:1/A\u00e7\u0131q)",
    "  \u2014 Tarix picker + m\u00fcdd\u0259t",
    "  \u2014 \u00c7\u0259tinlik: ya\u015f\u0131l/nar\u0131nc\u0131/q\u0131rm\u0131z\u0131",
    "  \u2014 \u00d6d\u0259ni\u015fli toggle + qiym\u0259t input",
    "",
    "\u2022 M\u0259hsul formu:",
    "  \u2014 \u015e\u0259kil y\u00fckl\u0259m\u0259 zonas\u0131 (dashed border)",
    "  \u2014 Tip se\u00e7imi: 2x2 grid chips",
    "  \u2014 Qiym\u0259t + valyuta se\u00e7imi",
    "",
    "\u2022 Q\u0131rm\u0131z\u0131 primary button (a\u015fa\u011f\u0131da)",
    "\u2022 Glassmorphism tab bar",
]
for i, n in enumerate(notes_form):
    c.setFillColor(TXT); c.setFont(F, 6.5)
    c.drawString(desc_x, y - 20*mm - i * 4*mm, n)


# =============================================
# PAGE 16 — UI MOCKUP: AI KALORI + AI TOVSIYE
# =============================================
np()
y = H - 25*mm
y = sec("15. UI N\u00fcmun\u0259 \u2014 AI Kalori + AI T\u00f6vsiy\u0259", y)

# ---- PHONE 5: AI Kalori Analiz ----
px5 = 15*mm; py5 = y - PH_H - 5*mm
sx, sy, sw, sh = phone_frame(px5, py5)
top = phone_status_bar(sx, sy, sw, sh)
top = phone_nav_bar(sx, sy, sw, top, "Qida Analizi", back=True)
cw = sw - 6*mm; cx = sx + 3*mm

# Camera/photo area
cam_h = 22*mm
c.setFillColor(HexColor("#2C2C2E"))
c.roundRect(cx, top - cam_h - 1*mm, cw, cam_h, 2.5*mm, fill=1, stroke=0)
# Camera icon
c.setFillColor(WHT); c.setFont(F, 10)
c.drawCentredString(cx + cw/2, top - cam_h/2 - 2, "\ud83d\udcf8")
c.setFont(F, 3.5); c.setFillColor(HexColor("#AAAAAA"))
c.drawCentredString(cx + cw/2, top - cam_h + 1.5*mm, "\u015e\u0259kil \u00e7\u0259k v\u0259 ya se\u00e7")
# Camera + Gallery buttons
btn_w = (cw - 2*mm)/2
btn_y = top - cam_h - 7*mm
phone_btn(cx, btn_y, btn_w, 4.5*mm, "\ud83d\udcf7 Kamera")
phone_btn(cx + btn_w + 2*mm, btn_y, btn_w, 4.5*mm, "\ud83d\uddbc Qalereya", primary=False)

# AI Result card
res_y = btn_y - 6*mm
c.setFillColor(HexColor("#F0FDF4")); c.setStrokeColor(CV_GREEN); c.setLineWidth(0.4)
c.roundRect(cx, res_y - 26*mm, cw, 26*mm, 2.5*mm, fill=1, stroke=1)
c.setFillColor(CV_GREEN); c.setFont(B, 4)
c.drawString(cx + 2*mm, res_y - 3*mm, "\u2713 ML Analiz N\u0259tic\u0259si")
c.setFillColor(CV_TXT1); c.setFont(B, 5)
c.drawString(cx + 2*mm, res_y - 7*mm, "Toyuq sa\u00e7\u0131 + d\u00fcy\u00fc + salat")
c.setFont(F, 3.5); c.setFillColor(CV_TXT2)
c.drawString(cx + 2*mm, res_y - 10.5*mm, "D\u0259qiqlik: 94%  |  Porsiya: Orta")

# Macros row
macro_y = res_y - 14*mm
macros = [("Kalori", "485", "kcal", CV_RED), ("Protein", "38g", "", CV_BLUE), ("Karb", "52g", "", CV_ORANGE), ("Ya\u011f", "14g", "", CV_PURPLE)]
mw = (cw - 6*mm) / 4
for i, (ml, mv, mu, mc) in enumerate(macros):
    mx = cx + 1.5*mm + i * (mw + 1.5*mm)
    c.setFillColor(mc); c.setFont(B, 5)
    c.drawCentredString(mx + mw/2, macro_y, mv)
    c.setFillColor(CV_TXT2); c.setFont(F, 3)
    c.drawCentredString(mx + mw/2, macro_y - 3.5*mm, ml)

# Add button
phone_btn(cx, res_y - 24*mm, cw, 4.5*mm, "\u2795 Qida Loqu-na \u018elav\u0259 Et")

phone_tab_bar(sx, sy, sw, active=2)
c.setFillColor(ACCENT); c.setFont(B, 8)
c.drawCentredString(px5 + PH_W/2, py5 - 3*mm, "AI Kalori Analizi (ML)")

# ---- PHONE 6: AI Tovsiye ----
px6 = px5 + PH_W + 12*mm; py6 = py5
sx, sy, sw, sh = phone_frame(px6, py6)
top = phone_status_bar(sx, sy, sw, sh)
top = phone_nav_bar(sx, sy, sw, top, "AI T\u00f6vsiy\u0259l\u0259r", right_icon="\ud83d\udd04")
cw = sw - 6*mm; cx = sx + 3*mm

# Daily summary card
ds_y = top - 1*mm
c.setFillColor(CV_RED)
c.roundRect(cx, ds_y - 12*mm, cw, 12*mm, 2.5*mm, fill=1, stroke=0)
c.setFillColor(WHT); c.setFont(B, 4.5)
c.drawString(cx + 2*mm, ds_y - 3.5*mm, "\ud83c\udfaf G\u00fcnl\u00fck H\u0259d\u0259f: 2100 kcal")
c.setFont(F, 3.5)
c.drawString(cx + 2*mm, ds_y - 7*mm, "Q\u0259bul: 1450 kcal  |  Qalan: 650 kcal")
# Progress bar
c.setFillColor(HexColor("#FFFFFF40"))
c.roundRect(cx + 2*mm, ds_y - 11*mm, cw - 4*mm, 2*mm, 1*mm, fill=1, stroke=0)
c.setFillColor(WHT)
c.roundRect(cx + 2*mm, ds_y - 11*mm, (cw - 4*mm) * 0.69, 2*mm, 1*mm, fill=1, stroke=0)

# Recommendation cards
rec_y = ds_y - 15*mm
recs = [
    ("\ud83c\udfcb\ufe0f", "M\u0259\u015fq T\u00f6vsiy\u0259si", "30 d\u0259q HIIT \u2014 bu g\u00fcn \u00fc\u00e7\u00fcn ideal", HexColor("#FFF5F5"), CV_RED),
    ("\ud83c\udf5d", "Qida T\u00f6vsiy\u0259si", "Ax\u015fam: toyuq sa\u00e7\u0131 + salat (520 kcal)", HexColor("#FFF8F0"), CV_ORANGE),
    ("\ud83d\udcc8", "Proqres", "Bu h\u0259ft\u0259 +2 m\u0259\u015fq \u2014 \u0259la gedirsiz!", HexColor("#F0FDF4"), CV_GREEN),
    ("\ud83d\udd25", "Motivasiya", "5 g\u00fcnl\u00fck streak! Davam edin!", HexColor("#FFF5F0"), CV_ORANGE),
]
for i, (emoji, title, desc, bg_col, border_col) in enumerate(recs):
    ry = rec_y - i * 12*mm
    c.setFillColor(bg_col); c.setStrokeColor(border_col); c.setLineWidth(0.4)
    c.roundRect(cx, ry - 10*mm, cw, 10*mm, 2.5*mm, fill=1, stroke=1)
    c.setFillColor(CV_TXT1); c.setFont(B, 4.5)
    c.drawString(cx + 2*mm, ry - 3.5*mm, f"{emoji} {title}")
    c.setFillColor(CV_TXT2); c.setFont(F, 3.3)
    c.drawString(cx + 2*mm, ry - 7.5*mm, desc)

phone_tab_bar(sx, sy, sw, active=0)
c.setFillColor(ACCENT); c.setFont(B, 8)
c.drawCentredString(px6 + PH_W/2, py6 - 3*mm, "AI T\u00f6vsiy\u0259l\u0259r (ML)")

# Description
desc_x = px6 + PH_W + 8*mm
c.setFillColor(DARK); c.setFont(B, 9)
c.drawString(desc_x, y - 12*mm, "AI Ekranlar\u0131")
c.setFont(F, 7.5); c.setFillColor(TXT)
notes_ai = [
    "\u2022 AI Kalori (sol):",
    "  \u2014 Kamera/qalereya \u015f\u0259kil se\u00e7imi",
    "  \u2014 ML analiz n\u0259tic\u0259si ya\u015f\u0131l kartda",
    "  \u2014 D\u0259qiqlik faizi + porsiya \u00f6l\u00e7\u00fcs\u00fc",
    "  \u2014 Makro-lar: 4 r\u0259ngli s\u00fctun",
    "  \u2014 Qida loqu-na \u0259lav\u0259 et buttonu",
    "",
    "\u2022 AI T\u00f6vsiy\u0259 (sa\u011f):",
    "  \u2014 G\u00fcnl\u00fck h\u0259d\u0259f kart\u0131 (q\u0131rm\u0131z\u0131)",
    "  \u2014 Kalori proqress bar\u0131",
    "  \u2014 F\u0259rdi t\u00f6vsiy\u0259 kartlar\u0131:",
    "    M\u0259\u015fq / Qida / Proqres / Motivasiya",
    "  \u2014 H\u0259r kart: emoji + ba\u015fl\u0131q + t\u0259svir",
    "  \u2014 R\u0259ngli border il\u0259 f\u0259rql\u0259ndirilir",
]
for i, n in enumerate(notes_ai):
    c.setFillColor(TXT); c.setFont(F, 6.5)
    c.drawString(desc_x, y - 20*mm - i * 4*mm, n)


# =============================================
# PAGE 17 — UI MOCKUP: STUDENT VIEWS
# =============================================
np()
y = H - 25*mm
y = sec("16. UI N\u00fcmun\u0259 \u2014 T\u0259l\u0259b\u0259 Ekranlar\u0131", y)

# ---- PHONE 7: Student - Live Sessions List ----
px7 = 15*mm; py7 = y - PH_H - 5*mm
sx, sy, sw, sh = phone_frame(px7, py7)
top = phone_status_bar(sx, sy, sw, sh)
top = phone_nav_bar(sx, sy, sw, top, "Canl\u0131 Sessiyalar", back=True)
cw = sw - 6*mm; cx = sx + 3*mm

# Filter chips
filters = ["Ham\u0131s\u0131", "Yax\u0131n", "Canl\u0131", "Bitib"]
fc_w = (cw - 3*mm) / 4
fc_y = top - 5*mm
for i, fl in enumerate(filters):
    fx = cx + i * (fc_w + 1*mm)
    if i == 0:
        c.setFillColor(CV_RED)
        c.roundRect(fx, fc_y, fc_w, 3.5*mm, 1.5*mm, fill=1, stroke=0)
        c.setFillColor(WHT); c.setFont(B, 3.2)
    else:
        c.setFillColor(HexColor("#F2F2F7"))
        c.roundRect(fx, fc_y, fc_w, 3.5*mm, 1.5*mm, fill=1, stroke=0)
        c.setFillColor(CV_TXT2); c.setFont(F, 3.2)
    c.drawCentredString(fx + fc_w/2, fc_y + 0.8*mm, fl)

# Session cards (student view - with Join button)
cards_data = [
    ("HIIT M\u0259\u015fq\u0131", "Vusal D.", "scheduled", "20 AZN", "3 Mar, 18:00", "8/15"),
    ("Yoga S\u0259h\u0259r", "Aysel T.", "live", "Pulsuz", "\u0130ndi canl\u0131!", "14/20"),
    ("Funksional", "Murad K.", "scheduled", "15 AZN", "5 Mar, 19:00", "3/10"),
]
for i, (t, tr, st, pr, dt, cnt) in enumerate(cards_data):
    cy = fc_y - 6*mm - i * 16*mm
    phone_session_card(cx, cy, cw, title=t, trainer=tr, status=st, price=pr, date=dt, count=cnt)
    # Join button for each
    btn_label = "Qo\u015ful" if st == "live" else "\u00d6d\u0259 v\u0259 Qo\u015ful" if pr != "Pulsuz" else "Qo\u015ful"
    phone_btn(cx + cw - 16*mm, cy + 1*mm, 15*mm, 3.5*mm, btn_label)

phone_tab_bar(sx, sy, sw, active=0)
c.setFillColor(ACCENT); c.setFont(B, 8)
c.drawCentredString(px7 + PH_W/2, py7 - 3*mm, "T\u0259l\u0259b\u0259 \u2014 Sessiya Siyah\u0131s\u0131")

# ---- PHONE 8: Student - Marketplace ----
px8 = px7 + PH_W + 12*mm; py8 = py7
sx, sy, sw, sh = phone_frame(px8, py8)
top = phone_status_bar(sx, sy, sw, sh)
top = phone_nav_bar(sx, sy, sw, top, "Market", back=True, right_icon="\ud83d\udd0d")
cw = sw - 6*mm; cx = sx + 3*mm

# Filter chips
mfilters = ["Ham\u0131s\u0131", "M\u0259\u015fq", "Qida", "E-Kitab"]
fc_y = top - 5*mm
for i, fl in enumerate(mfilters):
    fx = cx + i * (fc_w + 1*mm)
    if i == 0:
        c.setFillColor(CV_RED)
        c.roundRect(fx, fc_y, fc_w, 3.5*mm, 1.5*mm, fill=1, stroke=0)
        c.setFillColor(WHT); c.setFont(B, 3.2)
    else:
        c.setFillColor(HexColor("#F2F2F7"))
        c.roundRect(fx, fc_y, fc_w, 3.5*mm, 1.5*mm, fill=1, stroke=0)
        c.setFillColor(CV_TXT2); c.setFont(F, 3.2)
    c.drawCentredString(fx + fc_w/2, fc_y + 0.8*mm, fl)

# Product cards
prods = [
    ("Full Body 30 G\u00fcn", "M\u0259\u015fq", "25 AZN", "4.8", "Vusal D."),
    ("Protein P\u0259hriz", "Qida", "18 AZN", "4.6", "Aysel T."),
    ("Ev M\u0259\u015fqi Kitab\u0131", "E-Kitab", "10 AZN", "4.9", "Murad K."),
    ("1:1 Konsultasiya", "Kons.", "40 AZN", "5.0", "Vusal D."),
]
for i, (t, tp, pr, rt, sl) in enumerate(prods):
    cy = fc_y - 6*mm - i * 13.5*mm
    phone_product_card(cx, cy, cw, title=t, typ=tp, price=pr, rating=rt, seller=sl)

phone_tab_bar(sx, sy, sw, active=0)
c.setFillColor(ACCENT); c.setFont(B, 8)
c.drawCentredString(px8 + PH_W/2, py8 - 3*mm, "T\u0259l\u0259b\u0259 \u2014 Market")

# Notes
desc_x = px8 + PH_W + 8*mm
c.setFillColor(DARK); c.setFont(B, 9)
c.drawString(desc_x, y - 12*mm, "T\u0259l\u0259b\u0259 Ekranlar\u0131")
c.setFont(F, 7.5); c.setFillColor(TXT)
notes_st = [
    "\u2022 Sessiya siyah\u0131s\u0131 (sol):",
    "  \u2014 Filtr chips: Ham\u0131s\u0131/Yax\u0131n/Canl\u0131/Bitib",
    "  \u2014 Status badge: mavi/q\u0131rm\u0131z\u0131/boz",
    "  \u2014 H\u0259r kartda 'Qo\u015ful' buttonu",
    "  \u2014 \u00d6d\u0259ni\u015fli sessiyalarda '\u00d6d\u0259 v\u0259 Qo\u015ful'",
    "",
    "\u2022 Market siyah\u0131s\u0131 (sa\u011f):",
    "  \u2014 Filtr chips: tip \u00fc\u00e7\u00fcn",
    "  \u2014 M\u0259hsul kartlar\u0131:",
    "    \u015e\u0259kil + tip badge + ad + rating",
    "  \u2014 Axtarma ikonu sa\u011f yuxar\u0131da",
    "",
    "\u2022 Uy\u011fun dizayn prinsipl\u0259ri:",
    "  \u2014 12px radius, shadow kartlar",
    "  \u2014 Q\u0131rm\u0131z\u0131 accent r\u0259ng",
    "  \u2014 System adaptive r\u0259ngl\u0259r",
]
for i, n in enumerate(notes_st):
    c.setFillColor(TXT); c.setFont(F, 6.5)
    c.drawString(desc_x, y - 20*mm - i * 3.8*mm, n)


# SAVE
c.save()
print(f"PDF: {out}")
print(f"\u00d6l\u00e7\u00fc: {os.path.getsize(out)/1024:.0f} KB")
print(f"S\u0259hif\u0259: {page_num[0]+1}")
