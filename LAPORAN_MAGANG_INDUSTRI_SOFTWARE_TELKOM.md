# LAPORAN PRAKTEK KERJA MAGANG INDUSTRI

## RANCANG BANGUN APLIKASI MONITORING OPERASIONAL ARMADA DAN MANAJEMEN PEMINJAMAN KENDARAAN BERBASIS FLUTTER DAN SUPABASE
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

**Judul:** Rancang Bangun Aplikasi Monitoring Operasional Armada dan Manajemen Peminjaman Kendaraan Berbasis Flutter dan Supabase  
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

**Judul:** Rancang Bangun Aplikasi Monitoring Operasional Armada dan Manajemen Peminjaman Kendaraan Berbasis Flutter dan Supabase  
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

Akhir kata, harapan semoga Tuhan Yang Maha Esa berkenan membalas segala kebaikan semua pihak yang telah membantu. Semoga Laporan Magang ini membawa manfaat bagi pengembangan ilmu pengetahuan dan teknologi perangkat lunak.

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
    * 2.2.1 Fleet Management System (FMS) ..................................................... 6
    * 2.2.2 Framework Flutter & Bahasa Pemrograman Dart .............................. 7
    * 2.2.3 Backend as a Service (BaaS) Supabase ............................................. 7
    * 2.2.4 Basis Data Relasional PostgreSQL & Row Level Security (RLS) ....... 7
    * 2.2.5 Supabase Realtime Engine (WebSocket Protocol) ............................. 7
    * 2.2.6 Pemetaan Digital flutter_map & Geolokasi GPS ................................ 7
    * 2.2.7 Live Stream CCTV Kabin & Telemetri Kendaraan ............................ 8
  * 2.3 Waktu Pelaksanaan PKMI ........................................................................ 8
  * 2.4 Penelitian Terdahulu ................................................................................. 8
  * 2.5 Tabel Perbandingan .................................................................................. 9
* **BAB III METODE PELAKSANAAN** ............................................................ 10
  * 3.1 Metode Penelitian (SDLC) ...................................................................... 10
    * 3.1.1 Planning .......................................................................................... 10
    * 3.1.2 Analisis ........................................................................................... 11
      * 3.1.2.1 Analisis Data ........................................................................... 11
      * 3.1.2.2 Analisis Kebutuhan ................................................................. 12
      * 3.1.2.3 Analisis Sistem ........................................................................ 12
    * 3.1.3 Design ............................................................................................. 17
      * 3.1.3.1 Perancangan Sistem Secara Umum (DFD & Flowchart) ......... 17
      * 3.1.3.2 Perancangan Basis Data (ERD & Spesifikasi Tabel) .............. 19
      * 3.1.3.3 Perancangan User Interface ..................................................... 21
    * 3.1.4 Implementasi ................................................................................... 22
      * 1. Implementasi Cloud Backend Supabase & Estimasi Biaya ............. 22
      * 2. Implementasi Aplikasi Mobile Flutter Admin Monitoring ........... 23
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
* Gambar 3. SDLC (System Development Life Cycle) Waterfall ....................... 10
* Gambar 4. Analisis Sistem yang Sedang Berjalan (Manual) ........................... 14
* Gambar 5. Alur Proses Sistem yang Akan Dikembangkan .............................. 16
* Gambar 6. DFD Level 0 Sistem Fleet Monitoring ............................................ 17
* Gambar 7. DFD Level 1 Sistem Fleet Monitoring ............................................ 17
* Gambar 8. Flowchart Sistem Utama (Verifikasi Booking & Monitoring) ......... 18
* Gambar 9. ERD (Entity Relationship Diagram) Database Supabase ................ 19
* Gambar 10. Desain UI Halaman Login & AuthGate ........................................ 21
* Gambar 11. Desain UI Dashboard Fleet Monitoring & Metrik Armada ......... 22
* Gambar 12. Desain UI Live Tracking Map & Telemetri Kendaraan ............... 22
* Gambar 13. Desain UI Booking Approval BottomSheet ................................. 23
* Gambar 14. Desain UI Riwayat Perjalanan & Ekspor Laporan ....................... 23
* Gambar 15. Dashboard Supabase Cloud Console & Database Schema ........... 24
* Gambar 16. Implementasi Login Sukses Role Admin ...................................... 25
* Gambar 17. Implementasi Dashboard Fleet Status Cards ................................ 25
* Gambar 18. Implementasi Persetujuan Booking Peminjaman Mobil ................ 26
* Gambar 19. Implementasi Pelacakan GPS Real-Time Armada ........................ 26
* Gambar 20. Implementasi Telemetri Kecepatan (km/jam) & Heading ............. 27
* Gambar 21. Implementasi Live CCTV Video Streaming Kabin Mobil ........... 27
* Gambar 22. Implementasi Ekspor Data Riwayat ke Spreadsheet .................... 28
* Gambar 23. Implementasi Peringatan AppRequirementGuard ........................ 28

*(Halaman vi)*

---

## DAFTAR TABEL

* Tabel 1. Tabel Perbandingan Penelitian ............................................................ 9
* Tabel 2. Alur Proses Sistem yang Sedang Berjalan (Manual) ........................... 13
* Tabel 3. Alur Proses Sistem yang Akan Dikembangkan (Aplikasi Flutter) ....... 15
* Tabel 4. Tabel Spesifikasi Database: `profiles` ................................................ 19
* Tabel 5. Tabel Spesifikasi Database: `vehicles` ................................................ 20
* Tabel 6. Tabel Spesifikasi Database: `bookings` ............................................... 20
* Tabel 7. Tabel Spesifikasi Database: `vehicle_maintenance` ............................ 20
* Tabel 8. Tabel Spesifikasi Database: `audit_logs` ............................................. 21
* Tabel 9. Kebutuhan Biaya Operasional Bulanan Cloud Database .................. 22
* Tabel 10. Uji Coba Struktural Perangkat Lunak .............................................. 29
* Tabel 11. Uji Coba Fungsional Aplikasi .......................................................... 33
* Tabel 12. Uji Coba Validasi Antarmuka & Input-Output ................................. 38

*(Halaman vii)*

---

## BAB I: PENDAHULUAN

### 1.1 Latar Belakang
Pencatatan transaksi dan pengelolaan operasional armada kendaraan bermotor dinas merupakan bagian penting dalam kelancaran aktivitas bisnis telekomunikasi di PT Telkom Akses Bogor. Kendaraan operasional roda empat dan roda dua berfungsi sebagai sarana mobilitas utama bagi para teknisi lapangan dalam menangani perbaikan jaringan kabel serat optik IndiHome, pemeliharaan berkala infrastruktur Sentral Telepon Otomat (STO), serta pemenuhan kebutuhan logistik dinas.

Namun, dalam praktiknya di lapangan, pengelolaan peminjaman armada dan pemantauan pergerakan kendaraan dinas di PT Telkom Akses Bogor, khususnya pada unit operasional dan Business Support, masih sering dilakukan secara manual. Berdasarkan hasil observasi selama pelaksanaan PKMI, pengajuan izin dinas dicatat menggunakan buku log fisik atau file spreadsheet terpisah. Setiap transaksi harus dicatat secara manual mulai dari identitas peminjam, nomor polisi kendaraan, jam pemakaian, hingga rute tujuan dinas. Proses manual seperti ini memiliki berbagai keterbatasan nyata:
1. **Risiko Kesalahan Pencatatan dan Inkonsistensi Data:** Data peminjaman yang tersebar di banyak baris lembar kerja rentan mengalami duplikasi, salah penulisan status, atau tercecer saat pergantian shift kerja admin.
2. **Ketiadaan Visibilitas Posisi Armada Secara Real-Time:** Admin operasional tidak dapat memantau secara langsung di mana posisi koordinat kendaraan dinas yang sedang beroperasi, kecepatan tempuh, dan apakah kendaraan melintasi batas zona penugasan dinas (*geofencing*).
3. **Keterlambatan Proses Rekapitulasi dan Verifikasi:** Pembuatan laporan berkala penggunaan armada dan klaim reimbursement memerlukan waktu rekapitulasi manual yang lama, memperlambat proses pengambilan keputusan manajemen.
4. **Kebutuhan Pengawasan Keamanan Pengemudi:** Dibutuhkan sarana pemantauan live stream kamera interior kabin secara langsung saat kendaraan beroperasi guna memastikan keselamatan teknisi selama berdinas di jalan raya.

Kondisi tersebut mendorong perlunya solusi perangkat lunak yang mampu mendigitalisasi seluruh siklus pengelolaan armada secara terpusat, transparan, dan terotomasi. Oleh karena itu, dikembangkan **Aplikasi Monitoring Operasional Armada dan Manajemen Peminjaman Kendaraan Berbasis Flutter dan Supabase**. Aplikasi ini memanfaatkan keunggulan framework **Flutter** untuk antarmuka pengguna responsif lintas platform serta backend cloud **Supabase** yang menyediakan database PostgreSQL enterprise, otentikasi JWT terenkripsi, Row Level Security (RLS), dan Realtime WebSocket Engine untuk transmisi telemetri berkecepatan tinggi.

### 1.2 Tujuan Praktek Kerja Magang Industri
Tujuan dari Praktek Kerja Magang Industri ini adalah untuk melakukan:
**Pembuatan Aplikasi Monitoring Operasional Armada dan Manajemen Peminjaman Kendaraan Berbasis Flutter dan Supabase pada PT Telkom Akses Bogor.**

### 1.3 Ruang Lingkup Praktek Kerja Magang Industri
Ruang lingkup pengembangan perangkat lunak ini meliputi:
a. Membangun antarmuka aplikasi mobile/tablet Admin Monitoring menggunakan framework Flutter dan bahasa pemrograman Dart.
b. Membangun arsitektur basis data cloud terpusat menggunakan Supabase (PostgreSQL) yang mencakup tabel `profiles`, `vehicles`, `bookings`, `vehicle_maintenance`, dan `audit_logs`.
c. Menerapkan mekanisme keamanan Row Level Security (RLS) dan Supabase Auth untuk memisahkan wewenang pengguna secara ketat (Admin vs Karyawan).
d. Mengembangkan modul Guard Keamanan tingkat sistem (`AppRequirementGuard`) yang memastikan perangkat admin wajib memiliki koneksi internet aktif (`NetworkManager`) dan wajib mengaktifkan sensor lokasi GPS (`GpsRequirementManager`).
e. Mengembangkan modul Dashboard Analitik dengan kartu ringkasan status armada (*Available*, *In-Use*, *Maintenance*) dan filter pemesanan dinas.
f. Mengembangkan modul persetujuan permohonan dinas (*Booking Approval*) dengan aksi satu ketukan (*one-tap approval*).
g. Mengembangkan fitur pelacakan armada interaktif di atas peta (*flutter_map*) yang menghitung telemetri kecepatan (km/jam), jarak tempuh kumulatif, orientasi arah mobil (*heading bearing angle*), batas wilayah (*geofence*), serta dukungan live CCTV stream MJPEG.
h. Mengembangkan modul riwayat audit dan ekspor rekap laporan dinas ke format spreadsheet/Excel.
i. Melakukan pengujian perangkat lunak meliputi uji coba struktural, uji coba fungsional, dan uji coba validasi sistem.

### 1.4 Manfaat
Adapun manfaat dari pengembangan aplikasi ini adalah:
a. Mempermudah proses pengajuan dan persetujuan peminjaman mobil dinas secara digital tanpa lembar formulir fisik.
b. Meningkatkan efisiensi dan transparansi pengawasan mobilitas armada PT Telkom Akses Bogor melalui visualisasi peta koordinat GPS live.
c. Menghemat waktu admin operasional dalam merekap riwayat pemakaian kendaraan dinas melalui fitur ekspor data otomatis.
d. Meminimalisir potensi penyalahgunaan aset dinas di luar jam dan rute penugasan resmi berkat fitur peringatan geofence.
e. Mendukung transformasi digital di lingkungan Telkom Group dengan memanfaatkan arsitektur cloud serverless modern.

---

## BAB II: TINJAUAN INSTANSI DAN PUSTAKA

### 2.1 Tinjauan Instansi
#### 2.1.1 Sejarah Instansi
PT Telkom Akses resmi didirikan pada tahun 2012 sebagai anak perusahaan PT Telkom Indonesia (Persero) Tbk, yang menjadi tonggak awal dalam upaya pengembangan dan perluasan infrastruktur jaringan broadband nasional. PT Telkom Akses Bogor berperan penting dalam menjaga ketersediaan layanan telekomunikasi di Kota dan Kabupaten Bogor, didukung oleh puluhan armada mobil dan motor operasional teknisi.

#### 2.1.2 Visi Misi Instansi
* **Visi:** “Menjadi Mitra Strategis Pilihan Telekomunikasi di Indonesia untuk Memajukan Masyarakat”
* **Misi:**
  1. Mempercepat pembangunan infrastruktur digital dan pengelolaan layanan yang berkualitas.
  2. Mengorkestrasi ekosistem infrastruktur digital untuk memberikan pengalaman pelanggan yang unggul.
  3. Mengembangkan talenta digital unggul dan kapabilitas digital baru untuk memaksimalkan nilai bagi semua pemangku kepentingan.

#### 2.1.3 Struktur Organisasi Instansi
PT Telkom Akses Bogor dipimpin oleh General Manager (GM) TA Bogor yang membawahi Manager Shared Service, Officer Business Support, Commerce, dan unit operasional lainnya.

*(Gambar 1. Struktur Organisasi PT Telkom Akses Bogor)*

#### 2.1.4 Dokumentasi PKMI
*(Gambar 2. Dokumentasi PKMI)*

---

### 2.2 Tinjauan Pustaka
#### 2.2.1 Fleet Management System (FMS)
Fleet Management System adalah sistem perangkat lunak terintegrasi yang berfungsi mengawasi, mengelola, dan mengoptimalkan armada kendaraan bermotor suatu institusi melalui pemantauan lokasi, penjadwalan peminjaman, serta rekapitulasi audit pemakaian.

#### 2.2.2 Framework Flutter & Bahasa Pemrograman Dart
Flutter adalah framework open-source Google untuk merancang antarmuka pengguna berkualitas tinggi yang dikompilasi secara Ahead-Of-Time (AOT) ke kode mesin native, menghasilkan performa grafis 60-120 fps yang responsif dan konsisten.

#### 2.2.3 Backend as a Service (BaaS) Supabase
Supabase merupakan platform BaaS berbasis PostgreSQL yang menyediakan rangkaian layanan backend lengkap: Supabase Auth (manajemen JWT), Database Storage, Edge Functions, serta WebSocket listener real-time.

#### 2.2.4 Basis Data Relasional PostgreSQL & Row Level Security (RLS)
PostgreSQL mendukung integritas data relasional enterprise. Fitur Row Level Security (RLS) memungkinkan pembatasan hak akses baca-tulis langsung pada level baris data di database, mencegah kebocoran data antar pengguna.

#### 2.2.5 Supabase Realtime Engine (WebSocket Protocol)
Realtime Engine memanfaatkan protokol WebSocket untuk mendengarkan perubahan data (`INSERT`, `UPDATE`, `DELETE`) pada tabel database dengan latensi milidetik, memungkinkan pembaruan koordinat GPS tanpa reload manual.

#### 2.2.6 Pemetaan Digital flutter_map & Geolokasi GPS
Pustaka `flutter_map` merender layer peta interaktif berbasis OpenStreetMap atau tile server custom, memetakan marker kendaraan berdasarkan koordinat lintang/bujur (LatLong) secara dinamis.

#### 2.2.7 Live Stream CCTV Kabin & Telemetri Kendaraan
Kamera kabin kendaraan dinas menyiarkan stream video MJPEG beresolusi teroptimasi untuk memantau keselamatan driver dan situasi interior kabin secara real-time.

---

### 2.3 Waktu Pelaksanaan PKMI
Pelaksanaan PKMI dilaksanakan di **PT Telkom Akses Bogor**, Jl. Pengadilan No. 14, Bogor Tengah, Jawa Barat, terhitung mulai tanggal **1 September 2025 hingga 1 Desember 2025** (pukul 08.00 – 17.00 WIB).

### 2.4 Penelitian Terdahulu
1. **Andata Leonarda & Irma Handayani (2025):** Prototipe Sistem Deteksi Plat Nomor Kendaraan Berbasis YOLOv8 dan Tesseract OCR untuk Lingkungan Kampus.
2. **Robby Darmawan et al. (2021):** Sistem Manajemen Kartu Nama dengan OCR dan Ekstraksi Informasi Otomatis.
3. **Muhammad Raihan et al. (2025):** Integration of OCR Technology with ETL Processes for Automating Data Pipeline.
4. **Rahman Eka Ardiansyah (2026):** Rancang Bangun Aplikasi Monitoring Operasional Armada dan Manajemen Peminjaman Kendaraan Berbasis Flutter dan Supabase pada PT Telkom Akses Bogor.

### 2.5 Tabel Perbandingan Penelitian
#### Tabel 1. Tabel Perbandingan Penelitian
| Nama Peneliti | Bahasa Pemrograman | Database | Framework UI | Engine Realtime | Pelacakan Live GPS | CCTV Stream | Ekspor Laporan |
| :--- | :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **Andata & Irma (2025)** | Python | MySQL | Web | - | - | - | - |
| **Robby Darmawan et al. (2021)** | PHP | MySQL | Mobile | - | - | - | - |
| **Raihan et al. (2025)** | Python | Google Sheets | Web | - | - | - | ✓ |
| **Rahman Eka Ardiansyah (2026)** | **Dart** | **Supabase (PostgreSQL)** | **Flutter** | **Supabase Realtime (WSS)** | **✓ (flutter_map)** | **✓ (MJPEG)** | **✓ (Excel)** |

---

## BAB III: METODE PELAKSANAAN

### 3.1 Metode Penelitian
Metode penelitian yang digunakan adalah **System Development Life Cycle (SDLC)** model Waterfall yang terstruktur:

```
[Start] ──> [Planning] ──> [Analysis] ──> [Design] ──> [Implementation] ──> [Testing] ──> {Valid?} ──(Ya)──> [Maintenance] ──> [Finish]
                                                                                             │
                                                                                           (Tidak) ──> Loop kembali ke Analysis
```
*(Gambar 3. SDLC System Development Life Cycle)*

#### 3.1.1 Planning
Pada tahap Planning (Perencanaan) dilakukan pendefinisian tujuan dan ruang lingkup permasalahan pengelolaan peminjaman armada dinas dan pelacakan GPS di PT Telkom Akses Bogor, merancang arsitektur software, serta menyusun kebutuhan sistem cloud.

#### 3.1.2 Analisis
##### 3.1.2.1 Analisis Data
1. **Metode Pengumpulan Data:**
   * *Studi Literatur:* Mempelajari dokumentasi resmi Flutter, arsitektur Supabase PostgreSQL, state management, dan library flutter_map.
   * *Wawancara:* Menggali alur pencatatan peminjaman kendaraan operasional dengan tim Business Support dan driver armada.
   * *Observasi:* Mengamati proses rekapitulasi data peminjaman mobil yang masih menggunakan spreadsheet terpisah di kantor Telkom Akses Bogor.
2. **Spesifikasi Kebutuhan:**
   * *User:* Staf dinas (peminjam armada), Admin Operasional, dan Super Admin.
   * *Perangkat Lunak (Software):* Flutter SDK, Dart, Supabase Cloud Platform, Visual Studio Code, Git/GitHub, dan browser Google Chrome untuk preview web.
   * *Perangkat Keras (Hardware):* Laptop pengembang dan smartphone Android/iOS untuk pengujian aplikasi.
3. **Jenis dan Sumber Data:**
   * Data primer dari observasi langsung dan uji coba alur permohonan dinas. Data sekunder dari dokumentasi teknis dan jurnal sistem informasi.

##### 3.1.2.2 Analisis Kebutuhan
1. **Kebutuhan Fungsional:**
   * Sistem mampu memvalidasi kredensial login pengguna dan mengarahkan sesuai peran (Admin vs Karyawan).
   * Sistem mampu menampilkan dashboard status armada (*Available*, *In-Use*, *Maintenance*).
   * Admin dapat meninjau permohonan dinas dan melakukan tindakan *Approve* atau *Reject*.
   * Sistem menampilkan peta live tracking armada dengan update koordinat GPS otomatis via Supabase Realtime.
   * Sistem menghitung telemetri kecepatan (km/jam), jarak tempuh, dan arah rotasi kendaraan.
   * Sistem menampilkan stream video kamera interior kabin secara live.
   * Admin dapat mengekspor rekapitulasi riwayat peminjaman ke format file spreadsheet Excel.
2. **Kebutuhan Non-Fungsional:**
   * *Keamanan:* Seluruh transmisi data dienkripsi dengan protokol HTTPS dan WSS; otentikasi menggunakan token JWT.
   * *Integritas Data:* Guard sistem (`AppRequirementGuard`) mewajibkan koneksi internet dan GPS aktif saat membuka aplikasi.
   * *Performa:* Latensi pembaruan koordinat GPS di bawah 1 detik; respons UI stabil pada 60 fps.

##### 3.1.2.3 Analisis Sistem
#### Tabel 2. Alur Proses Sistem yang Sedang Berjalan (Manual)
| No | Alur Proses Manual Saat Ini |
| :---: | :--- |
| 1 | Karyawan mendatangi meja admin dan mengajukan izin pemakaian mobil dinas. |
| 2 | Admin memeriksa ketersediaan mobil secara manual di lembar catatan kantor. |
| 3 | Admin mencatat nama karyawan, nomor plat mobil, dan jam peminjaman di buku log fisik. |
| 4 | Admin menyerahkan kunci kendaraan secara tatap muka kepada karyawan. |
| 5 | Karyawan menggunakan mobil dinas tanpa adanya pemantauan lokasi koordinat secara terpusat. |
| 6 | Setelah dinas selesai, karyawan mengembalikan kunci dan menandatangani buku log pengembalian. |

*(Gambar 4. Analisis Sistem yang Sedang Berjalan)*

#### Tabel 3. Alur Proses Sistem yang Akan Dikembangkan (Aplikasi Flutter)
| No | Alur Proses Sistem Aplikasi Fleet Monitoring yang Dikembangkan |
| :---: | :--- |
| 1 | Karyawan mengajukan permohonan peminjaman armada dinas melalui aplikasi. |
| 2 | Notifikasi permohonan masuk ke dashboard aplikasi Flutter Admin Monitoring. |
| 3 | Admin membuka kartu permohonan dan memeriksa tujuan dinas serta waktu pemakaian. |
| 4 | Admin menekan tombol persetujuan (*Approve*) pada antarmuka aplikasi. |
| 5 | Supabase memperbarui status pemesanan di database menjadi *'Approved'* secara seketika. |
| 6 | Status armada dinas otomatis berubah menjadi *'In-Use'* dan muncul pada daftar pelacakan aktif. |
| 7 | Admin membuka menu *Tracking Screen* untuk memantau posisi koordinat live GPS armada di peta. |
| 8 | Sistem menghitung telemetri kecepatan (km/jam), jarak tempuh, dan menampilkan stream CCTV kabin. |
| 9 | Setelah tugas selesai, status booking diubah menjadi *'Completed'*. |
| 10 | Seluruh data transaksi tersimpan di riwayat audit dan siap diekspor ke format Excel kapan pun. |

*(Gambar 5. Alur Proses Sistem yang Akan Dikembangkan)*

---

### 3.1.3 Design
#### 3.1.3.1 Perancangan Sistem Secara Umum
* **DFD Level 0:** Menampilkan aliran data global antara entitas Karyawan, Admin Operasional, Aplikasi Flutter, dan Supabase Cloud. *(Gambar 6)*
* **DFD Level 1:** Menguraikan proses menjadi modul Autentikasi Pengguna (1.0), Manajemen Armada & Pemeliharaan (2.0), Verifikasi Booking (3.0), Live Tracking & Telemetri GPS (4.0), serta Ekspor Laporan (5.0). *(Gambar 7)*
* **Flowchart Sistem Utama:** Memvisualisasikan alur logika dari login pengguna, verifikasi guard, peninjauan permohonan, hingga pemantauan armada dinas. *(Gambar 8)*

#### 3.1.3.2 Perancangan Basis Data
* **Entity Relationship Diagram (ERD):** Relasi antar entitas `profiles`, `vehicles`, `bookings`, `vehicle_maintenance`, dan `audit_logs`. *(Gambar 9)*

#### Tabel 4. Tabel Spesifikasi Database: `profiles`
| No | Field | Tipe Data | Deskripsi |
| :---: | :--- | :--- | :--- |
| 1 | id | UUID | Primary Key (Relasi ke auth.users) |
| 2 | full_name | VARCHAR(100) | Nama lengkap pengguna |
| 3 | employee_no | VARCHAR(30) | Nomor Induk Karyawan (NIK) Telkom |
| 4 | role | VARCHAR(20) | Peran otorisasi ('admin' / 'employee') |
| 5 | phone_number | VARCHAR(20) | Nomor kontak darurat |

#### Tabel 5. Tabel Spesifikasi Database: `vehicles`
| No | Field | Tipe Data | Deskripsi |
| :---: | :--- | :--- | :--- |
| 1 | id | UUID | Primary Key |
| 2 | make_model | VARCHAR(100) | Tipe armada (misal: "Toyota Innova Zenix") |
| 3 | registration_no | VARCHAR(20) | Nomor plat dinas (misal: "B 1965 TKM") |
| 4 | admin_id | UUID | Foreign Key ke profiles.id |
| 5 | status | VARCHAR(20) | Status armada ('available', 'in-use', 'maintenance') |
| 6 | current_lat | DOUBLE PRECISION | Koordinat lintang GPS terkini |
| 7 | current_lng | DOUBLE PRECISION | Koordinat bujur GPS terkini |

#### Tabel 6. Tabel Spesifikasi Database: `bookings`
| No | Field | Tipe Data | Deskripsi |
| :---: | :--- | :--- | :--- |
| 1 | id | UUID | Primary Key |
| 2 | vehicle_id | UUID | Foreign Key ke vehicles.id |
| 3 | employee_id | UUID | Foreign Key ke profiles.id |
| 4 | start_time | TIMESTAMPTZ | Waktu mulai peminjaman |
| 5 | end_time | TIMESTAMPTZ | Perkiraan waktu selesai dinas |
| 6 | purpose | TEXT | Keperluan dinas |
| 7 | status | VARCHAR(20) | Status booking ('pending', 'approved', 'active', 'completed') |

#### Tabel 7. Tabel Spesifikasi Database: `vehicle_maintenance`
| No | Field | Tipe Data | Deskripsi |
| :---: | :--- | :--- | :--- |
| 1 | id | UUID | Primary Key |
| 2 | vehicle_id | UUID | Foreign Key ke vehicles.id |
| 3 | maintenance_type | VARCHAR(50) | Jenis servis (Ganti Oli / Servis Rem) |
| 4 | cost | NUMERIC(15,2) | Estimasi biaya perbaikan |
| 5 | status | VARCHAR(20) | Status servis ('in_progress' / 'done') |

#### Tabel 8. Tabel Spesifikasi Database: `audit_logs`
| No | Field | Tipe Data | Deskripsi |
| :---: | :--- | :--- | :--- |
| 1 | id | UUID | Primary Key |
| 2 | action | VARCHAR(50) | Aksi yang dilakukan ('APPROVE_BOOKING', 'EXPORT_EXCEL') |
| 3 | performed_by | UUID | Foreign Key ke profiles.id |
| 4 | timestamp | TIMESTAMPTZ | Waktu eksekusi aksi |

#### 3.1.3.3 Perancangan User Interface
Perancangan antarmuka pengguna mencakup Halaman Login (Gambar 10), Dashboard Armada (Gambar 11), Live Tracking Map & Telemetri (Gambar 12), Booking Approval Sheet (Gambar 13), dan Riwayat Perjalanan (Gambar 14).

---

### 3.1.4 Implementasi
#### 1. Implementasi Cloud Backend Supabase & Estimasi Biaya
Konfigurasi Supabase mencakup pembuatan tabel relasional, pengaktifan ekstensi Realtime, dan penerapan Row Level Security (RLS).

#### Tabel 9. Kebutuhan Biaya Operasional Bulanan Cloud Database
| Kebutuhan Layanan | Keterangan Fungsional | Estimasi Biaya / Bulan |
| :--- | :--- | :---: |
| **Cloud Database (Supabase)** | Untuk Database PostgreSQL, Auth, & Realtime WebSocket | **±Rp 450.000 / bulan** |

#### 2. Implementasi Aplikasi Mobile Flutter Admin Monitoring
Pengkodean dilakukan menggunakan framework Flutter dengan arsitektur modular:
* `NetworkManager` & `GpsRequirementManager`: Pengawasan status internet dan sensor GPS.
* `AuthGate` & `SessionManager`: Manajemen sesi persisten *'Ingat Saya'*.
* `TrackingScreen`: Peta dinamis dengan sinkronisasi stream real-time.
* `ExcelExporter`: Modul ekspor laporan tabel perjalanan dinas.

#### 3.1.5 Testing
Pengujian fungsionalitas dan performa aplikasi mobile Flutter dilakukan menggunakan skenario Black-box testing, uji latensi query, dan uji akurasi geolokasi.

#### 3.1.6 Maintenance
Pemeliharaan software mencakup pembaruan dependensi pubspec Flutter, optimasi query SQL indexing, dan pembaruan patch keamanan Supabase.

### 3.2 Tahap atau Metode Pelaksanaan
Pelaksanaan magang berfokus pada tahapan rekayasa perangkat lunak mulai dari wawancara kebutuhan, perancangan DFD dan ERD, implementasi Supabase, pembuatan kode Flutter, hingga pengujian fungsional.

### 3.3 Waktu dan Tempat Pelaksanaan
* **Waktu:** 1 September – 1 Desember 2025 (Pukul 08.00 – 17.00 WIB)
* **Lokasi:** PT Telkom Akses Bogor, Jl. Pengadilan No. 14, Bogor Tengah.

---

## BAB IV: HASIL DAN PEMBAHASAN

### 4.1 Hasil
Pengembangan perangkat lunak menghasilkan aplikasi terpadu dengan capaian fungsional:
1. **Respon Otentikasi & Role Guard:** Sistem memvalidasi kredensial pengguna dan mengarahkan admin ke dashboard operasional (*Gambar 16*).
2. **Respon Dashboard Metrik Armada:** Menampilkan total armada dinas, mobil yang sedang beroperasi, dan kartu permohonan dinas (*Gambar 17*).
3. **Respon Persetujuan Booking:** Admin dapat menyetujui peminjaman armada dinas dengan tombol *Approve* dalam hitungan detik (*Gambar 18*).
4. **Respon Pelacakan GPS Real-Time:** Peta menampilkan marker armada yang bergerak dinamis sesuai koordinat live GPS (*Gambar 19*).
5. **Respon Perhitungan Telemetri:** Aplikasi menghitung kecepatan mobil (km/jam), jarak tempuh, dan bearing angle rotasi (*Gambar 20*).
6. **Respon Live CCTV Kabin:** Video streaming kabin kendaraan dinas tampil lancar via protokol MJPEG (*Gambar 21*).
7. **Respon Ekspor Laporan Excel:** Admin dapat mengunduh rekapitulasi data peminjaman ke format file spreadsheet (*Gambar 22*).
8. **Respon Guard Jaringan & GPS:** Sistem memblokir akses jika koneksi internet terputus atau sensor lokasi dimatikan (*Gambar 23*).

---

### 4.2 Pembahasan

#### 4.2.1 Uji Coba Struktural
Uji coba struktural dilakukan untuk memastikan kebenaran alur logika komponen internal perangkat lunak dan respon database Supabase.

#### Tabel 10. Uji Coba Struktural Perangkat Lunak
| NO | Komponen | Input | Output Aplikasi Flutter | Output Database Supabase | Hasil |
| :---: | :--- | :--- | :--- | :--- | :---: |
| 1 | Koneksi Login Admin | Input email & password admin valid | Masuk ke Admin Dashboard Screen | Token JWT tersimpan & sesi aktif | **Sesuai** |
| 2 | Validasi Role AuthGate | Input email karyawan non-admin | Muncul pesan error akses ditolak | Sesi Supabase di-sign out | **Sesuai** |
| 3 | Guard Jaringan Offline | Mematikan koneksi data / Wi-Fi | Tampil dialog modal NetworkGuard | Akses fitur aplikasi terkunci sementara | **Sesuai** |
| 4 | Guard GPS Nonaktif | Mematikan sensor lokasi GPS HP | Tampil dialog aktifkan GPS | Permintaan izin lokasi perangkat | **Sesuai** |
| 5 | Fetch Data Armada | Membuka Dashboard Admin | Kartu armada terisi data live | Query ke tabel vehicles sukses | **Sesuai** |
| 6 | Filter Status Armada | Memilih tab 'Available' | Hanya armada tersedia yang muncul | Filter query state lokal bekerja | **Sesuai** |
| 7 | Detail Permohonan Booking | Klik kartu booking 'Pending' | BottomSheet menampilkan profil staf | Query relasi profiles & vehicles sukses | **Sesuai** |
| 8 | Persetujuan Booking | Klik tombol 'Setujui' | Status booking berubah 'Approved' | Baris tabel bookings ter-update | **Sesuai** |
| 9 | Penolakan Booking | Klik tombol 'Tolak' | Status booking berubah 'Rejected' | Baris tabel bookings ter-update | **Sesuai** |
| 10 | Update Status Armada | Booking berstatus 'Approved' | Kartu armada berubah 'In-Use' | Tabel vehicles status = 'in-use' | **Sesuai** |
| 11 | Subscribe Lokasi GPS Live | Buka TrackingScreen | Marker armada muncul di peta | Stream Supabase realtime aktif | **Sesuai** |
| 12 | Kalkulasi Kecepatan | Koordinat GPS berpindah | Speedometer terupdate (km/h) | Formula Haversine & diferensiasi waktu | **Sesuai** |
| 13 | Rotasi Sudut Heading Mobil | Kendaraan belok arah | Marker berputar sesuai heading | Bearing angle dihitung matematis | **Sesuai** |
| 14 | Batas Wilayah Geofence | Kendaraan keluar batas dinas | Tampil banner peringatan geofence | Log koordinat ditandai 'Out of Zone' | **Sesuai** |
| 15 | Streaming CCTV Kabin | Klik ikon kamera armada | Stream video MJPEG muncul lancar | Koneksi socket RTSP/HTTP sukses | **Sesuai** |
| 16 | Rekap Riwayat Peminjaman | Navigasi ke menu History | Daftar perjalanan dinas tampil rapi | Query tabel bookings status 'completed' | **Sesuai** |
| 17 | Filter Rentang Tanggal | Pilih rentang 1 - 30 November | Riwayat terfilter sesuai tanggal | Query SQL range timestamp sukses | **Sesuai** |
| 18 | Ekspor Laporan Excel | Klik tombol 'Ekspor ke Excel' | File spreadsheet (.xlsx) terunduh | Ekstraksi kolom data sukses | **Sesuai** |
| 19 | Modul Pemeliharaan Mobil | Klik 'Tandai Dalam Perbaikan' | Armada berstatus 'Maintenance' | Tabel vehicle_maintenance bertambah | **Sesuai** |
| 20 | Proteksi Armada Servis | Coba booking mobil dalam servis | Mobil tidak dapat dipilih (disable) | Validasi status vehicle != 'maintenance' | **Sesuai** |
| 21 | Ganti Bahasa Antarmuka | Pilih opsi 'English' | Seluruh teks berubah ke bahasa Inggris | LanguageManager memuat kamus EN | **Sesuai** |
| 22 | Proteksi Biometrik Admin | Aktifkan keamanan sidik jari | Konfirmasi fingerprint saat buka app | LocalAuthentication SDK bekerja | **Sesuai** |
| 23 | Edit Profil Admin | Ubah nomor telepon kontak | Profil terbarui di layar pengaturan | Query UPDATE tabel profiles sukses | **Sesuai** |
| 24 | Ubah Kata Sandi | Input password lama & baru | Notifikasi: "Password berhasil diubah" | Supabase auth.updateUser() sukses | **Sesuai** |
| 25 | Logout Akun Admin | Klik tombol 'Keluar' | Kembali ke LoginScreen | Sesi lokal dibersihkan total | **Sesuai** |

---

#### 4.2.2 Uji Coba Fungsional
Uji coba fungsional dilakukan untuk memastikan semua perintah pada sistem aplikasi bekerja sesuai kebutuhan pengguna.

#### Tabel 11. Uji Coba Fungsional Aplikasi
| NO | Komponen | Input | Output Antarmuka Aplikasi | Output Database Supabase | Hasil |
| :---: | :--- | :--- | :--- | :--- | :---: |
| 1 | Login Admin Valid | Input email & password benar | Masuk ke antarmuka Dashboard | Token Supabase JWT terverifikasi | **Sesuai** |
| 2 | Login Password Salah | Input password keliru | SnackBar: "Kredensial tidak valid" | Tidak ada sesi dibuat | **Sesuai** |
| 3 | Sesi Ingat Saya | Centang checkbox 'Ingat Saya' | Sesi tersimpan saat aplikasi ditutup | Tidak perlu login ulang | **Sesuai** |
| 4 | Tampilan Peta Tracking | Navigasi ke menu 'Tracking' | Peta memuat koordinat armada live | Posisi terpetakan secara presisi | **Sesuai** |
| 5 | Pencarian Cepat Plat | Ketik nomor plat "B 1965 TKM" | Menampilkan spesifik mobil tersebut | List armada terfilter otomatis | **Sesuai** |
| 6 | Approval Booking | Klik 'Setujui' permohonan dinas | Dialog: "Peminjaman Disetujui" | Status booking di database = 'approved' | **Sesuai** |
| 7 | Penolakan Booking | Klik 'Tolak' permohonan dinas | Dialog: "Peminjaman Ditolak" | Status booking di database = 'rejected' | **Sesuai** |
| 8 | Telemetri Speedometer | Armada bergerak di rute dinas | Teks kecepatan km/jam dinamis | Nilai speed tersinkron live | **Sesuai** |
| 9 | Live CCTV Kabin | Tekan tombol kamera interior | Video streaming kabin tampil | Paket video stream diterima lancar | **Sesuai** |
| 10 | Ekspor Riwayat Excel | Tekan tombol 'Unduh Excel' | File laporan tersimpan di perangkat | Kolom laporan lengkap dan rapi | **Sesuai** |
| 11 | Penggantian Bahasa | Ubah bahasa ke 'English' | Seluruh menu berubah bahasa Inggris | LanguageManager memuat kamus EN | **Sesuai** |
| 12 | Validasi Guard GPS | Sensor GPS perangkat dimatikan | Dialog permintaan aktifkan lokasi | Aplikasi terkunci hingga GPS aktif | **Sesuai** |

---

#### 4.2.3 Uji Coba Validasi
Uji coba validasi dilakukan untuk menguji kesesuaian antara input pengguna dengan respon yang dihasilkan perangkat lunak.

#### Tabel 12. Uji Coba Validasi Antarmuka & Input-Output
| Form | Input | Output Sistem | Hasil |
| :--- | :--- | :--- | :---: |
| **Form Login Admin** | Email admin & kata sandi terdaftar | Berhasil masuk ke Dashboard Fleet Monitoring Telkom | **Valid** |
| **Form Verifikasi Booking** | Tinjau nama staf, NIK, dan rute dinas | Status booking diupdate 'Approved' di database cloud | **Valid** |
| **Peta Pelacakan GPS** | Koordinat lintang/bujur diperbarui | Marker mobil bergerak dinamis di peta dengan telemetri | **Valid** |
| **Form Ekspor Laporan** | Klik tombol ekspor data riwayat dinas | File format Excel (.xlsx) terunduh dan dapat dibuka di Excel | **Valid** |
| **Proteksi Keamanan Guard** | Akses dicoba saat koneksi internet mati | Sistem memblokir aksi dan menampilkan dialog wajib internet | **Valid** |

---

## BAB V: PENUTUP

### 5.1 Kesimpulan
Berdasarkan seluruh tahapan perancangan, implementasi, dan pengujian perangkat lunak yang telah dilaksanakan, dapat disimpulkan bahwa:
1. **Digitalisasi Manajemen Armada:** Aplikasi Monitoring Operasional Armada berbasis Flutter berhasil menggantikan pencatatan manual buku log di PT Telkom Akses Bogor, menyederhanakan alur permohonan dan persetujuan dinas menjadi satu ketukan (*one-tap approval*).
2. **Kekuatan Arsitektur Cloud Supabase:** Pemanfaatan PostgreSQL, Row Level Security (RLS), dan Realtime WebSocket Engine pada Supabase memfasilitasi penyimpanan data yang aman, terpusat, dan mendukung streaming koordinat GPS dengan latensi sangat rendah.
3. **Komprehensivitas Pengawasan Real-Time:** Fitur peta dinamis *flutter_map* yang dilengkapi kalkulasi telemetri kecepatan (km/jam), jarak tempuh, bearing angle rotasi, peringatan batas wilayah *geofencing*, serta live CCTV kabin memberikan pengawasan operasional yang transparan dan akuntabel.
4. **Keamanan Sistem Tingkat Lanjut:** Penerapan guard ganda (`AppRequirementGuard`) memastikan aplikasi hanya dapat beroperasi saat koneksi internet dan sensor GPS aktif, menjaga integritas pengawasan aset dinas.
5. **Pencapaian Target Magang:** Praktikan berhasil menerapkan keahlian rekayasa perangkat lunak modern dari Program Studi Teknik Komputer Sekolah Vokasi Universitas Pakuan ke dalam kebutuhan operasional nyata di PT Telkom Akses Bogor.

### 5.2 Saran
Saran untuk pengembangan perangkat lunak ke depan adalah:
1. **Penerapan Algoritma Route Optimization:** Menambahkan modul kecerdasan buatan untuk merekomendasikan rute penugasan teknisi yang paling hemat bahan bakar dan bebas kemacetan.
2. **Integrasi Push Notification Otomatis:** Mengintegrasikan Firebase Cloud Messaging (FCM) agar admin menerima notifikasi instan saat kendaraan keluar dari zona geofence atau mendekati batas waktu dinas.
3. **Pengembangan Modul Prediksi Pemeliharaan (Predictive Maintenance):** Memanfaatkan data riwayat kilometer perjalanan dinas untuk memicu peringatan servis berkala secara otomatis sebelum kendaraan mengalami kendala teknis.

---

## DAFTAR PUSTAKA

1. Bruno Silva Leite. (2024). *Journal of Applied Learning & Teaching content responses*. 7(2).
2. Ekaputra, A. R., Affandi, A. S., Studi, P., Informasi, S., Informasi, F. T., & Malang, U. M. (2023). Pemanfaatan layanan cloud computing dan docker container untuk meningkatkan kinerja aplikasi web. *JISAD*, 1(2), 141–150.
3. Google Developers. (2025). *Flutter Documentation: Architectural Overview & State Management*. Mountain View: Google LLC.
4. Imran, M., & Almusharraf, N. (2024). Google Gemini as a next generation AI educational tool. *Smart Learning Environments*.
5. Novita, W., Fitriadi, Y., Nopiana, P. R., et al. (2023). Pelatihan Laporan Keuangan dengan Google Spreadsheet dalam Rangka Meningkatkan Pengetahuan UMKM. *Jurnal Pengabdian Masyarakat*, 2(2), 217–225.
6. PT Telkom Indonesia (Persero) Tbk. (2023). *Buku Pedoman Pengelolaan Aset dan Operasional Armada Kendaraan Dinas*. Jakarta: Telkom Indonesia.
7. Sekolah Vokasi Universitas Pakuan. (2025). *Pedoman Pelaksanaan dan Penyusunan Laporan Praktik Kerja Lapangan (PKL)*. Bogor: Universitas Pakuan.
8. Sommerville, I. (2015). *Software Engineering (10th Edition)*. Boston: Pearson.
9. Supabase Inc. (2025). *Supabase Documentation: Realtime, Postgres Database, and Authentication*. San Francisco: Supabase.
10. Tanenbaum, A. S., & Wetherall, D. J. (2011). *Computer Networks (5th Edition)*. Boston: Pearson.
