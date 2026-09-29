import 'package:flutter/material.dart';
import '../utils/network_manager.dart';
import '../utils/gps_requirement_manager.dart';
import '../screens/common/no_network_screen.dart';
import '../screens/common/gps_required_screen.dart';

/// Guard terpusat yang memverifikasi kedua prasyarat wajib:
/// 1. Koneksi Data / Internet Aktif
/// 2. Layanan Lokasi / GPS Aktif
class AppRequirementGuard extends StatelessWidget {
  final Widget child;

  const AppRequirementGuard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: NetworkManager.instance.isConnectedNotifier,
      builder: (context, isConnected, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: GpsRequirementManager.instance.isGpsReadyNotifier,
          builder: (context, isGpsReady, _) {
            Widget currentScreen;

            // Prioritas 1: Jika jaringan internet / data mati -> Layar Tidak Ada Jaringan
            if (!isConnected) {
              currentScreen = const NoNetworkScreen(key: ValueKey('no_network_screen'));
            }
            // Prioritas 2: Jika GPS mati atau izin ditolak -> Layar GPS Wajib Aktif
            else if (!isGpsReady) {
              currentScreen = const GpsRequiredScreen(key: ValueKey('gps_required_screen'));
            }
            // Normal: Tampilkan konten aplikasi
            else {
              currentScreen = KeyedSubtree(
                key: const ValueKey('normal_app_content'),
                child: child,
              );
            }

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              switchInCurve: Curves.easeInOut,
              switchOutCurve: Curves.easeInOut,
              child: currentScreen,
            );
          },
        );
      },
    );
  }
}
