import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/language_manager.dart';

class AboutAppScreen extends StatelessWidget {
  const AboutAppScreen({super.key});

  Future<void> _launchURL(BuildContext context, String urlString) async {
    try {
      final Uri uri = Uri.parse(urlString);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Gagal membuka $urlString';
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Tidak dapat membuka tautan: $urlString'),
          backgroundColor: const Color(0xFFBB0016),
        ),
      );
    }
  }

  void _showTermsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Syarat & Ketentuan Penggunaan',
                    style: TextStyle(
                      fontFamily: 'Hanken Grotesk',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191C1D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1. Hak Akses Admin:\nAkun admin hanya dapat digunakan oleh personel yang ditunjuk secara resmi oleh PT Telkom Indonesia atau tim magang SV Universitas Pakuan yang bertugas.\n\n'
                    '2. Pengawasan Kendaraan Dinas:\nSeluruh data koordinat GPS, live streaming kamera, dan riwayat perjalanan armada merupakan milik PT Telkom Indonesia dan diawasi demi keamanan dan efisiensi dinas.\n\n'
                    '3. Integritas Data:\nAdmin dilarang memanipulasi, menghapus, atau memberikan akses monitoring kepada pihak ketiga yang tidak berwenang.\n\n'
                    '4. Penanganan Keadaan Darurat:\nJika terjadi pelanggaran zona geofence atau insiden darurat, admin wajib segera menghubungi driver atau pihak yang bersangkutan sesuai SOP yang berlaku.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Color(0xFF5C403D),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F3567),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Saya Memahami & Menyetujui'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showPrivacySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          expand: false,
          builder: (context, scrollController) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Kebijakan Privasi Data',
                    style: TextStyle(
                      fontFamily: 'Hanken Grotesk',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF191C1D),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1. Pengumpulan Data Lokasi:\nAplikasi mengumpulkan koordinat geolokasi kendaraan dinas secara berkala saat peminjaman aktif berlangsung.\n\n'
                    '2. Rekaman & Kamera Monitoring:\nFitur streaming video hanya aktif saat kendaraan dalam masa operasional dan digunakan untuk keselamatan driver serta aset perusahaan.\n\n'
                    '3. Enkripsi dan Keamanan:\nSeluruh kredensial akun dan data perjalanan disimpan secara aman menggunakan enkripsi Supabase Cloud Infrastructure bersertifikasi enterprise.\n\n'
                    '4. Perlindungan Kerahasiaan:\nData pribadi karyawan peminjam dilindungi dan tidak akan disebarluaskan ke publik.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.6,
                      color: Color(0xFF5C403D),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F3567),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Tutup'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _checkUpdates(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xFFE8F5E9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_done_rounded,
                color: Color(0xFF1B873F),
                size: 40,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aplikasi Terkini',
              style: TextStyle(
                fontFamily: 'Hanken Grotesk',
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Versi v1.0.0 (Build 1)',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F3567),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Anda telah menggunakan versi terbaru aplikasi Admin Fleet Monitoring Telkom.',
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Selesai'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFBB0016)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF191C1D),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lm = LanguageManager.instance;

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
          lm.t('about_app'),
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
          // Header Logo & Versi
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE1E3E4)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/telkom_logo.png',
                    height: 70,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.directions_car_filled_rounded,
                      size: 60,
                      color: Color(0xFFBB0016),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Fleet Admin Monitoring',
                  style: TextStyle(
                    fontFamily: 'Hanken Grotesk',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF191C1D),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F3567).withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Versi 1.0.0 (Build 1)',
                    style: TextStyle(
                      color: Color(0xFF0F3567),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  lm.t('about_desc'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5C403D),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildFeatureChip(Icons.location_searching, 'GPS Real-time'),
                    _buildFeatureChip(Icons.videocam_outlined, 'Live CCTV MJPEG'),
                    _buildFeatureChip(Icons.shield_outlined, 'Geofence Security'),
                    _buildFeatureChip(Icons.cloud_outlined, 'Supabase Cloud'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Pengembang & Kolaborasi
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE1E3E4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'INFORMASI PENGEMBANG & INSTITUSI',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0F3567).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.person, color: Color(0xFF0F3567), size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Maulana Akbar',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: Color(0xFF191C1D),
                          ),
                        ),
                        Text(
                          'Admin Magang - SV Universitas Pakuan',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFBB0016).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.apartment_rounded,
                        color: Color(0xFFBB0016),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'PT Telkom Indonesia (Persero) Tbk',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: Color(0xFF191C1D),
                            ),
                          ),
                          Text(
                            'Divisi Monitoring Operasional Armada',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Menu Navigasi Tentang
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE1E3E4)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(
                    Icons.system_update_alt,
                    color: Color(0xFF0F3567),
                    size: 20,
                  ),
                  title: Text(
                    lm.t('about_check_update'),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                  onTap: () => _checkUpdates(context),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                ListTile(
                  leading: const Icon(
                    Icons.description_outlined,
                    color: Color(0xFF0F3567),
                    size: 20,
                  ),
                  title: Text(
                    lm.t('about_terms'),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                  onTap: () => _showTermsSheet(context),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                ListTile(
                  leading: const Icon(
                    Icons.policy_outlined,
                    color: Color(0xFF0F3567),
                    size: 20,
                  ),
                  title: Text(
                    lm.t('about_privacy'),
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                  onTap: () => _showPrivacySheet(context),
                ),
                Divider(height: 1, color: Colors.grey.shade200),
                ListTile(
                  leading: const Icon(
                    Icons.public,
                    color: Color(0xFF0F3567),
                    size: 20,
                  ),
                  title: const Text(
                    'Kunjungi Website Resmi Telkom',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  trailing: const Icon(Icons.open_in_new, color: Colors.grey, size: 18),
                  onTap: () => _launchURL(context, 'https://www.telkom.co.id'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Center(
            child: Text(
              '© 2026 PT Telkom Indonesia. All Rights Reserved.',
              style: TextStyle(color: Colors.grey, fontSize: 11),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
