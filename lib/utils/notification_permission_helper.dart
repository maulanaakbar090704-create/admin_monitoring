import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Helper untuk mengelola perizinan notifikasi pada perangkat Android / iOS.
/// Menampilkan dialog edukasi izin yang elegan, lalu memanggil dialog izin sistem OS HP.
class NotificationPermissionHelper {
  static const String _kKeyNotificationPermissionAsked = 'has_asked_notification_permission';

  /// Memeriksa status izin notifikasi saat ini
  static Future<bool> isNotificationGranted() async {
    try {
      final status = await Permission.notification.status;
      return status.isGranted;
    } catch (_) {
      return false;
    }
  }

  /// Memeriksa dan menampilkan dialog izin notifikasi jika belum diizinkan
  /// Dipanggil otomatis setelah login berhasil atau saat pertama kali masuk Dashboard
  static Future<void> checkAndPromptAfterLogin(BuildContext context, {bool forcePrompt = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final alreadyAsked = prefs.getBool(_kKeyNotificationPermissionAsked) ?? false;

      // Cek apakah permission sudah diberikan
      final status = await Permission.notification.status;
      if (status.isGranted && !forcePrompt) {
        return;
      }

      // Jika belum pernah ditanya atau dipaksa muncul setelah login
      if (!alreadyAsked || forcePrompt || status.isDenied) {
        if (!context.mounted) return;
        await showNotificationPermissionDialog(context);
        await prefs.setBool(_kKeyNotificationPermissionAsked, true);
      }
    } catch (e) {
      debugPrint('Error checking notification permission: $e');
    }
  }

  /// Menampilkan dialog perizinan notifikasi dengan tema Telkom Akses yang profesional
  static Future<bool> showNotificationPermissionDialog(BuildContext context) async {
    if (!context.mounted) return false;

    bool granted = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          elevation: 12,
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 22, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(22.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon Header Bernuansa Telkom (Navy & Red)
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0F3567), Color(0xFFBB0016)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFBB0016).withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notifications_active_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Judul Perizinan
                const Text(
                  'Izinkan Notifikasi di HP?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Hanken Grotesk',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 8),

                // Penjelasan Kebutuhan Notifikasi
                Text(
                  'Aktifkan notifikasi untuk menerima pantauan otomatis berkala setiap 30 menit mengenai posisi peminjam, kecepatan, dan status armada kendaraan operasional.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12.5,
                    color: Colors.grey.shade700,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),

                // Card Rincian Manfaat Izin
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildBenefitItem(
                        icon: Icons.timer_outlined,
                        color: const Color(0xFF0F3567),
                        text: 'Notifikasi berkala lokasi peminjam setiap 30 menit',
                      ),
                      const Divider(height: 14, thickness: 0.7, color: Color(0xFFE2E8F0)),
                      _buildBenefitItem(
                        icon: Icons.speed_rounded,
                        color: const Color(0xFFBB0016),
                        text: 'Peringatan kecepatan & status kendaraan real-time',
                      ),
                      const Divider(height: 14, thickness: 0.7, color: Color(0xFFE2E8F0)),
                      _buildBenefitItem(
                        icon: Icons.verified_user_outlined,
                        color: const Color(0xFF10B981),
                        text: 'Akses cepat langsung menuju peta pelacakan GPS',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),

                // Tombol Aksi
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Tombol Izinkan (Memanggil Izin Sistem HP)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F3567),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      onPressed: () async {
                        Navigator.pop(dialogCtx);

                        // Simpan preferensi izin aktif
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setBool('in_app_notification_enabled', true);
                        await prefs.setBool(_kKeyNotificationPermissionAsked, true);

                        // Panggil request dialog perizinan native OS (Android/iOS)
                        try {
                          final reqStatus = await Permission.notification.request();
                          granted = reqStatus.isGranted;
                        } catch (e) {
                          debugPrint('Permission request error: $e');
                        }

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white, size: 20),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Izin notifikasi aktif! Notifikasi 30 menit & persetujuan ACC siap diterima di HP.',
                                      style: TextStyle(fontSize: 12.5),
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Color(0xFF10B981),
                              duration: Duration(seconds: 4),
                            ),
                          );
                        }
                      },
                      child: const Text(
                        'Izinkan Notifikasi',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Tombol Lewati / Nanti
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF64748B),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onPressed: () {
                        Navigator.pop(dialogCtx);
                      },
                      child: const Text(
                        'Nanti Saja',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    return granted;
  }

  static Widget _buildBenefitItem({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 14, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: Color(0xFF334155),
            ),
          ),
        ),
      ],
    );
  }

  /// Dialog penuntun jika tombol izin abu-abu / dibatasi di level OS Android
  static void showOpenSettingsPrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.settings_outlined, color: Color(0xFF0F3567)),
            SizedBox(width: 8),
            Text('Pengaturan Notifikasi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Jika tombol "Izinkan notifikasi" di pengaturan HP berwarna abu-abu / tidak bisa diklik:\n',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            Text(
              '1. Buka Info Aplikasi pada HP Anda.\n'
              '2. Klik ikon Titik Tiga (⋮) di pojok kanan atas.\n'
              '3. Pilih "Izinkan setelan yang dibatasi" (Allow restricted settings).\n'
              '4. Setelah itu tombol notifikasi akan langsung aktif dan bisa dinyalakan.\n\n'
              'Catatan: Notifikasi pop-up di dalam aplikasi saat ini SUDAH AKTIF dan siap digunakan.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF475569), height: 1.4),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F3567),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              openAppSettings();
            },
            child: const Text('Buka Info Aplikasi'),
          ),
        ],
      ),
    );
  }
}
