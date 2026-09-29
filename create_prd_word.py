import os
from PIL import Image, ImageDraw, ImageFont
import docx
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT, WD_ALIGN_VERTICAL
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

# --- 1. GENERATE FLOWCHART DIAGRAMS LOCALLY ---
os.makedirs("assets/diagrams", exist_ok=True)
font_regular = "C:/Windows/Fonts/segoeui.ttf"
font_bold = "C:/Windows/Fonts/segoeuib.ttf" if os.path.exists("C:/Windows/Fonts/segoeuib.ttf") else font_regular

def get_font(size, bold=False):
    fp = font_bold if bold else font_regular
    try:
        return ImageFont.truetype(fp, size)
    except:
        return ImageFont.load_default()

def draw_arrow(draw, start, end, color=(100, 116, 139), width=3, text=None, text_offset=(10, -10)):
    x1, y1 = start
    x2, y2 = end
    draw.line([start, end], fill=color, width=width)
    
    # Arrow head
    import math
    angle = math.atan2(y2 - y1, x2 - x1)
    arrow_len = 12
    arrow_angle = math.pi / 6
    
    px1 = x2 - arrow_len * math.cos(angle - arrow_angle)
    py1 = y2 - arrow_len * math.sin(angle - arrow_angle)
    px2 = x2 - arrow_len * math.cos(angle + arrow_angle)
    py2 = y2 - arrow_len * math.sin(angle + arrow_angle)
    
    draw.polygon([(x2, y2), (px1, py1), (px2, py2)], fill=color)
    
    if text:
        f = get_font(14, bold=True)
        tx = (x1 + x2) / 2 + text_offset[0]
        ty = (y1 + y2) / 2 + text_offset[1]
        draw.text((tx, ty), text, fill=color, font=f)

def draw_rounded_rect(draw, bbox, fill, outline, width=2, radius=12):
    draw.rounded_rectangle(bbox, radius=radius, fill=fill, outline=outline, width=width)

def draw_diamond(draw, bbox, fill, outline, width=2):
    x1, y1, x2, y2 = bbox
    cx, cy = (x1 + x2) / 2, (y1 + y2) / 2
    pts = [(cx, y1), (x2, cy), (cx, y2), (x1, cy)]
    draw.polygon(pts, fill=fill, outline=outline)
    draw.line(pts + [(cx, y1)], fill=outline, width=width)

def draw_node_text(draw, bbox, text, text_color=(255, 255, 255), font_size=15, bold=False):
    f = get_font(font_size, bold)
    lines = text.split("\n")
    x1, y1, x2, y2 = bbox
    cx, cy = (x1 + x2) / 2, (y1 + y2) / 2
    
    # Calculate total height
    line_height = font_size + 4
    total_h = len(lines) * line_height
    start_y = cy - (total_h / 2)
    
    for i, line in enumerate(lines):
        bbox_t = draw.textbbox((0, 0), line, font=f)
        tw = bbox_t[2] - bbox_t[0]
        tx = cx - (tw / 2)
        ty = start_y + (i * line_height)
        draw.text((tx, ty), line, fill=text_color, font=f)

# === FLOWCHART 1: Alur Peminjaman & Buka Loker ===
def generate_flowchart_1():
    img_w, img_h = 1000, 1420
    im = Image.new("RGBA", (img_w, img_h), (255, 255, 255, 255))
    d = ImageDraw.Draw(im)
    
    # Title
    f_title = get_font(24, bold=True)
    d.text((500, 35), "FLOWCHART ALUR PEMINJAMAN & AKSES SMART LOCKER", fill=(187, 0, 22), font=f_title, anchor="mm")
    
    cx = 500
    w_box = 440
    h_box = 65
    
    steps = [
        ("Mulai: Karyawan Mengajukan Peminjaman\nvia Aplikasi Mobile Fleet", (37, 99, 235), "start", 90),
        ("Karyawan Memilih Armada & Jam Pemakaian\nInput Keperluan Dinas", (51, 65, 85), "box", 200),
        ("Status Persetujuan\nAdmin Operasional?", (217, 119, 6), "diamond", 325),
        ("Sistem Memperbarui Status Booking ke 'Approved'\nNotifikasi Akses Dikirim ke Aplikasi Karyawan", (51, 65, 85), "box", 490),
        ("Karyawan Mendatangi Unit Smart Locker Fisik\nTekan Tombol 'Buka Loker' di Aplikasi", (51, 65, 85), "box", 605),
        ("Supabase Mengirim Sinyal Buka ke ESP32\nvia Real-Time WebSocket / Secure API", (124, 58, 237), "box", 720),
        ("ESP32 Memicu Relay 5V Channel 1\nSolenoid Door Lock Terbuka (12V) Selama 5 Detik", (187, 0, 22), "box", 835),
        ("LED Hijau Menyala Sebagai Indikator Terbuka\nKaryawan Mengambil Kunci Kendaraan", (13, 148, 136), "box", 950),
        ("Pintu Loker Ditutup & Solenoid Mengunci Kembali\nSensor / Relay Mengirim Status Tertutup", (51, 65, 85), "box", 1065),
        ("ESP32 Mengupdate Status Kunci ke Supabase\nStatus Kendaraan Berubah 'In-Use'", (124, 58, 237), "box", 1180),
        ("Selesai: Transaksi Berjalan & Armada Siap Dipantau", (22, 163, 74), "end", 1300)
    ]
    
    # Draw branches first
    # Rejected branch from diamond (y=325)
    # Diamond bbox: cx=500, cy=325, w=300, h=110 -> x1=350, y1=270, x2=650, y2=380
    draw_diamond(d, (350, 270, 650, 380), fill=(254, 243, 199), outline=(217, 119, 6), width=3)
    draw_node_text(d, (350, 270, 650, 380), "Persetujuan Admin?", text_color=(180, 83, 9), font_size=16, bold=True)
    
    # Arrow to rejection (Right)
    draw_arrow(d, (650, 325), (820, 325), color=(220, 38, 38), width=3, text="Ditolak", text_offset=(15, -18))
    # Box rejection
    draw_rounded_rect(d, (720, 380, 920, 450), fill=(254, 226, 226), outline=(220, 38, 38), width=2, radius=8)
    draw_node_text(d, (720, 380, 920, 450), "Peminjaman Ditolak\nNotifikasi ke Pemohon", text_color=(185, 28, 28), font_size=13, bold=True)
    draw_arrow(d, (820, 325), (820, 380), color=(220, 38, 38), width=3)
    
    # End node rejection
    draw_rounded_rect(d, (740, 480, 900, 530), fill=(239, 68, 68), outline=(185, 28, 28), width=2, radius=20)
    draw_node_text(d, (740, 480, 900, 530), "Selesai (Ditolak)", text_color=(255, 255, 255), font_size=13, bold=True)
    draw_arrow(d, (820, 450), (820, 480), color=(220, 38, 38), width=3)
    
    # Down arrow Disetujui
    draw_arrow(d, (500, 380), (500, 490), color=(22, 163, 74), width=3, text="Disetujui", text_offset=(10, -10))
    
    # Other steps
    for item in steps:
        txt, col, ntype, y = item
        if ntype == "diamond":
            continue
        bbox = (cx - w_box//2, y - h_box//2, cx + w_box//2, y + h_box//2)
        if ntype in ["start", "end"]:
            draw_rounded_rect(d, bbox, fill=col, outline=(30, 41, 59), width=2, radius=25)
            draw_node_text(d, bbox, txt, text_color=(255, 255, 255), font_size=14, bold=True)
        else:
            draw_rounded_rect(d, bbox, fill=(241, 245, 249), outline=col, width=3, radius=10)
            draw_node_text(d, bbox, txt, text_color=(15, 23, 42), font_size=14, bold=True)
            
    # Connect standard arrows
    draw_arrow(d, (500, 90 + 32), (500, 200 - 32), color=(71, 85, 105))
    draw_arrow(d, (500, 200 + 32), (500, 270), color=(71, 85, 105))
    
    draw_arrow(d, (500, 490 + 32), (500, 605 - 32), color=(71, 85, 105))
    draw_arrow(d, (500, 605 + 32), (500, 720 - 32), color=(71, 85, 105))
    draw_arrow(d, (500, 720 + 32), (500, 835 - 32), color=(71, 85, 105))
    draw_arrow(d, (500, 835 + 32), (500, 950 - 32), color=(71, 85, 105))
    draw_arrow(d, (500, 950 + 32), (500, 1065 - 32), color=(71, 85, 105))
    draw_arrow(d, (500, 1065 + 32), (500, 1180 - 32), color=(71, 85, 105))
    draw_arrow(d, (500, 1180 + 32), (500, 1300 - 32), color=(71, 85, 105))
    
    im.save("assets/diagrams/flowchart1_peminjaman.png", "PNG", dpi=(300, 300))

# === FLOWCHART 2: Firmware ESP32 & Solenoid ===
def generate_flowchart_2():
    img_w, img_h = 1000, 1380
    im = Image.new("RGBA", (img_w, img_h), (255, 255, 255, 255))
    d = ImageDraw.Draw(im)
    
    f_title = get_font(24, bold=True)
    d.text((500, 35), "FLOWCHART FIRMWARE ESP32 & KONTROL SOLENOID", fill=(187, 0, 22), font=f_title, anchor="mm")
    
    cx = 500
    w_box = 440
    h_box = 65
    
    # 1. Start
    draw_rounded_rect(d, (cx-w_box//2, 80-30, cx+w_box//2, 80+30), fill=(37, 99, 235), outline=(30, 41, 59), width=2, radius=25)
    draw_node_text(d, (cx-w_box//2, 80-30, cx+w_box//2, 80+30), "Mulai: Booting Microcontroller ESP32\nInisialisasi Shield 30-Pin & Pin I/O", text_color=(255, 255, 255), font_size=14, bold=True)
    
    draw_arrow(d, (500, 110), (500, 170))
    
    # 2. Config Wi-Fi
    draw_rounded_rect(d, (cx-w_box//2, 170, cx+w_box//2, 230), fill=(241, 245, 249), outline=(51, 65, 85), width=3, radius=10)
    draw_node_text(d, (cx-w_box//2, 170, cx+w_box//2, 230), "Konfigurasi Mode Wi-Fi Station\n& Mencoba Hubungkan ke SSID Kantor", text_color=(15, 23, 42), font_size=14, bold=True)
    
    draw_arrow(d, (500, 230), (500, 290))
    
    # 3. Decision Wi-Fi
    draw_diamond(d, (350, 290, 650, 390), fill=(254, 243, 199), outline=(217, 119, 6), width=3)
    draw_node_text(d, (350, 290, 650, 390), "Wi-Fi Terhubung?", text_color=(180, 83, 9), font_size=16, bold=True)
    
    # No Wi-Fi (loop right)
    draw_arrow(d, (650, 340), (820, 340), color=(220, 38, 38), width=3, text="Tidak", text_offset=(15, -18))
    draw_rounded_rect(d, (720, 220, 920, 280), fill=(254, 226, 226), outline=(220, 38, 38), width=2, radius=8)
    draw_node_text(d, (720, 220, 920, 280), "LED Error Berkedip\nDelay 3s & Retry", text_color=(185, 28, 28), font_size=13, bold=True)
    draw_arrow(d, (820, 340), (820, 280), color=(220, 38, 38), width=3)
    draw_arrow(d, (720, 250), (cx+w_box//2, 200), color=(220, 38, 38), width=3)
    
    # Yes Wi-Fi (Down)
    draw_arrow(d, (500, 390), (500, 460), color=(22, 163, 74), width=3, text="Ya", text_offset=(10, -10))
    
    # 4. Listen Supabase
    draw_rounded_rect(d, (cx-w_box//2, 460, cx+w_box//2, 520), fill=(241, 245, 249), outline=(124, 58, 237), width=3, radius=10)
    draw_node_text(d, (cx-w_box//2, 460, cx+w_box//2, 520), "Koneksi ke Supabase Client\nSubscribe ke Channel Real-Time 'lockers'", text_color=(15, 23, 42), font_size=14, bold=True)
    
    draw_arrow(d, (500, 520), (500, 580))
    
    # 5. Decision Message
    draw_diamond(d, (350, 580, 650, 680), fill=(254, 243, 199), outline=(217, 119, 6), width=3)
    draw_node_text(d, (350, 580, 650, 680), "Perintah Buka Diterima?", text_color=(180, 83, 9), font_size=16, bold=True)
    
    # No message loop left
    draw_arrow(d, (350, 630), (180, 630), color=(100, 116, 139), width=3, text="Tidak", text_offset=(-60, -18))
    draw_line_pts = [(180, 630), (180, 490), (cx-w_box//2, 490)]
    d.line([(180, 630), (180, 490)], fill=(100, 116, 139), width=3)
    draw_arrow(d, (180, 490), (cx-w_box//2, 490), color=(100, 116, 139), width=3)
    
    # Yes message (Down)
    draw_arrow(d, (500, 680), (500, 750), color=(22, 163, 74), width=3, text="Ya", text_offset=(10, -10))
    
    # 6. Trigger Relay
    draw_rounded_rect(d, (cx-w_box//2, 750, cx+w_box//2, 810), fill=(241, 245, 249), outline=(187, 0, 22), width=3, radius=10)
    draw_node_text(d, (cx-w_box//2, 750, cx+w_box//2, 810), "Set Pin Relay 5V Channel 1 = HIGH\nArus 12V Mengalir ke Solenoid Door Lock", text_color=(15, 23, 42), font_size=14, bold=True)
    
    draw_arrow(d, (500, 810), (500, 870))
    
    # 7. LED ON & Timer
    draw_rounded_rect(d, (cx-w_box//2, 870, cx+w_box//2, 930), fill=(241, 245, 249), outline=(13, 148, 136), width=3, radius=10)
    draw_node_text(d, (cx-w_box//2, 870, cx+w_box//2, 930), "Nyalakan LED Indikator Hijau (Akses Buka)\nJalankan Timer Countdown 5 Detik", text_color=(15, 23, 42), font_size=14, bold=True)
    
    draw_arrow(d, (500, 930), (500, 990))
    
    # 8. Relay OFF
    draw_rounded_rect(d, (cx-w_box//2, 990, cx+w_box//2, 1050), fill=(241, 245, 249), outline=(187, 0, 22), width=3, radius=10)
    draw_node_text(d, (cx-w_box//2, 990, cx+w_box//2, 1050), "Timer Habis -> Set Pin Relay = LOW\nSolenoid Lock Terkunci Kembali & LED Standby", text_color=(15, 23, 42), font_size=14, bold=True)
    
    draw_arrow(d, (500, 1050), (500, 1110))
    
    # 9. Send ACK
    draw_rounded_rect(d, (cx-w_box//2, 1110, cx+w_box//2, 1170), fill=(241, 245, 249), outline=(124, 58, 237), width=3, radius=10)
    draw_node_text(d, (cx-w_box//2, 1110, cx+w_box//2, 1170), "Kirim Konfirmasi Berhasil (ACK & Timestamp)\nke Database Supabase", text_color=(15, 23, 42), font_size=14, bold=True)
    
    draw_arrow(d, (500, 1170), (500, 1230))
    
    # 10. Loop back to standby
    draw_rounded_rect(d, (cx-w_box//2, 1230, cx+w_box//2, 1290), fill=(37, 99, 235), outline=(30, 41, 59), width=2, radius=25)
    draw_node_text(d, (cx-w_box//2, 1230, cx+w_box//2, 1290), "Status Kembali Standby (Siaga Perintah Baru)", text_color=(255, 255, 255), font_size=14, bold=True)
    
    im.save("assets/diagrams/flowchart2_firmware.png", "PNG", dpi=(300, 300))

# === FLOWCHART 3: Manajemen Daya & UPS ===
def generate_flowchart_3():
    img_w, img_h = 1000, 1100
    im = Image.new("RGBA", (img_w, img_h), (255, 255, 255, 255))
    d = ImageDraw.Draw(im)
    
    f_title = get_font(24, bold=True)
    d.text((500, 35), "FLOWCHART MANAJEMEN DAYA & CADANGAN LISTRIK UPS", fill=(187, 0, 22), font=f_title, anchor="mm")
    
    cx = 500
    w_box = 440
    h_box = 65
    
    # 1. Start
    draw_rounded_rect(d, (cx-w_box//2, 80-30, cx+w_box//2, 80+30), fill=(37, 99, 235), outline=(30, 41, 59), width=2, radius=25)
    draw_node_text(d, (cx-w_box//2, 80-30, cx+w_box//2, 80+30), "Mulai: Sistem Smart Locker Beroperasi\nTerhubung ke UPS TechBee Output 5V + 12V", text_color=(255, 255, 255), font_size=14, bold=True)
    
    draw_arrow(d, (500, 110), (500, 180))
    
    # 2. Decision PLN
    draw_diamond(d, (350, 180, 650, 280), fill=(254, 243, 199), outline=(217, 119, 6), width=3)
    draw_node_text(d, (350, 180, 650, 280), "Sumber Listrik PLN Aktif?", text_color=(180, 83, 9), font_size=16, bold=True)
    
    # Yes PLN (Left branch)
    draw_arrow(d, (350, 230), (180, 230), color=(22, 163, 74), width=3, text="Ya (Normal)", text_offset=(-90, -18))
    draw_rounded_rect(d, (70, 310, 290, 390), fill=(240, 253, 244), outline=(22, 163, 74), width=2, radius=10)
    draw_node_text(d, (70, 310, 290, 390), "UPS Meneruskan Daya PLN\n& Mengisi Daya Baterai\n(Charging Cycle)", text_color=(21, 128, 61), font_size=13, bold=True)
    draw_arrow(d, (180, 230), (180, 310), color=(22, 163, 74), width=3)
    
    # Normal Operation
    draw_rounded_rect(d, (70, 460, 290, 530), fill=(241, 245, 249), outline=(51, 65, 85), width=2, radius=10)
    draw_node_text(d, (70, 460, 290, 530), "Output Stabil: 5V (ESP32)\n& 12V (Solenoid Lock)", text_color=(15, 23, 42), font_size=13, bold=True)
    draw_arrow(d, (180, 390), (180, 460), color=(71, 85, 105), width=3)
    
    # Loop back PLN
    d.line([(180, 530), (180, 600), (330, 600)], fill=(71, 85, 105), width=2)
    
    # No PLN (Right branch - Blackout)
    draw_arrow(d, (650, 230), (820, 230), color=(220, 38, 38), width=3, text="Tidak (Listrik Padam)", text_offset=(15, -18))
    draw_rounded_rect(d, (710, 310, 930, 390), fill=(254, 226, 226), outline=(220, 38, 38), width=2, radius=10)
    draw_node_text(d, (710, 310, 930, 390), "UPS Otomatis Beralih ke\nBaterai Internal TechBee\nTanpa Jeda Waktu (0ms)", text_color=(185, 28, 28), font_size=13, bold=True)
    draw_arrow(d, (820, 230), (820, 310), color=(220, 38, 38), width=3)
    
    # Blackout notification
    draw_rounded_rect(d, (710, 460, 930, 530), fill=(241, 245, 249), outline=(124, 58, 237), width=2, radius=10)
    draw_node_text(d, (710, 460, 930, 530), "ESP32 Deteksi Hilang PLN\nKirim Telemetri ke Supabase\n'Power Outage / On Battery'", text_color=(15, 23, 42), font_size=13, bold=True)
    draw_arrow(d, (820, 390), (820, 460), color=(220, 38, 38), width=3)
    
    # Loop back to merge
    d.line([(820, 530), (820, 600), (670, 600)], fill=(71, 85, 105), width=2)
    
    # Merged box
    draw_rounded_rect(d, (330, 570, 670, 630), fill=(241, 245, 249), outline=(37, 99, 235), width=3, radius=10)
    draw_node_text(d, (330, 570, 670, 630), "Sistem Loker Tetap Beroperasi Normal\nKetahanan Daya Cadangan 4 - 6 Jam", text_color=(15, 23, 42), font_size=14, bold=True)
    
    draw_arrow(d, (500, 630), (500, 710))
    
    # Check battery low
    draw_diamond(d, (350, 710, 650, 810), fill=(254, 243, 199), outline=(217, 119, 6), width=3)
    draw_node_text(d, (350, 710, 650, 810), "Kapasitas Baterai Kritis\n(< 15%)?", text_color=(180, 83, 9), font_size=15, bold=True)
    
    # Aman (Left)
    draw_arrow(d, (350, 760), (220, 760), color=(22, 163, 74), width=3, text="Aman", text_offset=(-60, -18))
    draw_rounded_rect(d, (100, 830, 340, 890), fill=(240, 253, 244), outline=(22, 163, 74), width=2, radius=8)
    draw_node_text(d, (100, 830, 340, 890), "Lanjutkan Operasional Normal\nLooping Monitoring Daya", text_color=(21, 128, 61), font_size=13, bold=True)
    draw_arrow(d, (220, 760), (220, 830), color=(22, 163, 74), width=3)
    
    # Kritis (Down)
    draw_arrow(d, (500, 810), (500, 880), color=(220, 38, 38), width=3, text="Ya (Kritis)", text_offset=(10, -10))
    draw_rounded_rect(d, (cx-w_box//2, 880, cx+w_box//2, 940), fill=(254, 226, 226), outline=(220, 38, 38), width=3, radius=10)
    draw_node_text(d, (cx-w_box//2, 880, cx+w_box//2, 940), "Kirim Peringatan Darurat ke Admin\nKunci Loker Tetap Terkunci Aman", text_color=(185, 28, 28), font_size=14, bold=True)
    
    draw_arrow(d, (500, 940), (500, 1000))
    
    # End
    draw_rounded_rect(d, (cx-w_box//2, 1000, cx+w_box//2, 1050), fill=(100, 116, 139), outline=(30, 41, 59), width=2, radius=25)
    draw_node_text(d, (cx-w_box//2, 1000, cx+w_box//2, 1050), "Safe State: Siaga Menunggu Suplai Listrik Utama", text_color=(255, 255, 255), font_size=14, bold=True)
    
    im.save("assets/diagrams/flowchart3_daya_ups.png", "PNG", dpi=(300, 300))

print("Generating flowcharts...")
generate_flowchart_1()
generate_flowchart_2()
generate_flowchart_3()
print("All 3 flowcharts generated successfully!")

# --- 2. BUILD PROFESSIONAL WORD DOCUMENT ---
doc = docx.Document()

# Set page margins: 1 inch (72 pt)
for section in doc.sections:
    section.top_margin = Inches(1.0)
    section.bottom_margin = Inches(1.0)
    section.left_margin = Inches(1.0)
    section.right_margin = Inches(1.0)

# Colors
COLOR_PRIMARY_HEX = "BB0016"      # Telkom Crimson
COLOR_DARK_HEX = "1E293B"         # Dark Slate
COLOR_BORDER_HEX = "CBD5E1"       # Light Slate Border
COLOR_BG_LIGHT_HEX = "F8FAFC"     # Card BG
COLOR_WHITE_HEX = "FFFFFF"

def set_cell_background(cell, hex_color):
    tcPr = cell._tc.get_or_add_tcPr()
    shd = parse_xml(f'<w:shd {nsdecls("w")} w:fill="{hex_color}"/>')
    tcPr.append(shd)

def set_cell_margins(cell, top=100, bottom=100, left=150, right=150):
    tcPr = cell._tc.get_or_add_tcPr()
    tcMar = parse_xml(f'<w:tcMar {nsdecls("w")}><w:top w:w="{top}" w:type="dxa"/><w:bottom w:w="{bottom}" w:type="dxa"/><w:left w:w="{left}" w:type="dxa"/><w:right w:w="{right}" w:type="dxa"/></w:tcMar>')
    tcPr.append(tcMar)

def add_heading_1(text):
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(18)
    p.paragraph_format.space_after = Pt(6)
    p.paragraph_format.keep_with_next = True
    run = p.add_run(text)
    run.font.name = 'Segoe UI'
    run.font.size = Pt(16)
    run.font.bold = True
    run.font.color.rgb = RGBColor(187, 0, 22) # Crimson

def add_heading_2(text):
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(14)
    p.paragraph_format.space_after = Pt(4)
    p.paragraph_format.keep_with_next = True
    run = p.add_run(text)
    run.font.name = 'Segoe UI'
    run.font.size = Pt(13)
    run.font.bold = True
    run.font.color.rgb = RGBColor(30, 41, 59) # Slate

def add_body_p(text, bold_prefix=None, space_after=4):
    p = doc.add_paragraph()
    p.paragraph_format.space_after = Pt(space_after)
    p.paragraph_format.line_spacing = 1.15
    if bold_prefix:
        r_pre = p.add_run(bold_prefix)
        r_pre.font.name = 'Segoe UI'
        r_pre.font.size = Pt(10.5)
        r_pre.font.bold = True
        r_pre.font.color.rgb = RGBColor(30, 41, 59)
    run = p.add_run(text)
    run.font.name = 'Segoe UI'
    run.font.size = Pt(10.5)
    run.font.color.rgb = RGBColor(51, 65, 85)
    return p

def add_bullet_p(text, bold_prefix=None):
    p = doc.add_paragraph(style='List Bullet')
    p.paragraph_format.space_after = Pt(3)
    p.paragraph_format.line_spacing = 1.15
    if bold_prefix:
        r_pre = p.add_run(bold_prefix)
        r_pre.font.name = 'Segoe UI'
        r_pre.font.size = Pt(10.5)
        r_pre.font.bold = True
        r_pre.font.color.rgb = RGBColor(30, 41, 59)
    run = p.add_run(text)
    run.font.name = 'Segoe UI'
    run.font.size = Pt(10.5)
    run.font.color.rgb = RGBColor(51, 65, 85)
    return p

# --- COVER / HEADER ---
p_title = doc.add_paragraph()
p_title.paragraph_format.space_before = Pt(10)
p_title.paragraph_format.space_after = Pt(2)
r_t = p_title.add_run("PRODUCT REQUIREMENT DOCUMENT")
r_t.font.name = 'Segoe UI'
r_t.font.size = Pt(22)
r_t.font.bold = True
r_t.font.color.rgb = RGBColor(187, 0, 22)

p_sub = doc.add_paragraph()
p_sub.paragraph_format.space_after = Pt(14)
r_s = p_sub.add_run("Smart Locker Key Management & Fleet Monitoring System")
r_s.font.name = 'Segoe UI'
r_s.font.size = Pt(14)
r_s.font.color.rgb = RGBColor(100, 116, 139)

# Accent line
p_line = doc.add_paragraph()
p_line.paragraph_format.space_after = Pt(14)
r_line = p_line.add_run("━" * 45)
r_line.font.color.rgb = RGBColor(187, 0, 22)
r_line.font.bold = True

# Metadata Box
t_meta = doc.add_table(rows=5, cols=2)
t_meta.alignment = WD_TABLE_ALIGNMENT.CENTER
t_meta.autofit = False

meta_data = [
    ("Nama Produk", "Smart Locker Key Management & Fleet Monitoring System"),
    ("Versi Dokumen", "1.0.0 (Final Release)"),
    ("Tanggal", "25 September 2026"),
    ("Status", "Approved & Ready for Production"),
    ("Target Pengguna", "Admin Operasional Telkom, Manager Armada, & Karyawan Peminjam")
]

for i, (k, v) in enumerate(meta_data):
    row = t_meta.rows[i]
    c1, c2 = row.cells[0], row.cells[1]
    c1.width = Inches(2.0)
    c2.width = Inches(4.5)
    
    set_cell_background(c1, "F1F5F9")
    set_cell_background(c2, "FFFFFF")
    set_cell_margins(c1, top=80, bottom=80, left=120, right=120)
    set_cell_margins(c2, top=80, bottom=80, left=120, right=120)
    
    p1 = c1.paragraphs[0]
    p1.paragraph_format.space_after = Pt(0)
    r1 = p1.add_run(k)
    r1.font.name = 'Segoe UI'
    r1.font.bold = True
    r1.font.size = Pt(10)
    r1.font.color.rgb = RGBColor(30, 41, 59)
    
    p2 = c2.paragraphs[0]
    p2.paragraph_format.space_after = Pt(0)
    r2 = p2.add_run(v)
    r2.font.name = 'Segoe UI'
    r2.font.size = Pt(10)
    r2.font.color.rgb = RGBColor(51, 65, 85)

# --- 1. RINGKASAN EKSEKUTIF ---
add_heading_1("1. Dokumen Informasi & Ringkasan Eksekutif")
add_body_p("Dokumen Product Requirement Document (PRD) ini merinci rancangan menyeluruh sistem Smart Locker Penyimpanan Kunci Armada berbasis Internet of Things (IoT). Sistem ini menggabungkan microcontroller ESP32 DevKit, mekanisme Solenoid Door Lock, backup daya UPS TechBee, basis data awan Supabase, serta antarmuka aplikasi pemantauan berbasis Flutter untuk Admin Operasional.")

# --- 2. LATAR BELAKANG & TUJUAN ---
add_heading_1("2. Latar Belakang & Tujuan")
add_heading_2("2.1 Latar Belakang Masalah")
add_body_p("Pengelolaan kunci kendaraan operasional armada (fleet management) secara konvensional sering kali menghadapi kendala serius, seperti risiko kehilangan kunci fisik, pencatatan log peminjaman yang rentan manipulasi atau hilang, serta ketiadaan sinkronisasi langsung antara kondisi fisik loker dan sistem monitoring kantor pusat. Hal ini menimbulkan inefisiensi dan menurunkan akuntabilitas operasional.")

add_heading_2("2.2 Tujuan Utama Sistem")
add_bullet_p(" Otomatisasi penguncian dan pembukaan pintu loker kunci menggunakan Solenoid Door Lock yang dikendalikan oleh ESP32 Microcontroller secara aman berbasis izin peminjaman digital.", "1. Otomatisasi Akses Loker:")
add_bullet_p(" Menghubungkan loker fisik secara langsung dengan Supabase Cloud Database untuk sinkronisasi instan atas data reservasi, pembukaan pintu, dan riwayat peminjaman.", "2. Integrasi Cloud Real-Time:")
add_bullet_p(" Memberikan kendali penuh bagi Admin Operasional melalui aplikasi Flutter untuk menyetujui peminjaman, memantau ketersediaan armada, dan melacak riwayat transaksi.", "3. Monitoring Admin:")
add_bullet_p(" Memastikan seluruh unit loker pintar tetap beroperasi tanpa henti (non-stop) meskipun terjadi pemadaman listrik dari jaringan utama PLN dengan suplai daya cadangan UPS TechBee 5V+12V.", "4. Ketahanan Sistem (UPS Backup):")

# --- 3. RUANG LINGKUP PRODUK ---
add_heading_1("3. Ruang Lingkup Sistem (Product Scope)")
add_body_p("Sistem Smart Locker terbagi ke dalam 3 (tiga) pilar integrasi utama:")
add_bullet_p(" Terdiri dari ESP32 DevKit Type-C, I/O Expansion Shield 30 Pin, Relay 5V 2 Channel, Solenoid Door Lock 12V, 6 titik LED Indikator, UPS TechBee Output 5V+12V, enclosure penyimpanan kunci, serta kabel dan konektor terstandarisasi.", "A. Perangkat Keras (Hardware IoT):")
add_bullet_p(" Berperan sebagai pusat penyimpanan data, autentikasi terenkripsi, manajemen relasi data (karyawan, kendaraan, booking), dan broadcast pesan real-time ke microcontroller.", "B. Cloud Database (Supabase):")
add_bullet_p(" Antarmuka grafis bagi admin untuk mengelola pengajuan peminjaman, memantau armada secara live, menyetujui/menolak booking, serta melihat riwayat log akses.", "C. Aplikasi Admin Monitoring (Flutter):")

# --- 4. KEBUTUHAN PENGGUNA & SPESIFIKASI FUNGSIONAL ---
add_heading_1("4. Kebutuhan Pengguna & Spesifikasi Fungsional")
add_bullet_p(" Setiap admin dan karyawan wajib terotentikasi melalui sistem Supabase Auth. Hak akses pembukaan loker hanya diberikan apabila status booking bernilai 'Approved'.", "FR-1 (Autentikasi & Hak Akses):")
add_bullet_p(" ESP32 mendengarkan instruksi buka kunci melalui koneksi real-time. Saat perintah terverifikasi, Relay Channel 1 diaktifkan sehingga Solenoid 12V menarik pin pengunci selama 5 detik, diiringi indikator LED hijau.", "FR-2 (Kontrol Solenoid & Relay):")
add_bullet_p(" Dashboard admin menampilkan status armada (Tersedia, Digunakan, Dalam Perbaikan) dan status loker secara transparan.", "FR-3 (Monitoring Real-Time):")
add_bullet_p(" Jika suplai PLN terputus, UPS TechBee secara otomatis menyuplai daya 5V ke ESP32 dan 12V ke Solenoid, memungkinkan operasional berlanjut selama 4-6 jam.", "FR-4 (Ketahanan Suplai Daya):")

# --- 5. DIAGRAM ALUR SISTEM (HANYA FLOWCHART) ---
add_heading_1("5. Diagram Alur Sistem (Flowcharts)")
add_body_p("Sesuai dengan spesifikasi perancangan, seluruh representasi diagram pada dokumen PRD ini disajikan secara eksklusif menggunakan Diagram Alur (Flowchart).")

add_heading_2("5.1 Flowchart 1: Alur Utama Peminjaman Kendaraan & Pengambilan Kunci")
add_body_p("Diagram berikut memetakan perjalanan proses (user journey) mulai dari pengajuan peminjaman oleh karyawan, peninjauan oleh admin, pemicuan sinyal cloud, pembukaan solenoid fisik, hingga pengambilan kunci.")

p_img1 = doc.add_paragraph()
p_img1.alignment = WD_ALIGN_PARAGRAPH.CENTER
p_img1.paragraph_format.space_before = Pt(8)
p_img1.paragraph_format.space_after = Pt(4)
doc.add_picture("assets/diagrams/flowchart1_peminjaman.png", width=Inches(5.8))

p_cap1 = doc.add_paragraph()
p_cap1.alignment = WD_ALIGN_PARAGRAPH.CENTER
p_cap1.paragraph_format.space_after = Pt(14)
r_cap1 = p_cap1.add_run("Gambar 5.1: Flowchart Alur Peminjaman Armada & Akses Smart Locker")
r_cap1.font.size = Pt(9.5)
r_cap1.font.italic = True
r_cap1.font.color.rgb = RGBColor(100, 116, 139)

add_heading_2("5.2 Flowchart 2: Alur Firmware ESP32 & Kontrol Hardware Solenoid")
add_body_p("Diagram berikut merinci logika internal firmware microcontroller ESP32 dalam mengelola koneksi Wi-Fi, mendengarkan sinyal Supabase, menggerakkan Relay Solenoid, mengontrol timer penguncian otomatis (5 detik), dan melaporkan konfirmasi balik (ACK).")

p_img2 = doc.add_paragraph()
p_img2.alignment = WD_ALIGN_PARAGRAPH.CENTER
p_img2.paragraph_format.space_before = Pt(8)
p_img2.paragraph_format.space_after = Pt(4)
doc.add_picture("assets/diagrams/flowchart2_firmware.png", width=Inches(5.8))

p_cap2 = doc.add_paragraph()
p_cap2.alignment = WD_ALIGN_PARAGRAPH.CENTER
p_cap2.paragraph_format.space_after = Pt(14)
r_cap2 = p_cap2.add_run("Gambar 5.2: Flowchart Firmware ESP32 & Kontrol Solenoid")
r_cap2.font.size = Pt(9.5)
r_cap2.font.italic = True
r_cap2.font.color.rgb = RGBColor(100, 116, 139)

add_heading_2("5.3 Flowchart 3: Alur Manajemen Daya & Cadangan Listrik UPS TechBee")
add_body_p("Diagram berikut memvisualisasikan bagaimana sirkuit UPS TechBee mengelola switching daya tanpa jeda (0 ms) antara sumber listrik utama PLN dan baterai cadangan terintegrasi (5V dan 12V), serta mekanisme perlindungan kondisi baterai kritis.")

p_img3 = doc.add_paragraph()
p_img3.alignment = WD_ALIGN_PARAGRAPH.CENTER
p_img3.paragraph_format.space_before = Pt(8)
p_img3.paragraph_format.space_after = Pt(4)
doc.add_picture("assets/diagrams/flowchart3_daya_ups.png", width=Inches(5.8))

p_cap3 = doc.add_paragraph()
p_cap3.alignment = WD_ALIGN_PARAGRAPH.CENTER
p_cap3.paragraph_format.space_after = Pt(14)
r_cap3 = p_cap3.add_run("Gambar 5.3: Flowchart Manajemen Daya & Cadangan Listrik UPS TechBee")
r_cap3.font.size = Pt(9.5)
r_cap3.font.italic = True
r_cap3.font.color.rgb = RGBColor(100, 116, 139)

# --- 6. RENCANA ANGGARAN BIAYA (RAB) ---
add_heading_1("6. Rencana Anggaran Biaya (RAB)")
add_body_p("Seluruh rincian biaya komponen perangkat keras Smart Locker dan kebutuhan biaya operasional bulanan berikut disusun tepat sesuai dengan dokumen RAB yang telah disetujui.")

add_heading_2("6.1 Biaya Perangkat Keras (Smart Locker Hardware)")

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

# Header row
hdr_row = t_rab.rows[0]
for idx, title in enumerate(headers):
    cell = hdr_row.cells[idx]
    cell.width = widths[idx]
    set_cell_background(cell, "BB0016") # Crimson
    set_cell_margins(cell, top=100, bottom=100, left=100, right=100)
    p = cell.paragraphs[0]
    p.paragraph_format.space_after = Pt(0)
    if idx in [0, 2]:
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    elif idx in [3, 4]:
        p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    run = p.add_run(title)
    run.font.name = 'Segoe UI'
    run.font.bold = True
    run.font.size = Pt(9.5)
    run.font.color.rgb = RGBColor(255, 255, 255)

# Item rows
for r_idx, item in enumerate(hardware_items, start=1):
    row = t_rab.rows[r_idx]
    bg_color = "F8FAFC" if r_idx % 2 == 1 else "FFFFFF"
    for c_idx, val in enumerate(item):
        cell = row.cells[c_idx]
        cell.width = widths[c_idx]
        set_cell_background(cell, bg_color)
        set_cell_margins(cell, top=70, bottom=70, left=100, right=100)
        p = cell.paragraphs[0]
        p.paragraph_format.space_after = Pt(0)
        if c_idx in [0, 2]:
            p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        elif c_idx in [3, 4]:
            p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
        run = p.add_run(val)
        run.font.name = 'Segoe UI'
        run.font.size = Pt(9.5)
        run.font.color.rgb = RGBColor(30, 41, 59)

# Total row
tot_row = t_rab.rows[-1]
# Merge first 4 cells
tot_cell_label = tot_row.cells[0]
tot_cell_label.merge(tot_row.cells[1]).merge(tot_row.cells[2]).merge(tot_row.cells[3])
set_cell_background(tot_cell_label, "1E293B")
set_cell_margins(tot_cell_label, top=100, bottom=100, left=100, right=100)
p_tot_lbl = tot_cell_label.paragraphs[0]
p_tot_lbl.paragraph_format.space_after = Pt(0)
p_tot_lbl.alignment = WD_ALIGN_PARAGRAPH.CENTER
r_tot_lbl = p_tot_lbl.add_run("TOTAL BIAYA PERANGKAT KERAS")
r_tot_lbl.font.name = 'Segoe UI'
r_tot_lbl.font.bold = True
r_tot_lbl.font.size = Pt(10)
r_tot_lbl.font.color.rgb = RGBColor(255, 255, 255)

tot_cell_val = tot_row.cells[4]
set_cell_background(tot_cell_val, "1E293B")
set_cell_margins(tot_cell_val, top=100, bottom=100, left=100, right=100)
p_tot_val = tot_cell_val.paragraphs[0]
p_tot_val.paragraph_format.space_after = Pt(0)
p_tot_val.alignment = WD_ALIGN_PARAGRAPH.RIGHT
r_tot_val = p_tot_val.add_run("Rp848.250")
r_tot_val.font.name = 'Segoe UI'
r_tot_val.font.bold = True
r_tot_val.font.size = Pt(10.5)
r_tot_val.font.color.rgb = RGBColor(255, 255, 255)

doc.add_paragraph().paragraph_format.space_after = Pt(10)

# 6.2 Biaya Operasional Bulanan
add_heading_2("6.2 Kebutuhan Biaya Operasional Bulanan")

t_ops = doc.add_table(rows=2, cols=3)
t_ops.alignment = WD_TABLE_ALIGNMENT.CENTER
t_ops.autofit = False

ops_headers = ["Kebutuhan", "Keterangan", "Estimasi / Bulan"]
ops_widths = [Inches(2.5), Inches(2.2), Inches(1.8)]

# Header row
hdr_ops = t_ops.rows[0]
for idx, title in enumerate(ops_headers):
    cell = hdr_ops.cells[idx]
    cell.width = ops_widths[idx]
    set_cell_background(cell, "BB0016")
    set_cell_margins(cell, top=100, bottom=100, left=100, right=100)
    p = cell.paragraphs[0]
    p.paragraph_format.space_after = Pt(0)
    if idx == 2:
        p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    run = p.add_run(title)
    run.font.name = 'Segoe UI'
    run.font.bold = True
    run.font.size = Pt(9.5)
    run.font.color.rgb = RGBColor(255, 255, 255)

# Value row
val_ops = t_ops.rows[1]
ops_data = ["Cloud Database (Supabase)", "Untuk Database", "±Rp 450.000 / bulan"]
for idx, val in enumerate(ops_data):
    cell = val_ops.cells[idx]
    cell.width = ops_widths[idx]
    set_cell_background(cell, "F8FAFC")
    set_cell_margins(cell, top=80, bottom=80, left=100, right=100)
    p = cell.paragraphs[0]
    p.paragraph_format.space_after = Pt(0)
    if idx == 2:
        p.alignment = WD_ALIGN_PARAGRAPH.RIGHT
    run = p.add_run(val)
    run.font.name = 'Segoe UI'
    run.font.size = Pt(10)
    run.font.bold = (idx == 2)
    run.font.color.rgb = RGBColor(187, 0, 22) if idx == 2 else RGBColor(30, 41, 59)

doc.add_paragraph().paragraph_format.space_after = Pt(10)

# --- 7. KEBUTUHAN NON-FUNGSIONAL ---
add_heading_1("7. Kebutuhan Non-Fungsional (Non-Functional Requirements)")
add_bullet_p(" Unit UPS TechBee (Output 5V & 12V) wajib memberikan cadangan suplai daya tanpa jeda minimal 4 hingga 6 jam kerja saat jaringan listrik utama mengalami gangguan.", "1. Keandalan Daya (Reliability):")
add_bullet_p(" Latensi eksekusi dari penekanan tombol 'Buka Loker' pada aplikasi Flutter hingga terbukanya Solenoid Door Lock tidak boleh melampaui 2 detik.", "2. Waktu Respon (Performance):")
add_bullet_p(" Mekanisme Solenoid Door Lock dipasang di dalam dinding kompartemen logam tertutup untuk mencegah manipulasi fisik dari luar. Seluruh lalu lintas data dilindungi enkripsi SSL/TLS.", "3. Keamanan Tingkat Tinggi (Security):")
add_bullet_p(" Komponen Dioda 1N4007 wajib dipasang secara antiparalel (flyback diode) melintasi terminal koil Solenoid guna meredam lonjakan tegangan balik induktif yang dapat merusak Relay dan ESP32.", "4. Ketahanan Elektronika (Durability):")

# --- 8. RENCANA PENGUJIAN ---
add_heading_1("8. Rencana Pengujian & Pemeliharaan (Testing & Maintenance)")
add_bullet_p(" Meliputi pengujian kontinuitas kabel AWG 20, kekuatan mekanik tarikan Solenoid Door Lock, dan uji simulasi pemadaman listrik PLN untuk verifikasi respons UPS TechBee.", "A. Pengujian Perangkat Keras:")
add_bullet_p(" Meliputi simulasi pemutusan dan penyambungan kembali jaringan Wi-Fi secara otomatis, penanganan antrean request Supabase, dan uji ketahanan siklus buka/tutup loker 100 kali berturut-turut.", "B. Pengujian Firmware & Integrasi:")

output_filename = "PRD_Smart_Locker_Key_Management.docx"
doc.save(output_filename)
print(f"Document saved successfully as '{output_filename}'!")
