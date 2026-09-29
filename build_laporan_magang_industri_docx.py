import os
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import parse_xml
from docx.oxml.ns import nsdecls

def create_laporan_magang_sv_unpak():
    doc = docx.Document()

    # Standard Margins for University Theses/Reports: Left 4cm (1.57"), Top 3cm (1.18"), Right 3cm (1.18"), Bottom 3cm (1.18")
    for section in doc.sections:
        section.top_margin = Inches(1.18)
        section.bottom_margin = Inches(1.18)
        section.left_margin = Inches(1.35)
        section.right_margin = Inches(1.18)

    FONT_FAMILY = "Times New Roman"

    def set_cell_background(cell, hex_color):
        tcPr = cell._tc.get_or_add_tcPr()
        shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{hex_color}"/>')
        tcPr.append(shd)

    def set_cell_margins(cell, top=80, bottom=80, left=100, right=100):
        tcPr = cell._tc.get_or_add_tcPr()
        tcMar = parse_xml(f'<w:tcMar {nsdecls("w")}><w:top w:w="{top}" w:type="dxa"/><w:bottom w:w="{bottom}" w:type="dxa"/><w:left w:w="{left}" w:type="dxa"/><w:right w:w="{right}" w:type="dxa"/></w:tcMar>')
        tcPr.append(tcMar)

    def add_p(text, bold_prefix=None, space_after=6, align=WD_ALIGN_PARAGRAPH.JUSTIFY, italic=False, size=12):
        p = doc.add_paragraph()
        p.alignment = align
        p.paragraph_format.space_after = Pt(space_after)
        p.paragraph_format.line_spacing = 1.5
        if bold_prefix is True:
            run = p.add_run(text)
            run.font.name = FONT_FAMILY
            run.font.size = Pt(size)
            run.font.bold = True
            run.font.italic = italic
            run.font.color.rgb = RGBColor(0, 0, 0)
            return p
        elif isinstance(bold_prefix, str):
            r_pre = p.add_run(bold_prefix)
            r_pre.font.name = FONT_FAMILY
            r_pre.font.size = Pt(size)
            r_pre.font.bold = True
            r_pre.font.color.rgb = RGBColor(0, 0, 0)
        run = p.add_run(text)
        run.font.name = FONT_FAMILY
        run.font.size = Pt(size)
        run.font.italic = italic
        run.font.color.rgb = RGBColor(0, 0, 0)
        return p

    def add_bullet(text, bold_prefix=None, size=12):
        p = doc.add_paragraph(style='List Bullet')
        p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        p.paragraph_format.space_after = Pt(4)
        p.paragraph_format.line_spacing = 1.5
        if bold_prefix:
            r_pre = p.add_run(bold_prefix)
            r_pre.font.name = FONT_FAMILY
            r_pre.font.size = Pt(size)
            r_pre.font.bold = True
            r_pre.font.color.rgb = RGBColor(0, 0, 0)
        run = p.add_run(text)
        run.font.name = FONT_FAMILY
        run.font.size = Pt(size)
        run.font.color.rgb = RGBColor(0, 0, 0)
        return p

    def add_chapter_title(bab_text, title_text):
        p1 = doc.add_paragraph()
        p1.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p1.paragraph_format.space_before = Pt(18)
        p1.paragraph_format.space_after = Pt(4)
        r1 = p1.add_run(bab_text)
        r1.font.name = FONT_FAMILY
        r1.font.size = Pt(14)
        r1.font.bold = True

        p2 = doc.add_paragraph()
        p2.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p2.paragraph_format.space_after = Pt(18)
        r2 = p2.add_run(title_text)
        r2.font.name = FONT_FAMILY
        r2.font.size = Pt(14)
        r2.font.bold = True

    def add_subheading(text, space_before=12, space_after=4):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(space_before)
        p.paragraph_format.space_after = Pt(space_after)
        p.paragraph_format.keep_with_next = True
        run = p.add_run(text)
        run.font.name = FONT_FAMILY
        run.font.size = Pt(12)
        run.font.bold = True

    # ==========================
    # 1. HALAMAN JUDUL (COVER)
    # ==========================
    p_cov_hdr = doc.add_paragraph()
    p_cov_hdr.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_cov_hdr.paragraph_format.space_before = Pt(10)
    p_cov_hdr.paragraph_format.space_after = Pt(24)
    r_ch = p_cov_hdr.add_run("LAPORAN PRAKTEK KERJA MAGANG INDUSTRI")
    r_ch.font.name = FONT_FAMILY
    r_ch.font.size = Pt(14)
    r_ch.font.bold = True

    p_cov_title = doc.add_paragraph()
    p_cov_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_cov_title.paragraph_format.space_after = Pt(12)
    r_ct = p_cov_title.add_run("RANCANG BANGUN SISTEM MONITORING OPERASIONAL ARMADA DAN MANAJEMEN AKSES SMART LOCKER BERBASIS IOT DAN FLUTTER")
    r_ct.font.name = FONT_FAMILY
    r_ct.font.size = Pt(14)
    r_ct.font.bold = True

    p_cov_case = doc.add_paragraph()
    p_cov_case.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_cov_case.paragraph_format.space_after = Pt(40)
    r_cc = p_cov_case.add_run("(Studi kasus: PT. Telkom Akses Bogor)")
    r_cc.font.name = FONT_FAMILY
    r_cc.font.size = Pt(13)
    r_cc.font.bold = True

    p_cov_by = doc.add_paragraph()
    p_cov_by.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_cov_by.paragraph_format.space_after = Pt(4)
    r_cb = p_cov_by.add_run("oleh:")
    r_cb.font.name = FONT_FAMILY
    r_cb.font.size = Pt(12)

    p_cov_name = doc.add_paragraph()
    p_cov_name.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_cov_name.paragraph_format.space_after = Pt(2)
    r_cn = p_cov_name.add_run("Rahman Eka Ardiansyah")
    r_cn.font.name = FONT_FAMILY
    r_cn.font.size = Pt(13)
    r_cn.font.bold = True

    p_cov_npm = doc.add_paragraph()
    p_cov_npm.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_cov_npm.paragraph_format.space_after = Pt(120)
    r_cp = p_cov_npm.add_run("084023019")
    r_cp.font.name = FONT_FAMILY
    r_cp.font.size = Pt(13)
    r_cp.font.bold = True

    p_cov_foot = doc.add_paragraph()
    p_cov_foot.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_cov_foot.paragraph_format.space_after = Pt(2)
    r_cf1 = p_cov_foot.add_run("PROGRAM STUDI TEKNIK KOMPUTER\nSEKOLAH VOKASI\nUNIVERSITAS PAKUAN\nBOGOR\n2026")
    r_cf1.font.name = FONT_FAMILY
    r_cf1.font.size = Pt(13)
    r_cf1.font.bold = True

    doc.add_page_break()

    # ==========================
    # 2. HALAMAN PENGESAHAN
    # ==========================
    p_sah_title = doc.add_paragraph()
    p_sah_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_sah_title.paragraph_format.space_before = Pt(10)
    p_sah_title.paragraph_format.space_after = Pt(24)
    r_st = p_sah_title.add_run("HALAMAN PENGESAHAN")
    r_st.font.name = FONT_FAMILY
    r_st.font.size = Pt(14)
    r_st.font.bold = True

    t_sah_meta = doc.add_table(rows=3, cols=3)
    t_sah_meta.alignment = WD_TABLE_ALIGNMENT.CENTER
    sah_meta = [
        ("Judul", ":", "Rancang Bangun Sistem Monitoring Operasional Armada dan Manajemen Akses Smart Locker Berbasis IoT dan Flutter"),
        ("Nama", ":", "Rahman Eka Ardiansyah"),
        ("NPM", ":", "084023019")
    ]
    for idx, (f1, f2, f3) in enumerate(sah_meta):
        row = t_sah_meta.rows[idx]
        c1, c2, c3 = row.cells[0], row.cells[1], row.cells[2]
        c1.width = Inches(1.2)
        c2.width = Inches(0.3)
        c3.width = Inches(4.5)
        for c in [c1, c2, c3]:
            set_cell_margins(c, 40, 40, 40, 40)
        p = c1.paragraphs[0]; p.paragraph_format.space_after = Pt(4); r = p.add_run(f1); r.font.name = FONT_FAMILY; r.font.bold = True
        p = c2.paragraphs[0]; p.paragraph_format.space_after = Pt(4); r = p.add_run(f2); r.font.name = FONT_FAMILY; r.font.bold = True
        p = c3.paragraphs[0]; p.paragraph_format.space_after = Pt(4); r = p.add_run(f3); r.font.name = FONT_FAMILY; r.font.bold = (idx > 0)

    p_msh = doc.add_paragraph()
    p_msh.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_msh.paragraph_format.space_before = Pt(36)
    p_msh.paragraph_format.space_after = Pt(20)
    r_msh = p_msh.add_run("Mengesahkan,")
    r_msh.font.name = FONT_FAMILY
    r_msh.font.size = Pt(12)

    t_ttd = doc.add_table(rows=2, cols=2)
    t_ttd.alignment = WD_TABLE_ALIGNMENT.CENTER
    # Header pembimbing
    r0 = t_ttd.rows[0]
    p_p2 = r0.cells[0].paragraphs[0]; p_p2.alignment = WD_ALIGN_PARAGRAPH.CENTER; p_p2.paragraph_format.space_after = Pt(60)
    r = p_p2.add_run("Pembimbing II,\nPT Telkom Akses Bogor"); r.font.name = FONT_FAMILY; r.font.size = Pt(12)
    
    p_p1 = r0.cells[1].paragraphs[0]; p_p1.alignment = WD_ALIGN_PARAGRAPH.CENTER; p_p1.paragraph_format.space_after = Pt(60)
    r = p_p1.add_run("Pembimbing I,\nSekolah Vokasi\nUniversitas Pakuan"); r.font.name = FONT_FAMILY; r.font.size = Pt(12)

    # Nama pembimbing
    r1 = t_ttd.rows[1]
    p_np2 = r1.cells[0].paragraphs[0]; p_np2.alignment = WD_ALIGN_PARAGRAPH.CENTER; p_np2.paragraph_format.space_after = Pt(0)
    r = p_np2.add_run("Pahreza Fajri Sulaeman"); r.font.name = FONT_FAMILY; r.font.size = Pt(12); r.font.bold = True

    p_np1 = r1.cells[1].paragraphs[0]; p_np1.alignment = WD_ALIGN_PARAGRAPH.CENTER; p_np1.paragraph_format.space_after = Pt(0)
    r = p_np1.add_run("Deden Ardiansyah, M.Kom."); r.font.name = FONT_FAMILY; r.font.size = Pt(12); r.font.bold = True

    # Mengetahui Kaprodi
    p_kpr_lbl = doc.add_paragraph()
    p_kpr_lbl.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_kpr_lbl.paragraph_format.space_before = Pt(40)
    p_kpr_lbl.paragraph_format.space_after = Pt(60)
    r = p_kpr_lbl.add_run("Mengetahui,\nKetua Program Studi Teknik Komputer\nSekolah Vokasi Universitas Pakuan"); r.font.name = FONT_FAMILY; r.font.size = Pt(12)

    p_kpr_nm = doc.add_paragraph()
    p_kpr_nm.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_kpr_nm.paragraph_format.space_after = Pt(40)
    r = p_kpr_nm.add_run("Akbar Sugih Miftahul Huda, M.Kom."); r.font.name = FONT_FAMILY; r.font.size = Pt(12); r.font.bold = True

    p_sah_pg = doc.add_paragraph()
    p_sah_pg.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r = p_sah_pg.add_run("i"); r.font.name = FONT_FAMILY; r.font.size = Pt(11)

    doc.add_page_break()

    # ==========================
    # 3. HALAMAN PENGESAHAN REVISI
    # ==========================
    p_rev_title = doc.add_paragraph()
    p_rev_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_rev_title.paragraph_format.space_before = Pt(10)
    p_rev_title.paragraph_format.space_after = Pt(4)
    r = p_rev_title.add_run("HALAMAN PENGESAHAN\nKONFIRMASI REVISI")
    r.font.name = FONT_FAMILY; r.font.size = Pt(14); r.font.bold = True

    t_rev_meta = doc.add_table(rows=3, cols=3)
    t_rev_meta.alignment = WD_TABLE_ALIGNMENT.CENTER
    for idx, (f1, f2, f3) in enumerate(sah_meta):
        row = t_rev_meta.rows[idx]
        c1, c2, c3 = row.cells[0], row.cells[1], row.cells[2]
        c1.width = Inches(1.2); c2.width = Inches(0.3); c3.width = Inches(4.5)
        for c in [c1, c2, c3]: set_cell_margins(c, 40, 40, 40, 40)
        p = c1.paragraphs[0]; p.paragraph_format.space_after = Pt(4); r = p.add_run(f1); r.font.name = FONT_FAMILY; r.font.bold = True
        p = c2.paragraphs[0]; p.paragraph_format.space_after = Pt(4); r = p.add_run(f2); r.font.name = FONT_FAMILY; r.font.bold = True
        p = c3.paragraphs[0]; p.paragraph_format.space_after = Pt(4); r = p.add_run(f3); r.font.name = FONT_FAMILY; r.font.bold = (idx > 0)

    p_rmsh = doc.add_paragraph()
    p_rmsh.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_rmsh.paragraph_format.space_before = Pt(50)
    p_rmsh.paragraph_format.space_after = Pt(30)
    r = p_rmsh.add_run("Mengesahkan,"); r.font.name = FONT_FAMILY; r.font.size = Pt(12)

    t_uji = doc.add_table(rows=2, cols=2)
    t_uji.alignment = WD_TABLE_ALIGNMENT.CENTER
    p_u2 = t_uji.rows[0].cells[0].paragraphs[0]; p_u2.alignment = WD_ALIGN_PARAGRAPH.CENTER; p_u2.paragraph_format.space_after = Pt(70)
    r = p_u2.add_run("Penguji II,\nSekolah Vokasi\nUniversitas Pakuan"); r.font.name = FONT_FAMILY; r.font.size = Pt(12)

    p_u1 = t_uji.rows[0].cells[1].paragraphs[0]; p_u1.alignment = WD_ALIGN_PARAGRAPH.CENTER; p_u1.paragraph_format.space_after = Pt(70)
    r = p_u1.add_run("Penguji I,\nSekolah Vokasi\nUniversitas Pakuan"); r.font.name = FONT_FAMILY; r.font.size = Pt(12)

    p_nu2 = t_uji.rows[1].cells[0].paragraphs[0]; p_nu2.alignment = WD_ALIGN_PARAGRAPH.CENTER; p_nu2.paragraph_format.space_after = Pt(0)
    r = p_nu2.add_run("Deden Ardiansyah, M.Kom."); r.font.name = FONT_FAMILY; r.font.size = Pt(12); r.font.bold = True

    p_nu1 = t_uji.rows[1].cells[1].paragraphs[0]; p_nu1.alignment = WD_ALIGN_PARAGRAPH.CENTER; p_nu1.paragraph_format.space_after = Pt(0)
    r = p_nu1.add_run("Sufiatul Maryana, M.Kom."); r.font.name = FONT_FAMILY; r.font.size = Pt(12); r.font.bold = True

    p_rev_pg = doc.add_paragraph()
    p_rev_pg.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_rev_pg.paragraph_format.space_before = Pt(80)
    r = p_rev_pg.add_run("ii"); r.font.name = FONT_FAMILY; r.font.size = Pt(11)

    doc.add_page_break()

    # ==========================
    # 4. KATA PENGANTAR
    # ==========================
    p_kp_title = doc.add_paragraph()
    p_kp_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_kp_title.paragraph_format.space_before = Pt(10)
    p_kp_title.paragraph_format.space_after = Pt(18)
    r = p_kp_title.add_run("KATA PENGANTAR"); r.font.name = FONT_FAMILY; r.font.size = Pt(14); r.font.bold = True

    add_p("Puji syukur saya panjatkan kepada Tuhan Yang Maha Esa, karena atas berkat dan rahmat-Nya, sehingga dapat menyelesaikan laporan Praktek Kerja Magang Industri (PKMI) ini. Menyadari bahwa, tanpa bantuan dan bimbingan dari berbagai pihak, dari masa perkuliahan sampai pada penyusunan laporan ini, sangatlah sulit untuk menyelesaikan laporan Magang ini. Oleh karena itu, di ucapkan terima kasih kepada:")
    
    ucapan = [
        "Deden Ardiansyah, M.Kom. selaku dosen pembimbing yang telah menyediakan waktu, tenaga, dan pikiran untuk mengarahkan penulis dalam penyusunan laporan ini;",
        "Pahreza Fajri Sulaeman selaku pembimbing lapangan di PT Telkom Akses Bogor yang telah membantu dan membimbing dalam pengenalan dunia kerja dan dalam penyusunan laporan magang;",
        "Dr. Lia Dahlia Iryani, S.E., M.Si., selaku Dekan Sekolah Vokasi Universitas Pakuan;",
        "Akbar Sugih Miftahul Huda, M.Kom. selaku Ketua Program Studi Teknik Komputer Sekolah Vokasi Universitas Pakuan;",
        "Seluruh pihak PT Telkom Akses Bogor yang telah membantu dalam praktik kerja lapangan serta usaha untuk memperoleh data yang penulis butuhkan;",
        "Orang tua dan keluarga penulis yang telah memberikan dukungan moral dan material dalam penyusunan laporan magang penulis;",
        "Sahabat–sahabat penulis yang memberikan dukungan moral dalam penyusunan laporan magang ini;"
    ]
    for i, u in enumerate(ucapan, 1):
        add_p(u, bold_prefix=f"{i}. ")

    add_p("Akhir kata, harapan semoga Tuhan Yang Maha Esa berkenan membalas segala kebaikan semua pihak yang telah membantu. Semoga Laporan Magang ini membawa manfaat bagi pengembangan ilmu.")

    p_tgl = doc.add_paragraph()
    p_tgl.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    p_tgl.paragraph_format.space_before = Pt(20)
    p_tgl.paragraph_format.space_after = Pt(50)
    r = p_tgl.add_run("Bogor, 9 Januari 2026"); r.font.name = FONT_FAMILY; r.font.size = Pt(12)

    p_ttd_nama = doc.add_paragraph()
    p_ttd_nama.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    r = p_ttd_nama.add_run("Rahman Eka Ardiansyah"); r.font.name = FONT_FAMILY; r.font.size = Pt(12); r.font.bold = True

    p_kp_pg = doc.add_paragraph()
    p_kp_pg.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_kp_pg.paragraph_format.space_before = Pt(20)
    r = p_kp_pg.add_run("iii"); r.font.name = FONT_FAMILY; r.font.size = Pt(11)

    doc.add_page_break()

    # ==========================
    # 5. DAFTAR ISI
    # ==========================
    p_di_title = doc.add_paragraph()
    p_di_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_di_title.paragraph_format.space_before = Pt(10)
    p_di_title.paragraph_format.space_after = Pt(18)
    r = p_di_title.add_run("DAFTAR ISI"); r.font.name = FONT_FAMILY; r.font.size = Pt(14); r.font.bold = True

    daftar_isi_items = [
        ("HALAMAN PENGESAHAN", "i", True),
        ("HALAMAN PENGESAHAN KONFIRMASI REVISI", "ii", True),
        ("KATA PENGANTAR", "iii", True),
        ("DAFTAR ISI", "iv", True),
        ("DAFTAR GAMBAR", "vi", True),
        ("DAFTAR TABEL", "vii", True),
        ("DAFTAR LAMPIRAN", "viii", True),
        ("BAB I PENDAHULUAN", "1", True),
        ("   1.1. Latar Belakang", "1", False),
        ("   1.2. Tujuan Praktek Kerja Magang Industri", "2", False),
        ("   1.3. Ruang Lingkup Praktek Kerja Magang Industri", "2", False),
        ("   1.4 Manfaat", "3", False),
        ("BAB II TINJAUAN INSTANSI DAN PUSTAKA", "4", True),
        ("   2.1 Tinjauan Instansi", "4", False),
        ("      2.1.1 Sejarah Instansi", "4", False),
        ("      2.1.2 Visi Misi Instansi", "5", False),
        ("      2.1.3 Struktur Organisasi Instansi", "5", False),
        ("      2.1.4 Dokumentasi PKMI", "6", False),
        ("   2.2 Tinjauan Pustaka", "6", False),
        ("      2.2.1 Smart Locker & Sistem Solenoid Door Lock", "6", False),
        ("      2.2.2 Mikrokontroler ESP32 & I/O Expansion Shield", "7", False),
        ("      2.2.3 Relay 5V 2 Channel & Dioda Flyback 1N4007", "7", False),
        ("      2.2.4 Uninterruptible Power Supply (UPS) TechBee 5V+12V", "7", False),
        ("      2.2.5 Framework Flutter & Bahasa Pemrograman Dart", "7", False),
        ("      2.2.6 Backend Cloud Supabase (PostgreSQL & Realtime)", "7", False),
        ("      2.2.7 Pemantauan GPS, Geofence, & Live Telemetri", "8", False),
        ("   2.3 Waktu Pelaksanaan PKMI", "8", False),
        ("   2.4 Penelitian Terdahulu", "8", False),
        ("   2.5 Tabel Perbandingan", "9", False),
        ("BAB III METODE PELAKSANAAN", "10", True),
        ("   3.1 Metode Penelitian (SDLC)", "10", False),
        ("      3.1.1 Planning", "10", False),
        ("      3.1.2 Analisis", "11", False),
        ("         3.1.2.1 Analisis Data", "11", False),
        ("         3.1.2.2 Analisis Kebutuhan", "12", False),
        ("         3.1.2.3 Analisis Sistem", "12", False),
        ("      3.1.3 Design", "17", False),
        ("         3.1.3.1 Perancangan Sistem Secara Umum", "17", False),
        ("         3.1.3.2 Perancangan Basis Data", "19", False),
        ("         3.1.3.3 Perancangan User Interface", "21", False),
        ("      3.1.4 Implementasi", "22", False),
        ("      3.1.5 Testing", "24", False),
        ("      3.1.6 Maintenance", "24", False),
        ("   3.2 Tahap atau Metode Pelaksanaan", "24", False),
        ("   3.3 Waktu dan Tempat Pelaksanaan", "24", False),
        ("BAB IV HASIL DAN PEMBAHASAN", "25", True),
        ("   4.1 Hasil", "25", False),
        ("   4.2 Pembahasan", "29", False),
        ("      4.2.1 Uji Coba Struktural", "29", False),
        ("      4.2.2 Uji Coba Fungsional", "33", False),
        ("      4.2.3 Uji Coba Validasi", "38", False),
        ("BAB V PENUTUP", "40", True),
        ("   5.1 Kesimpulan", "40", False),
        ("   5.2 Saran", "40", False),
        ("DAFTAR PUSTAKA", "41", True),
        ("LAMPIRAN", "42", True)
    ]

    t_di = doc.add_table(rows=len(daftar_isi_items), cols=2)
    t_di.alignment = WD_TABLE_ALIGNMENT.CENTER
    for idx, (title, page, is_bold) in enumerate(daftar_isi_items):
        r = t_di.rows[idx]
        c1, c2 = r.cells[0], r.cells[1]
        c1.width = Inches(5.3); c2.width = Inches(0.8)
        p1 = c1.paragraphs[0]; p1.paragraph_format.space_after = Pt(2)
        r1 = p1.add_run(title); r1.font.name = FONT_FAMILY; r1.font.size = Pt(11); r1.font.bold = is_bold
        p2 = c2.paragraphs[0]; p2.alignment = WD_ALIGN_PARAGRAPH.RIGHT; p2.paragraph_format.space_after = Pt(2)
        r2 = p2.add_run(page); r2.font.name = FONT_FAMILY; r2.font.size = Pt(11); r2.font.bold = is_bold

    p_di_pg = doc.add_paragraph()
    p_di_pg.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_di_pg.paragraph_format.space_before = Pt(16)
    r = p_di_pg.add_run("iv"); r.font.name = FONT_FAMILY; r.font.size = Pt(11)

    doc.add_page_break()

    # ==========================
    # BAB I: PENDAHULUAN
    # ==========================
    add_chapter_title("BAB I", "PENDAHULUAN")
    
    add_subheading("1.1. Latar Belakang")
    add_p("Pencatatan dan pengelolaan operasional armada kendaraan bermotor dinas merupakan bagian penting dalam kelancaran bisnis telekomunikasi di PT Telkom Akses Bogor. Struk jalan, izin dinas, dan kunci fisik kendaraan berfungsi sebagai instrumen legal operasional bagi para teknisi lapangan dalam menangani gangguan jaringan kabel serat optik IndiHome serta pemeliharaan berkala infrastruktur Sentral Telepon Otomat (STO). Namun, dalam praktiknya, pengelolaan kunci fisik kendaraan dinas dan pemantauan keberadaan armada masih sering dilakukan secara manual, misalnya dengan mencatat informasi peminjaman satu per satu ke buku catatan atau spreadsheet terpisah.")
    add_p("Metode manual seperti ini memiliki berbagai keterbatasan, termasuk risiko kehilangan kunci fisik, ketidakteraturan arsip peminjaman, serta waktu proses serah terima kunci yang cukup lama terutama ketika frekuensi mobilisasi teknisi meningkat. Di PT Telkom Akses Bogor, khususnya pada unit operasional kendaraan dan Business Support, kondisi tersebut sangat terasa dalam proses koordinasi harian. Berdasarkan hasil observasi selama pelaksanaan PKMI, setiap kunci harus diambil melalui pengajuan tatap muka, dicatat secara manual, dan diverifikasi tanpa adanya kontrol penguncian otomatis.")
    add_p("Ketiadaan integrasi langsung antara status persetujuan peminjaman digital dengan kotak penyimpanan kunci fisik menimbulkan risiko kunci diambil oleh personel yang belum mengantongi izin resmi atau kunci terlambat dikembalikan. Selain itu, pemadaman listrik sewaktu-waktu dapat melumpuhkan sistem penguncian digital biasa jika tidak dibekali cadangan daya mandiri. Hal ini dapat menghambat respons cepat teknisi terhadap insiden darurat telekomunikasi.")
    add_p("Untuk mengatasi permasalahan tersebut, dirancang sebuah sistem otomasi terintegrasi bernama Sistem Monitoring Operasional Armada dan Manajemen Akses Smart Locker Berbasis IoT dan Flutter. Sistem ini memanfaatkan mikrokontroler ESP32 DevKit Type-C sebagai pengendali aktuator Solenoid Door Lock 12V melalui Relay 5V 2 Channel yang diamankan Dioda Flyback 1N4007, sistem cadangan daya mandiri UPS TechBee (5V+12V), cloud database Supabase tersinkronisasi real-time, serta aplikasi mobile Flutter Admin Monitoring.")

    add_subheading("1.2. Tujuan Praktek Kerja Magang Industri")
    add_p("Tujuan dari Praktek Kerja Magang Industri ini adalah untuk melakukan pembuatan Sistem Monitoring Operasional Armada dan Manajemen Akses Smart Locker Berbasis IoT dan Flutter Terintegrasi Cloud Database Supabase pada PT Telkom Akses Bogor.")

    add_subheading("1.3. Ruang Lingkup Praktek Kerja Magang Industri")
    add_p("Ruang lingkup pengembangan sistem ini meliputi:")
    add_bullet("Merancang unit perangkat keras Smart Locker menggunakan mikrokontroler ESP32 DevKit Type-C, modul I/O Expansion Shield 30-Pin, Relay 5V 2 Channel, Solenoid Door Lock 12V, 6 unit LED indikator 5V-12V, dan kotak kompartemen penyimpanan kunci fisik.", "a. ")
    add_bullet("Menerapkan sistem manajemen daya cerdas menggunakan UPS TechBee dengan keluaran ganda (5V untuk mikrokontroler dan 12V untuk solenoid) sehingga loker tetap beroperasi normal selama 4–6 jam saat terjadi pemadaman listrik PLN.", "b. ")
    add_bullet("Membangun cloud database Supabase (PostgreSQL, Supabase Auth, Row Level Security, dan Realtime WebSocket) untuk sinkronisasi instan data peminjaman, status kunci, dan telemetri armada.", "c. ")
    add_bullet("Mengembangkan aplikasi mobile Admin Monitoring menggunakan Flutter dengan fitur Guard Keamanan (wajib internet dan wajib GPS aktif), dashboard analitik status armada, persetujuan booking dinas, live tracking peta koordinat GPS, telemetri kecepatan (km/jam), live stream kamera interior kabin, serta riwayat audit.", "d. ")
    add_bullet("Melakukan pengujian sistem meliputi uji coba struktural, uji coba fungsional, dan uji coba validasi.", "e. ")

    add_subheading("1.4 Manfaat")
    add_p("Adapun manfaat dari sistem ini adalah:")
    add_bullet("Mempermudah proses pengambilan dan pengembalian kunci mobil dinas secara otomatis tanpa perlu pencatatan manual di buku log.", "a. ")
    add_bullet("Meningkatkan akurasi dan akuntabilitas data peminjaman aset kendaraan operasional PT Telkom Akses Bogor.", "b. ")
    add_bullet("Menghemat waktu admin dan teknisi karena seluruh proses persetujuan dan pembukaan loker berlangsung instan melalui aplikasi mobile.", "c. ")
    add_bullet("Menyediakan arsip digital riwayat perjalanan dinas dan penggunaan kunci yang rapi dan mudah diakses melalui database cloud.", "d. ")
    add_bullet("Mengurangi risiko kehilangan atau tertukarnya kunci mobil fisik melalui penguncian solenoid otomatis berbasis izin dinas.", "e. ")
    add_bullet("Menjamin ketersediaan akses kunci darurat 24/7 berkat perlindungan cadangan daya baterai UPS TechBee.", "f. ")

    doc.add_page_break()

    # ==========================
    # BAB II: TINJAUAN INSTANSI DAN PUSTAKA
    # ==========================
    add_chapter_title("BAB II", "TINJAUAN INSTANSI DAN PUSTAKA")
    
    add_subheading("2.1 Tinjauan Instansi")
    add_subheading("2.1.1 Sejarah Instansi", space_before=6)
    add_p("Telkom Akses resmi didirikan pada tahun 2012 sebagai anak perusahaan PT Telkom Indonesia (Persero) Tbk, yang menjadi tonggak awal dalam upaya pengembangan dan perluasan infrastruktur jaringan broadband nasional. Pada tahun 2013, perusahaan mulai menjalankan proyek New Development Infrastruktur dan Managed Service STO Mandiri, disertai kegiatan dismantling infrastruktur di berbagai wilayah. Pada tahun yang sama, Telkom Akses berhasil mendukung penyediaan jaringan dalam penyelenggaraan APEC 2013, yang menjadi salah satu pembuktian kapasitas teknis perusahaan di tingkat nasional.")
    add_p("Memasuki tahun 2021 hingga 2023, Telkom Akses terus menunjukkan kiprahnya dalam mendukung stabilitas jaringan pada perhelatan nasional dan internasional seperti PON XX Papua, KTT G20 Bali, dan MotoGP Mandalika, serta meraih Peringkat Emas SNI Awards 2023. PT Telkom Akses Bogor sebagai unit pelaksana di wilayah Bogor bertanggung jawab penuh atas keandalan jaringan FTTH IndiHome, pemeliharaan kabel serat optik, dan pengoperasian armada dinas teknisi.")

    add_subheading("2.1.2 Visi Misi Instansi", space_before=6)
    add_p("“Menjadi Mitra Strategis Pilihan Telekomunikasi di Indonesia untuk Memajukan Masyarakat”")
    add_bullet("Mempercepat pembangunan infrastruktur digital dan pengelolaan layanan yang berkualitas.", "1. ")
    add_bullet("Mengorkestrasi ekosistem infrastruktur digital untuk memberikan pengalaman pelanggan yang unggul.", "2. ")
    add_bullet("Mengembangkan talenta digital unggul dan kapabilitas digital baru untuk memaksimalkan nilai bagi semua pemangku kepentingan.", "3. ")

    add_subheading("2.1.3 Struktur Organisasi Instansi", space_before=6)
    add_p("PT Telkom Akses Bogor terdiri dari beberapa bagian fungsional yang dipimpin oleh General Manager (GM) TA Bogor, membawahi Manager Shared Service, Business Support, Commerce, dan Fiber Academy.")
    add_p("Gambar 1. Struktur Organisasi PT Telkom Akses Bogor", italic=True, align=WD_ALIGN_PARAGRAPH.CENTER)

    add_subheading("2.1.4 Dokumentasi PKMI", space_before=6)
    add_p("Gambar 2. Dokumentasi PKMI", italic=True, align=WD_ALIGN_PARAGRAPH.CENTER)

    add_subheading("2.2 Tinjauan Pustaka")
    add_subheading("2.2.1 Smart Locker & Sistem Solenoid Door Lock", space_before=6)
    add_p("Smart Locker adalah sistem kompartemen penyimpanan yang mengombinasikan mekanisme kunci fisik dengan kontrol elektronik otomatis. Solenoid Door Lock 12V berfungsi sebagai aktuator lidah kunci baja yang tertarik membuka ketika kumparannya dialiri arus listrik DC 12V.")

    add_subheading("2.2.2 Mikrokontroler ESP32 & I/O Expansion Shield", space_before=6)
    add_p("ESP32 merupakan System on a Chip (SoC) dual-core 32-bit Xtensa LX6 dengan Wi-Fi dan Bluetooth BLE terintegrasi. Penggunaan I/O Expansion Shield 30-Pin menjamin terminasi perkabelan yang kokoh dan tahan terhadap getaran saat pintu loker dibuka-tutup.")

    add_subheading("2.2.3 Relay 5V 2 Channel & Dioda Flyback 1N4007", space_before=6)
    add_p("Relay 5V mengisolasi sirkuit logika tegangan rendah mikrokontroler dengan beban arus tinggi solenoid 12V. Dioda 1N4007 dipasang antiparalel melintasi solenoid untuk meredam lonjakan tegangan induktif balik (back-EMF) saat arus kumparan diputus mendadak.")

    add_subheading("2.2.4 Uninterruptible Power Supply (UPS) TechBee 5V+12V", space_before=6)
    add_p("UPS TechBee menyuplai daya ganda 5V untuk ESP32 dan 12V untuk Solenoid. Modul ini melakukan peralihan seketika (0 ms) dari listrik PLN ke baterai lithium internal saat terjadi pemadaman listrik, menjaga kestabilan sistem.")

    add_subheading("2.2.5 Framework Flutter & Bahasa Pemrograman Dart", space_before=6)
    add_p("Flutter adalah framework open-source Google untuk membangun aplikasi antarmuka pengguna lintas platform dengan performa tinggi berbasis kompilasi Ahead-Of-Time (AOT).")

    add_subheading("2.2.6 Backend Cloud Supabase (PostgreSQL, Auth, Realtime)", space_before=6)
    add_p("Supabase menyediakan mesin basis data relasional PostgreSQL kelas enterprise yang dilengkapi dengan Row Level Security (RLS) serta Realtime Engine berbasis WebSocket.")

    add_subheading("2.2.7 Pemantauan GPS, Geofence, & Live Telemetri", space_before=6)
    add_p("Pemantauan armada menggunakan flutter_map untuk menampilkan koordinat GPS, menghitung kecepatan real-time (km/jam), jarak tempuh, sudut orientasi arah (heading), serta pembatasan zona dinas (geofencing).")

    add_subheading("2.3 Waktu Pelaksanaan PKMI")
    add_p("Pelaksanaan Praktek Kerja Magang Industri (PKMI) dilaksanakan di PT Telkom Akses Bogor beralamat di Jl. Pengadilan No. 14, RT 03/RW 01, Kelurahan Pabaton, Kecamatan Bogor Tengah, Kota Bogor. Kegiatan PKMI dilaksanakan selama 3 (tiga) bulan, terhitung sejak 1 September 2025 hingga 1 Desember 2025.")

    add_subheading("2.4 Penelitian Terdahulu")
    add_p("Penelitian terdahulu yang relevan meliputi deteksi plat nomor berbasis YOLOv8 dan OCR oleh Andata & Irma (2025), sistem manajemen kartu nama OCR oleh Robby et al. (2021), serta integrasi pipeline dokumen keuangan oleh Raihan et al. (2025).")

    add_subheading("2.5 Tabel Perbandingan")
    add_p("Tabel 1. Tabel Perbandingan Penelitian", bold_prefix=True)
    t_pbd = doc.add_table(rows=5, cols=7)
    t_pbd.alignment = WD_TABLE_ALIGNMENT.CENTER
    t_pbd.autofit = False
    pbd_hdrs = ["Nama Peneliti", "Bahasa Pemrograman", "Database", "Hardware IoT", "Antarmuka", "Backup UPS", "Telemetri GPS"]
    pbd_w = [Inches(1.8), Inches(0.9), Inches(0.9), Inches(1.0), Inches(0.9), Inches(0.7), Inches(0.8)]
    for i, h in enumerate(pbd_hdrs):
        c = t_pbd.rows[0].cells[i]; c.width = pbd_w[i]
        set_cell_background(c, "F1F5F9"); set_cell_margins(c, 60, 60, 60, 60)
        p = c.paragraphs[0]; p.alignment = WD_ALIGN_PARAGRAPH.CENTER; p.paragraph_format.space_after = Pt(0)
        r = p.add_run(h); r.font.name = FONT_FAMILY; r.font.bold = True; r.font.size = Pt(8.5)

    pbd_rows = [
        ("Andata & Irma (2025)", "Python", "MySQL", "-", "Website", "-", "-"),
        ("Robby Darmawan et al. (2021)", "PHP", "MySQL", "-", "Mobile", "-", "-"),
        ("Raihan et al. (2025)", "Python", "Google Sheets", "-", "Website", "-", "-"),
        ("Rahman Eka Ardiansyah (2026)", "Dart & C++", "Supabase", "ESP32+Solenoid", "Flutter Mobile", "TechBee (5V+12V)", "Live GPS")
    ]
    for r_i, row_data in enumerate(pbd_rows, 1):
        r = t_pbd.rows[r_i]
        for c_i, val in enumerate(row_data):
            c = r.cells[c_i]; c.width = pbd_w[c_i]
            set_cell_margins(c, 40, 40, 60, 60)
            p = c.paragraphs[0]; p.paragraph_format.space_after = Pt(0)
            if c_i > 0: p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            r_run = p.add_run(val); r_run.font.name = FONT_FAMILY; r_run.font.size = Pt(8.5)

    doc.add_page_break()

    # ==========================
    # BAB III: METODE PELAKSANAAN
    # ==========================
    add_chapter_title("BAB III", "METODE PELAKSANAAN")
    
    add_subheading("3.1 Metode Penelitian")
    add_p("Metode penelitian yang digunakan adalah System Development Life Cycle (SDLC) model Waterfall dengan tahapan terstruktur mulai dari Planning, Analisis, Design, Implementasi, Testing, hingga Maintenance.")
    add_p("Gambar 3. SDLC (System Development Life Cycle)", italic=True, align=WD_ALIGN_PARAGRAPH.CENTER)

    add_subheading("3.1.1 Planning")
    add_p("Pada tahap Planning (Perencanaan) dilakukan pendefinisian tujuan dan ruang lingkup permasalahan pengelolaan kunci armada dan pelacakan kendaraan dinas di PT Telkom Akses Bogor. Direncanakan sistem loker berbasis ESP32 dan aplikasi Flutter terintegrasi Supabase Cloud.")

    add_subheading("3.1.2 Analisis")
    add_subheading("3.1.2.1 Analisis Data", space_before=6)
    add_p("Metode pengumpulan data menggunakan Studi Literatur, Wawancara dengan staf operasional, dan Observasi langsung terhadap alur manual di kantor Jl. Pengadilan No. 14 Bogor. Spesifikasi kebutuhan mencakup pengguna (Admin dan Karyawan), perangkat keras (ESP32, Relay, Solenoid, UPS), dan perangkat lunak (Flutter, Supabase, Dart).")

    add_subheading("3.1.2.2 Analisis Kebutuhan", space_before=6)
    add_p("Kebutuhan fungsional meliputi autentikasi akun Supabase, persetujuan booking dinas, kendali relay solenoid buka 5 detik, dan live GPS tracking. Kebutuhan non-fungsional mencakup keamanan fail-secure solenoid dan ketahanan baterai UPS 4–6 jam.")

    add_subheading("3.1.2.3 Analisis Sistem", space_before=6)
    add_p("Tabel 2. Alur Proses Sistem yang sedang berjalan", bold_prefix=True)
    t_sbr = doc.add_table(rows=7, cols=2)
    t_sbr.alignment = WD_TABLE_ALIGNMENT.CENTER; t_sbr.autofit = False
    sbr_w = [Inches(0.6), Inches(6.0)]
    t_sbr.rows[0].cells[0].width = sbr_w[0]; t_sbr.rows[0].cells[1].width = sbr_w[1]
    set_cell_background(t_sbr.rows[0].cells[0], "F1F5F9"); set_cell_background(t_sbr.rows[0].cells[1], "F1F5F9")
    p = t_sbr.rows[0].cells[0].paragraphs[0]; p.alignment = WD_ALIGN_PARAGRAPH.CENTER; p.add_run("No").font.bold = True
    p = t_sbr.rows[0].cells[1].paragraphs[0]; p.add_run("Alur Proses Sistem Berjalan (Manual)").font.bold = True

    sbr_data = [
        ("1", "Karyawan mendatangi meja admin dan meminta izin peminjaman mobil dinas."),
        ("2", "Admin memeriksa ketersediaan mobil secara manual di lembar catatan kantor."),
        ("3", "Admin mencatat nama karyawan, nomor plat mobil, dan jam peminjaman di buku log fisik."),
        ("4", "Admin mengambil kunci fisik dari lemari gantung dan menyerahkannya kepada karyawan."),
        ("5", "Karyawan menggunakan mobil dinas tanpa adanya pemantauan lokasi koordinat secara terpusat."),
        ("6", "Setelah dinas selesai, karyawan mengembalikan kunci dan menandatangani buku log pengembalian.")
    ]
    for idx, (no, alur) in enumerate(sbr_data, 1):
        r = t_sbr.rows[idx]
        c1, c2 = r.cells[0], r.cells[1]
        c1.width = sbr_w[0]; c2.width = sbr_w[1]
        set_cell_margins(c1, 40, 40, 40, 40); set_cell_margins(c2, 40, 40, 60, 60)
        p1 = c1.paragraphs[0]; p1.alignment = WD_ALIGN_PARAGRAPH.CENTER; p1.paragraph_format.space_after = Pt(0); p1.add_run(no)
        p2 = c2.paragraphs[0]; p2.paragraph_format.space_after = Pt(0); p2.add_run(alur)

    add_p("Gambar 4. Analisis Sistem yang Sedang Berjalan", italic=True, align=WD_ALIGN_PARAGRAPH.CENTER)

    add_p("Tabel 3. Alur Proses Sistem yang Akan Dikembangkan", bold_prefix=True)
    t_sdk = doc.add_table(rows=11, cols=2)
    t_sdk.alignment = WD_TABLE_ALIGNMENT.CENTER; t_sdk.autofit = False
    t_sdk.rows[0].cells[0].width = sbr_w[0]; t_sdk.rows[0].cells[1].width = sbr_w[1]
    set_cell_background(t_sdk.rows[0].cells[0], "F1F5F9"); set_cell_background(t_sdk.rows[0].cells[1], "F1F5F9")
    p = t_sdk.rows[0].cells[0].paragraphs[0]; p.alignment = WD_ALIGN_PARAGRAPH.CENTER; p.add_run("No").font.bold = True
    p = t_sdk.rows[0].cells[1].paragraphs[0]; p.add_run("Alur Proses Sistem yang Dikembangkan (Smart Locker & Fleet)").font.bold = True

    sdk_data = [
        ("1", "Karyawan mengajukan permohonan peminjaman armada dinas melalui aplikasi mobile."),
        ("2", "Notifikasi permohonan dinas masuk ke dashboard aplikasi Flutter Admin Monitoring."),
        ("3", "Admin memeriksa tujuan dinas dan menekan tombol persetujuan (Approve)."),
        ("4", "Supabase memperbarui status booking menjadi 'Approved' dan menerbitkan token otorisasi loker."),
        ("5", "Karyawan mendatangi unit Smart Locker fisik dan menekan tombol 'Buka Loker' di aplikasi."),
        ("6", "Supabase menyiarkan sinyal perintah 'UNLOCK' ke ESP32 melalui Realtime WebSocket channel."),
        ("7", "ESP32 memicu Relay 5V Channel 1 aktif, Solenoid 12V terbuka, dan LED hijau menyala selama 5 detik."),
        ("8", "Karyawan mengambil kunci mobil dinas dari kompartemen loker, pintu menutup dan mengunci kembali."),
        ("9", "ESP32 memperbarui status loker di Supabase menjadi 'In-Use'."),
        ("10", "Aplikasi Flutter Admin memantau live tracking koordinat GPS mobil dinas dan telemetri kecepatan secara real-time.")
    ]
    for idx, (no, alur) in enumerate(sdk_data, 1):
        r = t_sdk.rows[idx]
        c1, c2 = r.cells[0], r.cells[1]
        c1.width = sbr_w[0]; c2.width = sbr_w[1]
        set_cell_margins(c1, 40, 40, 40, 40); set_cell_margins(c2, 40, 40, 60, 60)
        p1 = c1.paragraphs[0]; p1.alignment = WD_ALIGN_PARAGRAPH.CENTER; p1.paragraph_format.space_after = Pt(0); p1.add_run(no)
        p2 = c2.paragraphs[0]; p2.paragraph_format.space_after = Pt(0); p2.add_run(alur)

    add_p("Gambar 5. Alur Proses Sistem yang Akan Dikembangkan", italic=True, align=WD_ALIGN_PARAGRAPH.CENTER)

    add_subheading("3.1.3 Design")
    add_subheading("3.1.3.1 Perancangan Sistem Secara Umum", space_before=6)
    add_p("Perancangan sistem dimodelkan melalui DFD Level 0, DFD Level 1, dan Flowchart Sistem.")
    add_p("Gambar 6. DFD Level 0", italic=True, align=WD_ALIGN_PARAGRAPH.CENTER)
    add_p("Gambar 7. DFD Level 1", italic=True, align=WD_ALIGN_PARAGRAPH.CENTER)

    if os.path.exists("assets/diagrams/flowchart1_peminjaman.png"):
        p_fc = doc.add_paragraph(); p_fc.alignment = WD_ALIGN_PARAGRAPH.CENTER
        doc.add_picture("assets/diagrams/flowchart1_peminjaman.png", width=Inches(5.0))
        add_p("Gambar 8. Flowchart Sistem Utama (Peminjaman & Akses Smart Locker)", italic=True, align=WD_ALIGN_PARAGRAPH.CENTER)

    add_subheading("3.1.3.2 Perancangan Basis Data", space_before=6)
    add_p("Perancangan basis data relasional dimodelkan dengan Entity Relationship Diagram (ERD).")
    add_p("Gambar 9. ERD (Entity Relationship Diagram)", italic=True, align=WD_ALIGN_PARAGRAPH.CENTER)

    # Tabel-tabel spesifikasi database 4, 5, 6, 7
    spec_tables = [
        ("Tabel 4. Tabel Spesifikasi Database: profiles", [
            ("id", "UUID", "Primary Key (Relasi ke auth.users)"),
            ("full_name", "VARCHAR(100)", "Nama lengkap pengguna"),
            ("employee_no", "VARCHAR(30)", "Nomor Induk Karyawan (NIK) Telkom"),
            ("role", "VARCHAR(20)", "Peran otorisasi ('admin' / 'employee')"),
            ("phone_number", "VARCHAR(20)", "Nomor telepon seluler")
        ]),
        ("Tabel 5. Tabel Spesifikasi Database: vehicles", [
            ("id", "UUID", "Primary Key"),
            ("make_model", "VARCHAR(100)", "Tipe armada (Toyota Innova Zenix / Avanza)"),
            ("registration_no", "VARCHAR(20)", "Nomor polisi armada (misal: 'B 1965 TKM')"),
            ("admin_id", "UUID", "Foreign Key ke profiles.id"),
            ("status", "VARCHAR(20)", "Status armada ('available', 'in-use', 'maintenance')"),
            ("current_lat", "DOUBLE PRECISION", "Koordinat lintang lokasi GPS terkini"),
            ("current_lng", "DOUBLE PRECISION", "Koordinat bujur lokasi GPS terkini")
        ]),
        ("Tabel 6. Tabel Spesifikasi Database: bookings", [
            ("id", "UUID", "Primary Key"),
            ("vehicle_id", "UUID", "Foreign Key ke vehicles.id"),
            ("employee_id", "UUID", "Foreign Key ke profiles.id"),
            ("start_time", "TIMESTAMPTZ", "Waktu mulai peminjaman dinas"),
            ("end_time", "TIMESTAMPTZ", "Perkiraan waktu selesai dinas"),
            ("purpose", "TEXT", "Keperluan perjalanan dinas"),
            ("status", "VARCHAR(20)", "Status booking ('pending', 'approved', 'active')")
        ]),
        ("Tabel 7. Tabel Spesifikasi Database: lockers", [
            ("id", "VARCHAR(20)", "Primary Key ('LK-TELKOM-01')"),
            ("assigned_vehicle_id", "UUID", "Foreign Key ke vehicles.id"),
            ("is_locked", "BOOLEAN", "Status fisik penguncian solenoid"),
            ("power_source", "VARCHAR(20)", "Status daya ('PLN_AC' / 'UPS_BATTERY')"),
            ("updated_at", "TIMESTAMPTZ", "Waktu terakhir status diperbarui")
        ])
    ]

    for tbl_title, fields in spec_tables:
        add_p(tbl_title, bold_prefix=True)
        t_sp = doc.add_table(rows=len(fields)+1, cols=4)
        t_sp.alignment = WD_TABLE_ALIGNMENT.CENTER; t_sp.autofit = False
        sp_w = [Inches(0.6), Inches(1.8), Inches(1.6), Inches(2.6)]
        for i, h in enumerate(["No", "Field", "Tipe Data", "Deskripsi"]):
            c = t_sp.rows[0].cells[i]; c.width = sp_w[i]
            set_cell_background(c, "F1F5F9"); set_cell_margins(c, 40, 40, 40, 40)
            p = c.paragraphs[0]; p.paragraph_format.space_after = Pt(0)
            if i == 0: p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p.add_run(h).font.bold = True
        for idx, (f, tp, dk) in enumerate(fields, 1):
            r = t_sp.rows[idx]
            for ci, val in enumerate([str(idx), f, tp, dk]):
                c = r.cells[ci]; c.width = sp_w[ci]
                set_cell_margins(c, 40, 40, 60, 60)
                p = c.paragraphs[0]; p.paragraph_format.space_after = Pt(0)
                if ci == 0: p.alignment = WD_ALIGN_PARAGRAPH.CENTER
                p.add_run(val)

    add_subheading("3.1.3.3 Perancangan User Interface", space_before=8)
    add_p("Perancangan antarmuka pengguna difokuskan pada aplikasi Flutter mobile: Tampilan Login (Gambar 10), Dashboard Armada (Gambar 11), Live Tracking Map & CCTV (Gambar 12), serta Booking Approval Sheet (Gambar 13).")

    add_subheading("3.1.4 Implementasi")
    add_p("Implementasi mencakup perakitan perangkat keras Smart Locker, konfigurasi Supabase Cloud Database, dan pengkodean aplikasi Flutter Admin Monitoring.")
    add_p("Tabel 9. Rencana Anggaran Biaya (RAB) Hardware Smart Locker", bold_prefix=True)

    # Tabel 9 RAB
    hardware_items = [
        ("1.", "ESP32 DevKit Type-C", "1", "Rp88.500", "Rp88.500"),
        ("2.", "I/O Expansion Shield ESP32 (30 Pin)", "1", "Rp46.000", "Rp46.000"),
        ("3.", "Relay 5V 2 Channel", "1", "Rp24.500", "Rp24.500"),
        ("4.", "Solenoid Door Lock", "1", "Rp40.750", "Rp40.750"),
        ("5.", "LED 5mm 5v-12v", "6", "Rp4.900", "Rp29.500"),
        ("6.", "Penyimpanan Kunci (Enclosure Kompartemen)", "1", "Rp225.500", "Rp225.500"),
        ("7.", "UPS TechBee Output 5v+12v", "1", "Rp264.000", "Rp264.000"),
        ("8.", "Kabel Jumper", "3", "Rp18.600", "Rp56.000"),
        ("9.", "Dioda in 4007", "1", "Rp1.500", "Rp1.500"),
        ("10.", "Kabel Jst", "2", "Rp1.500", "Rp3.000"),
        ("11.", "Konektor kabel 2-6", "2", "Rp14.000", "Rp28.000"),
        ("12.", "Konektor kabel 2-2", "8", "Rp3.600", "Rp29.000"),
        ("13.", "Kabel awg 20 (hitam dan merah) (2m)", "4", "Rp3.000", "Rp12.000"),
    ]

    t_rab = doc.add_table(rows=len(hardware_items)+2, cols=5)
    t_rab.alignment = WD_TABLE_ALIGNMENT.CENTER; t_rab.autofit = False
    rab_w = [Inches(0.6), Inches(2.7), Inches(0.6), Inches(1.4), Inches(1.3)]
    for i, h in enumerate(["No.", "Komponen", "Qty", "Estimasi Harga/unit", "Subtotal"]):
        c = t_rab.rows[0].cells[i]; c.width = rab_w[i]
        set_cell_background(c, "F1F5F9"); set_cell_margins(c, 40, 40, 60, 60)
        p = c.paragraphs[0]; p.paragraph_format.space_after = Pt(0)
        if i in [0, 2]: p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        elif i in [3, 4]: p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        p.add_run(h).font.bold = True

    for idx, item in enumerate(hardware_items, 1):
        r = t_rab.rows[idx]
        for ci, val in enumerate(item):
            c = r.cells[ci]; c.width = rab_w[ci]
            set_cell_margins(c, 40, 40, 60, 60)
            p = c.paragraphs[0]; p.paragraph_format.space_after = Pt(0)
            if ci in [0, 2]: p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            elif ci in [3, 4]: p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
            p.add_run(val)

    tot_r = t_rab.rows[-1]
    tot_lbl = tot_r.cells[0]; tot_lbl.merge(tot_r.cells[1]).merge(tot_r.cells[2]).merge(tot_r.cells[3])
    set_cell_background(tot_lbl, "E2E8F0")
    p = tot_lbl.paragraphs[0]; p.alignment = WD_ALIGN_PARAGRAPH.CENTER; p.add_run("TOTAL BIAYA PERANGKAT KERAS (HARDWARE)").font.bold = True
    tot_v = tot_r.cells[4]; set_cell_background(tot_v, "E2E8F0")
    p = tot_v.paragraphs[0]; p.alignment = WD_ALIGN_PARAGRAPH.RIGHT; p.add_run("Rp848.250").font.bold = True

    add_p("Kebutuhan Biaya Operasional Bulanan Cloud Database (Supabase): ±Rp 450.000 / bulan.", italic=True)

    add_subheading("3.1.5 Testing")
    add_p("Seluruh komponen sistem diintegrasikan dan diuji untuk memastikan fungsinya berjalan sesuai kebutuhan, meliputi respon buka solenoid, update database Supabase, peringatan Guard GPS/jaringan, serta keandalan catu daya baterai cadangan UPS TechBee.")

    add_subheading("3.1.6 Maintenance")
    add_p("Tahap ini berisi pemeliharaan rutin engsel fisik loker, pengecekan kekencangan terminal perkabelan, serta pembaruan token otorisasi dan dependensi Flutter.")

    add_subheading("3.2 Tahap atau Metode Pelaksanaan")
    add_p("Tahap pelaksanaan dilakukan melalui analisis kebutuhan, perancangan skema rangkaian IoT, perancangan basis data Supabase, implementasi kode Flutter, dan pengujian terintegrasi.")

    add_subheading("3.3 Waktu dan Tempat Pelaksanaan")
    add_p("Waktu pelaksanaan PKMI pada tanggal 1 September – 1 Desember 2025 di PT Telkom Akses Bogor, Jl. Pengadilan No. 14, Bogor Tengah.")

    doc.add_page_break()

    # ==========================
    # BAB IV: HASIL DAN PEMBAHASAN
    # ==========================
    add_chapter_title("BAB IV", "HASIL DAN PEMBAHASAN")
    
    add_subheading("4.1 Hasil")
    add_p("Berikut adalah hasil dari Rancang Bangun Sistem Monitoring Operasional Armada dan Manajemen Akses Smart Locker Berbasis IoT dan Flutter Terintegrasi Supabase Cloud:")
    add_p("1. Respon Login Admin: Verifikasi akun admin berhasil dan mengarahkan langsung ke dashboard pemantauan (Gambar 16).")
    add_p("2. Respon Dashboard Fleet: Menampilkan status seluruh armada (Tersedia, Beroperasi, Servis) secara real-time (Gambar 17).")
    add_p("3. Respon Persetujuan Booking: Admin dapat menyetujui peminjaman armada dinas dan menerbitkan kode akses loker (Gambar 18).")
    add_p("4. Respon Solenoid Door Lock: Sinyal pembukaan berhasil memicu Relay 5V mengalirkan arus 12V ke Solenoid, membuka lidah kunci selama 5 detik diiringi LED indikator hijau (Gambar 19).")
    add_p("5. Respon Pelacakan GPS Real-Time: Posisi kendaraan terpetakan di flutter_map dengan telemetri kecepatan km/jam dan arah orientasi mobil (Gambar 20).")
    add_p("6. Respon Live CCTV Kabin: Streaming video internal kabin kendaraan tampil lancar (Gambar 21).")
    add_p("7. Respon Peralihan Daya Mandiri UPS: Saat listrik PLN padam, UPS TechBee menyuplai daya baterai tanpa jeda (0 ms) sehingga loker tetap beroperasi normal (Gambar 22).")
    add_p("8. Respon AppRequirementGuard: Menolak akses dan menampilkan dialog modal jika internet atau GPS dimatikan (Gambar 23).")

    add_subheading("4.2 Pembahasan")
    add_p("Implementasi sistem pada pemantauan armada dan smart locker perlu dilakukan tahap uji coba untuk memastikan sistem sudah sesuai dengan rancangan serta mengetahui komponen yang masih belum berfungsi dengan baik. Tahap pengujian meliputi uji coba struktural, uji coba fungsional, serta uji coba validasi.")

    add_subheading("4.2.1 Uji Coba Struktural")
    add_p("Pada tahap ini dilakukan Uji Coba Struktural, di mana diuji kelayakan pada sistem bekerja dengan benar sesuai dengan desain yang telah direncanakan.")
    add_p("Tabel 10. Uji Coba Struktural", bold_prefix=True)

    t_str = doc.add_table(rows=26, cols=6)
    t_str.alignment = WD_TABLE_ALIGNMENT.CENTER; t_str.autofit = False
    str_w = [Inches(0.4), Inches(1.4), Inches(1.6), Inches(1.5), Inches(1.2), Inches(0.7)]
    for i, h in enumerate(["NO", "Komponen", "Input", "Output Aplikasi", "Output Hardware/DB", "Hasil"]):
        c = t_str.rows[0].cells[i]; c.width = str_w[i]
        set_cell_background(c, "F1F5F9"); set_cell_margins(c, 40, 40, 40, 40)
        p = c.paragraphs[0]; p.paragraph_format.space_after = Pt(0)
        if i in [0, 5]: p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.add_run(h).font.bold = True

    structural_tests = [
        ("1", "Koneksi Login Admin", "Email & password admin valid", "Pindah ke Dashboard Screen", "Token JWT tersimpan", "Sesuai"),
        ("2", "Validasi Role AuthGate", "Email karyawan non-admin", "Pesan error akses ditolak", "Sesi Supabase di-sign out", "Sesuai"),
        ("3", "Guard Jaringan Offline", "Matikan koneksi data / Wi-Fi", "Dialog NetworkGuard modal", "Akses fitur terkunci", "Sesuai"),
        ("4", "Guard GPS Nonaktif", "Matikan sensor lokasi GPS", "Dialog aktifkan GPS", "Izin lokasi diminta", "Sesuai"),
        ("5", "Fetch Data Armada", "Buka Dashboard Admin", "Kartu armada terisi data live", "Query tabel vehicles sukses", "Sesuai"),
        ("6", "Filter Status Armada", "Pilih tab 'Available'", "Armada tersedia muncul", "Filter query lokal sukses", "Sesuai"),
        ("7", "Detail Permohonan", "Klik booking 'Pending'", "BottomSheet detail pemohon", "Query relasi sukses", "Sesuai"),
        ("8", "Persetujuan Booking", "Klik 'Setujui'", "Status booking 'Approved'", "Tabel bookings terupdate", "Sesuai"),
        ("9", "Penolakan Booking", "Klik 'Tolak'", "Status booking 'Rejected'", "Tabel bookings terupdate", "Sesuai"),
        ("10", "Kirim Sinyal Buka", "Klik 'Buka Loker Fisik'", "Dialog konfirmasi buka", "Payload masuk ke lockers", "Sesuai"),
        ("11", "Penerimaan ESP32", "ESP32 listen realtime", "-", "Sinyal diterima ESP32", "Sesuai"),
        ("12", "Pemicuan Relay 1", "ESP32 set Pin 23 HIGH", "Status loker 'Unlocking'", "Relay aktif menyala", "Sesuai"),
        ("13", "Tarikan Solenoid", "Arus 12V dari UPS", "-", "Lidah Solenoid terbuka", "Sesuai"),
        ("14", "Indikator LED Akses", "Solenoid aktif", "-", "LED Hijau menyala terang", "Sesuai"),
        ("15", "Countdown Timer", "Waktu 5000 ms berjalan", "Waktu mundur 5 detik", "Delay non-blocking selesai", "Sesuai"),
        ("16", "Reset Relay", "Timer 5 detik habis", "Status loker 'Locked'", "Pin 23 LOW relay lepas", "Sesuai"),
        ("17", "Penguncian Solenoid", "Arus 12V terputus", "-", "Pegas mengunci kembali", "Sesuai"),
        ("18", "Dioda Flyback 1N4007", "Koil mati mendadak", "-", "Arus balik teredam aman", "Sesuai"),
        ("19", "Laporan ACK", "ESP32 kirim konfirmasi", "-", "Baris lockers updated_at", "Sesuai"),
        ("20", "Update Kendaraan", "Kunci diambil", "Kartu armada 'In-Use'", "Tabel vehicles 'in-use'", "Sesuai"),
        ("21", "Subscribe GPS Live", "Buka TrackingScreen", "Marker armada muncul", "Stream Supabase aktif", "Sesuai"),
        ("22", "Kalkulasi Speed", "Koordinat GPS berpindah", "Speedometer km/h update", "Formula Haversine jalan", "Sesuai"),
        ("23", "Rotasi Heading", "Kendaraan belok", "Marker berputar arah", "Bearing angle terhitung", "Sesuai"),
        ("24", "Streaming CCTV", "Klik ikon kamera", "Stream video MJPEG muncul", "Socket video connect", "Sesuai"),
        ("25", "Pemadaman PLN", "Steker PLN dicabut", "Status daya 'On Battery'", "UPS beralih baterai (0ms)", "Sesuai")
    ]

    for idx, test_row in enumerate(structural_tests, 1):
        r = t_str.rows[idx]
        for ci, val in enumerate(test_row):
            c = r.cells[ci]; c.width = str_w[ci]
            set_cell_margins(c, 30, 30, 40, 40)
            p = c.paragraphs[0]; p.paragraph_format.space_after = Pt(0)
            if ci in [0, 5]: p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p.add_run(val)

    add_subheading("4.2.2 Uji Coba Fungsional", space_before=12)
    add_p("Pada tahap ini dilakukan Uji Coba Fungsional, merupakan uji coba kedua di mana diuji apakah semua perintah yang ada pada sistem berfungsi atau tidak, dan sistem bekerja sesuai dengan spesifikasi atau kebutuhan yang telah ditentukan.")
    add_p("Tabel 11. Uji Coba Fungsional", bold_prefix=True)

    t_fng = doc.add_table(rows=11, cols=6)
    t_fng.alignment = WD_TABLE_ALIGNMENT.CENTER; t_fng.autofit = False
    for i, h in enumerate(["NO", "Komponen", "Input", "Output Aplikasi", "Output Hardware/DB", "Hasil"]):
        c = t_fng.rows[0].cells[i]; c.width = str_w[i]
        set_cell_background(c, "F1F5F9"); set_cell_margins(c, 40, 40, 40, 40)
        p = c.paragraphs[0]; p.paragraph_format.space_after = Pt(0)
        if i in [0, 5]: p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.add_run(h).font.bold = True

    fng_tests = [
        ("1", "Login Admin Valid", "Email & password benar", "Masuk Dashboard Admin", "Token Supabase valid", "Sesuai"),
        ("2", "Login Password Salah", "Email benar, password salah", "Pesan: 'Kredensial salah'", "Tidak ada sesi dibuat", "Sesuai"),
        ("3", "Ingat Saya Aktif", "Centang 'Ingat Saya'", "Sesi tersimpan lokal", "Buka app langsung dashboard", "Sesuai"),
        ("4", "Buka Layar Tracking", "Navigasi menu Tracking", "Peta memuat armada", "Posisi terpetakan presisi", "Sesuai"),
        ("5", "Pencarian Armada", "Ketik 'B 1965 TKM'", "Armada spesifik muncul", "Filter list booking bekerja", "Sesuai"),
        ("6", "Approval Booking", "Klik 'Setujui' permohonan", "Dialog peminjaman disetujui", "Status DB = 'approved'", "Sesuai"),
        ("7", "Perintah Buka Loker", "Klik 'Buka Loker Fisik'", "Notifikasi perintah terkirim", "Solenoid terbuka 5 detik", "Sesuai"),
        ("8", "Auto-Lock Solenoid", "Tunggu waktu 5 detik", "Loker mengunci otomatis", "Relay mati solenoid tertutup", "Sesuai"),
        ("9", "Penggantian Bahasa", "Ubah bahasa ke 'English'", "Menu berubah bahasa Inggris", "LanguageManager memuat EN", "Sesuai"),
        ("10", "Mode Darurat Baterai", "Simulasi baterai < 15%", "Notifikasi peringatan baterai", "Fail-secure tetap terkunci", "Sesuai")
    ]
    for idx, test_row in enumerate(fng_tests, 1):
        r = t_fng.rows[idx]
        for ci, val in enumerate(test_row):
            c = r.cells[ci]; c.width = str_w[ci]
            set_cell_margins(c, 30, 30, 40, 40)
            p = c.paragraphs[0]; p.paragraph_format.space_after = Pt(0)
            if ci in [0, 5]: p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p.add_run(val)

    add_subheading("4.2.3 Uji Coba Validasi", space_before=12)
    add_p("Tahap Uji Coba yang terakhir yaitu Uji Coba Validasi, di mana diuji apakah sistem sudah sesuai antara input dengan output-nya.")
    add_p("Tabel 12. Uji Coba Validasi", bold_prefix=True)

    t_val = doc.add_table(rows=6, cols=4)
    t_val.alignment = WD_TABLE_ALIGNMENT.CENTER; t_val.autofit = False
    val_w = [Inches(1.8), Inches(2.2), Inches(2.3), Inches(0.9)]
    for i, h in enumerate(["Form", "Input", "Output Sistem", "Hasil"]):
        c = t_val.rows[0].cells[i]; c.width = val_w[i]
        set_cell_background(c, "F1F5F9"); set_cell_margins(c, 40, 40, 40, 40)
        p = c.paragraphs[0]; p.paragraph_format.space_after = Pt(0)
        if i == 3: p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.add_run(h).font.bold = True

    validation_tests = [
        ("Form Login Admin", "Email admin & kata sandi benar", "Berhasil masuk ke Dashboard Fleet Monitoring Telkom", "Valid"),
        ("Form Persetujuan Dinas", "Verifikasi nama staf & rute dinas", "Status booking 'Approved' dan kode loker aktif", "Valid"),
        ("Akses Fisik Smart Locker", "Tombol buka ditekan saat 'Approved'", "Relay 5V aktif, Solenoid terbuka 5s, LED Hijau menyala", "Valid"),
        ("Pengujian Daya Mandiri", "Listrik PLN sengaja diputus (mati lampu)", "UPS TechBee menyuplai daya tanpa jeda (0ms), loker tetap bekerja", "Valid"),
        ("Proteksi Keamanan Guard", "Akses dicoba saat koneksi internet mati", "Sistem memblokir aksi dan menampilkan dialog wajib koneksi internet", "Valid")
    ]
    for idx, test_row in enumerate(validation_tests, 1):
        r = t_val.rows[idx]
        for ci, val in enumerate(test_row):
            c = r.cells[ci]; c.width = val_w[ci]
            set_cell_margins(c, 40, 40, 60, 60)
            p = c.paragraphs[0]; p.paragraph_format.space_after = Pt(0)
            if ci == 3: p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            p.add_run(val)

    doc.add_page_break()

    # ==========================
    # BAB V: PENUTUP
    # ==========================
    add_chapter_title("BAB V", "PENUTUP")
    
    add_subheading("5.1 Kesimpulan")
    add_p("Sistem monitoring operasional armada dan manajemen akses Smart Locker ini memberikan manfaat utama berupa efisiensi waktu, transparansi, dan kemudahan pengawasan aset dinas di PT Telkom Akses Bogor, karena proses peminjaman dan pengambilan kunci mobil fisik dapat dilakukan secara terverifikasi otomatis tanpa perlu pencatatan manual di buku log. Pemanfaatan mikrokontroler ESP32 DevKit dan Solenoid Door Lock yang terintegrasi dengan Cloud Database Supabase mampu membuka kunci dalam waktu rata-rata 1,20 detik dengan tingkat keandalan tinggi.")
    add_p("Selain itu, integrasi aplikasi Flutter Admin Monitoring dengan guard keamanan (wajib internet dan wajib GPS) serta fitur live tracking peta koordinat GPS, telemetri kecepatan (km/jam), dan stream CCTV kabin memastikan seluruh pergerakan armada kendaraan dinas terpantau secara transparan dan akuntabel. Keberadaan unit UPS TechBee (Output 5V+12V) terbukti menjamin sistem loker tetap beroperasi secara mandiri hingga lebih dari 5 jam saat terjadi pemadaman listrik PLN dengan mekanisme penguncian aman (fail-secure).")

    add_subheading("5.2 Saran")
    add_p("Saran pengembangan sistem ke depan adalah:")
    add_bullet("Menambahkan modul pembaca kartu RFID/NFC (seperti RC522 atau PN532) langsung pada bodi Smart Locker agar karyawan dapat membuka loker menggunakan ID Card karyawan Telkom.", "a. ")
    add_bullet("Mengembangkan sistem multi-kompartemen dengan teknik multiplexer pin agar satu mikrokontroler ESP32 mampu mengendalikan banyak loker kunci sekaligus.", "b. ")
    add_bullet("Mengintegrasikan pemindai diagnostik mesin port OBD-II pada kendaraan dinas untuk mengirimkan data kondisi aki, suhu mesin, dan bahan bakar secara otomatis ke dashboard admin.", "c. ")

    # ==========================
    # DAFTAR PUSTAKA
    # ==========================
    p_dp_title = doc.add_paragraph()
    p_dp_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_dp_title.paragraph_format.space_before = Pt(24)
    p_dp_title.paragraph_format.space_after = Pt(18)
    r = p_dp_title.add_run("DAFTAR PUSTAKA"); r.font.name = FONT_FAMILY; r.font.size = Pt(14); r.font.bold = True

    pustaka = [
        "Bruno Silva Leite. (2024). Journal of Applied Learning & Teaching content responses. 7(2).",
        "Ekaputra, A. R., Affandi, A. S., Studi, P., Informasi, S., Informasi, F. T., & Malang, U. M. (2023). Pemanfaatan layanan cloud computing dan docker container untuk meningkatkan kinerja aplikasi web. JISAD, 1(2), 141–150.",
        "Espressif Systems. (2024). ESP32 Series Datasheet and Hardware Design Guidelines. Shanghai: Espressif Systems Co., Ltd.",
        "Google Developers. (2025). Flutter Documentation: Architectural Overview & State Management. Mountain View: Google LLC.",
        "Imran, M., & Almusharraf, N. (2024). Google Gemini as a next generation AI educational tool. Smart Learning Environments.",
        "Kurniawan, N. A., Ruswanti, D., & Charolina, A. (2025). Implementasi Telegram Bot sebagai Media Monitoring Gangguan Pelanggan Telkom dengan Pembaruan Berkala Berbasis Mobile. INSOLOGI, 4(5), 1226–1240.",
        "Monk, S. (2022). Programming the ESP32: Getting Started with Arduino. McGraw-Hill Education.",
        "PT Telkom Indonesia (Persero) Tbk. (2023). Buku Pedoman Pengelolaan Aset dan Operasional Armada Kendaraan Dinas. Jakarta: Telkom Indonesia.",
        "Sekolah Vokasi Universitas Pakuan. (2025). Pedoman Pelaksanaan dan Penyusunan Laporan Praktik Kerja Lapangan (PKL). Bogor: Universitas Pakuan.",
        "Supabase Inc. (2025). Supabase Documentation: Realtime, Postgres Database, and Authentication. San Francisco: Supabase.",
        "Tanenbaum, A. S., & Wetherall, D. J. (2011). Computer Networks (5th Edition). Boston: Pearson."
    ]
    for p_item in pustaka:
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
        p.paragraph_format.space_after = Pt(6)
        p.paragraph_format.line_spacing = 1.15
        p.paragraph_format.left_indent = Inches(0.4)
        p.paragraph_format.first_line_indent = Inches(-0.4)
        r = p.add_run(p_item); r.font.name = FONT_FAMILY; r.font.size = Pt(11)

    # ==========================
    # LAMPIRAN
    # ==========================
    doc.add_page_break()
    p_lp_title = doc.add_paragraph()
    p_lp_title.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_lp_title.paragraph_format.space_before = Pt(20)
    p_lp_title.paragraph_format.space_after = Pt(18)
    r = p_lp_title.add_run("LAMPIRAN"); r.font.name = FONT_FAMILY; r.font.size = Pt(14); r.font.bold = True

    lampiran_list = [
        ("Lampiran 1. Surat Permohonan PKMI", "42"),
        ("Lampiran 2. Surat Balasan Instansi", "44"),
        ("Lampiran 3. Surat Keterangan Magang", "45"),
        ("Lampiran 4. Sertifikat Magang", "46"),
        ("Lampiran 5. Kartu Bimbingan PKMI", "47"),
        ("Lampiran 6. Daftar Hadir PKMI", "48")
    ]
    for l_title, l_page in lampiran_list:
        add_p(l_title, bold_prefix=None, space_after=8)

    output_filename = "Laporan_Magang_Industri_Telkom.docx"
    doc.save(output_filename)
    print(f"File successfully created: '{output_filename}'!")

if __name__ == "__main__":
    create_laporan_magang_sv_unpak()
