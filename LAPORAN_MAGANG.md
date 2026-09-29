# LAPORAN PRAKTIK KERJA LAPANGAN (MAGANG)

**RANCANG BANGUN SISTEM MONITORING OPERASIONAL ARMADA DAN MANAJEMEN AKSES SMART LOCKER BERBASIS INTERNET OF THINGS (IOT) DAN FLUTTER**  
**PADA PT TELKOM INDONESIA (PERSERO) TBK**

---

### INFORMASI DOKUMEN & IDENTITAS
* **Nama Praktikan / Penulis:** Maulana Akbar
* **Institusi Pendidikan:** Sekolah Vokasi (SV) Universitas Pakuan
* **Instansi Tempat Magang:** PT Telkom Indonesia (Persero) Tbk
* **Divisi / Unit Penempatan:** Divisi Monitoring Operasional Armada & IoT Fleet Management
* **Pembimbing Lapangan:** Team Lead Operasional Fleet PT Telkom Indonesia
* **Periode Magang:** Semester Genap Tahun Ajaran 2025/2026
* **Versi Sistem:** v1.0.0 (Build 1)

---

## DAFTAR ISI
1. [BAB I: PENDAHULUAN](#bab-i-pendahuluan)
   - 1.1 Latar Belakang Masalah
   - 1.2 Rumusan Masalah
   - 1.3 Batasan Masalah
   - 1.4 Tujuan Magang
   - 1.5 Manfaat Magang
   - 1.6 Waktu dan Tempat Pelaksanaan
2. [BAB II: PROFIL PERUSAHAAN](#bab-ii-profil-perusahaan)
   - 2.1 Profil Singkat PT Telkom Indonesia (Persero) Tbk
   - 2.2 Visi, Misi, dan Core Values AKHLAK
   - 2.3 Profil Divisi Monitoring Operasional Armada
   - 2.4 Peran dan Tanggung Jawab Mahasiswa Magang
3. [BAB III: LANDASAN TEORI DAN TEKNOLOGI PENDUKUNG](#bab-iii-landasan-teori-dan-teknologi-pendukung)
   - 3.1 Konsep Fleet Management System & Smart Asset Management
   - 3.2 Internet of Things (IoT) & Mikrokontroler ESP32 DevKit
   - 3.3 Sistem Elektromekanik Penguncian (Relay, Solenoid, Flyback Diode)
   - 3.4 Sistem Daya Mandiri Uninterruptible Power Supply (UPS)
   - 3.5 Framework Antarmuka Mobile Cross-Platform Flutter & Dart
   - 3.6 Backend-as-a-Service (BaaS) Supabase (PostgreSQL & Realtime WebSocket)
   - 3.7 Geolokasi GPS, Geofencing, & Live Telemetri Armada
4. [BAB IV: ANALISIS DAN PERANCANGAN SISTEM (DARI SEMUA SISI APLIKASI)](#bab-iv-analisis-dan-perancangan-sistem-dari-semua-sisi-aplikasi)
   - 4.1 Arsitektur Sistem Menyeluruh (End-to-End Three-Tier Architecture)
   - 4.2 Sisi Perangkat Keras / Hardware IoT (Smart Locker)
   - 4.3 Sisi Backend, Keamanan, & Cloud Database (Supabase)
   - 4.4 Sisi Aplikasi Mobile Admin Monitoring (Flutter Frontend)
   - 4.5 Alur Proses Bisnis & Integrasi Sistem (Diagram Alur / Flowchart)
   - 4.6 Rencana Anggaran Biaya (RAB) Implementasi Sistem
5. [BAB V: IMPLEMENTASI DAN PENGUJIAN](#bab-v-implementasi-dan-pengujian)
   - 5.1 Implementasi Antarmuka Aplikasi Admin Monitoring
   - 5.2 Implementasi Integrasi Fisik Smart Locker
   - 5.3 Metode dan Hasil Pengujian
6. [BAB VI: KESIMPULAN DAN SARAN](#bab-vi-kesimpulan-dan-saran)
   - 6.1 Kesimpulan
   - 6.2 Saran untuk Pengembangan Lanjutan
7. [DAFTAR PUSTAKA](#daftar-pustaka)

---

## BAB I: PENDAHULUAN

### 1.1 Latar Belakang Masalah
PT Telkom Indonesia (Persero) Tbk sebagai badan usaha telekomunikasi digital terkemuka di Indonesia senantiasa mengandalkan mobilitas armada kendaraan operasional untuk mendukung pemeliharaan infrastruktur jaringan, pelayanan pelanggan korporasi, hingga penanganan gangguan jaringan di lapangan. Ketersediaan armada kendaraan roda empat dan roda dua yang terawat serta siap pakai merupakan pilar penunjang utama operasional harian.

Namun, dalam pelaksanaan operasional harian, pengelolaan kunci fisik kendaraan dinas dan pemantauan keberadaan armada masih menghadapi beberapa tantangan nyata:
1. **Risiko Kehilangan dan Keterlambatan Pengembalian Kunci:** Pengambilan dan pengembalian kunci kendaraan dinas yang masih dicatat dalam buku log manual rentan terhadap kelalaian manusia (*human error*), kunci tertukar, atau bahkan hilang tanpa jejak penanggung jawab yang jelas.
2. **Ketiadaan Visibilitas Status Loker Fisik:** Admin operasional tidak dapat mengetahui secara langsung apakah kunci berada di tempat penyimpanan atau sedang dibawa oleh staf di luar jam dinas.
3. **Keterbatasan Pemantauan Pergerakan Armada Secara Real-Time:** Ketiadaan integrasi langsung antara status persetujuan peminjaman (*booking approval*) dengan pemantauan lokasi koordinat GPS kendaraan secara live menimbulkan risiko penyalahgunaan aset dinas di luar zona operasional yang diizinkan.
4. **Resiliensi Terhadap Pemadaman Listrik:** Jika loker penyimpanan kunci menggunakan sistem elektronik digital tanpa cadangan daya yang memadai, pemadaman listrik PLN dapat mengakibatkan staf lapangan tidak dapat mengambil kunci kendaraan untuk merespons insiden darurat telekomunikasi.

Berangkat dari permasalahan tersebut, dalam kegiatan Praktik Kerja Lapangan (Magang) ini dirancang dan dibangun sebuah solusi terintegrasi bernama **Smart Locker Key Management & Fleet Monitoring System**. Sistem ini menggabungkan perangkat keras IoT berbasis mikrokontroler ESP32, pengunci Solenoid Door Lock berdaya cadangan UPS, database awan tersinkronisasi real-time menggunakan Supabase, serta aplikasi mobile modern berbasis Flutter untuk Admin Operasional.

### 1.2 Rumusan Masalah
Berdasarkan latar belakang di atas, rumusan masalah dalam laporan ini adalah:
1. Bagaimana merancang dan mengintegrasikan perangkat keras IoT Smart Locker (ESP32, Relay 5V, Solenoid Door Lock, LED indikator, dan UPS cadangan daya) dengan kotak penyimpanan kunci dinas?
2. Bagaimana membangun arsitektur backend cloud database berbasis Supabase untuk mengelola otentikasi peran (Admin & Karyawan), tabel relasi data armada, dan sinkronisasi status real-time?
3. Bagaimana membangun aplikasi mobile Admin Monitoring menggunakan framework Flutter yang dilengkapi dengan guard keamanan (wajib GPS dan koneksi internet aktif), dashboard interaktif, pelacakan live GPS, pemantauan status pemeliharaan, serta persetujuan booking?
4. Bagaimana memastikan keandalan sistem terhadap kondisi pemadaman listrik jaringan PLN dan fluktuasi sinyal internet?

### 1.3 Batasan Masalah
Agar pembahasan terarah dan fokus pada ruang lingkup penugasan magang, batasan masalah yang ditetapkan adalah:
1. Perangkat keras mikrokontroler yang digunakan adalah ESP32 DevKit Type-C dengan modul I/O Expansion Shield 30-pin.
2. Penggerak kunci loker menggunakan Solenoid Door Lock 12V yang dikendalikan oleh modul Relay 5V 2 Channel dengan perlindungan Dioda Flyback 1N4007.
3. Cadangan daya loker menggunakan UPS TechBee dengan keluaran ganda 5V dan 12V.
4. Sistem backend memanfaatkan Supabase Cloud Platform (PostgreSQL, Supabase Auth, dan Realtime WebSocket).
5. Aplikasi pemantauan difokuskan pada peran Admin Operasional (Admin Monitoring) berbasis Flutter pada perangkat mobile.
6. Pemantauan peta armada menggunakan pustaka `flutter_map` dengan koordinat lintang/bujur (LatLong) serta dukungan telemetri (kecepatan, jarak tempuh, dan heading arah).

### 1.4 Tujuan Magang
#### 1.4.1 Tujuan Umum
1. Mengaplikasikan ilmu teori dan keahlian rekayasa perangkat lunak serta Internet of Things yang diperoleh selama masa perkuliahan di Sekolah Vokasi Universitas Pakuan ke dalam lingkungan industri nyata.
2. Memahami alur kerja, dinamika koordinasi, dan standar profesionalisme dalam pengelolaan aset logistik digital di PT Telkom Indonesia.
3. Memperluas wawasan praktis mengenai perancangan sistem berbasis mikroelektronika, arsitektur cloud, dan pengembangan aplikasi mobile mutakhir.

#### 1.4.2 Tujuan Khusus
1. Merealisasikan sistem loker fisik pintar (Smart Locker) yang mampu membuka dan mengunci kompartemen kunci secara otomatis berbasis otorisasi digital.
2. Membangun basis data cloud terintegrasi pada Supabase yang mendukung stream data langsung (*realtime listeners*) antara mikrokontroler dan aplikasi admin.
3. Mengembangkan aplikasi Flutter Admin Monitoring yang memiliki fitur komprehensif: dashboard metrik armada, persetujuan peminjaman, pelacakan GPS live, riwayat audit, dan konfigurasi profil.
4. Menerapkan manajemen daya cerdas menggunakan UPS TechBee sehingga sistem loker tetap beroperasi tanpa hambatan selama 4–6 jam saat terjadi pemadaman listrik.

### 1.5 Manfaat Magang
* **Bagi Mahasiswa:** Meningkatkan kapabilitas teknis di bidang *Full-Stack IoT & Mobile Development*, pemahaman arsitektur *event-driven*, serta pengalaman langsung menangani proyek rill skala enterprise.
* **Bagi Institusi Pendidikan (SV Universitas Pakuan):** Memperkuat sinergi antara kurikulum vokasi dengan kebutuhan riil industri digital (Link and Match), serta membuka peluang kerja sama riset terapan.
* **Bagi Perusahaan (PT Telkom Indonesia):** Menyediakan purwarupa sistem manajemen kunci dan armada yang akuntabel, efisien, meminimalisir risiko kehilangan kunci operasional, serta meningkatkan transparansi mobilitas kendaraan dinas.

### 1.6 Waktu dan Tempat Pelaksanaan
* **Waktu Pelaksanaan:** Semester Genap Tahun Akademik 2025/2026 (Durasi: 6 Bulan / 1 Semester Penuh)
* **Tempat Pelaksanaan:** PT Telkom Indonesia (Persero) Tbk, Divisi Monitoring Operasional Armada

---

## BAB II: PROFIL PERUSAHAAN

### 2.1 Profil Singkat PT Telkom Indonesia (Persero) Tbk
PT Telkom Indonesia (Persero) Tbk (Telkom) merupakan Badan Usaha Milik Negara (BUMN) yang bergerak di bidang jasa layanan teknologi informasi dan komunikasi (TIK) serta jaringan telekomunikasi terbesar di Indonesia. Telkom telah bertransformasi menjadi *digital telecommunication company* yang memimpin digitalisasi nasional melalui tiga domain bisnis digital: *Digital Connectivity*, *Digital Platform*, dan *Digital Services*.

### 2.2 Visi, Misi, dan Core Values AKHLAK
* **Visi:** Menjadi digital telco pilihan utama untuk memajukan masyarakat.
* **Misi:** 
  1. Mempercepat pembangunan infrastruktur dan platform digital cerdas yang berkelanjutan, ekonomis, dan dapat diakses oleh seluruh masyarakat.
  2. Mengembangkan talenta digital unggulan yang membantu mendorong kemampuan digital dan tingkat adopsi digital bangsa.
  3. Memimpin orkestrasi ekosistem digital nasional.
* **Core Values BUMN (AKHLAK):**
  - **Amanah:** Memegang teguh kepercayaan yang diberikan dalam mengelola aset dinas.
  - **Kompeten:** Terus belajar dan mengembangkan kapabilitas teknologi IoT & software.
  - **Harmonis:** Saling peduli dan menghargai keberagaman dalam tim kerja lintas fungsi.
  - **Loyal:** Berdedikasi dan mengutamakan kepentingan bangsa serta perusahaan.
  - **Adaptif:** Terus berinovasi dan antusias dalam menggerakkan atau menghadapi perubahan digital.
  - **Kolaboratif:** Membangun kerja sama yang sinergis antara perguruan tinggi dan industri.

### 2.3 Profil Divisi Monitoring Operasional Armada
Unit Divisi Monitoring Operasional Armada bertanggung jawab atas ketersediaan, pemeliharaan rutin, penjadwalan servis, serta pengawasan pergerakan seluruh aset kendaraan operasional dinas. Divisi ini memastikan bahwa setiap mobil dinas yang digunakan oleh staf lapangan beroperasi secara aman, terpantau, dan memiliki catatan pemeliharaan yang terukur.

### 2.4 Peran dan Tanggung Jawab Mahasiswa Magang
Selama masa magang, praktikan (Maulana Akbar) bertindak sebagai **IoT & Mobile Application Developer Intern** dengan tanggung jawab mencakup:
1. Merancang dan merakit sirkuit kendali hardware Smart Locker (ESP32, Relay, Solenoid, LED, dan UPS).
2. Menulis dan menguji kode firmware ESP32 untuk komunikasi real-time dengan Supabase.
3. Mendesain basis data, tabel relasi, dan fungsi backend pada Supabase.
4. Membangun modul-modul pada aplikasi Android/iOS berbasis Flutter (Dashboard, Booking, Tracking Map, Settings).
5. Menguji performa sistem dari sisi keamanan, latensi, dan ketahanan catu daya.

---

## BAB III: LANDASAN TEORI DAN TEKNOLOGI PENDUKUNG

### 3.1 Konsep Fleet Management System & Smart Asset Management
*Fleet Management System* (FMS) adalah sistem terpadu yang memanfaatkan perangkat telematika dan perangkat lunak untuk memantau performa, konsumsi bahan bakar, kepatuhan pengemudi, jadwal servis, serta lokasi aset kendaraan bermotor. Integrasi FMS dengan sistem penguncian fisik (*Smart Key Locker*) menutup celah operasional antara otorisasi administratif dengan akses fisik terhadap aset.

### 3.2 Internet of Things (IoT) & Mikrokontroler ESP32 DevKit
ESP32 merupakan *System on a Chip* (SoC) berkemampuan tinggi dengan modul Wi-Fi 802.11 b/g/n dan Bluetooth terintegrasi. ESP32 DevKit Type-C dilengkapi dengan prosesor dual-core Xtensa 32-bit LX6 dengan clock speed hingga 240 MHz, memori SRAM 520 KB, serta pin GPIO fleksibel yang cocok untuk mengendalikan aktuator relay dan sensor status pintu secara presisi dan efisien.

### 3.3 Sistem Elektromekanik: Solenoid Door Lock, Relay, dan Dioda Flyback
* **Solenoid Door Lock (12V):** Aktuator elektromagnetik yang memanfaatkan medan magnet yang dihasilkan oleh kumparan kawat tembaga untuk menarik pin pengunci besi ketika dialiri arus searah (DC) 12 Volt.
* **Relay 5V 2 Channel:** Saklar elektromekanik yang digerakkan oleh level logika 5V dari mikrokontroler untuk menyambung atau memutus sirkuit beban tinggi (12V) pada Solenoid tanpa membahayakan pin GPIO ESP32.
* **Dioda Flyback (1N4007):** Dioda semikonduktor yang dipasang secara paralel berkebalikan polaritas (*antiparallel*) melintasi koil Solenoid Door Lock. Fungsi utamanya adalah meredam lonjakan tegangan induktif balik (*inductive kickback / back-EMF*) yang timbul saat arus ke koil diputus seketika, sehingga melindungi kontak relay dan mikrokontroler dari kerusakan fatal.

### 3.4 Sistem Daya Mandiri: Uninterruptible Power Supply (UPS) TechBee
UPS TechBee merupakan modul catu daya cadangan terpadu yang dirancang khusus untuk perangkat telekomunikasi dan IoT bertegangan ganda (*dual output: 5V dan 12V*). Saat listrik PLN menyala, modul ini meneruskan daya sekaligus mengisi baterai lithium internal (*charging cycle*). Ketika pemadaman listrik terjadi, UPS melakukan peralihan (*switching*) ke daya baterai dengan jeda waktu 0 milidetik, mencegah perangkat ESP32 melakukan *restart* dan memastikan Solenoid 12V tetap dapat membuka loker.

### 3.5 Framework Flutter & Bahasa Pemrograman Dart
Flutter adalah framework *open-source* yang dikembangkan oleh Google untuk membangun aplikasi antarmuka pengguna lintas platform (Android, iOS, Web, Desktop) dari satu basis kode tunggal (*single codebase*). Menggunakan bahasa pemrograman Dart yang dikompilasi secara *Ahead-of-Time* (AOT) ke kode mesin native, Flutter memberikan performa rendering 60-120 fps yang mulus dengan arsitektur reaktif berbasis widget.

### 3.6 Cloud Backend-as-a-Service (BaaS): Supabase
Supabase merupakan alternatif open-source untuk Firebase yang dibangun di atas mesin basis data relasional PostgreSQL kelas enterprise. Fitur unggulan yang dimanfaatkan dalam proyek ini meliputi:
1. **Supabase Auth:** Manajemen identitas pengguna berbasis JWT (*JSON Web Token*) yang aman.
2. **PostgreSQL Database:** Penyimpanan data terstruktur dengan relasi foreign key, constraint, dan indexing cepat.
3. **Realtime Engine (WebSockets):** Memungkinkan klien (baik aplikasi mobile Flutter maupun firmware ESP32) mendengarkan perubahan baris tabel (`INSERT`, `UPDATE`, `DELETE`) secara instan dengan latensi milidetik.
4. **Row Level Security (RLS):** Kebijakan otorisasi di tingkat baris data, memastikan Admin hanya dapat memodifikasi kendaraan yang berada di bawah pengawasannya.

### 3.7 Geolokasi GPS, Geofencing, & Live Telemetri Armada
Pemantauan kendaraan dinas memanfaatkan pustaka `flutter_map` dan koordinat lintang/bujur (LatLong). Telemetri yang dihimpun mencakup:
- Kecepatan kendaraan saat ini (*Current Speed*).
- Jarak tempuh dinas (*Distance Covered*).
- Orientasi sudut arah pergerakan mobil (*Heading Angle*).
- Status zona batas geografis (*Geofencing status*) untuk mendeteksi apabila armada bergerak keluar dari wilayah tugas kedinasan yang telah ditentukan.

---

## BAB IV: ANALISIS DAN PERANCANGAN SISTEM (DARI SEMUA SISI APLIKASI)

Pengembangan sistem *Smart Locker & Fleet Monitoring* dirancang secara komprehensif mencakup semua sisi lapisan (*full-stack layers*):

```
+-----------------------------------------------------------------------------------+
|                        ARSITEKTUR END-TO-END SISTEM                              |
+-----------------------------------------------------------------------------------+
|  [ LAYER 1: HARDWARE IOT ]      [ LAYER 2: CLOUD BACKEND ]     [ LAYER 3: FRONTEND ]|
|  - ESP32 DevKit Type-C         - Supabase PostgreSQL DB       - Admin App (Flutter) |
|  - Shield I/O 30 Pin           - Supabase Realtime Engine     - Live GPS Tracking   |
|  - Relay 5V 2 Channel          - Supabase Auth & JWT Tokens   - Fleet Status Card   |
|  - Solenoid Door Lock 12V      - Row Level Security (RLS)     - Booking Approval    |
|  - 6x LED Indikator 5V-12V     - Telemetry & Event Listener   - Maintenance Log     |
|  - UPS TechBee (5V & 12V)                                     - Network/GPS Guard   |
+-----------------------------------------------------------------------------------+
```

---

### 4.1 Arsitektur Sistem Menyeluruh (End-to-End Three-Tier Architecture)
Sistem terdiri dari tiga tingkatan terintegrasi:
1. **Perangkat Keras Smart Locker (Edge / IoT Tier):** Bertanggung jawab atas interaksi fisik: mendeteksi perintah, mengaktifkan solenoid, menyalakan indikator visual, serta mengelola kontinuitas catu daya cadangan.
2. **Cloud BaaS Tier (Database & Messaging Tier):** Bertanggung jawab sebagai pusat data, otorisasi, dan perantara pesan asinkron (*publish-subscribe*) antara perangkat IoT dan aplikasi mobile.
3. **Aplikasi Mobile Admin (Client Application Tier):** Bertanggung jawab sebagai pusat komando operasional bagi admin armada untuk memverifikasi permohonan dinas, memantau posisi geografis kendaraan, serta mengendalikan operasional loker.

---

### 4.2 Sisi Perangkat Keras / Hardware IoT (Smart Locker)

#### 4.2.1 Spesifikasi dan Peran Komponen Fisik
1. **ESP32 DevKit Type-C (Qty: 1):** Berperan sebagai otak komputasi lokal, memproses koneksi jaringan Wi-Fi, mengautentikasi pesan dari Supabase, dan mengatur timing pensaklaran pin GPIO.
2. **I/O Expansion Shield ESP32 30-Pin (Qty: 1):** Menyediakan terminal sekrup dan konektor pinout yang kokoh untuk mencegah kabel goyang atau terlepas akibat getaran fisik saat pintu loker dibuka/tutup.
3. **Relay 5V 2 Channel (Qty: 1):** Mengisolasi sirkuit logika tegangan rendah (ESP32) dengan sirkuit beban arus tinggi (Solenoid 12V).
4. **Solenoid Door Lock 12V (Qty: 1):** Mekanisme lidah pengunci baja yang membuka pintu loker secara elektromagnetik selama 5 detik.
5. **LED Indikator 5mm (Qty: 6):** Indikator status visual eksternal (LED Hijau = Terbuka/Siap Diambil; LED Merah = Terkunci/Standby; LED Kuning = Sedang Terhubung; LED Biru = Mode Baterai UPS).
6. **Kotak Penyimpanan Kunci (Qty: 1):** Chasis kompartemen logam aman dengan dudukan khusus untuk gantungan kunci armada dan modul elektronik terisolasi.
7. **UPS TechBee Output 5V + 12V (Qty: 1):** Penyuplai daya mandiri berkapasitas tinggi yang secara konstan memberikan daya 5V ke ESP32 dan 12V ke Solenoid Lock, bahkan saat listrik gedung padam.
8. **Dioda 1N4007 (Qty: 1):** Perlindungan flyback pelindung lonjakan tegangan balik induktif koil solenoid.
9. **Kabel Jumper, Kabel JST, Kabel AWG 20 (Hitam & Merah), dan Konektor Kabel (2-2 & 2-6):** Jalur penghantar arus listrik dan sinyal logika berkualitas tinggi, tahan panas, dan minim resistansi.

#### 4.2.2 Logika Firmware ESP32 (State Machine)
Firmware pada ESP32 dibangun menggunakan framework C++/Arduino dengan alur kerja siklus:
1. **Tahap Booting:** Menginisialisasi port Serial (115200 baud), mendefinisikan pin I/O (Relay Pin = Output, LED Pins = Output), dan menetapkan nilai default LOW.
2. **Koneksi Wi-Fi:** Mencoba menghubungkan diri ke access point kantor. Jika gagal, LED merah berkedip dan sistem mencoba kembali (*auto-reconnect*) setiap 3 detik tanpa memblokir watchdog timer.
3. **Koneksi Supabase Realtime:** Setelah terhubung ke internet, ESP32 menginisialisasi protokol WebSocket ke endpoint Supabase dan berlangganan (*subscribe*) pada tabel `lockers` dengan filter `locker_id = 'LK-TELKOM-01'`.
4. **Eksekusi Pembukaan Loker:**
   - Ketika payload bernilai `{ "command": "UNLOCK", "booking_id": "BK-XXXX" }` diterima, ESP32 memvalidasi status.
   - Mengaktifkan Pin Relay 1 (Level HIGH), solenoid menarik pin pengunci, dan LED hijau menyala.
   - Menjalankan timer *non-blocking* selama 5000 ms (5 detik).
   - Setelah 5 detik terlampaui, Relay 1 dinonaktifkan kembali (Level LOW), solenoid mengunci, dan LED kembali ke mode standby.
   - Mengirimkan laporan balasan (*Acknowledge*) ke tabel `locker_logs` di Supabase.

---

### 4.3 Sisi Backend, Keamanan, & Cloud Database (Supabase)

#### 4.3.1 Struktur Relasi Basis Data (Database Schema)
Basis data dirancang menggunakan PostgreSQL pada Supabase dengan tabel utama sebagai berikut:

1. **Tabel `profiles`:**
   - `id` (UUID, Primary Key, Foreign Key ke `auth.users`)
   - `full_name` (Text): Nama lengkap personel.
   - `employee_no` (Text): Nomor Induk Karyawan (NIK) Telkom.
   - `role` (Text): Peran otorisasi (`admin` atau `employee`).
   - `phone_number` (Text): Nomor kontak darurat.
2. **Tabel `vehicles`:**
   - `id` (UUID, Primary Key)
   - `make_model` (Text): Merek dan tipe mobil (misal: "Toyota Innova Zenix", "Avanza Veloz").
   - `registration_no` (Text): Nomor plat dinas (misal: "B 1965 TKM").
   - `admin_id` (UUID, Foreign Key ke `profiles.id`): Admin penanggung jawab armada tersebut.
   - `status` (Text): Status operasional (`available`, `in-use`, `maintenance`).
   - `current_lat` & `current_lng` (Double Precision): Koordinat lokasi GPS terkini.
   - `fuel_level` & `odometer` (Integer): Indikator telemetri bahan bakar dan kilometer tempuh.
3. **Tabel `bookings`:**
   - `id` (UUID, Primary Key)
   - `vehicle_id` (UUID, Foreign Key ke `vehicles.id`)
   - `employee_id` (UUID, Foreign Key ke `profiles.id`)
   - `start_time` & `end_time` (Timestamp with Timezone): Jadwal durasi peminjaman.
   - `purpose` (Text): Keperluan perjalanan dinas.
   - `destination` (Text): Alamat lokasi tujuan tugas.
   - `status` (Text): Status pemesanan (`pending`, `approved`, `active`, `completed`, `rejected`).
   - `created_at` (Timestamp with Timezone).
4. **Tabel `lockers`:**
   - `id` (Text, Primary Key, misal: "LK-01")
   - `assigned_vehicle_id` (UUID, Foreign Key ke `vehicles.id`)
   - `is_locked` (Boolean): Status fisik penguncian solenoid.
   - `last_accessed_by` (UUID, Foreign Key ke `profiles.id`)
   - `power_source` (Text): Status sumber daya (`PLN_AC` atau `UPS_BATTERY`).
   - `updated_at` (Timestamp with Timezone).

#### 4.3.2 Kebijakan Keamanan Row Level Security (RLS)
Untuk menjamin integritas data sesuai standar privasi PT Telkom Indonesia, diaktifkan kebijakan RLS:
* Pengguna biasa (`employee`) hanya diizinkan membaca data armada dan data peminjaman milik dirinya sendiri.
* Pengguna admin (`admin`) memiliki wewenang penuh untuk membaca seluruh data armada, memverifikasi permohonan peminjaman, serta mengirim instruksi pembukaan smart locker.

---

### 4.4 Sisi Aplikasi Mobile Admin Monitoring (Flutter Frontend)

Aplikasi Admin Monitoring dibangun dengan arsitektur modular yang tersusun rapi:

#### 4.4.1 Modul Guard Keamanan Global (`AppRequirementGuard`)
Setiap layar pada aplikasi dilindungi oleh *guard widget* (`lib/widgets/app_requirement_guard.dart`) yang dipasang pada root `MaterialApp`. Modul ini mengintegrasikan:
1. **`NetworkManager`:** Memantau konektivitas data seluler atau Wi-Fi secara live. Jika koneksi terputus, aplikasi langsung menampilkan layar dialog modal yang mencegah aksi manipulasi data *offline* yang tidak tersinkron.
2. **`GpsRequirementManager`:** Mengingat aplikasi ini bertugas memantau keberadaan aset kendaraan dinas di peta, perangkat admin diwajibkan mengaktifkan sensor lokasi GPS perangkat untuk menentukan jarak relatif admin terhadap posisi kendaraan dinas.

#### 4.4.2 Modul Otentikasi & Pengelolaan Sesi (`AuthGate` & `SessionManager`)
* **`SessionManager`:** Mengelola preferensi fitur *'Ingat Saya' (Remember Me)* menggunakan penyimpanan lokal persisten.
* **`AuthGate`:** Memverifikasi validitas token JWT Supabase saat aplikasi dibuka. Jika token kedaluwarsa atau peran pengguna bukan `admin`, sesi otomatis di-*sign out* dan diarahkan kembali ke layar `LoginScreen`.

#### 4.4.3 Modul Dashboard Utama (`AdminDashboardScreen`)
Dashboard berfungsi sebagai pusat ringkasan metrik operasional yang memuat:
* **`DashboardSummaryCard`:** Menampilkan total armada, armada aktif beroperasi, armada dalam jadwal perawatan (*maintenance*), dan pengajuan peminjaman yang menunggu persetujuan (*pending approvals*).
* **`FleetStatusCard`:** Menampilkan visualisasi kartu armada lengkap dengan nomor plat dinas, foto kendaraan, tipe mesin, dan status ketersediaan.
* **Penyaringan & Pencarian Cepat:** Memudahkan admin menemukan kendaraan berdasarkan nomor registrasi atau nama karyawan peminjam.

#### 4.4.4 Modul Persetujuan & Tindakan Booking (`BookingDetailSheet`)
Ketika permohonan peminjaman dipilih, admin dapat meninjau:
* Foto profil dan identitas karyawan pemohon (NIK, Unit Kerja).
* Keperluan dinas, destinasi, dan perkiraan waktu pemakaian.
* Tombol aksi satu ketukan (*One-Tap Action*): **Setujui (Approve)** atau **Tolak (Reject)**. Saat disetujui, sistem secara otomatis menerbitkan kode unik otorisasi yang dapat digunakan karyawan untuk mengakses unit Smart Locker.

#### 4.4.5 Modul Pelacakan Armada Real-Time (`TrackingScreen` & `TrackingMapPage`)
Fitur inti pengawasan pergerakan mobil dinas yang memanfaatkan `flutter_map` dengan kapabilitas:
* **Streaming Lokasi Real-Time:** Berlangganan langsung ke baris tabel `bookings` bersetatus `active` menggunakan Supabase Realtime Stream.
* **Telemetri Presisi:** Menghitung kecepatan kendaraan saat ini (*km/jam*), jarak tempuh kumulatif, serta orientasi arah rotasi marker mobil di peta (*heading bearing angle*).
* **Live CCTV Stream (MJPEG):** Memungkinkan admin memantau umpan video kamera internal kabin kendaraan secara live guna memastikan keselamatan pengemudi dinas.
* **Geofence Boundary Security:** Memberikan penanda visual batas wilayah operasional yang sah di peta dan memicu peringatan jika kendaraan dinas melintasi batas zona tugas.

#### 4.4.6 Modul Pengaturan & Personalisasi (`SettingsScreen`)
* **Dukungan Dua Bahasa (`LanguageManager`):** Antarmuka bilingual yang dapat beralih seketika antara Bahasa Indonesia dan Bahasa Inggris (*English*) tanpa perlu memuat ulang aplikasi.
* **Keamanan Lanjutan (`SecurityManager`):** Mendukung proteksi otentikasi biometrik (Fingerprint / Face ID) dan PIN sebelum membuka fitur kritis kontrol loker.
* **Manajemen Profil & Pemeliharaan Armada (`VehicleMaintenanceManager`):** Menandai kendaraan yang sedang dalam masa perbaikan mesin atau penggantian oli agar terkunci sementara dari daftar armada yang dapat dipesan.

---

### 4.5 Alur Proses Bisnis & Integrasi Sistem (Diagram Alur / Flowchart)

Sesuai ketentuan rancangan, alur integrasi seluruh sisi sistem direpresentasikan melalui Diagram Alur (*Flowchart*):

#### 4.5.1 Flowchart Alur Utama: Peminjaman Kendaraan & Pengambilan Kunci Loker
Menjelaskan keterkaitan antara pengajuan di aplikasi karyawan, verifikasi admin di Flutter, trigger Supabase, pemicuan ESP32 dan Solenoid, hingga pengambilan kunci dinas:

```
[Mulai: Karyawan Mengajukan Peminjaman via Aplikasi]
                      │
                      ▼
    [Input Data Armada, Waktu, & Tujuan Dinas]
                      │
                      ▼
         {Verifikasi & Persetujuan Admin?}
           ├── (Ditolak) ──> [Notifikasi Ditolak] ──> [Selesai]
           └── (Disetujui)
                      │
                      ▼
      [Supabase Update Status Booking ke 'Approved']
                      │
                      ▼
     [Karyawan Mendatangi Unit Smart Locker Fisik]
                      │
                      ▼
       [Tekan Tombol 'Buka Loker' di Aplikasi]
                      │
                      ▼
    [Supabase Broadcast Sinyal Real-Time ke ESP32]
                      │
                      ▼
         [ESP32 Memverifikasi Perintah & Token]
                      │
                      ▼
   [Relay 5V Aktif -> Solenoid 12V Terbuka Selama 5 Detik]
                      │
                      ▼
  [LED Indikator Hijau Menyala & Karyawan Ambil Kunci]
                      │
                      ▼
    [Pintu Loker Ditutup & Solenoid Mengunci Kembali]
                      │
                      ▼
 [ESP32 Mengupdate Status Kunci 'In-Use' ke Supabase]
                      │
                      ▼
 [Selesai: Transaksi Berjalan & Armada Mulai Dipantau]
```

#### 4.5.2 Flowchart Firmware ESP32 & Kontrol Hardware Solenoid
Menjelaskan logika siklus hidup mikrokontroler di sisi loker fisik:

```
    [Mulai: Booting ESP32 DevKit & Inisialisasi Pin I/O Shield]
                                │
                                ▼
          [Menghubungkan ESP32 ke Jaringan Wi-Fi Kantor]
                                │
                                ▼
                     {Wi-Fi Berhasil Terhubung?}
                       ├── (Tidak) ──> [LED Error Berkedip & Retry 3s] ──┐
                       │                                                  │
                       └── (Ya) <─────────────────────────────────────────┘
                                │
                                ▼
        [Subscribe ke Supabase Realtime Channel 'lockers']
                                │
                                ▼
                  {Menerima Perintah 'UNLOCK'?}
                       ├── (Tidak) ──> [Looping Siaga] ──┐
                       │                                 │
                       └── (Ya) <────────────────────────┘
                                │
                                ▼
        [Set Pin Relay 1 = HIGH (Solenoid 12V Buka)]
                                │
                                ▼
            [Nyalakan LED Indikator Hijau (Akses Buka)]
                                │
                                ▼
              [Jalankan Timer Hitung Mundur 5 Detik]
                                │
                                ▼
        [Set Pin Relay 1 = LOW (Solenoid Mengunci Kembali)]
                                │
                                ▼
          [Kirim Acknowledge (ACK) Sukses ke Supabase]
                                │
                                ▼
                   [Kembali ke Status Standby]
```

#### 4.5.3 Flowchart Manajemen Daya UPS TechBee
Menjelaskan proteksi pasokan listrik loker saat terjadi pemadaman listrik:

```
        [Mulai: Sistem Smart Locker Terhubung ke UPS TechBee]
                                │
                                ▼
                   {Sumber Listrik PLN Aktif?}
          ┌─────────────────────┴─────────────────────┐
     (Ya / Normal)                              (Tidak / Padam)
          │                                           │
          ▼                                           ▼
[UPS Alirkan Daya PLN &                     [UPS Otomatis Beralih ke
 Charge Baterai Cadangan]                    Baterai Cadangan (0ms Delay)]
          │                                           │
          ▼                                           ▼
[Tegangan Stabil 5V & 12V]                  [ESP32 Kirim Notifikasi
          │                                  'Power Outage' ke Supabase]
          │                                           │
          └─────────────────────┬─────────────────────┘
                                │
                                ▼
          [Sistem Loker Tetap Beroperasi Penuh (4 - 6 Jam)]
                                │
                                ▼
                {Kapasitas Baterai Cadangan Kritis?}
                   ├── (Tidak) ──> [Operasional Normal]
                   └── (Ya / < 15%)
                                │
                                ▼
    [Kirim Notifikasi Peringatan Darurat Baterai ke Admin]
                                │
                                ▼
        [Safe-State: Solenoid Tetap Mengunci Demi Keamanan]
```

---

### 4.6 Rencana Anggaran Biaya (RAB) Implementasi Sistem

Rencana Anggaran Biaya mencakup dua kategori pembiayaan, yaitu pengadaan perangkat keras (*hardware Smart Locker*) dan kebutuhan operasional bulanan (*cloud backend*).

#### 4.6.1 Rincian Biaya Perangkat Keras (Smart Locker Hardware)
| No. | Komponen Perangkat Keras | Qty | Estimasi Harga/Unit | Subtotal |
| :---: | :--- | :---: | :---: | :---: |
| **1.** | ESP32 DevKit Type-C | 1 | Rp88.500 | Rp88.500 |
| **2.** | I/O Expansion Shield ESP32 (30 Pin) | 1 | Rp46.000 | Rp46.000 |
| **3.** | Relay 5V 2 Channel | 1 | Rp24.500 | Rp24.500 |
| **4.** | Solenoid Door Lock | 1 | Rp40.750 | Rp40.750 |
| **5.** | LED 5mm 5v-12v | 6 | Rp4.900 | Rp29.500 |
| **6.** | Penyimpanan Kunci (Enclosure Kompartemen) | 1 | Rp225.500 | Rp225.500 |
| **7.** | UPS TechBee Output 5v+12v | 1 | Rp264.000 | Rp264.000 |
| **8.** | Kabel Jumper | 3 | Rp18.600 | Rp56.000 |
| **9.** | Dioda in 4007 | 1 | Rp1.500 | Rp1.500 |
| **10.** | Kabel Jst | 2 | Rp1.500 | Rp3.000 |
| **11.** | Konektor kabel 2-6 | 2 | Rp14.000 | Rp28.000 |
| **12.** | Konektor kabel 2-2 | 8 | Rp3.600 | Rp29.000 |
| **13.** | Kabel awg 20 (hitam dan merah) (2m) | 4 | Rp3.000 | Rp12.000 |
| **TOTAL** | **BIAYA PERANGKAT KERAS (HARDWARE)** | | | **Rp848.250** |

#### 4.6.2 Kebutuhan Biaya Operasional Bulanan
| Kebutuhan Layanan | Keterangan Fungsional | Estimasi Biaya / Bulan |
| :--- | :--- | :---: |
| **Cloud Database (Supabase)** | Untuk Database PostgreSQL, Auth, & Realtime WebSocket | **±Rp 450.000 / bulan** |

---

## BAB V: IMPLEMENTASI DAN PENGUJIAN

### 5.1 Implementasi Antarmuka Aplikasi Admin Monitoring
Aplikasi Flutter Admin Monitoring telah diimplementasikan dengan fitur-fitur utama berikut:
1. **Layar Login & AuthGate:** Memastikan autentikasi berbasis Supabase Auth dengan penanganan peran admin secara otomatis.
2. **Layar Dashboard Armada:** Menampilkan status armada dinas secara komprehensif, kartu peminjaman aktif, serta integrasi filter status (*All, Pending, Active, Completed*).
3. **Layar Live Tracking Map:** Memetakan posisi koordinat kendaraan secara dinamis di atas peta, visualisasi kecepatan telemetri, serta dukungan stream CCTV internal kabin.
4. **Layar Detail & Riwayat Peminjaman:** Menampilkan seluruh rekam jejak peminjaman sebelumnya secara kronologis untuk keperluan audit operasional.
5. **Layar Pengaturan (Settings):** Pengaturan bahasa (ID/EN), pengaturan notifikasi, ubah kata sandi, dan informasi tentang pengembang aplikasi.

### 5.2 Implementasi Integrasi Fisik Smart Locker
Unit Smart Locker dirakit di dalam chasis penyimpanan kunci berinsulasi:
* Modul ESP32 DevKit dipasang di atas I/O Expansion Shield untuk menjamin kestabilan perkabelan.
* Modul Relay 5V 2 Channel dihubungkan ke Pin GPIO 23 ESP32 sebagai pemicu coil relay.
* Solenoid Door Lock dihubungkan ke sumber tegangan 12V UPS TechBee melalui kontak *Normally Open* (NO) Relay.
* Dioda 1N4007 disolder tepat pada terminal katoda-anoda solenoid dengan konfigurasi reverse-biased untuk mencegah *arcing* dan lonjakan induksi listrik.
* Indikator LED 5mm dipasang pada panel depan pintu loker untuk memberikan visualisasi status yang jelas bagi staf lapangan.

### 5.3 Metode dan Hasil Pengujian

#### 5.3.1 Pengujian Black-Box Antarmuka Aplikasi Mobile
| No. | Skenario Pengujian | Hasil yang Diharapkan | Status |
| :---: | :--- | :--- | :---: |
| 1. | Login dengan kredensial Admin valid | Berhasil masuk ke Admin Dashboard Screen | **BERHASIL** |
| 2. | Login dengan akun karyawan biasa | Ditolak oleh AuthGate dan sesi dibersihkan | **BERHASIL** |
| 3. | Buka aplikasi saat koneksi internet mati | Muncul modal peringatan AppRequirementGuard | **BERHASIL** |
| 4. | Buka aplikasi saat GPS HP nonaktif | Muncul dialog permintaan aktifkan lokasi | **BERHASIL** |
| 5. | Admin menekan tombol "Setujui" pada booking | Status booking berubah ke "Approved" di Supabase | **BERHASIL** |
| 6. | Penggantian bahasa ke Bahasa Inggris | Seluruh label antarmuka beralih ke English | **BERHASIL** |

#### 5.3.2 Pengujian Latensi Pembukaan Solenoid Door Lock
Pengujian dilakukan untuk mengukur waktu respon dari tombol ditekan di aplikasi hingga solenoid fisik terbuka:
* **Uji Coba 1 (Jaringan Wi-Fi Kantor):** 0,82 detik.
* **Uji Coba 2 (Jaringan 4G LTE Seluler):** 1,15 detik.
* **Uji Coba 3 (Jaringan 4G Sinyal Rendah):** 1,64 detik.
* **Rata-rata Respon:** **1,20 detik** (Memenuhi kriteria toleransi < 2,0 detik).

#### 5.3.3 Pengujian Ketahanan Catu Daya Cadangan UPS TechBee
Pengujian dilakukan dengan mencabut steker listrik utama PLN dari stop kontak:
* **Respon Peralihan Daya:** Beralih ke baterai internal dengan jeda waktu 0 ms (ESP32 tidak mengalami restart atau freeze).
* **Durasi Operasional:** Sistem loker mampu bertahan dalam status siaga (*standby*) dan melayani 45 kali siklus buka-tutup solenoid selama **5 jam 18 menit** sebelum baterai mencapai batas kritis 15%.
* **Kondisi Fail-Safe:** Saat baterai habis total, mekanisme Solenoid Door Lock tetap berada dalam kondisi terkunci rapat (*fail-secure*), sehingga isi kompartemen kunci tetap terlindungi secara fisik.

---

## BAB VI: KESIMPULAN DAN SARAN

### 6.1 Kesimpulan
Berdasarkan seluruh tahapan perancangan, implementasi, dan pengujian yang telah dilaksanakan selama kegiatan Praktik Kerja Lapangan (Magang) di PT Telkom Indonesia, dapat ditarik kesimpulan sebagai berikut:
1. **Keberhasilan Rancang Bangun IoT Smart Locker:** Sistem perangkat keras Smart Locker yang memadukan ESP32 DevKit, Relay 2 Channel, Solenoid Door Lock 12V, LED indikator, dan UPS TechBee berhasil dirakit dan berfungsi dengan tingkat keandalan tinggi dan respon rata-rata pembukaan 1,20 detik.
2. **Kekuatan Arsitektur Cloud Supabase:** Pemanfaatan Supabase sebagai backend BaaS terbukti sangat efektif dalam menyediakan sinkronisasi status real-time antara aplikasi mobile dan firmware IoT dengan latensi rendah, didukung keamanan autentikasi Row Level Security (RLS).
3. **Komprehensivitas Aplikasi Mobile Flutter:** Aplikasi Admin Monitoring berhasil dibangun dengan memperhatikan seluruh aspek fungsionalitas dan keamanan, meliputi dashboard analitik, persetujuan peminjaman cepat, pelacakan live GPS armada, telemetri, live stream CCTV kabin, hingga perlindungan guard jaringan dan GPS.
4. **Resiliensi Daya Tinggi:** Pemanfaatan UPS TechBee terbukti menjamin kelangsungan operasional sistem loker hingga lebih dari 5 jam saat terjadi pemadaman listrik PLN dengan mekanisme fail-secure.
5. **Pencapaian Target Magang:** Praktikan berhasil menyatukan kompetensi akademis dari Sekolah Vokasi Universitas Pakuan dengan kebutuhan nyata operasional logistik di PT Telkom Indonesia (Persero) Tbk.

### 6.2 Saran untuk Pengembangan Lanjutan
Untuk pengembangan dan penyempurnaan sistem pada skala implementasi yang lebih luas, disarankan:
1. **Integrasi RFID / NFC Card Reader:** Menambahkan modul pembaca kartu RFID (seperti RC522 atau PN532) langsung pada bodi Smart Locker sehingga staf dapat membuka loker menggunakan ID Card karyawan Telkom sebagai alternatif aplikasi mobile.
2. **Pengembangan Multi-Compartment Lockers:** Mengembangkan sistem multiplexer (I2C atau shift register) agar satu mikrokontroler ESP32 mampu mengendalikan banyak loker kunci sekaligus (misal: 10 hingga 20 loker armada).
3. **Penerapan Edge AI / Telematika OBD-II:** Mengintegrasikan pemindai OBD-II pada kendaraan dinas untuk mengirimkan telemetri langsung kondisi mesin (kesehatan aki, suhu mesin, kode kerusakan DTC) ke dashboard admin secara otomatis.

---

## DAFTAR PUSTAKA

1. ESP32 Series Datasheet, Espressif Systems (Shanghai) Co., Ltd., 2024.
2. Flutter Documentation & Architecture Guide, Google Developers, 2025.
3. Supabase Documentation: Realtime, Database, and Authentication, Supabase Inc., 2025.
4. Tanenbaum, A. S., & Wetherall, D. J. *Computer Networks (5th Edition)*. Pearson, 2011.
5. Sommerville, I. *Software Engineering (10th Edition)*. Pearson, 2015.
6. Monk, S. *Programming the ESP32: Getting Started with Arduino*. McGraw-Hill Education, 2022.
7. PT Telkom Indonesia (Persero) Tbk. *Buku Pedoman Pengelolaan Aset dan Operasional Armada Kendaraan Dinas*. Jakarta, 2023.
8. Sekolah Vokasi Universitas Pakuan. *Pedoman Pelaksanaan dan Penyusunan Laporan Praktik Kerja Lapangan (PKL)*. Bogor, 2025.
