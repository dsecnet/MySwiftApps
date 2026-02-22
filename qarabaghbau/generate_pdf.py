#!/usr/bin/env python3
"""
Garabag-Bau & Inno-Bahnbau - Company Analysis PDF Generator
"""

from reportlab.lib.pagesizes import A4
from reportlab.lib import colors
from reportlab.lib.units import mm, cm
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, HRFlowable
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.lib.enums import TA_CENTER, TA_LEFT, TA_JUSTIFY

def create_pdf():
    doc = SimpleDocTemplate(
        "/Users/vusaldadashov/Desktop/qarabaghbau/Garabag_Bau_Analysis.pdf",
        pagesize=A4,
        rightMargin=2*cm,
        leftMargin=2*cm,
        topMargin=2*cm,
        bottomMargin=2*cm
    )

    styles = getSampleStyleSheet()

    # Custom styles
    title_style = ParagraphStyle(
        'CustomTitle',
        parent=styles['Title'],
        fontSize=24,
        textColor=colors.HexColor('#1a1a2e'),
        spaceAfter=6,
        alignment=TA_CENTER,
        fontName='Helvetica-Bold'
    )

    subtitle_style = ParagraphStyle(
        'CustomSubtitle',
        parent=styles['Normal'],
        fontSize=12,
        textColor=colors.HexColor('#666666'),
        spaceAfter=20,
        alignment=TA_CENTER,
        fontName='Helvetica'
    )

    section_style = ParagraphStyle(
        'SectionHeader',
        parent=styles['Heading1'],
        fontSize=16,
        textColor=colors.HexColor('#16213e'),
        spaceBefore=20,
        spaceAfter=10,
        fontName='Helvetica-Bold',
        borderWidth=0,
        borderColor=colors.HexColor('#e94560'),
        borderPadding=5,
    )

    subsection_style = ParagraphStyle(
        'SubsectionHeader',
        parent=styles['Heading2'],
        fontSize=13,
        textColor=colors.HexColor('#0f3460'),
        spaceBefore=12,
        spaceAfter=6,
        fontName='Helvetica-Bold'
    )

    body_style = ParagraphStyle(
        'CustomBody',
        parent=styles['Normal'],
        fontSize=10,
        textColor=colors.HexColor('#333333'),
        spaceAfter=6,
        alignment=TA_JUSTIFY,
        fontName='Helvetica',
        leading=14
    )

    bullet_style = ParagraphStyle(
        'BulletStyle',
        parent=body_style,
        leftIndent=20,
        bulletIndent=10,
        spaceAfter=4,
    )

    info_style = ParagraphStyle(
        'InfoStyle',
        parent=body_style,
        fontSize=10,
        leftIndent=15,
        spaceAfter=3,
    )

    elements = []

    # ==========================================
    # COVER / TITLE
    # ==========================================
    elements.append(Spacer(1, 3*cm))
    elements.append(Paragraph("GARABAG-BAU", title_style))
    elements.append(Paragraph("Bauunternehmung", subtitle_style))
    elements.append(Spacer(1, 0.5*cm))
    elements.append(HRFlowable(width="60%", thickness=2, color=colors.HexColor('#e94560'), spaceAfter=10, spaceBefore=0, hAlign='CENTER'))
    elements.append(Spacer(1, 0.5*cm))
    elements.append(Paragraph("Detalli Sirket Analizi ve Melumat Hesabati", subtitle_style))
    elements.append(Paragraph("Hazirlanma tarixi: Fevral 2026", subtitle_style))
    elements.append(Spacer(1, 2*cm))

    # Info box
    info_data = [
        ['Sayt:', 'www.garabag-bau.de'],
        ['Yer:', 'Munster, Almaniya'],
        ['Sahib:', 'Vugar Azizov'],
        ['Sahesi:', 'Tikinti / Bauunternehmung'],
    ]
    info_table = Table(info_data, colWidths=[4*cm, 10*cm])
    info_table.setStyle(TableStyle([
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTNAME', (1, 0), (1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 0), (-1, -1), 10),
        ('TEXTCOLOR', (0, 0), (0, -1), colors.HexColor('#16213e')),
        ('TEXTCOLOR', (1, 0), (1, -1), colors.HexColor('#333333')),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor('#f8f9fa')),
        ('BOX', (0, 0), (-1, -1), 1, colors.HexColor('#dee2e6')),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#dee2e6')),
    ]))
    elements.append(info_table)

    # PAGE BREAK
    from reportlab.platypus import PageBreak
    elements.append(PageBreak())

    # ==========================================
    # SECTION 1: GARABAG-BAU ESAS MELUMATLAR
    # ==========================================
    elements.append(Paragraph("1. GARABAG-BAU - ESAS MELUMATLAR", section_style))
    elements.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor('#e94560'), spaceAfter=10))

    elements.append(Paragraph("1.1 Huquqi Melumatlar (Impressum)", subsection_style))

    legal_data = [
        ['Sirketin Tam Adi:', 'Bauunternehmung GARABAG-Bau'],
        ['Sahibi / Direktor:', 'Vugar Azizov'],
        ['Unvan:', 'Eichendorffstr. 3, 48167 Munster, Almaniya'],
        ['Telefon:', '+49 172 600 9105'],
        ['E-poct:', 'info@garabag-bau.de'],
        ['Vergi Nomresi (USt-IdNr):', '12024368757'],
        ['Senedkarliq Nomresi:', '41987065'],
        ['Qeydiyyat Orqani:', 'Handwerkskammer (Senedkarliq Palatasi)'],
        ['Redaksiya Mesuliyyeti:', 'Azizova Shafag'],
        ['Munaqise Hell:', 'Isterakci munaqise helli prosedurlarinda istirak etmir'],
    ]
    legal_table = Table(legal_data, colWidths=[5.5*cm, 10*cm])
    legal_table.setStyle(TableStyle([
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTNAME', (1, 0), (1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('TEXTCOLOR', (0, 0), (0, -1), colors.HexColor('#16213e')),
        ('TEXTCOLOR', (1, 0), (1, -1), colors.HexColor('#333333')),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BACKGROUND', (0, 0), (0, -1), colors.HexColor('#f0f4f8')),
        ('BACKGROUND', (1, 0), (1, -1), colors.white),
        ('BOX', (0, 0), (-1, -1), 1, colors.HexColor('#c5cdd5')),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#dee2e6')),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
    ]))
    elements.append(legal_table)
    elements.append(Spacer(1, 0.5*cm))

    # 1.2 Sirket Haqqinda
    elements.append(Paragraph("1.2 Sirket Haqqinda", subsection_style))
    elements.append(Paragraph(
        "GARABAG-Bau, Almaniya'nin Munster seherinde yerlesen professional tikinti sirketi (Bauunternehmung) olaraq "
        "fealiyyet gosterir. Sirket ozunu tikinti sektorunda liderliyini vurgulayir ve musterilerine innovativ, "
        "yuksek keyfiyyetli heller teqdim etmeyi esas meqsed kimi qoyur.",
        body_style
    ))
    elements.append(Paragraph(
        "Sirket 7 nefer mutexessisden ibaret komanda ile isleyir. Esas deyerler arasinda kompetensiya, "
        "etibarlilik ve musteri memnuniyyeti dayanir. Sirket qurulan gunden bu prinsiplere sadiq qalib.",
        body_style
    ))
    elements.append(Paragraph(
        "Missiyasi: Musterilerin vizyonlarini reallastirmaq - tikinti layihelerinde ehtirasli ve pesekar "
        "yanasma ile.",
        body_style
    ))

    # 1.3 Xidmetler
    elements.append(Paragraph("1.3 Teqdim Olunan Xidmetler", subsection_style))

    services = [
        ("Mauer-Betonbau (Horgu ve Beton Isler)",
         "Yasayis ve kommersiya layiheleri ucun individual heller. "
         "Horgu ve beton emeliyyatlari musterinin texniki teleblerine uygun icra olunur."),

        ("Altbausanierung (Kohne Bina Berpa / Renovasiya)",
         "Kohne binalarin berpasi ve modernlesdirilmesi. Pesekar yanasma ile kohne tikililerin "
         "yeniden heyata qaytarilmasi."),

        ("Anbau und Abbruch (Genislendirme ve Sokulme)",
         "Binalarin genislendirilmesi ve ya tehlukesiz sokulme emeliyyatlari. "
         "Movcud strukturlarin boyudulmesi ve ya nezaretli dagilma."),

        ("Schalung und Eisenbewehrungsarbeit (Qelib ve Demirle Moglendirme)",
         "Muxtelf tikinti layihelerinde deqiq ve etibarlii qelib sistemleri ve "
         "mohlendirici polad emeliyyatlari.")
    ]

    for svc_name, svc_desc in services:
        elements.append(Paragraph(f"<b>{svc_name}</b>", bullet_style))
        elements.append(Paragraph(svc_desc, info_style))
        elements.append(Spacer(1, 2*mm))

    # 1.4 Elaqe ve Raqemsal Istirak
    elements.append(Paragraph("1.4 Elaqe ve Raqemsal Istirak", subsection_style))

    digital_data = [
        ['Veb-sayt:', 'www.garabag-bau.de'],
        ['E-poct:', 'info@garabag-bau.de'],
        ['Telefon:', '+49 172 600 9105'],
        ['WhatsApp:', '+49 172 600 9105'],
        ['Instagram:', '@garabag_bau'],
        ['Google Maps:', '51.914348, 7.690807 (Munster)'],
    ]
    digital_table = Table(digital_data, colWidths=[4*cm, 10*cm])
    digital_table.setStyle(TableStyle([
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTNAME', (1, 0), (1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 4),
        ('TOPPADDING', (0, 0), (-1, -1), 4),
        ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor('#f8f9fa')),
        ('BOX', (0, 0), (-1, -1), 0.5, colors.HexColor('#dee2e6')),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#dee2e6')),
    ]))
    elements.append(digital_table)

    elements.append(PageBreak())

    # ==========================================
    # SECTION 2: INNO-BAHNBAU
    # ==========================================
    elements.append(Paragraph("2. INNO-BAHNBAU (INNOVATIVE BAHNBAU)", section_style))
    elements.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor('#e94560'), spaceAfter=10))

    elements.append(Paragraph("2.1 Umumi Melumat", subsection_style))

    inno_data = [
        ['Sirket Adi:', 'Innovative Bahnbau'],
        ['Veb-sayt:', 'www.inno-bahnbau.de'],
        ['Fealiyyet Sahesi:', 'Gleisbau & Instandhaltung (Demir yolu tikintisi ve texniki xidmet)'],
        ['Olke:', 'Almaniya'],
    ]
    inno_table = Table(inno_data, colWidths=[4.5*cm, 10*cm])
    inno_table.setStyle(TableStyle([
        ('FONTNAME', (0, 0), (0, -1), 'Helvetica-Bold'),
        ('FONTNAME', (1, 0), (1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 0), (-1, -1), 9),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 5),
        ('TOPPADDING', (0, 0), (-1, -1), 5),
        ('BACKGROUND', (0, 0), (0, -1), colors.HexColor('#f0f4f8')),
        ('BACKGROUND', (1, 0), (1, -1), colors.white),
        ('BOX', (0, 0), (-1, -1), 1, colors.HexColor('#c5cdd5')),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#dee2e6')),
    ]))
    elements.append(inno_table)
    elements.append(Spacer(1, 0.5*cm))

    elements.append(Paragraph("2.2 Xidmetler", subsection_style))
    elements.append(Paragraph(
        "<b>Gleisbau (Rels/Yol Tikintisi):</b> Demir yolu relsleri ve elaqeli infrastrukturun tikilmesi ve qurasdirilmasi.",
        bullet_style
    ))
    elements.append(Paragraph(
        "<b>Instandhaltung (Texniki Xidmet):</b> Movcud demir yolu sistemlerinin texniki xidmeti, "
        "temir ve baximini ehate edir.",
        bullet_style
    ))
    elements.append(Spacer(1, 0.3*cm))

    elements.append(Paragraph("2.3 Sayt Analizi", subsection_style))
    elements.append(Paragraph(
        "Inno-bahnbau.de sayti hazirda minimal mezmunla isleyir. Saytda yalniz sirketin adi ve esas "
        "fealiyyet istiqameti gosterilir. Impressum, elaqe sehifesi, detalli xidmet tesviri, komanda "
        "melumatlari ve digder standart biznes sayt bolmeleri ya movcud deyil, ya da JavaScript render-e "
        "esaslanir ve static crawler-ler terefinden oxuna bilmir.",
        body_style
    ))
    elements.append(Paragraph(
        "Tovsiyeler: Saytin SEO optimizasiyasi, Impressum elavesi, detalli xidmet sehifeleri, "
        "elaqe formu ve referans layiheler bolmesi elave edilmelidir.",
        body_style
    ))

    elements.append(PageBreak())

    # ==========================================
    # SECTION 3: MUQAYISE
    # ==========================================
    elements.append(Paragraph("3. MUQAYISELI ANALIZ", section_style))
    elements.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor('#e94560'), spaceAfter=10))

    comp_data = [
        ['Kriteriya', 'GARABAG-Bau', 'Inno-Bahnbau'],
        ['Fealiyyet sahesi', 'Umumi tikinti\n(Hochbau)', 'Demir yolu tikintisi\n(Gleisbau)'],
        ['Yer', 'Munster, Almaniya', 'Almaniya (deqiq yer yoxdur)'],
        ['Veb-sayt keyfiyyeti', 'Yaxsi (tam mezmun)', 'Zeyif (minimal mezmun)'],
        ['Impressum', 'Var (tam)', 'Yoxdur / Tapilmadi'],
        ['Xidmet sayi', '4 esas xidmet', '2 esas xidmet'],
        ['Sosial media', 'Instagram aktiv', 'Tapilmadi'],
        ['Komanda', '7 mutexessis', 'Melumat yoxdur'],
        ['Elaqe kanallari', 'Telefon, Email,\nWhatsApp, Instagram', 'Melumat yoxdur'],
    ]

    comp_table = Table(comp_data, colWidths=[4.5*cm, 5.5*cm, 5.5*cm])
    comp_table.setStyle(TableStyle([
        # Header row
        ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
        ('FONTSIZE', (0, 0), (-1, 0), 10),
        ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#16213e')),
        ('TEXTCOLOR', (0, 0), (-1, 0), colors.white),
        ('ALIGN', (0, 0), (-1, 0), 'CENTER'),

        # Body
        ('FONTNAME', (0, 1), (-1, -1), 'Helvetica'),
        ('FONTSIZE', (0, 1), (-1, -1), 9),
        ('TEXTCOLOR', (0, 1), (-1, -1), colors.HexColor('#333333')),

        # First column bold
        ('FONTNAME', (0, 1), (0, -1), 'Helvetica-Bold'),

        # Alternating row colors
        ('BACKGROUND', (0, 1), (-1, 1), colors.HexColor('#f8f9fa')),
        ('BACKGROUND', (0, 2), (-1, 2), colors.white),
        ('BACKGROUND', (0, 3), (-1, 3), colors.HexColor('#f8f9fa')),
        ('BACKGROUND', (0, 4), (-1, 4), colors.white),
        ('BACKGROUND', (0, 5), (-1, 5), colors.HexColor('#f8f9fa')),
        ('BACKGROUND', (0, 6), (-1, 6), colors.white),
        ('BACKGROUND', (0, 7), (-1, 7), colors.HexColor('#f8f9fa')),
        ('BACKGROUND', (0, 8), (-1, 8), colors.white),

        # Grid
        ('BOX', (0, 0), (-1, -1), 1, colors.HexColor('#c5cdd5')),
        ('INNERGRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#dee2e6')),
        ('VALIGN', (0, 0), (-1, -1), 'MIDDLE'),
        ('BOTTOMPADDING', (0, 0), (-1, -1), 6),
        ('TOPPADDING', (0, 0), (-1, -1), 6),
        ('LEFTPADDING', (0, 0), (-1, -1), 8),
    ]))
    elements.append(comp_table)

    elements.append(Spacer(1, 1*cm))

    # ==========================================
    # SECTION 4: NETICE VE TOVSIYELER
    # ==========================================
    elements.append(Paragraph("4. NETICE VE TOVSIYELER", section_style))
    elements.append(HRFlowable(width="100%", thickness=1, color=colors.HexColor('#e94560'), spaceAfter=10))

    elements.append(Paragraph("<b>GARABAG-Bau:</b>", subsection_style))
    elements.append(Paragraph(
        "- Professional ve tam funksional veb-sayti var",
        bullet_style
    ))
    elements.append(Paragraph(
        "- Huquqi melumatlar (Impressum) tam aciqdir - Handwerkskammer qeydiyyatli",
        bullet_style
    ))
    elements.append(Paragraph(
        "- 4 esas tikinti xidmeti teqdim edir",
        bullet_style
    ))
    elements.append(Paragraph(
        "- Munsterde 7 neferlik mutexessis komanda",
        bullet_style
    ))
    elements.append(Paragraph(
        "- Coxkanalli elaqe (telefon, email, WhatsApp, Instagram)",
        bullet_style
    ))
    elements.append(Spacer(1, 0.3*cm))

    elements.append(Paragraph("<b>Inno-Bahnbau:</b>", subsection_style))
    elements.append(Paragraph(
        "- Sayt minimal mezmunla isleyir, tek sirket adi ve 2 xidmet basligi gorunur",
        bullet_style
    ))
    elements.append(Paragraph(
        "- Impressum, elaqe melumati ve diger standart bolmeler tapilmadi",
        bullet_style
    ))
    elements.append(Paragraph(
        "- Demir yolu tikintisi (Gleisbau) ve texniki xidmet (Instandhaltung) sahesinde ixtisaslasib",
        bullet_style
    ))
    elements.append(Paragraph(
        "- Sayt ya hazirlanma merhelesindedir, ya da SPA (single-page app) arxitekturasindadir",
        bullet_style
    ))
    elements.append(Spacer(1, 0.5*cm))

    elements.append(Paragraph("<b>Umumi Tovsiye:</b>", subsection_style))
    elements.append(Paragraph(
        "Her iki sirket tikinti sektorunda fealiyyet gosterir, lakin ferqli sub-sektor larda: "
        "GARABAG-Bau umumi tikinti (Hochbau), Inno-Bahnbau ise demir yolu tikintisi (Gleisbau). "
        "Qarabaghbau layihesi ucun her iki sirketin tecrubesi ve xidmetleri nezere alinmalidir.",
        body_style
    ))

    # Footer line
    elements.append(Spacer(1, 2*cm))
    elements.append(HRFlowable(width="100%", thickness=0.5, color=colors.HexColor('#cccccc'), spaceAfter=5))

    footer_style = ParagraphStyle(
        'Footer',
        parent=styles['Normal'],
        fontSize=8,
        textColor=colors.HexColor('#999999'),
        alignment=TA_CENTER,
    )
    elements.append(Paragraph(
        "Bu hesabat avtomatik olaraq web scraping vasitesile toplanmis melumatlara esaslanir. | Fevral 2026",
        footer_style
    ))

    # Build PDF
    doc.build(elements)
    print("PDF ugurla yaradildi: Garabag_Bau_Analysis.pdf")

if __name__ == "__main__":
    create_pdf()
