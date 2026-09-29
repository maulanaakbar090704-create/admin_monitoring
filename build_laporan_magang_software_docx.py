import os
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml import parse_xml
from docx.oxml.ns import nsdecls

def create_laporan_magang_software_docx():
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
    r_ct = p_cov_title.add_run("RANCANG BANGUN APLIKASI MONITORING OPERASIONAL ARMADA DAN MANAJEMEN PEMINJAMAN KENDARAAN BERBASIS FLUTTER DAN SUPABASE")
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
        ("Judul", ":", "Rancang Bangun Aplikasi Monitoring Operasional Armada dan Manajemen Peminjaman Kendaraan Berbasis Flutter dan Supabase"),
        ("Nama", ":", "Rahman Eka Ardiansyah"),
        ("NPM", ":", "084023019")
    ]
    for idx, (f1, f2, f3) in enumerate(sah_meta):
        row = t_sah_meta.rows[idx]
        c1, c2, c3 = row.cells[0], row.cells[1], row.cells[2]
        c1.width = Inches(1.2); c2.width = Inches(0.3); c3.width = Inches(4.5)
        for c in [c1, c2, c3]: set_cell_margins(c, 40, 40, 40, 40)
        p = c1.paragraphs[0]; p.paragraph_format.space_after = Pt(4); r = p.add_run(f1); r.font.name = FONT_FAMILY; r.font.bold = True
        p = c2.paragraphs[0]; p.paragraph_format.space_after = Pt(4); r = p.add_run(f2); r.font.name = FONT_FAMILY; r.font.bold = True
        p = c3.paragraphs[0]; p.paragraph_format.space_after = Pt(4); r = p.add_run(f3); r.font.name = FONT_FAMILY; r.font.bold = (idx > 0)

    p_msh = doc.add_paragraph()
    p_msh.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_msh.paragraph_format.space_before = Pt(36)
    p_msh.paragraph_format.space_after = Pt(20)
    r_msh = p_msh.add_run("Mengesahkan,")
    r_msh.font.name = FONT_FAMILY; r_msh.font.size = Pt(12)

    t_ttd = doc.add_table(rows=2, cols=2)
    t_ttd.alignment = WD_TABLE_ALIGNMENT.CENTER
    r0 = t_ttd.rows[0]
    p_p2 = r0.cells[0].paragraphs[0]; p_p2.alignment = WD_ALIGN_PARAGRAPH.CENTER; p_p2.paragraph_format.space_after = Pt(60)
    r = p_p2.add_run("Pembimbing II,\nPT Telkom Akses Bogor"); r.font.name = FONT_FAMILY; r.font.size = Pt(12)
    p_p1 = r0.cells[1].paragraphs[0]; p_p1.alignment = WD_ALIGN_PARAGRAPH.CENTER; p_p1.paragraph_format.space_after = Pt(60)
    r = p_p1.add_run("Pembimbing I,\nSekolah Vokasi\nUniversitas Pakuan"); r.font.name = FONT_FAMILY; r.font.size = Pt(12)

    r1 = t_ttd.rows[1]
    p_np2 = r1.cells[0].paragraphs[0]; p_np2.alignment = WD_ALIGN_PARAGRAPH.CENTER; p_np2.paragraph_format.space_after = Pt(0)
    r = p_np2.add_run("Pahreza Fajri Sulaeman"); r.font.name = FONT_FAMILY; r.font.size = Pt(12); r.font.bold = True
    p_np1 = r1.cells[1].paragraphs[0]; p_np1.alignment = WD_ALIGN_PARAGRAPH.CENTER; p_np1.paragraph_format.space_after = Pt(0)
    r = p_np1.add_run("Deden Ardiansyah, M.Kom."); r.font.name = FONT_FAMILY; r.font.size = Pt(12); r.font.bold = True

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
        ("      2.2.1 Fleet Management System (FMS)", "6", False),
        ("      2.2.2 Framework Flutter & Bahasa Pemrograman Dart", "7", False),
        ("      2.2.3 Backend as a Service (BaaS) Supabase", "7", False),
        ("      2.2.4 Basis Data Relasional PostgreSQL & Row Level Security (RLS)", "7", False),
        ("      2.2.5 Supabase Realtime Engine (WebSocket Protocol)", "7", False),
        ("      2.2.6 Pemetaan Digital flutter_map & Geolokasi GPS", "7", False),
        ("      2.2.7 Live Stream CCTV Kabin & Telemetri Kendaraan", "8", False),
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
    add_p("Pencatatan dan pengelolaan operasional armada kendaraan bermotor dinas merupakan bagian penting dalam kelancaran aktivitas bisnis telekomunikasi di PT Telkom Akses Bogor. Struk jalan, izin dinas, dan pengawasan mobil operasional dinas berfungsi sebagai instrumen legal bagi para teknisi lapangan dalam menangani perbaikan jaringan kabel serat optik IndiHome serta pemeliharaan berkala infrastruktur Sentral Telepon Otomat (STO). Namun, dalam praktiknya, pengelolaan permohonan peminjaman armada dan pemantauan pergerakan kendaraan dinas di PT Telkom Akses Bogor masih sering dilakukan secara manual, misalnya dengan mencatat informasi peminjaman satu per satu ke buku catatan atau spreadsheet terpisah.")
    add_p("Metode manual seperti ini memiliki berbagai keterbatasan, termasuk risiko kesalahan pencatatan, ketidakteraturan arsip peminjaman, serta waktu proses verifikasi permohonan yang cukup lama terutama ketika frekuensi mobilisasi teknisi meningkat. Di PT Telkom Akses Bogor, khususnya pada unit operasional kendaraan dan Business Support, kondisi tersebut sangat terasa dalam proses koordinasi harian. Berdasarkan hasil observasi selama pelaksanaan PKMI, setiap permohonan kendaraan harus diajukan secara tatap muka, dicatat ke dalam banyak baris spreadsheet, dan diverifikasi tanpa adanya sistem pemantauan posisi GPS terpusat.")
    add_p("Tingginya volume peminjaman tersebut menyebabkan data riwayat dinas menjadi sulit dikelola dan rawan tercecer. Admin operasional tidak dapat mengetahui posisi koordinat aktual kendaraan dinas saat bertugas, kecepatan tempuh, dan apakah kendaraan melintasi batas zona penugasan dinas (geofencing). Hal ini dapat berdampak langsung pada keterlambatan respon darurat perbaikan jaringan dan potensi penyalahgunaan aset dinas di luar keperluan kantor.")
    add_p("Untuk mengatasi permasalahan tersebut, dirancang sebuah sistem perangkat lunak terintegrasi bernama Aplikasi Monitoring Operasional Armada dan Manajemen Peminjaman Kendaraan Berbasis Flutter dan Supabase. Sistem ini memanfaatkan framework Flutter untuk antarmuka pengguna mobile responsif, backend cloud Supabase yang menyediakan database PostgreSQL enterprise, otentikasi JWT terenkripsi, Row Level Security (RLS), dan Realtime WebSocket Engine untuk pelacakan live GPS armada dan telemetri kendaraan.")

    add_subheading("1.2. Tujuan Praktek Kerja Magang Industri")
    add_p("Tujuan dari Praktek Kerja Magang Industri ini adalah untuk melakukan pembuatan Aplikasi Monitoring Operasional Armada dan Manajemen Peminjaman Kendaraan Berbasis Flutter dan Supabase pada PT Telkom Akses Bogor.")

    add_subheading("1.3. Ruang Lingkup Praktek Kerja Magang Industri")
    add_p("Ruang lingkup pengembangan perangkat lunak ini meliputi:")
    add_bullet("Membangun antarmuka aplikasi mobile Admin Monitoring menggunakan framework Flutter dan bahasa pemrograman Dart.", "a. ")
    add_bullet("Membangun arsitektur basis data cloud terpusat menggunakan Supabase (PostgreSQL) yang mencakup tabel profiles, vehicles, bookings, vehicle_maintenance, dan audit_logs.", "b. ")
    add_bullet("Menerapkan mekanisme keamanan Row Level Security (RLS) dan Supabase Auth untuk memisahkan wewenang pengguna secara ketat (Admin vs Karyawan).", "c. ")
    add_bullet("Mengembangkan modul Guard Keamanan tingkat sistem (AppRequirementGuard) yang memastikan perangkat admin wajib memiliki koneksi internet aktif (NetworkManager) dan wajib mengaktifkan sensor lokasi GPS (GpsRequirementManager).", "d. ")
    add_bullet("Mengembangkan modul Dashboard Analitik dengan kartu ringkasan status armada (Available, In-Use, Maintenance) dan filter pemesanan dinas.", "e. ")
    add_bullet("Mengembangkan modul persetujuan permohonan dinas (Booking Approval) dengan aksi satu ketukan (one-tap approval).", "f. ")
    add_bullet("Mengembangkan fitur pelacakan armada interaktif di atas peta (flutter_map) yang menghitung telemetri kecepatan (km/jam), jarak tempuh kumulatif, orientasi arah mobil (heading bearing angle), batas wilayah (geofence), serta dukungan live CCTV stream MJPEG.", "g. ")
    add_bullet("Mengembangkan modul riwayat audit dan ekspor rekap laporan dinas ke format spreadsheet Excel.", "h. ")
    add_bullet("Melakukan pengujian perangkat lunak meliputi uji coba struktural, uji coba fungsional, dan uji coba validasi sistem.", "i. ")

    add_subheading("1.4 Manfaat")
    add_p("Adapun manfaat dari pengembangan aplikasi ini adalah:")
    add_bullet("Mempermudah proses pengajuan dan persetujuan peminjaman mobil dinas secara digital tanpa lembar formulir fisik.", "a. ")
    add_bullet("Meningkatkan efisiensi dan transparansi pengawasan mobilitas armada PT Telkom Akses Bogor melalui visualisasi peta koordinat GPS live.", "b. ")
    add_bullet("Menghemat waktu admin operasional dalam merekap riwayat pemakaian kendaraan dinas melalui fitur ekspor data otomatis.", "c. ")
    add_bullet("Meminimalisir potensi penyalahgunaan aset dinas di luar jam dan rute penugasan resmi berkat fitur peringatan geofence.", "d. ")
    add_bullet("Menyediakan arsip digital riwayat perjalanan dinas yang rapi dan mudah diakses melalui database cloud.", "e. ")
    add_bullet("Mendukung transformasi digital di lingkungan Telkom Group dengan memanfaatkan arsitektur cloud modern.", "f. ")

    doc.add_page_break()

    # ==========================
    # BAB II: TINJAUAN INSTANSI DAN PUSTAKA
    # ==========================
    add_chapter_title("BAB II", "TINJAUAN INSTANSI DAN PUSTAKA")
    
    add_subheading("2.1 Tinjauan Instansi")
    add_subheading("2.1.1 Sejarah Instansi", space_before=6)
    add_p("Telkom Akses resmi didirikan pada tahun 2012 sebagai anak perusahaan PT Telkom Indonesia (Persero) Tbk, yang menjadi tonggak awal dalam upaya pengembangan dan perluasan infrastruktur jaringan broadband nasional. PT Telkom Akses Bogor berperan penting dalam menjaga ketersediaan layanan telekomunikasi di Kota dan Kabupaten Bogor, didukung oleh puluhan armada mobil dan motor operasional teknisi.")

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
    add_subheading("2.2.1 Fleet Management System (FMS)", space_before=6)
    add_p("Fleet Management System adalah sistem perangkat lunak terintegrasi yang berfungsi mengawasi, mengelola, dan mengoptimalkan armada kendaraan bermotor suatu institusi melalui pemantauan lokasi, penjadwalan peminjaman, serta rekapitulasi audit pemakaian.")

    add_subheading("2.2.2 Framework Flutter & Bahasa Pemrograman Dart", space_before=6)
    add_p("Flutter adalah framework open-source Google untuk merancang antarmuka pengguna berkualitas tinggi yang dikompilasi secara Ahead-Of-Time (AOT) ke kode mesin native, menghasilkan performa grafis 60-120 fps yang responsif dan konsisten.")

    add_subheading("2.2.3 Backend as a Service (BaaS) Supabase", space_before=6)
    add_p("Supabase merupakan platform BaaS berbasis PostgreSQL yang menyediakan rangkaian layanan backend lengkap: Supabase Auth (manajemen JWT), Database Storage, Edge Functions, serta WebSocket listener real-time.")

    add_subheading("2.2.4 Basis Data Relasional PostgreSQL & Row Level Security (RLS)", space_before=6)
    add_p("PostgreSQL mendukung integritas data relasional enterprise. Fitur Row Level Security (RLS) memungkinkan pembatasan hak akses baca-tulis langsung pada level baris data di database, mencegah kebocoran data antar pengguna.")

    add_subheading("2.2.5 Supabase Realtime Engine (WebSocket Protocol)", space_before=6)
    add_p("Realtime Engine memanfaatkan protokol WebSocket untuk mendengarkan perubahan data (INSERT, UPDATE, DELETE) pada tabel database dengan latensi milidetik, memungkinkan pembaruan koordinat GPS tanpa reload manual.")

    add_subheading("2.2.6 Pemetaan Digital flutter_map & Geolokasi GPS", space_before=6)
    add_p("Pustaka flutter_map merender layer peta interaktif berbasis OpenStreetMap atau tile server custom, memetakan marker kendaraan berdasarkan koordinat lintang/bujur (LatLong) secara dinamis.")

    add_subheading("2.2.7 Live Stream CCTV Kabin & Telemetri Kendaraan", space_before=6)
    add_p("Kamera kabin kendaraan dinas menyiarkan stream video MJPEG beresolusi teroptimasi untuk memantau situasi interior kabin dan keselamatan driver secara langsung.")

    add_subheading("2.3 Waktu Pelaksanaan PKMI")
    add_p("Pelaksanaan Praktek Kerja Magang Industri (PKMI) dilaksanakan di PT Telkom Akses Bogor beralamat di Jl. Pengadilan No. 14, RT 03/RW 01, Kelurahan Pabaton, Kecamatan Bogor Tengah, Kota Bogor. Kegiatan PKMI dilaksanakan selama 3 (tiga) bulan, terhitung sejak 1 September 2025 hingga 1 Desember 2025.")

    add_subheading("2.4 Penelitian Terdahulu")
    add_p("Penelitian terdahulu mencakup deteksi plat nomor berbasis YOLOv8 oleh Andata & Irma (2025), sistem kartu nama OCR oleh Robby et al. (2021), serta pipeline data keuangan oleh Raihan et al. (2025).")

    add_subheading("2.5 Tabel Perbandingan")
    add_p("Tabel 1. Tabel Perbandingan Penelitian", bold_prefix=True)
    t_pbd = doc.add_table(rows=5, cols=8)
    t_pbd.alignment = WD_TABLE_ALIGNMENT.CENTER; t_pbd.autofit = False
    pbd_hdrs = ["Nama Peneliti", "Bahasa Pemrograman", "Database", "Framework UI", "Engine Realtime", "GPS Live", "CCTV Stream", "Ekspor Laporan"]
    pbd_w = [Inches(1.5), Inches(0.9), Inches(0.9), Inches(0.9), Inches(0.9), Inches(0.6), Inches(0.6), Inches(0.7)]
    for i, h in enumerate(pbd_hdrs):
        c = t_pbd.rows[0].cells[i]; c.width = pbd_w[i]
        set_cell_background(c, "F1F5F9"); set_cell_margins(c, 50, 50, 40, 40)
        p = c.paragraphs[0]; p.alignment = WD_ALIGN_PARAGRAPH.CENTER; p.paragraph_format.space_after = Pt(0)
        r = p.add_run(h); r.font.name = FONT_FAMILY; r.font.bold = True; r.font.size = Pt(8.5)

    pbd_rows = [
        ("Andata & Irma (2025)", "Python", "MySQL", "Website", "-", "-", "-", "-"),
        ("Robby Darmawan et al. (2021)", "PHP", "MySQL", "Mobile App", "-", "-", "-", "-"),
        ("Raihan et al. (2025)", "Python", "Google Sheets", "Website", "-", "-", "-", "✓"),
        ("Rahman Eka Ardiansyah (2026)", "Dart", "Supabase", "Flutter", "Supabase Realtime", "✓", "✓", "✓")
    ]
    for r_i, row_data in enumerate(pbd_rows, 1):
        r = t_pbd.rows[r_i]
        for c_i, val in enumerate(row_data):
            c = r.cells[c_i]; c.width = pbd_w[c_i]
            set_cell_margins(c, 40, 40, 50, 50)
            p = c.paragraphs[0]; p.paragraph_format.space_after = Pt(0)
            if c_i > 0: p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            r_run = p.add_run(val); r_run.font.name = FONT_FAMILY; r_run.font.size = Pt(8.5)

    doc.add_page_break()

    # ==========================
    # BAB III: METODE PELAKSANAAN
    # ==========================
    add_chapter_title("BAB III", "METODE PELAKSANAAN")
    
    add_subheading("3.1 Metode Penelitian")
    add_p("Metode penelitian yang digunakan dalam pengembangan aplikasi ini adalah System Development Life Cycle (SDLC) model Waterfall yang terstruktur mulai dari Planning, Analisis, Design, Implementasi, Testing, hingga Maintenance.")
    add_p("Gambar 3. SDLC (System Development Life Cycle) Waterfall", italic=True, align=WD_ALIGN_PARAGRAPH.CENTER)

    add_subheading("3.1.1 Planning")
    add_p("Pada tahap Planning (Perencanaan) dilakukan pendefinisian tujuan dan ruang lingkup permasalahan pengelolaan peminjaman armada dinas dan pelacakan GPS di PT Telkom Akses Bogor, merancang arsitektur software, serta menyusun kebutuhan sistem cloud backend Supabase.")

    add_subheading("3.1.2 Analisis")
    add_subheading("3.1.2.1 Analisis Data", space_before=6)
    add_p("Metode pengumpulan data menggunakan Studi Literatur, Wawancara dengan staf operasional, dan Observasi langsung terhadap alur manual di kantor Jl. Pengadilan No. 14 Bogor. Spesifikasi kebutuhan mencakup pengguna (Admin dan Karyawan) serta perangkat lunak (Flutter SDK, Dart, Supabase Platform, VS Code).")

    add_subheading("3.1.2.2 Analisis Kebutuhan", space_before=6)
    add_p("Kebutuhan fungsional meliputi validasi kredensial login, dashboard analitik status armada, verifikasi permohonan dinas, live tracking koordinat GPS dengan telemetri kecepatan (km/jam), live CCTV kabin, dan ekspor riwayat dinas ke file Excel. Kebutuhan non-fungsional mencakup enkripsi HTTPS/WSS, otentikasi JWT, dan guard ganda (wajib koneksi internet dan sensor GPS aktif).")

    add_subheading("3.1.2.3 Analisis Sistem", space_before=6)
    add_p("Tabel 2. Alur Proses Sistem yang Sedang Berjalan (Manual)", bold_prefix=True)
    t_sbr = doc.add_table(rows=7, cols=2)
    t_sbr.alignment = WD_TABLE_ALIGNMENT.CENTER; t_sbr.autofit = False
    sbr_w = [Inches(0.6), Inches(6.0)]
    t_sbr.rows[0].cells[0].width = sbr_w[0]; t_sbr.rows[0].cells[1].width = sbr_w[1]
    set_cell_background(t_sbr.rows[0].cells[0], "F1F5F9"); set_cell_background(t_sbr.rows[0].cells[1], "F1F5F9")
    p = t_sbr.rows[0].cells[0].paragraphs[0]; p.alignment = WD_ALIGN_PARAGRAPH.CENTER; p.add_run("No").font.bold = True
    p = t_sbr.rows[0].cells[1].paragraphs[0]; p.add_run("Alur Proses Sistem Berjalan (Manual)").font.bold = True

    sbr_data = [
        ("1", "Karyawan mendatangi meja admin dan mengajukan izin pemakaian mobil dinas."),
        ("2", "Admin memeriksa ketersediaan mobil secara manual di lembar catatan kantor."),
        ("3", "Admin mencatat nama karyawan, nomor plat mobil, dan jam peminjaman di buku log fisik."),
        ("4", "Admin menyerahkan kunci kendaraan secara tatap muka kepada karyawan."),
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

    add_p("Gambar 4. Analisis Sistem yang Sedang Berjalan (Manual)", italic=True, align=WD_ALIGN_PARAGRAPH.CENTER)

    add_p("Tabel 3. Alur Proses Sistem yang Akan Dikembangkan (Aplikasi Flutter)", bold_prefix=True)
    t_sdk = doc.add_table(rows=11, cols=2)
    t_sdk.alignment = WD_TABLE_ALIGNMENT.CENTER; t_sdk.autofit = False
    t_sdk.rows[0].cells[0].width = sbr_w[0]; t_sdk.rows[0].cells[1].width = sbr_w[1]
    set_cell_background(t_sdk.rows[0].cells[0], "F1F5F9"); set_cell_background(t_sdk.rows[0].cells[1], "F1F5F9")
    p = t_sdk.rows[0].cells[0].paragraphs[0]; p.alignment = WD_ALIGN_PARAGRAPH.CENTER; p.add_run("No").font.bold = True
    p = t_sdk.rows[0].cells[1].paragraphs[0]; p.add_run("Alur Proses Sistem yang Dikembangkan (Aplikasi Flutter)").font.bold = True

    sdk_data = [
        ("1", "Karyawan mengajukan permohonan peminjaman armada dinas melalui aplikasi mobile."),
        ("2", "Notifikasi permohonan masuk ke dashboard aplikasi Flutter Admin Monitoring."),
        ("3", "Admin membuka kartu permohonan dan memeriksa tujuan dinas serta waktu pemakaian."),
        ("4", "Admin menekan tombol persetujuan (Approve) pada antarmuka aplikasi."),
        ("5", "Supabase memperbarui status pemesanan di database menjadi 'Approved' secara seketika."),
        ("6", "Status armada dinas otomatis berubah menjadi 'In-Use' dan muncul pada daftar pelacakan aktif."),
        ("7", "Admin membuka menu Tracking Screen untuk memantau posisi koordinat live GPS armada di peta."),
        ("8", "Sistem menghitung telemetri kecepatan (km/jam), jarak tempuh, dan menampilkan stream CCTV kabin."),
        ("9", "Setelah tugas dinas selesai, status booking diubah menjadi 'Completed'."),
        ("10", "Seluruh data transaksi tersimpan di riwayat audit dan siap diekspor ke format Excel kapan pun.")
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
    add_p("Gambar 6. DFD Level 0 Sistem Fleet Monitoring", italic=True, align=WD_ALIGN_PARAGRAPH.CENTER)
    add_p("Gambar 7. DFD Level 1 Sistem Fleet Monitoring", italic=True, align=WD_ALIGN_PARAGRAPH.CENTER)
    add_p("Gambar 8. Flowchart Sistem Utama (Verifikasi Booking & Monitoring)", italic=True, align=WD_ALIGN_PARAGRAPH.CENTER)

    add_subheading("3.1.3.2 Perancangan Basis Data", space_before=6)
    add_p("Perancangan basis data relasional pada Supabase dimodelkan dengan Entity Relationship Diagram (ERD).")
    add_p("Gambar 9. ERD (Entity Relationship Diagram) Database Supabase", italic=True, align=WD_ALIGN_PARAGRAPH.CENTER)

    # Spesifikasi Tabel 4 - 8
    spec_tables = [
        ("Tabel 4. Tabel Spesifikasi Database: profiles", [
            ("id", "UUID", "Primary Key (Relasi ke auth.users)"),
            ("full_name", "VARCHAR(100)", "Nama lengkap pengguna"),
            ("employee_no", "VARCHAR(30)", "Nomor Induk Karyawan (NIK) Telkom"),
            ("role", "VARCHAR(20)", "Peran otorisasi ('admin' / 'employee')"),
            ("phone_number", "VARCHAR(20)", "Nomor kontak darurat")
        ]),
        ("Tabel 5. Tabel Spesifikasi Database: vehicles", [
            ("id", "UUID", "Primary Key"),
            ("make_model", "VARCHAR(100)", "Tipe armada (misal: 'Toyota Innova Zenix')"),
            ("registration_no", "VARCHAR(20)", "Nomor plat dinas (misal: 'B 1965 TKM')"),
            ("admin_id", "UUID", "Foreign Key ke profiles.id"),
            ("status", "VARCHAR(20)", "Status armada ('available', 'in-use', 'maintenance')"),
            ("current_lat", "DOUBLE PRECISION", "Koordinat lintang GPS terkini"),
            ("current_lng", "DOUBLE PRECISION", "Koordinat bujur GPS terkini")
        ]),
        ("Tabel 6. Tabel Spesifikasi Database: bookings", [
            ("id", "UUID", "Primary Key"),
            ("vehicle_id", "UUID", "Foreign Key ke vehicles.id"),
            ("employee_id", "UUID", "Foreign Key ke profiles.id"),
            ("start_time", "TIMESTAMPTZ", "Waktu mulai peminjaman"),
            ("end_time", "TIMESTAMPTZ", "Perkiraan waktu selesai dinas"),
            ("purpose", "TEXT", "Keperluan dinas"),
            ("status", "VARCHAR(20)", "Status booking ('pending', 'approved', 'active')")
        ]),
        ("Tabel 7. Tabel Spesifikasi Database: vehicle_maintenance", [
            ("id", "UUID", "Primary Key"),
            ("vehicle_id", "UUID", "Foreign Key ke vehicles.id"),
            ("maintenance_type", "VARCHAR(50)", "Jenis servis (Ganti Oli / Servis Rem)"),
            ("cost", "NUMERIC(15,2)", "Estimasi biaya perbaikan"),
            ("status", "VARCHAR(20)", "Status servis ('in_progress' / 'done')")
        ]),
        ("Tabel 8. Tabel Spesifikasi Database: audit_logs", [
            ("id", "UUID", "Primary Key"),
            ("action", "VARCHAR(50)", "Aksi dilakukan ('APPROVE_BOOKING', 'EXPORT_EXCEL')"),
            ("performed_by", "UUID", "Foreign Key ke profiles.id"),
            ("timestamp", "TIMESTAMPTZ", "Waktu eksekusi aksi")
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
    add_p("Perancangan antarmuka pengguna difokuskan pada aplikasi Flutter mobile: Halaman Login (Gambar 10), Dashboard Armada (Gambar 11), Live Tracking Map (Gambar 12), Booking Approval Sheet (Gambar 13), dan Riwayat Perjalanan (Gambar 14).")

    add_subheading("3.1.4 Implementasi")
    add_subheading("1. Implementasi Cloud Backend Supabase & Estimasi Biaya", space_before=4)
    add_p("Tabel 9. Kebutuhan Biaya Operasional Bulanan Cloud Database", bold_prefix=True)
    t_ops = doc.add_table(rows=2, cols=3)
    t_ops.alignment = WD_TABLE_ALIGNMENT.CENTER; t_ops.autofit = False
    ops_hdrs = ["Kebutuhan Layanan", "Keterangan Fungsional", "Estimasi Biaya / Bulan"]
    ops_w = [Inches(2.5), Inches(2.3), Inches(1.8)]
    for i, h in enumerate(ops_hdrs):
        c = t_ops.rows[0].cells[i]; c.width = ops_w[i]
        set_cell_background(c, "F1F5F9"); set_cell_margins(c, 40, 40, 50, 50)
        p = c.paragraphs[0]; p.paragraph_format.space_after = Pt(0)
        if i == 2: p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        p.add_run(h).font.bold = True
    c0 = t_ops.rows[1].cells[0]; c0.width = ops_w[0]; set_cell_margins(c0, 40, 40, 50, 50); c0.paragraphs[0].add_run("Cloud Database (Supabase)")
    c1 = t_ops.rows[1].cells[1]; c1.width = ops_w[1]; set_cell_margins(c1, 40, 40, 50, 50); c1.paragraphs[0].add_run("Untuk Database PostgreSQL, Auth, & Realtime")
    c2 = t_ops.rows[1].cells[2]; c2.width = ops_w[2]; set_cell_margins(c2, 40, 40, 50, 50); p2 = c2.paragraphs[0]; p2.alignment = WD_ALIGN_PARAGRAPH.RIGHT; p2.add_run("±Rp 450.000 / bulan").font.bold = True

    add_subheading("2. Implementasi Aplikasi Mobile Flutter Admin Monitoring", space_before=6)
    add_p("Pengkodean dilakukan menggunakan framework Flutter dengan arsitektur modular: NetworkManager & GpsRequirementManager (Pengawasan status internet dan sensor GPS), AuthGate & SessionManager (Manajemen sesi persisten 'Ingat Saya'), TrackingScreen (Peta dinamis dengan sinkronisasi stream real-time), dan ExcelExporter (Modul ekspor laporan tabel perjalanan dinas).")

    add_subheading("3.1.5 Testing")
    add_p("Pengujian fungsionalitas dan performa aplikasi mobile Flutter dilakukan menggunakan skenario Black-box testing, uji latensi query, dan uji akurasi geolokasi.")

    add_subheading("3.1.6 Maintenance")
    add_p("Pemeliharaan software mencakup pembaruan dependensi pubspec Flutter, optimasi query SQL indexing, dan pembaruan patch keamanan Supabase.")

    add_subheading("3.2 Tahap atau Metode Pelaksanaan")
    add_p("Tahap pelaksanaan berfokus pada tahapan rekayasa perangkat lunak mulai dari wawancara kebutuhan, perancangan DFD dan ERD, implementasi Supabase, pembuatan kode Flutter, hingga pengujian fungsional.")

    add_subheading("3.3 Waktu dan Tempat Pelaksanaan")
    add_p("Waktu pelaksanaan PKMI pada tanggal 1 September – 1 Desember 2025 di PT Telkom Akses Bogor, Jl. Pengadilan No. 14, Bogor Tengah.")

    doc.add_page_break()

    # ==========================
    # BAB IV: HASIL DAN PEMBAHASAN
    # ==========================
    add_chapter_title("BAB IV", "HASIL DAN PEMBAHASAN")
    
    add_subheading("4.1 Hasil")
    add_p("Berikut adalah hasil dari Rancang Bangun Aplikasi Monitoring Operasional Armada dan Manajemen Peminjaman Kendaraan Berbasis Flutter dan Supabase:")
    add_p("1. Respon Otentikasi & Role Guard: Sistem memvalidasi kredensial pengguna dan mengarahkan admin ke dashboard operasional (Gambar 16).")
    add_p("2. Respon Dashboard Metrik Armada: Menampilkan total armada dinas, mobil yang sedang beroperasi, dan kartu permohonan dinas (Gambar 17).")
    add_p("3. Respon Persetujuan Booking: Admin dapat menyetujui peminjaman armada dinas dengan tombol Approve dalam hitungan detik (Gambar 18).")
    add_p("4. Respon Pelacakan GPS Real-Time: Peta menampilkan marker armada yang bergerak dinamis sesuai koordinat live GPS (Gambar 19).")
    add_p("5. Respon Perhitungan Telemetri: Aplikasi menghitung kecepatan mobil (km/jam), jarak tempuh, dan bearing angle rotasi (Gambar 20).")
    add_p("6. Respon Live CCTV Kabin: Video streaming kabin kendaraan dinas tampil lancar via protokol MJPEG (Gambar 21).")
    add_p("7. Respon Ekspor Laporan Excel: Admin dapat mengunduh rekapitulasi data peminjaman ke format file spreadsheet (Gambar 22).")
    add_p("8. Respon Guard Jaringan & GPS: Sistem memblokir akses jika koneksi internet terputus atau sensor lokasi dimatikan (Gambar 23).")

    add_subheading("4.2 Pembahasan")
    add_p("Implementasi aplikasi pada pemantauan armada dinas perlu dilakukan tahap uji coba untuk memastikan sistem sudah sesuai dengan rancangan serta mengetahui komponen yang masih belum berfungsi dengan baik. Tahap pengujian meliputi uji coba struktural, uji coba fungsional, serta uji coba validasi.")

    add_subheading("4.2.1 Uji Coba Struktural")
    add_p("Pada tahap ini dilakukan Uji Coba Struktural, di mana diuji kelayakan pada sistem bekerja dengan benar sesuai dengan desain yang telah direncanakan.")
    add_p("Tabel 10. Uji Coba Struktural Perangkat Lunak", bold_prefix=True)

    t_str = doc.add_table(rows=26, cols=6)
    t_str.alignment = WD_TABLE_ALIGNMENT.CENTER; t_str.autofit = False
    str_w = [Inches(0.4), Inches(1.4), Inches(1.6), Inches(1.5), Inches(1.2), Inches(0.7)]
    for i, h in enumerate(["NO", "Komponen", "Input", "Output Aplikasi", "Output Database Supabase", "Hasil"]):
        c = t_str.rows[0].cells[i]; c.width = str_w[i]
        set_cell_background(c, "F1F5F9"); set_cell_margins(c, 40, 40, 40, 40)
        p = c.paragraphs[0]; p.paragraph_format.space_after = Pt(0)
        if i in [0, 5]: p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.add_run(h).font.bold = True

    structural_tests = [
        ("1", "Koneksi Login Admin", "Input email & password admin valid", "Pindah ke Dashboard Screen", "Token JWT tersimpan", "Sesuai"),
        ("2", "Validasi Role AuthGate", "Input email karyawan non-admin", "Pesan error akses ditolak", "Sesi Supabase di-sign out", "Sesuai"),
        ("3", "Guard Jaringan Offline", "Matikan koneksi data / Wi-Fi", "Dialog NetworkGuard modal", "Akses fitur terkunci", "Sesuai"),
        ("4", "Guard GPS Nonaktif", "Matikan sensor lokasi GPS", "Dialog aktifkan GPS", "Izin lokasi diminta", "Sesuai"),
        ("5", "Fetch Data Armada", "Buka Dashboard Admin", "Kartu armada terisi data live", "Query tabel vehicles sukses", "Sesuai"),
        ("6", "Filter Status Armada", "Pilih tab 'Available'", "Armada tersedia muncul", "Filter query lokal sukses", "Sesuai"),
        ("7", "Detail Permohonan", "Klik booking 'Pending'", "BottomSheet detail pemohon", "Query relasi sukses", "Sesuai"),
        ("8", "Persetujuan Booking", "Klik 'Setujui'", "Status booking 'Approved'", "Tabel bookings terupdate", "Sesuai"),
        ("9", "Penolakan Booking", "Klik 'Tolak'", "Status booking 'Rejected'", "Tabel bookings terupdate", "Sesuai"),
        ("10", "Update Status Armada", "Booking 'Approved'", "Kartu armada 'In-Use'", "Tabel vehicles 'in-use'", "Sesuai"),
        ("11", "Subscribe GPS Live", "Buka TrackingScreen", "Marker armada muncul", "Stream Supabase aktif", "Sesuai"),
        ("12", "Kalkulasi Speed", "Koordinat GPS berpindah", "Speedometer km/h update", "Formula Haversine jalan", "Sesuai"),
        ("13", "Rotasi Heading", "Kendaraan belok", "Marker berputar arah", "Bearing angle terhitung", "Sesuai"),
        ("14", "Batas Geofence", "Kendaraan keluar batas dinas", "Tampil banner peringatan geofence", "Log ditandai 'Out of Zone'", "Sesuai"),
        ("15", "Streaming CCTV", "Klik ikon kamera", "Stream video MJPEG muncul", "Socket video connect", "Sesuai"),
        ("16", "Rekap Riwayat", "Buka menu History", "Daftar perjalanan tampil", "Query status 'completed'", "Sesuai"),
        ("17", "Filter Tanggal", "Pilih rentang 1-30 Nov", "Riwayat terfilter tanggal", "SQL range timestamp sukses", "Sesuai"),
        ("18", "Ekspor Excel", "Klik tombol 'Ekspor Excel'", "File spreadsheet (.xlsx) unduh", "Ekstraksi kolom sukses", "Sesuai"),
        ("19", "Modul Servis Mobil", "Klik 'Tandai Perbaikan'", "Armada berstatus 'Maintenance'", "Tabel maintenance bertambah", "Sesuai"),
        ("20", "Proteksi Servis", "Coba booking mobil servis", "Mobil disable tidak bisa dipesan", "Validasi status != maintenance", "Sesuai"),
        ("21", "Ganti Bahasa", "Pilih opsi 'English'", "Semua teks bahasa Inggris", "LanguageManager memuat EN", "Sesuai"),
        ("22", "Proteksi Biometrik", "Aktifkan sidik jari", "Konfirmasi sidik jari saat buka", "LocalAuth SDK bekerja", "Sesuai"),
        ("23", "Edit Profil Admin", "Ubah nomor telepon", "Profil terbarui di layar setting", "Query UPDATE profiles sukses", "Sesuai"),
        ("24", "Ubah Password", "Input password lama & baru", "Pesan: 'Password berhasil diubah'", "Supabase updateUser() sukses", "Sesuai"),
        ("25", "Logout Akun", "Klik tombol 'Keluar'", "Kembali ke LoginScreen", "Sesi lokal dibersihkan", "Sesuai")
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
    add_p("Tabel 11. Uji Coba Fungsional Aplikasi", bold_prefix=True)

    t_fng = doc.add_table(rows=13, cols=6)
    t_fng.alignment = WD_TABLE_ALIGNMENT.CENTER; t_fng.autofit = False
    for i, h in enumerate(["NO", "Komponen", "Input", "Output Aplikasi", "Output Database Supabase", "Hasil"]):
        c = t_fng.rows[0].cells[i]; c.width = str_w[i]
        set_cell_background(c, "F1F5F9"); set_cell_margins(c, 40, 40, 40, 40)
        p = c.paragraphs[0]; p.paragraph_format.space_after = Pt(0)
        if i in [0, 5]: p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.add_run(h).font.bold = True

    fng_tests = [
        ("1", "Login Admin Valid", "Email & password benar", "Masuk Dashboard Admin", "Token Supabase valid", "Sesuai"),
        ("2", "Login Password Salah", "Email benar, password salah", "Pesan: 'Kredensial salah'", "Tidak ada sesi dibuat", "Sesuai"),
        ("3", "Sesi Ingat Saya", "Centang 'Ingat Saya'", "Sesi tersimpan lokal", "Buka app langsung dashboard", "Sesuai"),
        ("4", "Buka Layar Tracking", "Navigasi menu Tracking", "Peta memuat armada", "Posisi terpetakan presisi", "Sesuai"),
        ("5", "Pencarian Armada", "Ketik 'B 1965 TKM'", "Armada spesifik muncul", "Filter list booking bekerja", "Sesuai"),
        ("6", "Approval Booking", "Klik 'Setujui' permohonan", "Dialog peminjaman disetujui", "Status DB = 'approved'", "Sesuai"),
        ("7", "Penolakan Booking", "Klik 'Tolak' permohonan", "Dialog peminjaman ditolak", "Status DB = 'rejected'", "Sesuai"),
        ("8", "Telemetri Speedometer", "Armada bergerak di rute dinas", "Teks kecepatan km/jam dinamis", "Nilai speed tersinkron live", "Sesuai"),
        ("9", "Live CCTV Kabin", "Tekan tombol kamera interior", "Video streaming kabin tampil", "Paket video stream lancar", "Sesuai"),
        ("10", "Ekspor Riwayat Excel", "Tekan tombol 'Unduh Excel'", "File laporan tersimpan lokal", "Kolom laporan lengkap rapi", "Sesuai"),
        ("11", "Penggantian Bahasa", "Ubah bahasa ke 'English'", "Menu berubah bahasa Inggris", "LanguageManager memuat EN", "Sesuai"),
        ("12", "Validasi Guard GPS", "Sensor GPS HP dimatikan", "Dialog aktifkan lokasi modal", "Aplikasi terkunci hingga aktif", "Sesuai")
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
    add_p("Tabel 12. Uji Coba Validasi Antarmuka & Input-Output", bold_prefix=True)

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
        ("Form Verifikasi Booking", "Tinjau nama staf, NIK, dan rute dinas", "Status booking diupdate 'Approved' di database cloud", "Valid"),
        ("Peta Pelacakan GPS", "Koordinat lintang/bujur diperbarui", "Marker mobil bergerak dinamis di peta dengan telemetri", "Valid"),
        ("Form Ekspor Laporan", "Klik tombol ekspor data riwayat dinas", "File format Excel (.xlsx) terunduh dan dapat dibuka di Excel", "Valid"),
        ("Proteksi Keamanan Guard", "Akses dicoba saat koneksi internet mati", "Sistem memblokir aksi dan menampilkan dialog wajib internet", "Valid")
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
    add_p("Berdasarkan seluruh tahapan perancangan, implementasi, dan pengujian perangkat lunak yang telah dilaksanakan, dapat disimpulkan bahwa:")
    add_bullet("Aplikasi Monitoring Operasional Armada berbasis Flutter berhasil mendigitalisasi pengelolaan peminjaman mobil dinas di PT Telkom Akses Bogor, menyederhanakan alur permohonan dan verifikasi menjadi satu ketukan (one-tap approval) tanpa memerlukan pencatatan di buku log manual.", "1. ")
    add_bullet("Pemanfaatan platform cloud Supabase (PostgreSQL, Row Level Security, dan Realtime WebSocket) menyediakan basis data yang aman, terstruktur, dan mampu menyiarkan perubahan data serta koordinat lokasi armada secara instan dengan latensi rendah.", "2. ")
    add_bullet("Fitur pelacakan live GPS interaktif pada flutter_map yang terintegrasi dengan telemetri kecepatan (km/jam), jarak tempuh, bearing angle rotasi, peringatan batas geofencing, serta live CCTV interior kabin berhasil memberikan transparansi dan akuntabilitas mobilitas armada operasional.", "3. ")
    add_bullet("Penerapan sistem proteksi berlapis (AppRequirementGuard) menjamin integritas pelacakan aset dinas dengan mewajibkan koneksi internet dan sensor GPS aktif sebelum membuka menu pemantauan.", "4. ")
    add_bullet("Pelaksanaan kegiatan Praktik Kerja Magang Industri (PKMI) di PT Telkom Akses Bogor berhasil mengaplikasikan kompetensi rekayasa perangkat lunak modern dari Program Studi Teknik Komputer Sekolah Vokasi Universitas Pakuan ke dalam dunia industri nyata.", "5. ")

    add_subheading("5.2 Saran")
    add_p("Saran pengembangan sistem ke depan adalah:")
    add_bullet("Menambahkan algoritma Route Optimization berbasis AI untuk memberikan rekomendasi rute perjalanan teknisi yang paling efisien dan bebas kemacetan.", "a. ")
    add_bullet("Mengintegrasikan modul Push Notification otomatis (seperti Firebase Cloud Messaging) agar admin menerima peringatan instan saat kendaraan keluar dari zona geofence dinas.", "b. ")
    add_bullet("Mengembangkan modul Predictive Maintenance yang memanfaatkan rekapitulasi data kilometer dinas untuk memicu peringatan servis berkala secara otomatis.", "c. ")

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
        "Google Developers. (2025). Flutter Documentation: Architectural Overview & State Management. Mountain View: Google LLC.",
        "Imran, M., & Almusharraf, N. (2024). Google Gemini as a next generation AI educational tool. Smart Learning Environments.",
        "Novita, W., Fitriadi, Y., Nopiana, P. R., Akuntansi, P., Barat, S., Manajemen, P., Barat, S., Akuntansi, P., Akuntansi, P., & Spreadsheet, G. (2023). Pelatihan Laporan Keuangan dengan Google Spreadsheet dalam Rangka Meningkatkan Pengetahuan UMKM. Jurnal Pengabdian Masyarakat Bidang Sosial dan Humaniora, 2(2), 217–225.",
        "PT Telkom Indonesia (Persero) Tbk. (2023). Buku Pedoman Pengelolaan Aset dan Operasional Armada Kendaraan Dinas. Jakarta: Telkom Indonesia.",
        "Sekolah Vokasi Universitas Pakuan. (2025). Pedoman Pelaksanaan dan Penyusunan Laporan Praktik Kerja Lapangan (PKL). Bogor: Universitas Pakuan.",
        "Sommerville, I. (2015). Software Engineering (10th Edition). Boston: Pearson.",
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

    output_filename = "Laporan_Magang_Software_Telkom.docx"
    doc.save(output_filename)
    print(f"File successfully created: '{output_filename}'!")

if __name__ == "__main__":
    create_laporan_magang_software_docx()
