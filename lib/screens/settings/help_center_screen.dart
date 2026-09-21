import 'dart:math';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/language_manager.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _allFaqs = [
    {
      'question': 'Bagaimana cara menyetujui peminjaman kendaraan?',
      'category': 'Peminjaman',
      'answer':
          'Buka tab "History" atau "Dashboard", lalu pilih peminjaman dengan status "Menunggu Persetujuan". Klik kartu peminjaman untuk membuka detail, periksa data driver & rute, kemudian klik tombol "Setujui Peminjaman" untuk mengaktifkan status kendaraan.',
    },
    {
      'question': 'Bagaimana cara melacak posisi kendaraan secara real-time?',
      'category': 'Tracking GPS',
      'answer':
          'Pilih tab "Tracking" pada menu bawah. Peta interaktif akan menampilkan seluruh armada yang sedang dalam perjalanan (status aktif). Anda dapat mengklik pin kendaraan untuk melihat kecepatan, pengemudi, dan koordinat saat ini.',
    },
    {
      'question': 'Apa yang harus dilakukan jika video kamera monitoring tidak tampil?',
      'category': 'Kamera Live',
      'answer':
          'Pastikan perangkat ESP32-CAM / IP Camera di kendaraan terhubung ke koneksi internet atau hotspot seluler. Jika feed terputus, pastikan URL streaming MJPEG pada database kendaraan sudah sesuai dan online.',
    },
    {
      'question': 'Bagaimana sistem peringatan Geofence bekerja?',
      'category': 'Geofence',
      'answer':
          'Sistem secara otomatis memantau koordinat GPS kendaraan terhadap radius zona aman yang telah ditentukan. Jika kendaraan melintasi batas zona aman, sistem akan memicu alarm notifikasi darurat pada aplikasi admin.',
    },
    {
      'question': 'Bagaimana cara mengubah kata sandi akun admin?',
      'category': 'Akun & Keamanan',
      'answer':
          'Masuk ke tab "Settings" > pilih menu "Ubah Kata Sandi" pada kelompok Akun. Masukkan kata sandi baru minimal 6 karakter dan ulangi pada kolom konfirmasi, lalu klik "Simpan Perubahan".',
    },
    {
      'question': 'Apakah data riwayat peminjaman dapat diunduh?',
      'category': 'Laporan',
      'answer':
          'Semua riwayat peminjaman dan penyelesaian tercatat rapi di Supabase Cloud Database. Laporan ringkasan berkala juga dapat diaktifkan pengirimannya melalui menu "Notifikasi" > "Ringkasan Laporan Mingguan".',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String urlString) async {
    try {
      final Uri uri = Uri.parse(urlString);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Tidak dapat membuka URL';
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal membuka tautan: $urlString'),
          backgroundColor: const Color(0xFFBB0016),
        ),
      );
    }
  }

  void _showCreateTicketSheet() {
    final subjectController = TextEditingController();
    final messageController = TextEditingController();
    String selectedCategory = 'Operasional Kendaraan';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kirim Tiket Bantuan',
                          style: TextStyle(
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF191C1D),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Jelaskan kendala operasional yang Anda alami. Tim teknis Telkom akan menindaklanjuti keluhan Anda.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),

                    // Kategori
                    const Text(
                      'Kategori Kendala',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF191C1D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedCategory,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: 'Operasional Kendaraan',
                              child: Text('Operasional & Peminjaman Kendaraan'),
                            ),
                            DropdownMenuItem(
                              value: 'GPS & Peta Tracking',
                              child: Text('GPS & Peta Tracking'),
                            ),
                            DropdownMenuItem(
                              value: 'Kamera Live Streaming',
                              child: Text('Kamera Live Streaming'),
                            ),
                            DropdownMenuItem(
                              value: 'Akun & Hak Akses',
                              child: Text('Akun & Hak Akses Admin'),
                            ),
                            DropdownMenuItem(
                              value: 'Lainnya',
                              child: Text('Kendala Lainnya'),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() => selectedCategory = val);
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Subjek
                    const Text(
                      'Subjek Kendala',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF191C1D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: subjectController,
                      decoration: InputDecoration(
                        hintText: 'Contoh: GPS Mobil Avanza Tidak Terkoneksi',
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Deskripsi
                    const Text(
                      'Deskripsi Masalah Lengkap',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF191C1D),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: messageController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Tuliskan detail kronologi atau kendala teknis...',
                        filled: true,
                        fillColor: const Color(0xFFF8F9FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Kirim
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBB0016),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: const Icon(Icons.send_rounded, size: 18),
                        label: const Text(
                          'Kirim Laporan Tiket',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          if (subjectController.text.trim().isEmpty ||
                              messageController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Harap isi subjek dan pesan tiket.'),
                                backgroundColor: Color(0xFFBB0016),
                              ),
                            );
                            return;
                          }

                          Navigator.pop(ctx);

                          // Tampilkan modal konfirmasi ID tiket
                          final randomTicket = 10000 + Random().nextInt(90000);
                          showDialog(
                            context: context,
                            builder: (dialogCtx) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFE8F5E9),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.task_alt,
                                      color: Color(0xFF1B873F),
                                      size: 44,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Tiket Berhasil Dibuat!',
                                    style: TextStyle(
                                      fontFamily: 'Hanken Grotesk',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Nomor Tiket: #TKM-$randomTicket\nKategori: $selectedCategory',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F3567),
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Laporan telah diteruskan ke tim support Telkom. Kami akan menghubungi Anda secepatnya.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 20),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0F3567),
                                        foregroundColor: Colors.white,
                                      ),
                                      onPressed: () => Navigator.pop(dialogCtx),
                                      child: const Text('Tutup'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContactCard({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE1E3E4)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Color(0xFF191C1D),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lm = LanguageManager.instance;

    final filteredFaqs = _allFaqs.where((faq) {
      final q = faq['question']!.toLowerCase();
      final a = faq['answer']!.toLowerCase();
      final c = faq['category']!.toLowerCase();
      final query = _searchQuery.toLowerCase();
      return q.contains(query) || a.contains(query) || c.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0F3567),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F3567), Color(0xFFBB0016)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          lm.t('help_center'),
          style: const TextStyle(
            fontFamily: 'Hanken Grotesk',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          // Banner Bantuan
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0F3567), Color(0xFF254779)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.headset_mic_outlined, color: Colors.white, size: 28),
                    SizedBox(width: 10),
                    Text(
                      'Pusat Bantuan & Support',
                      style: TextStyle(
                        fontFamily: 'Hanken Grotesk',
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Temukan jawaban cepat atau hubungi tim teknis operasional armada Telkom.',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 16),
                // Search Input
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    decoration: InputDecoration(
                      hintText: 'Cari kendala, FAQ, atau kata kunci...',
                      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF0F3567)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Hubungi Kami Saluran Langsung
          Text(
            lm.t('help_contact'),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildContactCard(
                icon: Icons.chat_bubble_outline,
                color: const Color(0xFF25D366),
                title: 'WhatsApp',
                subtitle: 'Chat Tim Support',
                onTap: () => _launchURL(
                  'https://wa.me/6281234567890?text=Halo%20Admin%20Telkom%20Monitoring,%20saya%20membutuhkan%20bantuan.',
                ),
              ),
              const SizedBox(width: 8),
              _buildContactCard(
                icon: Icons.email_outlined,
                color: const Color(0xFFBB0016),
                title: 'Email',
                subtitle: 'support@telkom.id',
                onTap: () => _launchURL(
                  'mailto:support.fleet@telkom.co.id?subject=Bantuan%20Aplikasi%20Admin%20Monitoring',
                ),
              ),
              const SizedBox(width: 8),
              _buildContactCard(
                icon: Icons.phone_in_talk_outlined,
                color: const Color(0xFF0F3567),
                title: 'Call 147',
                subtitle: 'Layanan 24 Jam',
                onTap: () => _launchURL('tel:147'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tombol Ajukan Tiket Keluhan
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFBB0016).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFBB0016).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFBB0016),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.confirmation_number_outlined,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Kendala Belum Terselesaikan?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: Color(0xFF191C1D),
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Buat tiket bantuan untuk ditinjau oleh teknisi IT.',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFBB0016),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _showCreateTicketSheet,
                  child: const Text('Buat Tiket', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // FAQ Accordion
          Text(
            lm.t('help_faq'),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),

          if (filteredFaqs.isEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              alignment: Alignment.center,
              child: const Text(
                'Tidak ada pertanyaan yang sesuai dengan pencarian Anda.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
            )
          else
            ...filteredFaqs.map((faq) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE1E3E4)),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    childrenPadding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F3567).withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        faq['category']!,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F3567),
                        ),
                      ),
                    ),
                    title: Text(
                      faq['question']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xFF191C1D),
                      ),
                    ),
                    children: [
                      Text(
                        faq['answer']!,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: Color(0xFF5C403D),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
