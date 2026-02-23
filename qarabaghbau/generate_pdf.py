#!/usr/bin/env python3
"""GARABAG-Bau Praesentation — Originaltexte + Bilder, kein Video"""
from reportlab.lib.pagesizes import landscape, A4
from reportlab.lib.colors import HexColor, Color
from reportlab.pdfgen import canvas
import os

BG=HexColor('#FFFFFF');CARD=HexColor('#F5F5F5');ACCENT=HexColor('#e93728')
DARK=HexColor('#1a1a1a');TEXT=HexColor('#444444');GRAY=HexColor('#777777')
MUTED=HexColor('#aaaaaa');BORDER=HexColor('#e0e0e0')

W,H=landscape(A4)
OUT='/Users/vusaldadashov/Desktop/ConsoleApp/qarabaghbau/GARABAG-Bau_Praesentation.pdf'
IMG='/Users/vusaldadashov/Desktop/ConsoleApp/qarabaghbau/images/png'

def bg(c):
    c.setFillColor(BG);c.rect(0,0,W,H,fill=1,stroke=0)
def topbar(c):
    c.setFillColor(ACCENT);c.rect(0,H-2.5,W*0.4,2.5,fill=1,stroke=0)
def pnum(c,n,t=5):
    c.setFillColor(MUTED);c.setFont('Helvetica',8);c.drawRightString(W-40,25,f'{n:02d} / {t:02d}')
def pbrand(c):
    c.setFillColor(MUTED);c.setFont('Helvetica-Bold',7);c.drawString(40,25,'GARABAG-BAU')
def aline(c,x,y,w=45):
    c.setFillColor(ACCENT);c.roundRect(x,y,w,2.5,1,fill=1,stroke=0)
def crd(c,x,y,w,h,r=10):
    c.setFillColor(CARD);c.setStrokeColor(BORDER);c.setLineWidth(0.5);c.roundRect(x,y,w,h,r,fill=1,stroke=1)
def crda(c,x,y,w,h):
    crd(c,x,y,w,h);c.setFillColor(ACCENT);c.rect(x,y+6,2.5,h-12,fill=1,stroke=0)

def draw_img(c, path, x, y, w, h, radius=8):
    """Draw image with clipping to rounded rect"""
    fp = os.path.join(IMG, path)
    if not os.path.exists(fp):
        crd(c,x,y,w,h,radius)
        return
    c.saveState()
    p = c.beginPath()
    p.roundRect(x, y, w, h, radius)
    c.clipPath(p, stroke=0)
    c.drawImage(fp, x, y, w, h, preserveAspectRatio=True, anchor='c')
    c.restoreState()
    # border
    c.setStrokeColor(BORDER);c.setLineWidth(0.5)
    p2 = c.beginPath();p2.roundRect(x,y,w,h,radius);c.drawPath(p2,stroke=1,fill=0)

# ════════════ PAGE 1 — COVER ════════════
def p1(c):
    bg(c)
    # Hero image as background (dimmed)
    c.saveState()
    c.drawImage(os.path.join(IMG,'hero_1.png'),0,0,W,H,preserveAspectRatio=True,anchor='c')
    c.setFillColor(Color(1,1,1,0.88))
    c.rect(0,0,W,H,fill=1,stroke=0)
    c.restoreState()

    for i in range(25):
        a=0.012-i*0.0005
        if a<=0:break
        c.setFillColor(Color(0.91,0.22,0.16,a));c.circle(W-80,H-50,100+i*14,fill=1,stroke=0)
    for i in range(18):
        a=0.008-i*0.0004
        if a<=0:break
        c.setFillColor(Color(0.91,0.22,0.16,a));c.circle(80,60,90+i*14,fill=1,stroke=0)

    c.setFillColor(MUTED);c.setFont('Helvetica',10);c.drawRightString(W-40,H-35,'2025')
    cx=W/2

    # Logo
    draw_img(c,'attachment_1.png',cx-35,H/2+52,70,50,10)

    c.setFillColor(DARK);c.setFont('Helvetica-Bold',54);c.drawCentredString(cx,H/2+5,'GARABAG')
    c.setFillColor(ACCENT);c.setFont('Helvetica-Bold',54);c.drawCentredString(cx,H/2-48,'BAU')
    c.setFillColor(TEXT);c.setFont('Helvetica',14)
    c.drawCentredString(cx,H/2-85,'Wir bauen Ihre Zukunft auf')
    c.setFillColor(MUTED);c.setFont('Helvetica',9)
    c.drawCentredString(cx,35,u'Eichendorffstr. 3, 48167 M\u00fcnster     \u00b7     01726009105     \u00b7     info@garabag-bau.de')
    c.showPage()

# ════════════ PAGE 2 — ÜBER UNS ════════════
def p2(c):
    bg(c);topbar(c);pbrand(c);pnum(c,2)
    lx=45

    c.setFillColor(ACCENT);c.setFont('Helvetica-Bold',8);c.drawString(lx,H-50,u'\u00dc B E R   U N S')
    c.setFillColor(DARK);c.setFont('Helvetica-Bold',26)
    c.drawString(lx,H-80,u'GARABAG-BAU IN M\u00dcNSTER')
    aline(c,lx,H-95)

    c.setFillColor(TEXT);c.setFont('Helvetica',10)
    y=H-120
    texts=[
        u'Wir sind ein f\u00fchrendes Unternehmen in der Bauindustrie und stolz',
        u'darauf, innovative und qualitativ hochwertige L\u00f6sungen f\u00fcr unsere',
        u'Kunden zu bieten. Seit unserer Gr\u00fcndung setzen wir auf Kompetenz,',
        u'Zuverl\u00e4ssigkeit und Kundenzufriedenheit.',
        '',
        u'Unser erfahrenes Team aus Fachleuten arbeitet engagiert daran,',
        u'jedes Bauprojekt erfolgreich zu realisieren, von Abbrucharbeiten',
        u'\u00fcber Ger\u00fcstbau bis hin zur Bereitstellung erstklassiger Baustoffe.',
        '',
        u'Mit Leidenschaft und Fachwissen verwandeln wir Ihre Visionen in',
        u'Wirklichkeit. Lernen Sie uns kennen und erfahren Sie, warum',
        u'GARABAG Bau Ihr vertrauensw\u00fcrdiger Partner f\u00fcr Bauprojekte',
        u'aller Art ist.',
    ]
    for l in texts:
        if l:c.drawString(lx,y,l)
        y-=16

    y-=10
    c.setFillColor(ACCENT);c.setFont('Helvetica-Bold',8);c.drawString(lx,y,'W I L L K O M M E N')
    y-=20
    c.setFillColor(TEXT);c.setFont('Helvetica',10)
    texts2=[
        u'Wir sind ein eingespieltes Team von sieben Fachkr\u00e4ften mit Sitz',
        u'in M\u00fcnster. Unsere Leistungen umfassen Rohbau, Betonarbeiten,',
        u'Mauerbau, Altbausanierung, Schalung, Eisenbewehrung, Anbau und',
        u'Abbruch. Pr\u00e4zision, Qualit\u00e4t und Kundenzufriedenheit stehen bei',
        u'uns an erster Stelle \u2014 jedes Projekt wird termingerecht und auf',
        u'h\u00f6chstem handwerklichen Niveau abgeschlossen.',
    ]
    for l in texts2:
        if l:c.drawString(lx,y,l)
        y-=16

    # Right side — image + info cards
    rx=W/2+15;cw=W/2-70

    # Hero image on right
    draw_img(c,'hero_2.png',rx,H-55-(cw*0.45),cw,cw*0.45,10)

    # Info cards below image
    img_bottom = H-55-(cw*0.45)-10
    cards=[
        ('INHABER','Vugar Azizov'),
        ('TEAM',u'7 Fachkr\u00e4fte'),
        ('ADRESSE',u'Eichendorffstr. 3, 48167 M\u00fcnster'),
        ('TELEFON','01726009105'),
        ('E-MAIL','info@garabag-bau.de'),
    ]
    ch=32;cg=5
    for i,(lab,val) in enumerate(cards):
        cy=img_bottom-i*(ch+cg)
        crda(c,rx,cy-ch,cw,ch)
        c.setFillColor(ACCENT);c.setFont('Helvetica-Bold',6.5);c.drawString(rx+14,cy-11,lab)
        c.setFillColor(DARK);c.setFont('Helvetica-Bold',9.5);c.drawString(rx+14,cy-25,val)
    c.showPage()

# ════════════ PAGE 3 — LEISTUNGEN ════════════
def p3(c):
    bg(c);topbar(c);pbrand(c);pnum(c,3)
    c.setFillColor(ACCENT);c.setFont('Helvetica-Bold',8);c.drawString(45,H-50,'L E I S T U N G E N')
    c.setFillColor(DARK);c.setFont('Helvetica-Bold',26);c.drawString(45,H-80,'DAS LEISTEN WIR')
    aline(c,45,H-95)

    # 2x2 grid with images
    svcs=[
        ('01','MAUER- & BETONBAU','project_1.png',[
            u'Garabag Bau, Ihr Experte f\u00fcr Mauer- und Betonbau.',
            u'Wir bieten ma\u00dfgeschneiderte L\u00f6sungen f\u00fcr private',
            u'und gewerbliche Bauprojekte. Unsere Leistungen',
            u'umfassen: Mauerbau und Betonarbeit. Kontaktieren',
            u'Sie uns f\u00fcr Ihr n\u00e4chstes Bauprojekt!']),
        ('02','ALTBAUSANIERUNG','project_3.png',[
            u'Erwecken Sie alte Geb\u00e4ude zu neuem Leben mit',
            u'Garabag Bau. Wir sind spezialisiert auf die',
            u'fachgerechte Sanierung und Modernisierung von',
            u'Altbauten. Vertrauen Sie auf unsere Erfahrung',
            u'und Expertise f\u00fcr eine gelungene Altbausanierung.']),
        ('03','ANBAU UND ABBRUCH','project_5.png',[
            u'Bei Garabag Bau bieten wir professionelle L\u00f6sungen',
            u'f\u00fcr Anbau und Abbruch an. Egal, ob Sie Ihr Geb\u00e4ude',
            u'erweitern oder sicher abrei\u00dfen m\u00f6chten, wir sind Ihr',
            u'verl\u00e4sslicher Partner. Vertrauen Sie auf unsere',
            u'Expertise f\u00fcr Ihr Bauprojekt.']),
        ('04','SCHALUNG & EISENBEWEHRUNG','project_7.png',[
            u'Garabag Bau ist Ihr Fachbetrieb f\u00fcr Schalung und',
            u'Eisenbewehrungsarbeiten. Wir bieten pr\u00e4zise und',
            u'zuverl\u00e4ssige L\u00f6sungen f\u00fcr alle Arten von',
            u'Bauprojekten. Vertrauen Sie auf unsere Erfahrung',
            u'und Kompetenz.']),
    ]
    cols=2;cw2=(W-90-20)/cols;ch2=125;img_h=48
    for i,(num,title,img,desc) in enumerate(svcs):
        col=i%cols;row=i//cols;x=45+col*(cw2+20);y=H-115-row*(ch2+14)
        crd(c,x,y-ch2,cw2,ch2)
        # Image strip at top of card
        draw_img(c,img,x+2,y-2-img_h,cw2-4,img_h,8)
        # Number
        c.setFillColor(Color(0,0,0,0.04));c.setFont('Helvetica-Bold',34);c.drawRightString(x+cw2-14,y-img_h-22,num)
        c.setFillColor(DARK);c.setFont('Helvetica-Bold',9.5);c.drawString(x+16,y-img_h-18,title)
        c.setFillColor(TEXT);c.setFont('Helvetica',8)
        for j,line in enumerate(desc):
            if line:c.drawString(x+16,y-img_h-34-j*12,line)
    c.showPage()

# ════════════ PAGE 4 — GALERIE ════════════
def p4(c):
    bg(c);topbar(c);pbrand(c);pnum(c,4)
    c.setFillColor(ACCENT);c.setFont('Helvetica-Bold',8);c.drawString(45,H-50,'G A L E R I E')
    c.setFillColor(DARK);c.setFont('Helvetica-Bold',26);c.drawString(45,H-80,'UNSERE ARBEIT')
    aline(c,45,H-95)

    c.setFillColor(DARK);c.setFont('Helvetica-Bold',11);c.drawString(45,H-115,'Bilder')

    # Row 1 — 4 project images
    imgs_row1 = ['project_1.png','project_2.png','project_3.png','project_4.png']
    gw = (W - 90 - 14*3) / 4
    gh = gw * 0.56
    gy1 = H - 135

    for i,img in enumerate(imgs_row1):
        x = 45 + i * (gw + 14)
        draw_img(c, img, x, gy1 - gh, gw, gh, 8)

    # Row 2 — 4 project images
    imgs_row2 = ['project_5.png','project_6.png','project_7.png','project_8.png']
    gy2 = gy1 - gh - 12

    for i,img in enumerate(imgs_row2):
        x = 45 + i * (gw + 14)
        draw_img(c, img, x, gy2 - gh, gw, gh, 8)

    # Row 3 — Drone images label
    gy3 = gy2 - gh - 20
    c.setFillColor(DARK);c.setFont('Helvetica-Bold',11);c.drawString(45,gy3,'Drohnenaufnahmen')

    # Row 3 — 3 DJI drone images
    imgs_row3 = ['DJI_20240423110827_0004_D.png','DJI_20240429154043_0005_D.png','DJI_20240506161336_0008_D.png']
    dw = (W - 90 - 14*2) / 3
    dh = dw * 0.48
    dy = gy3 - 16

    for i,img in enumerate(imgs_row3):
        x = 45 + i * (dw + 14)
        draw_img(c, img, x, dy - dh, dw, dh, 8)

    c.showPage()

# ════════════ PAGE 5 — KONTAKT ════════════
def p5(c):
    bg(c);topbar(c);pbrand(c);pnum(c,5)
    cx=W/2

    c.setFillColor(ACCENT);c.setFont('Helvetica-Bold',8);c.drawCentredString(cx,H-50,'T E R M I N E   &   K O N T A K T')
    c.setFillColor(DARK);c.setFont('Helvetica-Bold',32);c.drawCentredString(cx,H-85,'KONTAKTIEREN SIE UNS')
    aline(c,cx-22,H-100)

    contacts=[
        ('TELEFON','01726009105'),
        ('E-MAIL','info@garabag-bau.de'),
        ('INSTAGRAM','@garabag_bau'),
    ]
    cw3,ch3=190,60;total=3*cw3+2*20;sx=(W-total)/2;cy=H-130
    for i,(lab,val) in enumerate(contacts):
        x=sx+i*(cw3+20);crd(c,x,cy-ch3,cw3,ch3)
        c.setFillColor(ACCENT);c.setFont('Helvetica-Bold',8);c.drawCentredString(x+cw3/2,cy-18,lab)
        c.setFillColor(DARK);c.setFont('Helvetica-Bold',11);c.drawCentredString(x+cw3/2,cy-38,val)

    ay=cy-ch3-30
    c.setFillColor(ACCENT);c.setFont('Helvetica-Bold',8);c.drawCentredString(cx,ay,'A N S C H R I F T')
    c.setFillColor(DARK);c.setFont('Helvetica-Bold',14);c.drawCentredString(cx,ay-22,'Eichendorffstr. 3')
    c.drawCentredString(cx,ay-42,u'48167 M\u00fcnster')

    fy=ay-75
    c.setFillColor(DARK);c.setFont('Helvetica-Bold',10);c.drawCentredString(cx,fy,'Schreiben Sie uns')
    fy-=20

    fw=400;fh=30;fsx=(W-fw)/2
    fields=['Vorname','Nachname','E-Mail','Ihre Nachricht']
    for i,f in enumerate(fields):
        crd(c,fsx,fy-i*(fh+8),fw,fh,6)
        c.setFillColor(GRAY);c.setFont('Helvetica',9);c.drawString(fsx+12,fy-i*(fh+8)+10,f)

    cby=fy-len(fields)*(fh+8)-10
    c.setFillColor(TEXT);c.setFont('Helvetica',7.5)
    c.drawCentredString(cx,cby,u'Ich habe die Datenschutzerkl\u00e4rung zur Kenntnis genommen.')
    c.drawCentredString(cx,cby-12,u'Ich stimme zu, dass meine Angaben zur Kontaktaufnahme und f\u00fcr R\u00fcckfragen dauerhaft gespeichert werden.')

    c.setFillColor(MUTED);c.setFont('Helvetica',7)
    c.drawCentredString(cx,30,u'\u00a9 2025 GARABAG-Bau     \u00b7     Impressum     \u00b7     Datenschutz')
    c.showPage()

# ════════════ GENERATE ════════════
def main():
    c2=canvas.Canvas(OUT,pagesize=landscape(A4))
    c2.setTitle(u'GARABAG-Bau \u2014 Unternehmenspr\u00e4sentation')
    c2.setAuthor('GARABAG-Bau')
    p1(c2);p2(c2);p3(c2);p4(c2);p5(c2)
    c2.save()
    fsize = os.path.getsize(OUT) / 1024
    print(f'\n\u2705 PDF erstellt: {OUT}')
    print(f'   5 Seiten | A4 Querformat | mit Bildern | {fsize:.0f} KB')

if __name__=='__main__':
    main()
