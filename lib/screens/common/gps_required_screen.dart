import 'package:flutter/material.dart';
import '../../utils/gps_requirement_manager.dart';

/// Layar peringatan jika layanan GPS di perangkat PIC dimatikan atau izin lokasi ditolak
class GpsRequiredScreen extends StatefulWidget {
  const GpsRequiredScreen({super.key});

  @override
  State<GpsRequiredScreen> createState() => _GpsRequiredScreenState();
}

class _GpsRequiredScreenState extends State<GpsRequiredScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.88, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E17),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Radar Ikon GPS Off dengan Glow Amber Gold
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 130 * _pulseAnimation.value,
                          height: 130 * _pulseAnimation.value,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
                            border: Border.all(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                              width: 1.5,
                            ),
                          ),
                        ),
                        Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [Color(0xFF2E2008), Color(0xFF171005)],
                            ),
                            border: Border.all(
                              color: const Color(0xFFF59E0B),
                              width: 2.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.45),
                                blurRadius: 20,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.location_off_rounded,
                              color: Color(0xFFFEF3C7),
                              size: 42,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 32),

                // 2. Badge Status GPS
                ValueListenableBuilder<GpsRequirementStatus>(
                  valueListenable: GpsRequirementManager.instance.statusNotifier,
                  builder: (context, status, _) {
                    final isPermDenied = status == GpsRequirementStatus.permissionDenied ||
                        status == GpsRequirementStatus.permissionPermanentlyDenied;
                    final label = isPermDenied
                        ? 'STATUS: IZIN LOKASI DITOLAK'
                        : 'STATUS: GPS DINONAKTIFKAN';

                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF451A03),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFF59E0B), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.gps_off_rounded, color: Color(0xFFFBBF24), size: 14),
                          const SizedBox(width: 6),
                          Text(
                            label,
                            style: const TextStyle(
                              color: Color(0xFFFEF3C7),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // 3. Judul & Penjelasan
                const Text(
                  'Layanan GPS Wajib Aktif',
                  style: TextStyle(
                    fontFamily: 'Hanken Grotesk',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 10),

                const Text(
                  'Aplikasi PIC Admin Monitoring mewajibkan GPS aktif untuk memvalidasi posisi dan menjaga kepatuhan pelacakan armada dinas.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF94A3B8),
                    height: 1.45,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                // 4. Kartu Panduan Checklist Pengaktifan GPS
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121824),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF263244)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.near_me_rounded, color: Color(0xFFF59E0B), size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Instruksi Pengaktifan GPS:',
                            style: TextStyle(
                              color: Color(0xFFFEF3C7),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildChecklistRow('1', 'Nyalakan Layanan Lokasi (GPS) pada ponsel Anda.'),
                      const SizedBox(height: 8),
                      _buildChecklistRow('2', 'Beri izin lokasi "Saat Aplikasi Digunakan".'),
                      const SizedBox(height: 8),
                      _buildChecklistRow('3', 'Pilih tingkat akurasi tinggi (High Accuracy).'),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                // 5. Tombol "Buka Pengaturan Lokasi / GPS"
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final status = GpsRequirementManager.instance.statusNotifier.value;
                      if (status == GpsRequirementStatus.permissionPermanentlyDenied) {
                        await GpsRequirementManager.instance.openAppSettings();
                      } else {
                        await GpsRequirementManager.instance.openLocationSettings();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF59E0B),
                      foregroundColor: const Color(0xFF0F172A),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.settings_suggest_rounded, size: 20),
                    label: const Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'BUKA PENGATURAN GPS',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 6. Tombol "Periksa Ulang GPS"
                ValueListenableBuilder<bool>(
                  valueListenable: GpsRequirementManager.instance.isCheckingNotifier,
                  builder: (context, isChecking, _) {
                    return SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: OutlinedButton.icon(
                        onPressed: isChecking
                            ? null
                            : () async {
                                final isReady = await GpsRequirementManager.instance.checkGpsStatus(
                                  requestPermissionIfNeeded: true,
                                );
                                if (!context.mounted) return;
                                if (!isReady) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Layanan GPS masih belum aktif atau izin belum diberikan.'),
                                      backgroundColor: Color(0xFFBB0016),
                                      duration: Duration(seconds: 2),
                                    ),
                                  );
                                }
                              },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF334155)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: isChecking
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.refresh_rounded, size: 18),
                        label: Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              isChecking ? 'MEMERIKSA...' : 'PERIKSA ULANG GPS',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChecklistRow(String number, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF475569), width: 1),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFCBD5E1),
              fontSize: 12,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
