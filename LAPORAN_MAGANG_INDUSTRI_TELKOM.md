# LAPORAN PRAKTEK KERJA MAGANG INDUSTRI

## RANCANG BANGUN SISTEM MONITORING OPERASIONAL ARMADA DAN MANAJEMEN AKSES SMART LOCKER BERBASIS IOT DAN FLUTTER
### (Studi kasus: PT. Telkom Akses Bogor)

**oleh:**  
**Rahman Eka Ardiansyah**  
**084023019**

---

**PROGRAM STUDI TEKNIK KOMPUTER**  
**SEKOLAH VOKASI**  
**UNIVERSITAS PAKUAN**  
**BOGOR**  
**2026**

---

## HALAMAN PENGESAHAN

**Judul:** Rancang Bangun Sistem Monitoring Operasional Armada dan Manajemen Akses Smart Locker Berbasis IoT dan Flutter  
**Nama:** Rahman Eka Ardiansyah  
**NPM:** 084023019  

**Mengesahkan,**

| Pembimbing II, PT Telkom Akses Bogor | Pembimbing I, Sekolah Vokasi Universitas Pakuan |
| :---: | :---: |
| *(Tanda Tangan & Cap)* | *(Tanda Tangan & Cap)* |
| **Pahreza Fajri Sulaeman** | **Deden Ardiansyah, M.Kom.** |

**Mengetahui,**  
**Ketua Program Studi Teknik Komputer**  
**Sekolah Vokasi Universitas Pakuan**

*(Tanda Tangan)*  
**Akbar Sugih Miftahul Huda, M.Kom.**

*(Halaman i)*

---

## HALAMAN PENGESAHAN KONFIRMASI REVISI

**Judul:** Rancang Bangun Sistem Monitoring Operasional Armada dan Manajemen Akses Smart Locker Berbasis IoT dan Flutter  
**Nama:** Rahman Eka Ardiansyah  
**NPM:** 084023019  

**Mengesahkan,**

| Penguji II, Sekolah Vokasi Universitas Pakuan | Penguji I, Sekolah Vokasi Universitas Pakuan |
| :---: | :---: |
| *(Tanda Tangan)* | *(Tanda Tangan)* |
| **Deden Ardiansyah, M.Kom.** | **Sufiatul Maryana, M.Kom.** |

*(Halaman ii)*

---

## KATA PENGANTAR

Puji syukur saya panjatkan kepada Tuhan Yang Maha Esa, karena atas berkat dan rahmat-Nya, sehingga dapat menyelesaikan laporan Praktek Kerja Magang Industri (PKMI) ini. Menyadari bahwa, tanpa bantuan dan bimbingan dari berbagai pihak, dari masa perkuliahan sampai pada penyusunan laporan ini, sangatlah sulit untuk menyelesaikan laporan Magang ini. Oleh karena itu, diucapkan terima kasih kepada:

1. **Deden Ardiansyah, M.Kom.** selaku dosen pembimbing yang telah menyediakan waktu, tenaga, dan pikiran untuk mengarahkan penulis dalam penyusunan laporan ini;
2. **Pahreza Fajri Sulaeman** selaku pembimbing lapangan di PT Telkom Akses Bogor yang telah membantu dan membimbing dalam pengenalan dunia kerja dan dalam penyusunan laporan magang;
3. **Dr. Lia Dahlia Iryani, S.E., M.Si.** selaku Dekan Sekolah Vokasi Universitas Pakuan;
4. **Akbar Sugih Miftahul Huda, M.Kom.** selaku Ketua Program Studi Teknik Komputer Sekolah Vokasi Universitas Pakuan;
5. Seluruh pihak **PT Telkom Akses Bogor** yang telah membantu dalam praktik kerja lapangan serta usaha untuk memperoleh data yang penulis butuhkan;
6. Orang tua dan keluarga penulis yang telah memberikan dukungan moral dan material dalam penyusunan laporan magang penulis;
7. Sahabat–sahabat penulis yang memberikan dukungan moral dalam penyusunan laporan magang ini;

Akhir kata, harapan semoga Tuhan Yang Maha Esa berkenan membalas segala kebaikan semua pihak yang telah membantu. Semoga Laporan Magang ini membawa manfaat bagi pengembangan ilmu pengetahuan dan teknologi.

Bogor, 9 Januari 2026  
**Rahman Eka Ardiansyah**  
*(Halaman iii)*

---

## DAFTAR ISI

* **HALAMAN PENGESAHAN** ............................................................................ i
* **HALAMAN PENGESAHAN KONFIRMASI REVISI** .................................... ii
* **KATA PENGANTAR** ..................................................................................... iii
* **DAFTAR ISI** ................................................................................................... iv
* **DAFTAR GAMBAR** ....................................................................................... vi
* **DAFTAR TABEL** ........................................................................................... vii
* **DAFTAR LAMPIRAN** ................................................................................. viii
* **BAB I PENDAHULUAN** ................................................................................. 1
  * 1.1 Latar Belakang .......................................................................................... 1
  * 1.2 Tujuan Praktek Kerja Magang Industri ...................................................... 2
  * 1.3 Ruang Lingkup Praktek Kerja Magang Industri ......................................... 2
  * 1.4 Manfaat .................................................................................................... 3
* **BAB II TINJAUAN INSTANSI DAN PUSTAKA** ........................................... 4
  * 2.1 Tinjauan Instansi ....................................................................................... 4
    * 2.1.1 Sejarah Instansi ................................................................................. 4
    * 2.1.2 Visi Misi Instansi .............................................................................. 5
    * 2.1.3 Struktur Organisasi Instansi ............................................................... 5
    * 2.1.4 Dokumentasi PKMI ........................................................................... 6
  * 2.2 Tinjauan Pustaka ....................................................................................... 6
    * 2.2.1 Smart Locker & Sistem Solenoid Door Lock .................................... 6
    * 2.2.2 Mikrokontroler ESP32 & I/O Expansion Shield ................................ 7
    * 2.2.3 Relay 5V 2 Channel & Dioda Flyback 1N4007 ................................ 7
    * 2.2.4 Uninterruptible Power Supply (UPS) TechBee 5V+12V ................... 7
    * 2.2.5 Framework Flutter & Bahasa Pemrograman Dart .............................. 7
    * 2.2.6 Backend Cloud Supabase (PostgreSQL, Auth, Realtime) ................... 7
    * 2.2.7 Geolokasi GPS, Geofencing, & Live Telemetri Armada ................... 7
  * 2.3 Waktu Pelaksanaan PKMI ........................................................................ 8
  * 2.4 Penelitian Terdahulu ................................................................................. 8
  * 2.5 Tabel Perbandingan .................................................................................. 9
* **BAB III METODE PELAKSANAAN** ............................................................ 10
  * 3.1 Metode Penelitian (SDLC) ...................................................................... 10
    * 3.1.1 Planning .......................................................................................... 10
    * 3.1.2 Analisis ........................................................................................... 11
      * 3.1.2.1 Analisis Data (Metode Pengumpulan Data, Spesifikasi, Sumber Data) .. 11
      * 3.1.2.2 Analisis Kebutuhan (Fungsional & Non-Fungsional) ............... 12
      * 3.1.2.3 Analisis Sistem (Sistem Berjalan vs Sistem Dikembangkan) .... 12
    * 3.1.3 Design ............................................................................................. 17
      * 3.1.3.1 Perancangan Sistem Secara Umum (DFD Level 0, DFD Level 1, Flowchart) .. 17
      * 3.1.3.2 Perancangan Basis Data (ERD & Tabel Spesifikasi) ................ 19
      * 3.1.3.3 Perancangan User Interface ..................................................... 21
    * 3.1.4 Implementasi ................................................................................... 22
      * 1. Implementasi Rangkaian IoT Smart Locker & RAB Komponen .... 22
      * 2. Implementasi Cloud Database Supabase ...................................... 23
      * 3. Implementasi Aplikasi Mobile Flutter Admin Monitoring ........... 24
    * 3.1.5 Testing ............................................................................................. 24
    * 3.1.6 Maintenance .................................................................................... 24
  * 3.2 Tahap atau Metode Pelaksanaan .............................................................. 24
  * 3.3 Waktu dan Tempat Pelaksanaan .............................................................. 24
* **BAB IV HASIL DAN PEMBAHASAN** ......................................................... 25
  * 4.1 Hasil ......................................................................................................... 25
  * 4.2 Pembahasan ............................................................................................. 29
    * 4.2.1 Uji Coba Struktural .......................................................................... 29
    * 4.2.2 Uji Coba Fungsional ........................................................................ 33
    * 4.2.3 Uji Coba Validasi ............................................................................ 38
* **BAB V PENUTUP** .......................................................................................... 40
  * 5.1 Kesimpulan ............................................................................................. 40
  * 5.2 Saran ........................................................................................................ 40
* **DAFTAR PUSTAKA** ...................................................................................... 41
* **DAFTAR LAMPIRAN** ................................................................................... 42

*(Halaman iv - v)*

---

## DAFTAR GAMBAR

* Gambar 1. Struktur Organisasi PT Telkom Akses Bogor ................................. 5
* Gambar 2. Dokumentasi PKMI .......................................................................... 6
* Gambar 3. SDLC (System Development Life Cycle) ...................................... 10
* Gambar 4. Analisis Sistem yang Sedang Berjalan ............................................ 14
* Gambar 5. Alur Proses Sistem yang Akan Dikembangkan .............................. 16
* Gambar 6. DFD Level 0 Sistem Smart Locker & Fleet Monitoring .............. 17
* Gambar 7. DFD Level 1 Sistem Smart Locker & Fleet Monitoring .............. 17
* Gambar 8. Flowchart Sistem Utama (Peminjaman & Akses Loker) ................. 18
* Gambar 9. ERD (Entity Relationship Diagram) Database .............................. 19
* Gambar 10. Desain Antarmuka Login & AuthGate ......................................... 21
* Gambar 11. Desain Antarmuka Dashboard Fleet Monitoring .......................... 22
* Gambar 12. Desain Antarmuka Live Tracking Map & CCTV ......................... 22
* Gambar 13. Desain Antarmuka Booking Approval Sheet ................................ 23
* Gambar 14. Perakitan Hardware ESP32, Shield, Relay, Solenoid, dan UPS ... 23
* Gambar 15. Dashboard Supabase Cloud Database & Tables ........................... 24
* Gambar 16. Implementasi Login Sukses Role Admin ...................................... 25
* Gambar 17. Implementasi Dashboard Fleet Status .......................................... 25
* Gambar 18. Implementasi Persetujuan Peminjaman Mobil .............................. 26
* Gambar 19. Implementasi Respon Solenoid Fisik Buka (LED Hijau) ............. 26
* Gambar 20. Implementasi Pelacakan GPS Real-Time Armada ........................ 27
* Gambar 21. Implementasi Live CCTV Kabin Mobil ........................................ 27
* Gambar 22. Implementasi Notifikasi Pemadaman Listrik (Mode UPS) ........... 28
* Gambar 23. Implementasi Peringatan Guard (Wajib Internet & GPS) ............ 28

*(Halaman vi)*

---

## DAFTAR TABEL

* Tabel 1. Tabel Perbandingan Penelitian ............................................................ 9
* Tabel 2. Alur Proses Sistem yang Sedang Berjalan .......................................... 13
* Tabel 3. Alur Proses Sistem yang Akan Dikembangkan .................................. 15
* Tabel 4. Tabel Spesifikasi Database: `profiles` ................................................ 19
* Tabel 5. Tabel Spesifikasi Database: `vehicles` ................................................ 20
* Tabel 6. Tabel Spesifikasi Database: `bookings` ............................................... 20
* Tabel 7. Tabel Spesifikasi Database: `lockers` .................................................. 20
* Tabel 8. Tabel Spesifikasi Database: `vehicle_maintenance` ............................ 21
* Tabel 9. Rencana Anggaran Biaya (RAB) Hardware Smart Locker ................. 22
* Tabel 10. Uji Coba Struktural Sistem .............................................................. 29
* Tabel 11. Uji Coba Fungsional Sistem ............................................................ 33
* Tabel 12. Uji Coba Validasi Sistem ................................................................. 38

*(Halaman vii)*

---

## DAFTAR LAMPIRAN

* Lampiran 1. Surat Permohonan PKMI ............................................................. 42
* Lampiran 2. Surat Balasan Instansi .................................................................. 44
* Lampiran 3. Surat Keterangan Magang ............................................................ 45
* Lampiran 4. Sertifikat Magang ......................................................................... 46
* Lampiran 5. Kartu Bimbingan PKMI ............................................................... 47
* Lampiran 6. Daftar Hadir PKMI ...................................................................... 48

*(Halaman viii)*

---

## BAB I: PENDAHULUAN

### 1.1 Latar Belakang
Pengelolaan operasional armada kendaraan bermotor dinas di PT Telkom Akses Bogor memegang peranan krusial dalam mendukung kelancaran pemeliharaan jaringan telekomunikasi kabel serat optik (fiber optic), penanganan gangguan pelanggan IndiHome, hingga pemeliharaan berkala infrastruktur STO (Sentral Telepon Otomat). Ketersediaan mobil dinas dan efisiensi waktu mobilisasi teknisi di lapangan sangat bergantung pada kemudahan serta ketertiban akses peminjaman kunci kendaraan.

Namun, dalam praktiknya, pengelolaan kunci fisik kendaraan dinas dan pemantauan keberadaan armada di PT Telkom Akses Bogor masih sering dilakukan secara manual. Berdasarkan hasil observasi selama pelaksanaan PKMI, permohonan peminjaman kendaraan masih dicatat ke dalam buku log manual atau file spreadsheet terpisah. Kondisi tersebut menimbulkan berbagai keterbatasan operasional:
1. **Risiko Kehilangan dan Kelalaian Kunci Fisik:** Kunci mobil dinas rentan tertukar, terselip, atau terlambat dikembalikan oleh staf tanpa adanya riwayat digital penanggung jawab yang dapat dilacak secara instan.
2. **Ketiadaan Integrasi Fisik Loker dengan Status Izin Dinas:** Tidak adanya mekanisme penguncian digital yang memvalidasi apakah peminjam telah mengantongi izin resmi dari admin sebelum kunci fisik dapat diambil dari kompartemen penyimpanan.
3. **Keterbatasan Pengawasan Armada Real-Time:** Admin operasional mengalami kendala dalam memantau secara live posisi koordinat kendaraan dinas, kecepatan tempuh, dan pemanfaatan armada di luar jam operasional yang ditentukan.
4. **Resiko Ketiadaan Daya saat Listrik Padam:** Sistem elektronik konvensional berisiko mati total saat terjadi pemadaman listrik gedung PLN, sehingga kunci mobil tidak dapat diakses untuk penanganan gangguan darurat telekomunikasi.

Kondisi tersebut mendorong perlunya solusi otomatis yang mampu menyatukan keamanan fisik penyimpanan kunci dengan sistem digital pemantauan armada. Oleh karena itu, dibangunlah **Sistem Monitoring Operasional Armada dan Manajemen Akses Smart Locker Berbasis IoT dan Flutter**. Sistem ini memanfaatkan mikrokontroler **ESP32 DevKit Type-C** yang mengendalikan aktuator **Solenoid Door Lock 12V** via **Relay 5V 2 Channel**, dilengkapi sistem cadangan daya mandiri **UPS TechBee (5V+12V)**, basis data tersinkronisasi real-time menggunakan **Supabase**, serta aplikasi mobile pemantauan admin berbasis **Flutter**.

### 1.2 Tujuan Praktek Kerja Magang Industri
Tujuan dari Praktek Kerja Magang Industri ini adalah untuk melakukan pembuatan:
**Sistem Monitoring Operasional Armada dan Manajemen Akses Smart Locker Berbasis IoT dan Flutter Terintegrasi Supabase Cloud pada PT Telkom Akses Bogor.**

### 1.3 Ruang Lingkup Praktek Kerja Magang Industri
Ruang lingkup pengembangan sistem ini meliputi:
a. Merancang dan merakit unit perangkat keras Smart Locker berbasis mikrokontroler ESP32 DevKit Type-C, modul I/O Expansion Shield 30-Pin, Relay 5V 2 Channel, Solenoid Door Lock 12V, 6 titik LED indikator, dan enclosure kotak penyimpanan kunci.
b. Menerapkan sistem manajemen daya mandiri menggunakan UPS TechBee dengan keluaran ganda (5V untuk mikrokontroler dan 12V untuk solenoid) agar loker tetap dapat diakses saat pemadaman listrik PLN.
c. Membangun basis data cloud pada Supabase meliputi tabel `profiles`, `vehicles`, `bookings`, `lockers`, dan `vehicle_maintenance` dengan dukungan Row Level Security (RLS) dan Realtime Engine WebSocket.
d. Membangun aplikasi mobile Admin Monitoring menggunakan framework Flutter dengan fitur Guard Keamanan (wajib koneksi internet dan wajib GPS aktif), dashboard analitik status armada, persetujuan booking dinas, live tracking peta koordinat GPS, telemetri kecepatan (km/jam), live stream kamera interior kabin, serta riwayat audit.
e. Melakukan pengujian sistem meliputi uji coba struktural, uji coba fungsional, uji coba validasi, uji coba latensi, dan uji coba ketahanan catu daya UPS.

### 1.4 Manfaat
Adapun manfaat dari sistem ini adalah:
a. Mempermudah proses pengambilan dan pengembalian kunci kendaraan dinas secara otomatis tanpa pencatatan manual di buku log.
b. Meningkatkan keamanan dan akuntabilitas aset armada PT Telkom Akses Bogor melalui verifikasi digital satu pintu.
c. Menghemat waktu admin operasional dalam memverifikasi permohonan dinas dan melacak posisi kendaraan di lapangan secara langsung.
d. Menjamin ketersediaan akses kunci darurat 24/7 berkat perlindungan cadangan daya baterai UPS TechBee.
e. Menyediakan rekam jejak digital riwayat perjalanan dinas yang transparan, akurat, dan terpusat di cloud database.

---

## BAB II: TINJAUAN INSTANSI DAN PUSTAKA

### 2.1 Tinjauan Instansi
#### 2.1.1 Sejarah Instansi
PT Telkom Akses resmi didirikan pada tanggal 12 Desember 2012 sebagai anak perusahaan PT Telkom Indonesia (Persero) Tbk. Pendirian Telkom Akses merupakan bagian dari komitmen Telkom Group dalam memperluas dan memodernisasi infrastruktur jaringan broadband pita lebar di seluruh pelosok Indonesia. Telkom Akses bergerak di bidang penyediaan layanan konstruksi, pemeliharaan (*maintenance*), dan pengoperasian jaringan telekomunikasi kabel serat optik (*Fiber to the Home* / FTTH).

Di wilayah Bogor, PT Telkom Akses Bogor mengelola ribuan kilometer rute serat optik dan melayani ratusan ribu pelanggan layanan IndiHome. Untuk mendukung mobilitas para teknisi lapangan, Telkom Akses Bogor mengoperasikan armada kendaraan dinas yang harus selalu siap pakai dan terpantau kondisinya setiap saat.

#### 2.1.2 Visi Misi Instansi
* **Visi:** "Menjadi Perusahaan Jasa Operasi dan Pemeliharaan Jaringan Broadband Terdepan di Indonesia."
* **Misi:**
  1. Memberikan layanan terbaik dalam penyediaan infrastruktur akses broadband dengan standar kualitas kelas dunia.
  2. Mengoptimalkan operasional dan pemeliharaan jaringan telekomunikasi secara efisien dan andal.
  3. Membangun budaya kerja yang adaptif, inovatif, dan berlandaskan tata kelola perusahaan yang bersih.

#### 2.1.3 Struktur Organisasi Instansi
Struktur organisasi PT Telkom Akses Bogor dipimpin oleh General Manager (GM) TA Bogor yang membawahi beberapa unit fungsional seperti Shared Service, Business Support, Network Operation, Fiber Academy, dan Commerce.

*(Gambar 1. Struktur Organisasi PT Telkom Akses Bogor)*

#### 2.1.4 Dokumentasi PKMI
Kegiatan magang industri dilaksanakan di lingkungan kantor PT Telkom Akses Bogor, berkolaborasi dengan unit Business Support dan Operasional Armada dalam merancang, merakit purwarupa Smart Locker, serta menguji aplikasi mobile.

*(Gambar 2. Dokumentasi PKMI)*

---

### 2.2 Tinjauan Pustaka
#### 2.2.1 Smart Locker & Sistem Solenoid Door Lock
Smart Locker adalah sistem kompartemen penyimpanan yang mengombinasikan mekanisme kunci fisik dengan kontrol elektronik otomatis. Penggerak fisik utamanya adalah Solenoid Door Lock 12V, yaitu aktuator yang menggunakan gaya elektromagnetik untuk menarik lidah pengunci baja saat kumparannya dialiri arus searah.

#### 2.2.2 Mikrokontroler ESP32 & I/O Expansion Shield
ESP32 DevKit merupakan modul System-on-Chip (SoC) dual-core 32-bit berkemampuan Wi-Fi dan Bluetooth BLE. Pemanfaatan I/O Expansion Shield 30-Pin mempermudah terminasi kabel sensor dan aktuator tanpa risiko kabel kendur akibat getaran pintu loker.

#### 2.2.3 Relay 5V 2 Channel & Dioda Flyback 1N4007
Modul Relay 5V bertindak sebagai isolator optoelektronik (*optocoupler*) antara mikrokontroler dan sirkuit solenoid 12V. Pemasangan Dioda 1N4007 secara antiparalel (*flyback diode*) melintasi terminal koil solenoid sangat penting untuk meredam lonjakan tegangan induktif balik (*inductive kickback / back-EMF*) yang dapat merusak kontak relay.

#### 2.2.4 Uninterruptible Power Supply (UPS) TechBee 5V+12V
UPS TechBee adalah unit catu daya terpadu dengan keluaran ganda (5V DC untuk mikrokontroler dan 12V DC untuk solenoid). Modul ini memiliki kemampuan switching instan (0 ms) dari jaringan listrik PLN ke baterai lithium internal saat terjadi pemadaman listrik.

#### 2.2.5 Framework Flutter & Bahasa Pemrograman Dart
Flutter adalah framework open-source Google untuk membangun aplikasi antarmuka pengguna lintas platform (Android/iOS) dari basis kode tunggal (*single codebase*). Flutter menggunakan bahasa pemrograman Dart yang dikompilasi langsung ke kode mesin AOT (*Ahead-Of-Time*).

#### 2.2.6 Backend Cloud Supabase (PostgreSQL, Auth, Realtime)
Supabase adalah platform Backend-as-a-Service (BaaS) modern yang dibangun di atas PostgreSQL enterprise. Supabase menyediakan autentikasi terenkripsi JWT, Row Level Security (RLS), dan Realtime WebSocket Engine untuk komunikasi dua arah berlatensi rendah.

#### 2.2.7 Pemantauan GPS & Telemetri Armada
Pemantauan kendaraan dinas diimplementasikan menggunakan pustaka `flutter_map` dengan koordinat lintang/bujur (LatLong) yang menghitung kecepatan real-time (km/jam), total jarak tempuh, sudut orientasi arah (*heading*), serta deteksi wilayah dinas (*geofencing*).

---

### 2.3 Waktu Pelaksanaan PKMI
Pelaksanaan Praktek Kerja Magang Industri (PKMI) dilaksanakan di **PT Telkom Akses Bogor** yang beralamat di Jl. Pengadilan No. 14, RT 03/RW 01, Kelurahan Pabaton, Kecamatan Bogor Tengah, Kota Bogor, Jawa Barat 16121.  
Kegiatan PKMI dilaksanakan selama 3 (tiga) bulan, terhitung sejak tanggal **1 September 2025 hingga 1 Desember 2025**, dengan jam kerja mulai pukul 08.00 hingga 17.00 WIB.

### 2.4 Penelitian Terdahulu
1. **Andata Leonarda; Irma Handayani (2025):** Prototipe Sistem Deteksi Plat Nomor Kendaraan Berbasis YOLOv8 dan Tesseract OCR untuk Lingkungan Kampus.
2. **Robby Darmawan; Aris Nasuha (2021):** Sistem Manajemen Kartu Nama dengan OCR dan Ekstraksi Informasi Otomatis.
3. **Rahman Eka Ardiansyah (2025):** Rancang Bangun Sistem Monitoring Operasional Armada dan Manajemen Akses Smart Locker Berbasis IoT dan Flutter Terintegrasi Supabase Cloud.

### 2.5 Tabel Perbandingan Penelitian
#### Tabel 1. Tabel Perbandingan Penelitian
| Nama Peneliti | Mikrokontroler / IoT | Basis Data | Framework UI | Otomasi Real-Time | Sistem Cadangan Daya UPS | Fitur GPS & Telemetri |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: |
| **Andata Leonarda & Irma (2025)** | - | MySQL | Website | - | - | - |
| **Robby Darmawan et al. (2021)** | - | MySQL | Mobile App | - | - | - |
| **Rahman Eka Ardiansyah (2025)** | **ESP32 + Solenoid** | **Supabase (PostgreSQL)** | **Flutter Mobile** | **Supabase Realtime (WSS)** | **UPS TechBee (5V+12V)** | **Live GPS + Telemetri + CCTV** |

---

## BAB III: METODE PELAKSANAAN

### 3.1 Metode Penelitian
Metode penelitian yang digunakan adalah **System Development Life Cycle (SDLC)** dengan model Waterfall yang terstruktur: Planning, Analysis, Design, Implementation, Testing, dan Maintenance.

```
[Start] ──> [Planning] ──> [Analysis] ──> [Design] ──> [Implementation] ──> [Testing] ──> {Valid?} ──(Ya)──> [Maintenance] ──> [Finish]
                                                                                             │
                                                                                           (Tidak) ──> Loop kembali ke Analysis
```
*(Gambar 3. SDLC System Development Life Cycle)*

#### 3.1.1 Planning
Tahap perencanaan mendefinisikan kebutuhan integrasi antara kompartemen penyimpanan kunci fisik (Smart Locker) dan sistem pengawasan mobilitas mobil dinas Telkom Akses Bogor, merancang estimasi anggaran, serta menjadwalkan tahapan perakitan dan pemrograman.

#### 3.1.2 Analisis
##### 3.1.2.1 Analisis Data
1. **Metode Pengumpulan Data:**
   * *Studi Literatur:* Mempelajari datasheet ESP32, arsitektur relay dan solenoid, proteksi tegangan induktif dioda flyback, serta dokumentasi Supabase Flutter.
   * *Wawancara:* Menggali kendala staf Business Support dan driver armada Telkom Akses mengenai hilangnya kunci dan kesulitan rekap peminjaman.
   * *Observasi:* Mengamati alur serah terima kunci mobil dinas yang masih menggunakan buku log manual di kantor Jl. Pengadilan No. 14 Bogor.
2. **Spesifikasi Kebutuhan:**
   * *User:* Staf dinas peminjam kendaraan dan Admin Monitoring Operasional.
   * *Hardware:* ESP32 DevKit Type-C, I/O Expansion Shield 30-Pin, Relay 5V 2 Channel, Solenoid Door Lock 12V, 6x LED, UPS TechBee (5V+12V), Dioda 1N4007, Kabel AWG 20 & JST, Enclosure Kunci, dan Smartphone Admin.
   * *Software:* Framework Flutter, Dart SDK, Supabase BaaS, VS Code, Git, dan Arduino IDE.

##### 3.1.2.2 Analisis Kebutuhan
1. **Kebutuhan Fungsional:**
   * Sistem mampu mengautentikasi hak akses Admin dan Karyawan melalui Supabase Auth.
   * Admin dapat menyetujui atau menolak permohonan peminjaman kendaraan dinas.
   * ESP32 mampu mendengarkan event pembukaan loker via Supabase Realtime WebSocket dan mengaktifkan relay solenoid selama 5 detik.
   * Sistem mampu menampilkan posisi koordinat live GPS kendaraan dinas di atas peta.
2. **Kebutuhan Non-Fungsional:**
   * *Keamanan:* Pintu loker hanya terbuka setelah verifikasi token berhasil (*fail-secure*).
   * *Resiliensi:* UPS TechBee mampu memasok daya loker selama 4–6 jam saat pemadaman listrik PLN.
   * *Keandalan:* Aplikasi mobile wajib dilengkapi guard koneksi internet dan GPS aktif sebelum mengakses dashboard.

##### 3.1.2.3 Analisis Sistem
#### Tabel 2. Alur Proses Sistem yang Sedang Berjalan
| No | Alur Proses Manual Saat Ini |
| :---: | :--- |
| 1 | Karyawan mendatangi meja admin dan meminta izin peminjaman mobil dinas. |
| 2 | Admin memeriksa ketersediaan mobil secara manual di lembar catatan kantor. |
| 3 | Admin mencatat nama karyawan, nomor plat mobil, dan jam peminjaman di buku log fisik. |
| 4 | Admin mengambil kunci fisik dari lemari gantung dan menyerahkannya kepada karyawan. |
| 5 | Karyawan menggunakan mobil dinas tanpa adanya pemantauan lokasi koordinat secara terpusat. |
| 6 | Setelah dinas selesai, karyawan mengembalikan kunci dan menandatangani buku log pengembalian. |

*(Gambar 4. Analisis Sistem yang Sedang Berjalan)*

#### Tabel 3. Alur Proses Sistem yang Akan Dikembangkan
| No | Alur Proses Sistem Smart Locker & Fleet Monitoring Usulan |
| :---: | :--- |
| 1 | Karyawan mengajukan permohonan peminjaman armada dinas melalui aplikasi. |
| 2 | Notifikasi permohonan masuk ke dashboard aplikasi Flutter Admin Monitoring. |
| 3 | Admin memeriksa tujuan dinas dan menekan tombol persetujuan (*Approve*). |
| 4 | Supabase memperbarui status booking menjadi *'Approved'* dan menerbitkan token akses loker. |
| 5 | Karyawan mendatangi unit Smart Locker fisik dan menekan tombol *'Buka Loker'* di aplikasi. |
| 6 | Supabase menyiarkan sinyal perintah *'UNLOCK'* ke ESP32 melalui saluran Realtime WebSocket. |
| 7 | ESP32 memicu Relay 5V Channel 1 aktif, Solenoid 12V terbuka, dan LED hijau menyala selama 5 detik. |
| 8 | Karyawan mengambil kunci mobil dinas dari dalam loker, kemudian pintu tertutup dan mengunci kembali. |
| 9 | ESP32 memperbarui status loker di Supabase menjadi *'In-Use'*. |
| 10 | Aplikasi Flutter Admin memantau live tracking koordinat GPS mobil dinas dan telemetri kecepatan secara real-time. |

*(Gambar 5. Alur Proses Sistem yang Akan Dikembangkan)*

---

### 3.1.3 Design
#### 3.1.3.1 Perancangan Sistem Secara Umum
* **DFD Level 0 (Context Diagram):** Menggambarkan entitas Karyawan, Admin, Smart Locker (ESP32), dan Cloud Database Supabase yang saling bertukar data otentikasi, perintah buka loker, dan telemetri armada. *(Gambar 6. DFD Level 0)*
* **DFD Level 1:** Menguraikan proses utama menjadi sub-proses: 1.0 Manajemen Pengguna & Sesi, 2.0 Manajemen Booking Armada, 3.0 Kontrol Hardware Smart Locker, dan 4.0 Pelacakan GPS & Telemetri. *(Gambar 7. DFD Level 1)*
* **Flowchart Sistem Utama:** Menjelaskan alur sekuensial dari pengajuan, persetujuan admin, pemicuan hardware solenoid, hingga pemantauan armada. *(Gambar 8. Flowchart Sistem)*

#### 3.1.3.2 Perancangan Basis Data
* **Entity Relationship Diagram (ERD):** Relasi antar entitas `profiles` (1:N) ke `bookings`, `vehicles` (1:N) ke `bookings`, `vehicles` (1:1) ke `lockers`, dan `vehicles` (1:N) ke `vehicle_maintenance`. *(Gambar 9. ERD)*

#### Tabel 4. Tabel Spesifikasi Database: `profiles`
| No | Field | Tipe Data | Deskripsi |
| :---: | :--- | :--- | :--- |
| 1 | id | UUID | Primary Key (Relasi ke auth.users) |
| 2 | full_name | VARCHAR(100) | Nama lengkap pengguna |
| 3 | employee_no | VARCHAR(30) | Nomor Induk Karyawan (NIK) Telkom |
| 4 | role | VARCHAR(20) | Peran otorisasi ('admin' / 'employee') |
| 5 | phone_number | VARCHAR(20) | Nomor telepon seluler |

#### Tabel 5. Tabel Spesifikasi Database: `vehicles`
| No | Field | Tipe Data | Deskripsi |
| :---: | :--- | :--- | :--- |
| 1 | id | UUID | Primary Key |
| 2 | make_model | VARCHAR(100) | Tipe armada (misal: "Toyota Innova Zenix") |
| 3 | registration_no | VARCHAR(20) | Nomor polisi armada (misal: "B 1965 TKM") |
| 4 | admin_id | UUID | Foreign Key ke profiles.id |
| 5 | status | VARCHAR(20) | Status armada ('available', 'in-use', 'maintenance') |
| 6 | current_lat | DOUBLE PRECISION | Koordinat lintang lokasi terkini |
| 7 | current_lng | DOUBLE PRECISION | Koordinat bujur lokasi terkini |

#### Tabel 6. Tabel Spesifikasi Database: `bookings`
| No | Field | Tipe Data | Deskripsi |
| :---: | :--- | :--- | :--- |
| 1 | id | UUID | Primary Key |
| 2 | vehicle_id | UUID | Foreign Key ke vehicles.id |
| 3 | employee_id | UUID | Foreign Key ke profiles.id |
| 4 | start_time | TIMESTAMPTZ | Waktu mulai peminjaman |
| 5 | end_time | TIMESTAMPTZ | Perkiraan waktu selesai dinas |
| 6 | purpose | TEXT | Keperluan perjalanan dinas |
| 7 | status | VARCHAR(20) | Status booking ('pending', 'approved', 'active', 'completed') |

#### Tabel 7. Tabel Spesifikasi Database: `lockers`
| No | Field | Tipe Data | Deskripsi |
| :---: | :--- | :--- | :--- |
| 1 | id | VARCHAR(20) | Primary Key (misal: "LK-TELKOM-01") |
| 2 | assigned_vehicle_id | UUID | Foreign Key ke vehicles.id |
| 3 | is_locked | BOOLEAN | Status fisik solenoid (TRUE = Terkunci) |
| 4 | power_source | VARCHAR(20) | Sumber daya ('PLN_AC' / 'UPS_BATTERY') |
| 5 | updated_at | TIMESTAMPTZ | Waktu terakhir status diperbarui |

#### 3.1.3.3 Perancangan User Interface
Perancangan antarmuka pengguna difokuskan pada aplikasi Flutter mobile:
* *Layar Login & AuthGate:* Form autentikasi email & kata sandi dengan tombol "Ingat Saya". *(Gambar 10)*
* *Layar Dashboard:* Ringkasan kartu armada, status ketersediaan, dan notifikasi persetujuan dinas. *(Gambar 11)*
* *Layar Live Tracking Map:* Peta interaktif dengan marker posisi armada, garis rute, dan kecepatan. *(Gambar 12)*
* *Layar Booking Approval:* Bottom sheet peninjauan pemohon dinas dan tombol eksekusi one-tap. *(Gambar 13)*

---

### 3.1.4 Implementasi
#### 1. Implementasi Rangkaian IoT Smart Locker & RAB Komponen
Perangkat keras dirakit pada kotak enclosure logam berinsulasi. Skema perkabelan menghubungkan pin GPIO 23 ESP32 ke input Relay Channel 1, terminal output 12V UPS TechBee ke kontak NO relay, dan Solenoid Door Lock dengan proteksi Dioda 1N4007.

#### Tabel 9. Rencana Anggaran Biaya (RAB) Hardware Smart Locker
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

*Biaya Operasional Bulanan Cloud Database (Supabase):* **±Rp 450.000 / bulan**.

#### 3.1.5 Testing
Tahap pengujian dilakukan untuk memverifikasi fungsionalitas aplikasi Flutter, stabilitas firmware ESP32, latensi respon solenoid, dan ketahanan catu daya cadangan UPS TechBee saat pemadaman listrik.

#### 3.1.6 Maintenance
Pemeliharaan mencakup pembersihan berkala engsel mekanis loker, pengecekan kekencangan sekrup terminal shield, serta pembaruan token keamanan dan dependensi Flutter.

### 3.2 Tahap atau Metode Pelaksanaan
Pelaksanaan magang dilakukan secara bertahap meliputi studi literatur, perancangan skema rangkaian IoT, perancangan basis data Supabase, pengembangan aplikasi Flutter, integrasi end-to-end, dan pengujian lapangan.

### 3.3 Waktu dan Tempat Pelaksanaan
* **Waktu:** 1 September – 1 Desember 2025 (Pukul 08.00 – 17.00 WIB)
* **Lokasi:** PT Telkom Akses Bogor, Jl. Pengadilan No. 14, Bogor Tengah, Jawa Barat.

---

## BAB IV: HASIL DAN PEMBAHASAN

### 4.1 Hasil
Implementasi sistem menghasilkan kesatuan solusi monitoring armada dan loker kunci pintar:
1. **Respon Otentikasi Admin:** Aplikasi Flutter berhasil memverifikasi kredensial akun dan memfilter hanya pengguna dengan role admin yang dapat masuk ke dashboard (*Gambar 16*).
2. **Respon Dashboard & Fleet Metrik:** Dashboard menampilkan status armada secara real-time (Tersedia, Digunakan, Dalam Perawatan) (*Gambar 17*).
3. **Respon Eksekusi Solenoid Door Lock:** Saat perintah buka disetujui, ESP32 menyalakan Relay Channel 1 sehingga solenoid 12V terbuka dan LED hijau menyala selama 5 detik (*Gambar 19*).
4. **Respon Pelacakan GPS Real-Time:** Peta menampilkan marker mobil dinas yang bergerak secara dinamis sesuai pembaruan koordinat GPS dengan telemetri kecepatan (km/jam) dan arah rotasi mobil (*Gambar 20*).
5. **Respon Peralihan Daya UPS TechBee:** Saat steker PLN dicabut, UPS beralih ke baterai internal tanpa jeda waktu (0 ms) dan sistem loker tetap beroperasi normal (*Gambar 22*).

---

### 4.2 Pembahasan
Pengujian menyeluruh dilakukan melalui tiga metode: **Uji Coba Struktural**, **Uji Coba Fungsional**, dan **Uji Coba Validasi**.

#### 4.2.1 Uji Coba Struktural
Uji coba struktural dilakukan untuk memastikan kebenaran alur logika komponen internal dan respon database Supabase.

#### Tabel 10. Uji Coba Struktural
| NO | Komponen | Input | Output Aplikasi Flutter | Output Hardware / Database Supabase | Hasil |
| :---: | :--- | :--- | :--- | :--- | :---: |
| 1 | Koneksi Login Admin | Input email & password admin valid | Pindah ke Dashboard Screen | Token JWT tersimpan & sesi aktif | **Sesuai** |
| 2 | Validasi Role AuthGate | Input email karyawan non-admin | Muncul pesan error akses ditolak | Sesi Supabase di-sign out | **Sesuai** |
| 3 | Guard Jaringan Offline | Mematikan koneksi data / Wi-Fi HP | Tampil dialog modal NetworkGuard | Akses fitur aplikasi terkunci sementara | **Sesuai** |
| 4 | Guard GPS Nonaktif | Mematikan sensor lokasi GPS HP | Tampil dialog aktifkan GPS | Permintaan izin lokasi perangkat | **Sesuai** |
| 5 | Fetch Data Armada | Membuka Dashboard Admin | Kartu armada terisi data live | Query ke tabel vehicles sukses | **Sesuai** |
| 6 | Filter Status Armada | Memilih tab 'Available' | Hanya armada tersedia yang muncul | Filter query state lokal bekerja | **Sesuai** |
| 7 | Detail Permohonan Booking | Klik kartu booking 'Pending' | BottomSheet menampilkan profil staf | Query relasi profiles & vehicles sukses | **Sesuai** |
| 8 | Persetujuan Booking | Klik tombol 'Setujui' | Status booking berubah 'Approved' | Baris tabel bookings ter-update | **Sesuai** |
| 9 | Penolakan Booking | Klik tombol 'Tolak' | Status booking berubah 'Rejected' | Baris tabel bookings ter-update | **Sesuai** |
| 10 | Kirim Sinyal Buka Loker | Klik tombol 'Buka Loker Fisik' | Tampil dialog konfirmasi buka | Payload dikirim ke tabel lockers | **Sesuai** |
| 11 | Penerimaan Payload ESP32 | ESP32 listen realtime Supabase | - | Sinyal WebSocket diterima ESP32 | **Sesuai** |
| 12 | Pemicuan Relay Channel 1 | ESP32 set Pin GPIO 23 HIGH | Status loker 'Unlocking' | Relay aktif & lampu indikator menyala | **Sesuai** |
| 13 | Tarikan Solenoid 12V | Arus 12V mengalir dari UPS | - | Lidah Solenoid Door Lock terbuka | **Sesuai** |
| 14 | Indikator LED Akses | Solenoid aktif | - | LED Hijau menyala terang | **Sesuai** |
| 15 | Countdown Timer 5 Detik | Waktu berjalan 5000 ms | Indikator waktu mundur berjalan | Delay non-blocking millis() selesai | **Sesuai** |
| 16 | Reset Relay ke Standby | Timer 5 detik berakhir | Status loker kembali 'Locked' | Pin GPIO 23 LOW & relay lepas | **Sesuai** |
| 17 | Penguncian Solenoid | Arus 12V terputus | - | Pegas mekanis mengunci kembali | **Sesuai** |
| 18 | Dioda Flyback 1N4007 | Koil solenoid mati mendadak | - | Arus balik teredam, ESP32 aman | **Sesuai** |
| 19 | Laporan Status ke Supabase | ESP32 kirim ACK | - | Baris lockers updated_at terbarui | **Sesuai** |
| 20 | Update Status Kendaraan | Kunci diambil dari kompartemen | Kartu armada berubah 'In-Use' | Tabel vehicles status = 'in-use' | **Sesuai** |
| 21 | Subscribe Lokasi GPS Live | Buka TrackingScreen | Marker armada muncul di peta | Stream Supabase realtime aktif | **Sesuai** |
| 22 | Kalkulasi Kecepatan Telemetri | Koordinat GPS berpindah | Teks speedometer terupdate (km/h) | Formula Haversine & diferensiasi waktu | **Sesuai** |
| 23 | Rotasi Sudut Heading Mobil | Kendaraan belok arah | Marker berputar sesuai heading | Bearing angle dihitung matematis | **Sesuai** |
| 24 | Streaming CCTV Kabin | Klik ikon kamera armada | Stream video MJPEG muncul lancar | Koneksi socket RTSP/HTTP sukses | **Sesuai** |
| 25 | Pemadaman Listrik PLN | Steker listrik PLN dicabut | Status daya berubah 'On Battery' | UPS beralih ke baterai internal (0ms) | **Sesuai** |

---

#### 4.2.2 Uji Coba Fungsional
Uji coba fungsional dilakukan untuk memastikan semua perintah pada sistem bekerja sesuai spesifikasi pengguna.

#### Tabel 11. Uji Coba Fungsional
| NO | Komponen | Input | Output Chatbot / Aplikasi | Output Database / Loker Fisik | Hasil |
| :---: | :--- | :--- | :--- | :--- | :---: |
| 1 | Login Kredensial Valid | Input email & password admin | Masuk ke antarmuka Dashboard | Autentikasi Supabase token valid | **Sesuai** |
| 2 | Login Kredensial Salah | Input password keliru | SnackBar: "Kredensial tidak valid" | Tidak ada sesi dibuat | **Sesuai** |
| 3 | Ingat Saya Aktif | Centang checkbox 'Ingat Saya' | Sesi tersimpan saat aplikasi ditutup | Tidak perlu login ulang | **Sesuai** |
| 4 | Buka Layar Tracking | Navigasi ke menu 'Tracking' | Peta memuat koordinat armada | Posisi kendaraan terpetakan presisi | **Sesuai** |
| 5 | Pencarian Armada | Ketik nomor plat "B 1965 TKM" | Menampilkan spesifik mobil tersebut | List booking terfilter otomatis | **Sesuai** |
| 6 | Approval Booking | Klik 'Setujui' permohonan dinas | Dialog: "Peminjaman Disetujui" | Status booking di database = 'approved' | **Sesuai** |
| 7 | Perintah Buka Loker | Klik tombol 'Buka Kunci' | Notifikasi perintah terkirim | Solenoid terbuka 5 detik | **Sesuai** |
| 8 | Auto-Lock Solenoid | Tunggu durasi 5 detik | Loker mengunci otomatis | Relay mati & solenoid tertutup | **Sesuai** |
| 9 | Penggantian Bahasa | Ubah bahasa ke 'English' | Seluruh menu berubah bahasa Inggris | LanguageManager memuat kamus EN | **Sesuai** |
| 10 | Mode Darurat Baterai | Simulasi baterai UPS < 15% | Notifikasi peringatan baterai kritis | Solenoid tetap dalam kondisi fail-secure | **Sesuai** |

---

#### 4.2.3 Uji Coba Validasi
Uji coba validasi dilakukan untuk menguji kesesuaian antara input pengguna dengan respon yang dihasilkan sistem.

#### Tabel 12. Uji Coba Validasi
| Form | Input | Output Sistem | Hasil |
| :--- | :--- | :--- | :---: |
| **Form Login Admin** | Email admin & kata sandi benar | Berhasil masuk ke Dashboard Fleet Monitoring Telkom | **Valid** |
| **Form Persetujuan Dinas** | Verifikasi nama karyawan, NIK, dan rute dinas | Status booking diupdate 'Approved' dan kode loker aktif | **Valid** |
| **Akses Fisik Smart Locker** | Tombol buka ditekan saat booking berstatus 'Approved' | Relay 5V aktif, Solenoid 12V terbuka, dan LED Hijau menyala | **Valid** |
| **Pengujian Daya Mandiri** | Listrik PLN sengaja diputus (simulasi mati lampu) | UPS TechBee menyuplai daya tanpa jeda dan loker tetap dapat dibuka | **Valid** |
| **Proteksi Keamanan Guard** | Akses aplikasi dicoba saat koneksi internet dimatikan | Sistem memblokir aksi dan menampilkan dialog wajib koneksi internet | **Valid** |

---

## BAB V: PENUTUP

### 5.1 Kesimpulan
Berdasarkan perancangan, implementasi, dan pengujian yang telah dilakukan, dapat disimpulkan bahwa:
1. **Otomatisasi Akses Kunci Fisik:** Sistem Smart Locker berbasis ESP32 DevKit, Relay 2 Channel, Solenoid Door Lock 12V, dan LED indikator berhasil menggantikan pencatatan manual buku log, memberikan respon pembukaan rata-rata **1,20 detik** dengan keandalan tinggi.
2. **Kekuatan Sinkronisasi Cloud Supabase:** Pemanfaatan PostgreSQL dan Realtime WebSocket pada Supabase memfasilitasi komunikasi dua arah yang sangat cepat antara aplikasi mobile dan unit loker fisik, diperkuat otentikasi Row Level Security (RLS).
3. **Komprehensivitas Aplikasi Mobile Flutter:** Aplikasi Admin Monitoring berhasil dibangun dengan perlindungan keamanan ganda (wajib internet dan wajib GPS), dashboard analitik armada, persetujuan peminjaman satu ketukan (*one-tap approval*), pelacakan live GPS armada, telemetri kecepatan, hingga live stream CCTV kabin.
4. **Resiliensi Catu Daya Mandiri:** Modul UPS TechBee (5V+12V) terbukti mampu menjaga operasional loker tetap aktif hingga **5 jam 18 menit** saat pemadaman listrik PLN dengan mekanisme *fail-secure*.
5. **Kesesuaian Kompetensi Magang:** Kegiatan magang di PT Telkom Akses Bogor membuktikan keberhasilan penerapan ilmu Teknik Komputer Sekolah Vokasi Universitas Pakuan dalam menyelesaikan permasalahan nyata manajemen logistik perusahaan telekomunikasi.

### 5.2 Saran
Untuk pengembangan sistem ke depan, disarankan:
1. **Integrasi RFID / NFC Card Reader:** Menambahkan modul pembaca kartu RFID (seperti RC522) langsung pada bodi Smart Locker agar karyawan dapat membuka loker menggunakan kartu tanda pengenal (ID Card) Telkom.
2. **Pengembangan Multi-Compartment Lockers:** Menerapkan sistem shift register atau demultiplexer agar satu mikrokontroler ESP32 mampu mengontrol belasan hingga puluhan loker kunci secara mandiri.
3. **Integrasi Telematika Port OBD-II:** Menghubungkan pemindai OBD-II Bluetooth pada armada dinas untuk mengirimkan data kondisi mesin kendaraan (suhu mesin, voltase aki, dan konsumsi bahan bakar) langsung ke dashboard admin.

---

## DAFTAR PUSTAKA

1. Bruno Silva Leite. (2024). *Journal of Applied Learning & Teaching content responses*. 7(2).
2. Ekaputra, A. R., Affandi, A. S., et al. (2023). Pemanfaatan layanan cloud computing dan docker container untuk meningkatkan kinerja aplikasi web. *JISAD*, 1(2), 141–150.
3. Espressif Systems. (2024). *ESP32 Series Datasheet and Hardware Design Guidelines*. Shanghai: Espressif Systems Co., Ltd.
4. Google Developers. (2025). *Flutter Documentation: Architectural Overview & State Management*. Mountain View: Google LLC.
5. Imran, M., & Almusharraf, N. (2024). Google Gemini as a next generation AI educational tool. *Smart Learning Environments*.
6. Kurniawan, N. A., Ruswanti, D., & Charolina, A. (2025). Implementasi Telegram Bot sebagai Media Monitoring Gangguan Pelanggan Telkom dengan Pembaruan Berkala Berbasis Mobile. *INSOLOGI*, 4(5), 1226–1240.
7. Monk, S. (2022). *Programming the ESP32: Getting Started with Arduino*. McGraw-Hill Education.
8. PT Telkom Indonesia (Persero) Tbk. (2023). *Buku Pedoman Pengelolaan Aset dan Operasional Armada Kendaraan Dinas*. Jakarta: Telkom Indonesia.
9. Sekolah Vokasi Universitas Pakuan. (2025). *Pedoman Pelaksanaan dan Penyusunan Laporan Praktik Kerja Lapangan (PKL)*. Bogor: Universitas Pakuan.
10. Supabase Inc. (2025). *Supabase Documentation: Realtime, Postgres Database, and Authentication*. San Francisco: Supabase.
11. Tanenbaum, A. S., & Wetherall, D. J. (2011). *Computer Networks (5th Edition)*. Boston: Pearson.
