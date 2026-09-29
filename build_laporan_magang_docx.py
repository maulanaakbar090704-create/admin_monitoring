import os
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml import parse_xml
from docx.oxml.ns import nsdecls

def create_laporan_magang_docx():
    doc = docx.Document()

    # Set page margins: 1 inch (72 pt)
    for section in doc.sections:
        section.top_margin = Inches(1.0)
        section.bottom_margin = Inches(1.0)
        section.left_margin = Inches(1.0)
        section.right_margin = Inches(1.0)

    COLOR_PRIMARY_HEX = "BB0016"      # Telkom Red
    COLOR_DARK_HEX = "1E293B"         # Dark Slate
    COLOR_BORDER_HEX = "CBD5E1"       # Light Slate Border
    COLOR_BG_LIGHT_HEX = "F8FAFC"     # Light BG

    def set_cell_background(cell, hex_color):
        tcPr = cell._tc.get_or_add_tcPr()
        shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{hex_color}"/>')
        tcPr.append(shd)

    def set_cell_margins(cell, top=80, bottom=80, left=120, right=120):
        tcPr = cell._tc.get_or_add_tcPr()
        tcMar = parse_xml(f'<w:tcMar {nsdecls("w")}><w:top w:w="{top}" w:type="dxa"/><w:bottom w:w="{bottom}" w:type="dxa"/><w:left w:w="{left}" w:type="dxa"/><w:right w:w="{right}" w:type="dxa"/></w:tcMar>')
        tcPr.append(tcMar)

    def add_title(text):
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_before = Pt(12)
        p.paragraph_format.space_after = Pt(4)
        run = p.add_run(text)
        run.font.name = 'Segoe UI'
        run.font.size = Pt(20)
        run.font.bold = True
        run.font.color.rgb = RGBColor(187, 0, 22)

    def add_subtitle(text):
        p = doc.add_paragraph()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_after = Pt(18)
        run = p.add_run(text)
        run.font.name = 'Segoe UI'
        run.font.size = Pt(12)
        run.font.color.rgb = RGBColor(71, 85, 105)

    def add_heading_1(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(16)
        p.paragraph_format.space_after = Pt(6)
        p.paragraph_format.keep_with_next = True
        run = p.add_run(text)
        run.font.name = 'Segoe UI'
        run.font.size = Pt(15)
        run.font.bold = True
        run.font.color.rgb = RGBColor(187, 0, 22)

    def add_heading_2(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(12)
        p.paragraph_format.space_after = Pt(4)
        p.paragraph_format.keep_with_next = True
        run = p.add_run(text)
        run.font.name = 'Segoe UI'
        run.font.size = Pt(12.5)
        run.font.bold = True
        run.font.color.rgb = RGBColor(30, 41, 59)

    def add_heading_3(text):
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(10)
        p.paragraph_format.space_after = Pt(3)
        p.paragraph_format.keep_with_next = True
        run = p.add_run(text)
        run.font.name = 'Segoe UI'
        run.font.size = Pt(11)
        run.font.bold = True
        run.font.color.rgb = RGBColor(71, 85, 105)

    def add_p(text, bold_prefix=None, space_after=4):
        p = doc.add_paragraph()
        p.paragraph_format.space_after = Pt(space_after)
        p.paragraph_format.line_spacing = 1.15
        if bold_prefix:
            r_pre = p.add_run(bold_prefix)
            r_pre.font.name = 'Segoe UI'
            r_pre.font.size = Pt(10)
            r_pre.font.bold = True
            r_pre.font.color.rgb = RGBColor(30, 41, 59)
        run = p.add_run(text)
        run.font.name = 'Segoe UI'
        run.font.size = Pt(10)
        run.font.color.rgb = RGBColor(51, 65, 85)
        return p

    def add_bullet(text, bold_prefix=None):
        p = doc.add_paragraph(style='List Bullet')
        p.paragraph_format.space_after = Pt(3)
        p.paragraph_format.line_spacing = 1.15
        if bold_prefix:
            r_pre = p.add_run(bold_prefix)
            r_pre.font.name = 'Segoe UI'
            r_pre.font.size = Pt(10)
            r_pre.font.bold = True
            r_pre.font.color.rgb = RGBColor(30, 41, 59)
        run = p.add_run(text)
        run.font.name = 'Segoe UI'
        run.font.size = Pt(10)
        run.font.color.rgb = RGBColor(51, 65, 85)
        return p

    # --- COVER PAGE ---
    p_cov_top = doc.add_paragraph()
    p_cov_top.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_cov_top.paragraph_format.space_before = Pt(20)
    p_cov_top.paragraph_format.space_after = Pt(4)
    r1 = p_cov_top.add_run("LAPORAN PRAKTIK KERJA LAPANGAN (MAGANG)")
    r1.font.name = 'Segoe UI'
    r1.font.size = Pt(13)
    r1.font.bold = True
    r1.font.color.rgb = RGBColor(100, 116, 139)

    add_title("RANCANG BANGUN SISTEM MONITORING OPERASIONAL ARMADA DAN MANAJEMEN AKSES SMART LOCKER BERBASIS IOT DAN FLUTTER")
    add_subtitle("Studi Kasus Implementasi pada PT Telkom Indonesia (Persero) Tbk\nDivisi Monitoring Operasional Armada")

    # Garis Aksen
    p_line = doc.add_paragraph()
    p_line.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p_line.paragraph_format.space_after = Pt(16)
    r_l = p_line.add_run("━" * 50)
    r_l.font.color.rgb = RGBColor(187, 0, 22)
    r_l.font.bold = True

    # Tabel Identitas Praktikan
    t_id = doc.add_table(rows=6, cols=2)
    t_id.alignment = WD_TABLE_ALIGNMENT.CENTER
    id_data = [
        ("Nama Praktikan", "Maulana Akbar"),
        ("Program Studi / Kampus", "Sekolah Vokasi (SV) Universitas Pakuan"),
        ("Instansi Tempat Magang", "PT Telkom Indonesia (Persero) Tbk"),
        ("Unit Kerja / Divisi", "Divisi Monitoring Operasional Armada & IoT"),
        ("Periode Magang", "Semester Genap Tahun Ajaran 2025/2026"),
        ("Versi Sistem / Build", "v1.0.0 (Build 1) - Production Ready")
    ]
    for idx, (k, v) in enumerate(id_data):
        row = t_id.rows[idx]
        c1, c2 = row.cells[0], row.cells[1]
        c1.width = Inches(2.2)
        c2.width = Inches(4.3)
        set_cell_background(c1, "F1F5F9")
        set_cell_background(c2, "FFFFFF")
        set_cell_margins(c1, top=60, bottom=60, left=100, right=100)
        set_cell_margins(c2, top=60, bottom=60, left=100, right=100)
        
        p1 = c1.paragraphs[0]
        p1.paragraph_format.space_after = Pt(0)
        rp1 = p1.add_run(k)
        rp1.font.bold = True
        rp1.font.size = Pt(9.5)
        rp1.font.color.rgb = RGBColor(30, 41, 59)
        
        p2 = c2.paragraphs[0]
        p2.paragraph_format.space_after = Pt(0)
        rp2 = p2.add_run(v)
        rp2.font.size = Pt(9.5)
        rp2.font.color.rgb = RGBColor(51, 65, 85)

    doc.add_page_break()

    # --- KATA PENGANTAR ---
    add_heading_1("KATA PENGANTAR")
    add_p("Puji dan syukur ke hadirat Tuhan Yang Maha Esa atas limpahan rahmat dan karunia-Nya, sehingga penulis dapat menyelesaikan kegiatan Praktik Kerja Lapangan (Magang) sekaligus menyusun Laporan Magang dengan judul: 'Rancang Bangun Sistem Monitoring Operasional Armada dan Manajemen Akses Smart Locker Berbasis IoT dan Flutter pada PT Telkom Indonesia (Persero) Tbk'.")
    add_p("Laporan ini disusun sebagai salah satu syarat akademis dalam menyelesaikan kurikulum perkuliahan pada Sekolah Vokasi (SV) Universitas Pakuan, serta sebagai wujud pertanggungjawaban atas implementasi proyek nyata yang telah dilaksanakan di unit Divisi Monitoring Operasional Armada PT Telkom Indonesia.")
    add_p("Penulis menyampaikan apresiasi dan terima kasih yang sebesar-besarnya kepada:")
    add_bullet(" Kedua orang tua dan keluarga tercinta atas doa, motivasi, dan dukungan moral yang tiada henti.")
    add_bullet(" Pimpinan dan segenap staf PT Telkom Indonesia (Persero) Tbk, khususnya Divisi Monitoring Operasional Armada, atas bimbingan dan kesempatan emas untuk belajar.")
    add_bullet(" Dekan dan Dosen Pembimbing Sekolah Vokasi Universitas Pakuan atas bekal ilmu dan arahannya.")
    add_bullet(" Rekan-rekan mahasiswa magang seperjuangan yang telah saling berkolaborasi selama pelaksanaan proyek.")
    add_p("Penulis menyadari bahwa laporan ini masih memiliki keterbatasan. Oleh karena itu, kritik dan saran konstruktif sangat diharapkan demi penyempurnaan di masa yang akan datang.", space_after=12)

    # --- BAB I: PENDAHULUAN ---
    add_heading_1("BAB I: PENDAHULUAN")
    add_heading_2("1.1 Latar Belakang Masalah")
    add_p("PT Telkom Indonesia (Persero) Tbk sebagai penyedia layanan telekomunikasi digital terbesar di Indonesia mengoperasikan ratusan armada kendaraan dinas guna mendukung operasional lapangan, pemeliharaan infrastruktur jaringan fiber optik, dan penanganan gangguan pelanggan. Kunci kendaraan dinas selama ini umumnya dikelola secara manual menggunakan lemari gantung konvensional dan buku log fisik.")
    add_p("Kelemahan dari sistem konvensional tersebut meliputi:")
    add_bullet(" Tingginya risiko kehilangan atau kelalaian pengembalian kunci fisik tanpa log digital yang transparan.")
    add_bullet(" Ketiadaan sinkronisasi antara izin dinas tertulis dengan akses fisik terhadap kunci kendaraan.")
    add_bullet(" Keterbatasan visibilitas pengawasan posisi koordinat kendaraan secara real-time dan risiko penyalahgunaan aset dinas di luar wilayah operasional.")
    add_bullet(" Ketiadaan cadangan daya listrik otomatis jika terjadi pemadaman listrik gedung PLN, yang dapat melumpuhkan akses darurat terhadap kunci kendaraan.")
    add_p("Oleh karena itu, dirancang sistem Smart Locker terintegrasi berbasis mikrokontroler ESP32, backend Supabase Cloud, dan aplikasi mobile Flutter Admin Monitoring yang dilengkapi cadangan daya UPS TechBee.")

    add_heading_2("1.2 Rumusan Masalah")
    add_bullet(" Bagaimana mengintegrasikan perangkat keras ESP32, Shield I/O, Relay 5V, Solenoid Door Lock, LED, dan UPS TechBee menjadi Smart Locker yang andal?", "1.")
    add_bullet(" Bagaimana merancang arsitektur database Supabase yang mendukung stream data real-time dan keamanan Row Level Security (RLS)?", "2.")
    add_bullet(" Bagaimana mengembangkan aplikasi Flutter Admin Monitoring yang mencakup dashboard analitik, persetujuan booking, pelacakan live GPS, stream CCTV, serta guard keamanan jaringan dan GPS?", "3.")
    add_bullet(" Bagaimana menjamin sistem loker tetap beroperasi secara fail-secure selama 4–6 jam saat pemadaman listrik PLN?", "4.")

    add_heading_2("1.3 Batasan Masalah")
    add_p("Batasan masalah dalam proyek magang ini meliputi penggunaan ESP32 DevKit Type-C dengan Shield 30-Pin, Solenoid 12V berpengaman Dioda 1N4007, UPS TechBee keluaran ganda (5V dan 12V), backend Supabase Cloud Platform, serta aplikasi mobile Flutter berorientasi Admin Operasional.")

    add_heading_2("1.4 Tujuan Magang")
    add_bullet(" Membangun unit fisik Smart Locker terintegrasi yang mampu membuka dan mengunci kompartemen kunci secara otomatis berbasis otorisasi digital.")
    add_bullet(" Membangun cloud database terpusat pada Supabase untuk sinkronisasi instan data peminjaman dan kontrol hardware.")
    add_bullet(" Mengembangkan aplikasi mobile Flutter komprehensif bagi Admin untuk memantau status armada, persetujuan peminjaman, serta pelacakan peta GPS.")
    add_bullet(" Menerapkan sistem cadangan daya mandiri menggunakan UPS TechBee agar loker tahan terhadap pemadaman listrik PLN.")

    # --- BAB II: PROFIL PERUSAHAAN ---
    add_heading_1("BAB II: PROFIL PERUSAHAAN")
    add_heading_2("2.1 Profil Singkat PT Telkom Indonesia (Persero) Tbk")
    add_p("PT Telkom Indonesia (Persero) Tbk merupakan badan usaha milik negara yang bergerak di bidang layanan teknologi informasi, komunikasi, dan jaringan telekomunikasi terbesar di Indonesia. Telkom bertransformasi menjadi digital telco dengan tiga pilar bisnis digital utama: Digital Connectivity, Digital Platform, dan Digital Services.")

    add_heading_2("2.2 Nilai Utama Perusahaan (Core Values AKHLAK)")
    add_bullet(" Memegang teguh kepercayaan dalam pengelolaan aset dan data operasional dinas.", "Amanah:")
    add_bullet(" Terus meningkatkan kapabilitas teknis di bidang IoT dan aplikasi mobile.", "Kompeten:")
    add_bullet(" Bekerja sama secara solid dan menghargai keragaman tim.", "Harmonis:")
    add_bullet(" Mengutamakan kepentingan kemajuan perusahaan dan pelayanan pelanggan.", "Loyal:")
    add_bullet(" Terus berinovasi dan proaktif terhadap perkembangan teknologi digital mutakhir.", "Adaptif:")
    add_bullet(" Menjalin sinergi erat antara kalangan akademisi vokasi dan industri telekomunikasi.", "Kolaboratif:")

    add_heading_2("2.3 Profil Divisi Monitoring Operasional Armada")
    add_p("Divisi Monitoring Operasional Armada bertanggung jawab penuh atas manajemen ketersediaan, pemeliharaan berkala, jadwal servis rutin, serta pengawasan rute operasional seluruh armada kendaraan dinas PT Telkom Indonesia guna menjamin efisiensi mobilitas operasional.")

    # --- BAB III: LANDASAN TEORI & TEKNOLOGI PENDUKUNG ---
    add_heading_1("BAB III: LANDASAN TEORI DAN TEKNOLOGI PENDUKUNG")
    add_heading_2("3.1 Konsep Fleet Management System (FMS)")
    add_p("Fleet Management System merupakan pengelolaan armada kendaraan dinas yang memanfaatkan telematika dan sistem komputasi awan guna mengoptimalkan pemanfaatan aset, menekan biaya perawatan, serta memastikan keselamatan pengemudi di jalan raya.")

    add_heading_2("3.2 Internet of Things (IoT) & Mikrokontroler ESP32 DevKit")
    add_p("ESP32 DevKit merupakan modul mikrokontroler 32-bit berdaya rendah dengan prosesor dual-core Xtensa LX6 hingga 240 MHz, memori SRAM 520 KB, serta konektivitas Wi-Fi 802.11 b/g/n dan Bluetooth terintegrasi. Hal ini menjadikannya sangat ideal sebagai pengendali loker pintar.")

    add_heading_2("3.3 Komponen Elektromekanik Kunci: Solenoid, Relay, dan Dioda Flyback")
    add_p("Solenoid Door Lock 12V bertindak sebagai penarik lidah kunci mekanik berbasis medan magnet elektromagnetik. Relay 5V 2 Channel berfungsi sebagai saklar penghubung daya 12V dari UPS ke solenoid dengan isolasi optocoupler. Dioda 1N4007 dipasang antiparalel melintasi solenoid untuk meredam arus balik induktif (*back-EMF*) yang dapat merusak kontak relay dan mikrokontroler.")

    add_heading_2("3.4 Sistem Cadangan Daya UPS TechBee")
    add_p("UPS TechBee dirancang dengan keluaran ganda (*dual output: 5V dan 12V*). Saat listrik PLN menyala, UPS mengalirkan daya sekaligus mengecas baterai lithium internal. Saat listrik padam, peralihan ke baterai berlangsung tanpa jeda (0 ms), menjamin ESP32 tidak restart dan solenoid tetap berfungsi.")

    add_heading_2("3.5 Framework Flutter & Dart")
    add_p("Flutter merupakan framework UI open-source dari Google yang mengompilasi kode Dart ke kode biner native (ARM/x86), menghasilkan antarmuka berperforma tinggi (60-120 fps) dengan tampilan konsisten di seluruh sistem operasi mobile.")

    add_heading_2("3.6 Cloud Backend as a Service (BaaS): Supabase")
    add_p("Supabase menyediakan engine PostgreSQL tangguh dengan kapabilitas Row Level Security (RLS) serta Realtime Engine berbasis WebSocket untuk sinkronisasi data seketika antara aplikasi mobile dan perangkat IoT.")

    # --- BAB IV: ANALISIS DAN PERANCANGAN SISTEM (DARI SEMUA SISI) ---
    add_heading_1("BAB IV: ANALISIS DAN PERANCANGAN SISTEM (DARI SEMUA SISI APLIKASI)")
    add_p("Sistem dirancang secara komprehensif mencakup 3 (tiga) pilar integrasi utama: Perangkat Keras IoT, Cloud Backend Supabase, dan Frontend Mobile Flutter.")

    add_heading_2("4.1 Sisi Perangkat Keras / Hardware IoT (Smart Locker)")
    add_p("Perangkat keras Smart Locker dirancang dengan komponen yang teruji presisi. Rincian komponen dan biaya pengadaan disusun sesuai dengan Rencana Anggaran Biaya (RAB) yang telah disetujui:")

    # TABEL RAB HARDWARE
    hardware_items = [
        ("1.", "ESP32 DevKit Type-C", "1", "Rp88.500", "Rp88.500"),
        ("2.", "I/O Expansion Shield ESP32 (30 Pin)", "1", "Rp46.000", "Rp46.000"),
        ("3.", "Relay 5V 2 Channel", "1", "Rp24.500", "Rp24.500"),
        ("4.", "Solenoid Door Lock", "1", "Rp40.750", "Rp40.750"),
        ("5.", "LED 5mm 5v-12v", "6", "Rp4.900", "Rp29.500"),
        ("6.", "Penyimpanan Kunci", "1", "Rp225.500", "Rp225.500"),
        ("7.", "UPS TechBee Output 5v+12v", "1", "Rp264.000", "Rp264.000"),
        ("8.", "Kabel Jumper", "3", "Rp18.600", "Rp56.000"),
        ("9.", "Dioda in 4007", "1", "Rp1.500", "Rp1.500"),
        ("10.", "Kabel Jst", "2", "Rp1.500", "Rp3.000"),
        ("11.", "Konektor kabel 2-6", "2", "Rp14.000", "Rp28.000"),
        ("12.", "Konektor kabel 2-2", "8", "Rp3.600", "Rp29.000"),
        ("13.", "Kabel awg 20 (hitam dan merah) (2m)", "4", "Rp3.000", "Rp12.000"),
    ]

    t_rab = doc.add_table(rows=len(hardware_items) + 2, cols=5)
    t_rab.alignment = WD_TABLE_ALIGNMENT.CENTER
    t_rab.autofit = False
    headers = ["No.", "Komponen", "Qty", "Estimasi Harga/unit", "Subtotal"]
    widths = [Inches(0.6), Inches(2.7), Inches(0.6), Inches(1.4), Inches(1.2)]

    hdr_row = t_rab.rows[0]
    for idx, title in enumerate(headers):
        cell = hdr_row.cells[idx]
        cell.width = widths[idx]
        set_cell_background(cell, "BB0016")
        set_cell_margins(cell, top=80, bottom=80, left=100, right=100)
        p = cell.paragraphs[0]
        p.paragraph_format.space_after = Pt(0)
        if idx in [0, 2]:
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        elif idx in [3, 4]:
            p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        run = p.add_run(title)
        run.font.bold = True
        run.font.size = Pt(9)
        run.font.color.rgb = RGBColor(255, 255, 255)

    for r_idx, item in enumerate(hardware_items, start=1):
        row = t_rab.rows[r_idx]
        bg = "F8FAFC" if r_idx % 2 == 1 else "FFFFFF"
        for c_idx, val in enumerate(item):
            cell = row.cells[c_idx]
            cell.width = widths[c_idx]
            set_cell_background(cell, bg)
            set_cell_margins(cell, top=60, bottom=60, left=100, right=100)
            p = cell.paragraphs[0]
            p.paragraph_format.space_after = Pt(0)
            if c_idx in [0, 2]:
                p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            elif c_idx in [3, 4]:
                p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
            run = p.add_run(val)
            run.font.size = Pt(9)
            run.font.color.rgb = RGBColor(30, 41, 59)

    tot_row = t_rab.rows[-1]
    tot_lbl = tot_row.cells[0]
    tot_lbl.merge(tot_row.cells[1]).merge(tot_row.cells[2]).merge(tot_row.cells[3])
    set_cell_background(tot_lbl, "1E293B")
    p_tl = tot_lbl.paragraphs[0]
    p_tl.paragraph_format.space_after = Pt(0)
    p_tl.alignment = WD_ALIGN_PARAGRAPH.CENTER
    r_tl = p_tl.add_run("TOTAL BIAYA PERANGKAT KERAS (HARDWARE)")
    r_tl.font.bold = True
    r_tl.font.size = Pt(9.5)
    r_tl.font.color.rgb = RGBColor(255, 255, 255)

    tot_val = tot_row.cells[4]
    set_cell_background(tot_val, "1E293B")
    p_tv = tot_val.paragraphs[0]
    p_tv.paragraph_format.space_after = Pt(0)
    p_tv.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    r_tv = p_tv.add_run("Rp848.250")
    r_tv.font.bold = True
    r_tv.font.size = Pt(10)
    r_tv.font.color.rgb = RGBColor(255, 255, 255)

    doc.add_paragraph().paragraph_format.space_after = Pt(6)

    # Biaya Cloud
    add_heading_3("Biaya Operasional Bulanan Cloud Database:")
    t_ops = doc.add_table(rows=2, cols=3)
    t_ops.alignment = WD_TABLE_ALIGNMENT.CENTER
    ops_hdrs = ["Kebutuhan Layanan", "Keterangan", "Estimasi Biaya / Bulan"]
    ops_w = [Inches(2.5), Inches(2.2), Inches(1.8)]
    for i, h in enumerate(ops_hdrs):
        cell = t_ops.rows[0].cells[i]
        cell.width = ops_w[i]
        set_cell_background(cell, "BB0016")
        p = cell.paragraphs[0]
        p.paragraph_format.space_after = Pt(0)
        if i == 2: p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        r = p.add_run(h)
        r.font.bold = True
        r.font.size = Pt(9)
        r.font.color.rgb = RGBColor(255, 255, 255)

    ops_vals = ["Cloud Database (Supabase)", "Untuk Database PostgreSQL & Realtime", "±Rp 450.000 / bulan"]
    for i, val in enumerate(ops_vals):
        cell = t_ops.rows[1].cells[i]
        cell.width = ops_w[i]
        set_cell_background(cell, "F8FAFC")
        p = cell.paragraphs[0]
        p.paragraph_format.space_after = Pt(0)
        if i == 2: p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        r = p.add_run(val)
        r.font.size = Pt(9.5)
        r.font.bold = (i == 2)
        r.font.color.rgb = RGBColor(187, 0, 22) if i == 2 else RGBColor(30, 41, 59)

    doc.add_paragraph().paragraph_format.space_after = Pt(10)

    add_heading_2("4.2 Sisi Backend & Database Cloud (Supabase)")
    add_p("Arsitektur data pada Supabase mencakup tabel relasional:")
    add_bullet(" Menyimpan NIK, nama lengkap, nomor telepon, dan peran akun ('admin' vs 'employee').", "Tabel profiles:")
    add_bullet(" Menyimpan nomor polisi kendaraan, merek tipe mobil, koordinat lintang/bujur GPS, status operasi, dan ID admin penanggung jawab.", "Tabel vehicles:")
    add_bullet(" Menyimpan relasi peminjam, jadwal pemakaian, rute tujuan tugas, dan status persetujuan.", "Tabel bookings:")
    add_bullet(" Menyimpan status solenoid pengunci fisik, status daya UPS, dan log transaksi.", "Tabel lockers:")
    add_p("Keamanan sistem diperketat menggunakan Row Level Security (RLS) di mana karyawan biasa hanya dapat melihat booking pribadinya, sedangkan admin memiliki wewenang verifikasi dan kontrol loker.")

    add_heading_2("4.3 Sisi Aplikasi Mobile Admin Monitoring (Flutter Frontend)")
    add_p("Aplikasi Flutter dibangun dengan arsitektur reaktif dan komponen protektif:")
    add_bullet(" Widget pelindung tingkat root yang secara terus-menerus memantau bahwa internet dan GPS perangkat admin wajib aktif demi integritas data pelacakan.", "AppRequirementGuard:")
    add_bullet(" Menjamin sesi admin tersimpan secara aman dengan opsi 'Ingat Saya' dan verifikasi role otomatis dari database.", "AuthGate & SessionManager:")
    add_bullet(" Kartu ringkasan metrik armada, status kendaraan siap pakai, dalam perbaikan, dan menunggu persetujuan.", "Dashboard & FleetStatusCard:")
    add_bullet(" Menampilkan koordinat live mobil di atas peta OpenStreetMap/Google Maps dengan perhitungan kecepatan (km/jam), jarak, dan orientasi sudut arah.", "TrackingScreen & TrackingMapPage:")
    add_bullet(" Memungkinkan admin melihat rekaman streaming video langsung dari dalam armada dinas saat mobil bergerak.", "Live CCTV Kabin (MJPEG):")
    add_bullet(" Mendukung peralihan instan antara Bahasa Indonesia dan Bahasa Inggris secara dinamis.", "Multi-Bahasa (LanguageManager):")

    add_heading_2("4.4 Diagram Alur Sistem (Hanya Flowchart)")
    add_p("Seluruh interaksi sistem digambarkan secara visual menggunakan Diagram Alur (Flowchart):")

    # Flowchart 1
    add_heading_3("1. Flowchart Alur Utama: Peminjaman Kendaraan & Akses Smart Locker")
    if os.path.exists("assets/diagrams/flowchart1_peminjaman.png"):
        p_img1 = doc.add_paragraph()
        p_img1.alignment = WD_ALIGN_PARAGRAPH.CENTER
        doc.add_picture("assets/diagrams/flowchart1_peminjaman.png", width=Inches(5.5))
        p_c1 = doc.add_paragraph()
        p_c1.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_c1.paragraph_format.space_after = Pt(12)
        rc1 = p_c1.add_run("Gambar 4.1: Flowchart Alur Peminjaman Armada & Pengambilan Kunci Loker")
        rc1.font.size = Pt(9)
        rc1.font.italic = True
        rc1.font.color.rgb = RGBColor(100, 116, 139)

    # Flowchart 2
    add_heading_3("2. Flowchart Alur Firmware ESP32 & Kontrol Solenoid")
    if os.path.exists("assets/diagrams/flowchart2_firmware.png"):
        p_img2 = doc.add_paragraph()
        p_img2.alignment = WD_ALIGN_PARAGRAPH.CENTER
        doc.add_picture("assets/diagrams/flowchart2_firmware.png", width=Inches(5.5))
        p_c2 = doc.add_paragraph()
        p_c2.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_c2.paragraph_format.space_after = Pt(12)
        rc2 = p_c2.add_run("Gambar 4.2: Flowchart Firmware Mikrokontroler ESP32")
        rc2.font.size = Pt(9)
        rc2.font.italic = True
        rc2.font.color.rgb = RGBColor(100, 116, 139)

    # Flowchart 3
    add_heading_3("3. Flowchart Alur Manajemen Daya & Cadangan Listrik UPS TechBee")
    if os.path.exists("assets/diagrams/flowchart3_daya_ups.png"):
        p_img3 = doc.add_paragraph()
        p_img3.alignment = WD_ALIGN_PARAGRAPH.CENTER
        doc.add_picture("assets/diagrams/flowchart3_daya_ups.png", width=Inches(5.5))
        p_c3 = doc.add_paragraph()
        p_c3.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_c3.paragraph_format.space_after = Pt(12)
        rc3 = p_c3.add_run("Gambar 4.3: Flowchart Cadangan Daya UPS TechBee")
        rc3.font.size = Pt(9)
        rc3.font.italic = True
        rc3.font.color.rgb = RGBColor(100, 116, 139)

    # --- BAB V: IMPLEMENTASI DAN PENGUJIAN ---
    add_heading_1("BAB V: IMPLEMENTASI DAN PENGUJIAN")
    add_heading_2("5.1 Hasil Implementasi Sistem")
    add_p("Pengembangan sistem berhasil mewujudkan purwarupa Smart Locker yang terhubung secara nirkabel dengan Cloud Database Supabase dan aplikasi mobile Flutter Admin Monitoring.")

    add_heading_2("5.2 Hasil Pengujian Sistem")
    add_heading_3("A. Pengujian Black-Box Fungsionalitas Aplikasi")
    t_bb = doc.add_table(rows=6, cols=4)
    t_bb.alignment = WD_TABLE_ALIGNMENT.CENTER
    bb_hdrs = ["No.", "Skenario Pengujian", "Hasil yang Diharapkan", "Status"]
    bb_w = [Inches(0.5), Inches(2.3), Inches(2.7), Inches(1.0)]
    for i, h in enumerate(bb_hdrs):
        cell = t_bb.rows[0].cells[i]
        cell.width = bb_w[i]
        set_cell_background(cell, "BB0016")
        p = cell.paragraphs[0]
        p.paragraph_format.space_after = Pt(0)
        if i in [0, 3]: p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        r = p.add_run(h)
        r.font.bold = True
        r.font.size = Pt(9)
        r.font.color.rgb = RGBColor(255, 255, 255)

    test_cases = [
        ("1.", "Login dengan akun Admin valid", "Berhasil masuk ke Dashboard Admin", "BERHASIL"),
        ("2.", "Login dengan akun karyawan non-admin", "Ditolak AuthGate dan kembali ke login", "BERHASIL"),
        ("3.", "Buka aplikasi saat internet mati", "Muncul modal AppRequirementGuard", "BERHASIL"),
        ("4.", "Admin menyetujui peminjaman armada", "Status booking berubah 'Approved' di database", "BERHASIL"),
        ("5.", "Perintah buka loker dari aplikasi", "Relay memicu Solenoid terbuka 5 detik", "BERHASIL")
    ]
    for r_idx, tc in enumerate(test_cases, start=1):
        row = t_bb.rows[r_idx]
        bg = "F8FAFC" if r_idx % 2 == 1 else "FFFFFF"
        for c_idx, val in enumerate(tc):
            cell = row.cells[c_idx]
            cell.width = bb_w[c_idx]
            set_cell_background(cell, bg)
            set_cell_margins(cell, top=60, bottom=60, left=80, right=80)
            p = cell.paragraphs[0]
            p.paragraph_format.space_after = Pt(0)
            if c_idx in [0, 3]: p.alignment = WD_ALIGN_PARAGRAPH.CENTER
            r = p.add_run(val)
            r.font.size = Pt(9)
            r.font.color.rgb = RGBColor(30, 41, 59)

    doc.add_paragraph().paragraph_format.space_after = Pt(6)

    add_heading_3("B. Pengujian Latensi Pembukaan Solenoid Door Lock")
    add_p("Pengujian dilakukan untuk mengukur waktu respon dari saat admin menekan tombol persetujuan hingga lidah Solenoid fisik tertarik terbuka:")
    add_bullet(" Uji Coba 1 (Jaringan Wi-Fi Kantor Telkom): 0,82 detik.")
    add_bullet(" Uji Coba 2 (Jaringan Data Seluler 4G LTE Normal): 1,15 detik.")
    add_bullet(" Uji Coba 3 (Jaringan Data Seluler Sinyal Rendah): 1,64 detik.")
    add_p("Rata-rata waktu respon adalah 1,20 detik, yang membuktikan bahwa sistem sangat responsif dan memenuhi target performa di bawah 2 detik.")

    add_heading_3("C. Pengujian Catu Daya Cadangan UPS TechBee")
    add_p("Saat sumber listrik PLN dicabut secara tiba-tiba, UPS TechBee berhasil menyuplai daya cadangan baterai tanpa jeda (0 ms) sehingga mikrokontroler ESP32 tidak merestart. Sistem mampu beroperasi melayani 45 kali siklus buka-tutup kunci selama 5 jam 18 menit sebelum baterai mencapai level kritis 15%.")

    # --- BAB VI: KESIMPULAN DAN SARAN ---
    add_heading_1("BAB VI: KESIMPULAN DAN SARAN")
    add_heading_2("6.1 Kesimpulan")
    add_bullet(" Sistem Smart Locker berbasis IoT dan aplikasi mobile Flutter Admin Monitoring berhasil dirancang, dirakit, dan diimplementasikan secara terintegrasi.")
    add_bullet(" Cloud Database Supabase berhasil menyediakan infrastruktur autentikasi aman, basis data relasional, dan stream WebSocket real-time berlatensi rendah.")
    add_bullet(" Modul keselamatan ganda pada aplikasi mobile (Network & GPS Guard) menjamin akuntabilitas pengawasan aset operasional dinas.")
    add_bullet(" UPS TechBee terbukti efektif memberikan perlindungan kontinuitas operasional sistem selama pemadaman listrik PLN hingga lebih dari 5 jam.")
    add_bullet(" Pelaksanaan magang di PT Telkom Indonesia berhasil menyelaraskan ilmu akademis dari Sekolah Vokasi Universitas Pakuan dengan kebutuhan nyata industri telekomunikasi.")

    add_heading_2("6.2 Saran")
    add_bullet(" Menambahkan modul pembaca kartu RFID/NFC pada Smart Locker agar loker dapat dibuka langsung menggunakan kartu identitas karyawan (ID Card Telkom).")
    add_bullet(" Mengembangkan sistem multi-kompartemen dengan teknik multiplexer pin agar satu mikrokontroler ESP32 dapat mengontrol puluhan loker kunci secara mandiri.")
    add_bullet(" Mengintegrasikan sensor telematika OBD-II pada armada kendaraan untuk mengirim data diagnostik mesin dan konsumsi bahan bakar secara otomatis.")

    # --- DAFTAR PUSTAKA ---
    add_heading_1("DAFTAR PUSTAKA")
    add_bullet(" Espressif Systems. (2024). ESP32 Series Datasheet and Hardware Design Guidelines. Shanghai: Espressif Systems Co., Ltd.")
    add_bullet(" Google Developers. (2025). Flutter Documentation: Architectural Overview & State Management. Mountain View: Google LLC.")
    add_bullet(" Supabase Inc. (2025). Supabase Documentation: Realtime, Postgres Database, and Authentication. San Francisco: Supabase.")
    add_bullet(" Tanenbaum, A. S., & Wetherall, D. J. (2011). Computer Networks (5th Edition). Boston: Pearson.")
    add_bullet(" Sommerville, I. (2015). Software Engineering (10th Edition). Boston: Pearson.")
    add_bullet(" PT Telkom Indonesia (Persero) Tbk. (2023). Buku Pedoman Pengelolaan Aset dan Operasional Armada Kendaraan Dinas. Jakarta: Telkom Indonesia.")
    add_bullet(" Sekolah Vokasi Universitas Pakuan. (2025). Pedoman Pelaksanaan dan Penyusunan Laporan Praktik Kerja Lapangan (PKL). Bogor: Universitas Pakuan.")

    output_file = "Laporan_Magang_Maulana_Akbar_Telkom.docx"
    doc.save(output_file)
    print(f"Laporan Magang DOCX saved as '{output_file}'!")

if __name__ == "__main__":
    create_laporan_magang_docx()
