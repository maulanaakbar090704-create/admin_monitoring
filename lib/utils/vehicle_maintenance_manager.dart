import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class VehicleMaintenanceItem {
  final String vehicleId;
  final String registrationNo;
  final String makeModel;
  final String issue;
  final DateTime startedAt;
  final String estimatedEnd;
  final String? adminNote;

  VehicleMaintenanceItem({
    required this.vehicleId,
    required this.registrationNo,
    required this.makeModel,
    required this.issue,
    required this.startedAt,
    required this.estimatedEnd,
    this.adminNote,
  });

  Map<String, dynamic> toJson() => {
        'vehicle_id': vehicleId,
        'registration_no': registrationNo,
        'make_model': makeModel,
        'issue': issue,
        'started_at': startedAt.toIso8601String(),
        'estimated_end': estimatedEnd,
        'admin_note': adminNote,
      };

  factory VehicleMaintenanceItem.fromJson(Map<String, dynamic> json) =>
      VehicleMaintenanceItem(
        vehicleId: json['vehicle_id'] ?? '',
        registrationNo: json['registration_no'] ?? '',
        makeModel: json['make_model'] ?? '',
        issue: json['issue'] ?? 'Perbaikan Berkala',
        startedAt: json['started_at'] != null
            ? DateTime.tryParse(json['started_at']) ?? DateTime.now()
            : DateTime.now(),
        estimatedEnd: json['estimated_end'] ?? 'Menunggu konfirmasi teknisi',
        adminNote: json['admin_note'],
      );
}

class VehicleMaintenanceManager {
  static final VehicleMaintenanceManager instance =
      VehicleMaintenanceManager._internal();

  VehicleMaintenanceManager._internal() {
    _loadFromStorage();
  }

  final Map<String, VehicleMaintenanceItem> _maintenanceMap = {};
  final ValueNotifier<int> maintenanceCountNotifier = ValueNotifier<int>(0);

  bool isUnderMaintenance(String? vehicleId, String? registrationNo) {
    if (vehicleId != null && _maintenanceMap.containsKey(vehicleId)) {
      return true;
    }
    if (registrationNo != null) {
      final cleanReg = registrationNo.trim().toUpperCase();
      return _maintenanceMap.values.any(
        (item) => item.registrationNo.trim().toUpperCase() == cleanReg,
      );
    }
    return false;
  }

  VehicleMaintenanceItem? getMaintenanceInfo(
      String? vehicleId, String? registrationNo) {
    if (vehicleId != null && _maintenanceMap.containsKey(vehicleId)) {
      return _maintenanceMap[vehicleId];
    }
    if (registrationNo != null) {
      final cleanReg = registrationNo.trim().toUpperCase();
      try {
        return _maintenanceMap.values.firstWhere(
          (item) => item.registrationNo.trim().toUpperCase() == cleanReg,
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  List<VehicleMaintenanceItem> getAllMaintenance() {
    return _maintenanceMap.values.toList();
  }

  Future<void> setVehicleMaintenance({
    required BuildContext context,
    required String vehicleId,
    required String registrationNo,
    required String makeModel,
    required String issue,
    required String estimatedEnd,
    String? adminNote,
  }) async {
    final item = VehicleMaintenanceItem(
      vehicleId: vehicleId,
      registrationNo: registrationNo,
      makeModel: makeModel,
      issue: issue,
      startedAt: DateTime.now(),
      estimatedEnd: estimatedEnd,
      adminNote: adminNote,
    );

    _maintenanceMap[vehicleId] = item;
    maintenanceCountNotifier.value = _maintenanceMap.length;
    await _saveToStorage();

    // Sinkronisasi status armada di Supabase agar dinonaktifkan (active = false)
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('vehicles').update({'active': false}).eq('id', vehicleId);
    } catch (e) {
      debugPrint('Warning: sync maintenance to supabase vehicles failed: $e');
    }
  }

  Future<void> resolveMaintenance({
    required BuildContext context,
    required String vehicleId,
    String? registrationNo,
  }) async {
    _maintenanceMap.remove(vehicleId);
    if (registrationNo != null) {
      final cleanReg = registrationNo.trim().toUpperCase();
      _maintenanceMap.removeWhere(
        (key, value) => value.registrationNo.trim().toUpperCase() == cleanReg,
      );
    }
    maintenanceCountNotifier.value = _maintenanceMap.length;
    await _saveToStorage();

    // Kembalikan armada menjadi Tersedia di Supabase (active = true)
    try {
      final supabase = Supabase.instance.client;
      await supabase.from('vehicles').update({'active': true}).eq('id', vehicleId);
    } catch (e) {
      debugPrint('Warning: sync resolve maintenance to supabase vehicles failed: $e');
    }
  }

  String generateNotificationMessage(VehicleMaintenanceItem item) {
    return '''📢 PEMBERITAHUAN ARMADA OPERASIONAL

Kepada Yth. Karyawan & Peminjam,
Diberitahukan bahwa kendaraan operasional berikut saat ini berstatus SEDANG DALAM PERBAIKAN:

🚗 Unit Mobil   : ${item.makeModel}
🔢 Nomor Polisi : ${item.registrationNo}
🔧 Kendala/Servis: ${item.issue}
📅 Estimasi Selesai: ${item.estimatedEnd}

⚠️ STATUS: SEDANG DALAM PERBAIKAN (TIDAK DAPAT DIPINJAM).
Silakan memilih armada lain yang berstatus "Tersedia" di pool operasional.

Terima kasih atas perhatian dan kerja samanya.
- Tim Operasional Armada Telkom''';
  }

  Future<void> sendNotificationViaWhatsApp({
    required BuildContext context,
    required VehicleMaintenanceItem item,
    String? targetPhone,
  }) async {
    final message = generateNotificationMessage(item);
    final encoded = Uri.encodeComponent(message);
    final urlString = (targetPhone != null && targetPhone.isNotEmpty)
        ? 'https://wa.me/$targetPhone?text=$encoded'
        : 'https://wa.me/?text=$encoded';

    try {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka WhatsApp: $e'),
            backgroundColor: const Color(0xFFBB0016),
          ),
        );
      }
    }
  }

  Future<void> copyNotificationText({
    required BuildContext context,
    required VehicleMaintenanceItem item,
  }) async {
    final message = generateNotificationMessage(item);
    await Clipboard.setData(ClipboardData(text: message));
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text('Teks notifikasi perbaikan berhasil disalin ke clipboard!'),
              ),
            ],
          ),
          backgroundColor: Color(0xFF0F3567),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  File? _getStorageFile() {
    try {
      final appSupportDir = Directory.systemTemp.path;
      return File('$appSupportDir/telkom_vehicle_maintenance.json');
    } catch (_) {
      return null;
    }
  }

  Future<void> _saveToStorage() async {
    try {
      final file = _getStorageFile();
      if (file == null) return;
      final data = _maintenanceMap.map((k, v) => MapEntry(k, v.toJson()));
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving maintenance to file: $e');
    }
  }

  Future<void> _loadFromStorage() async {
    try {
      final file = _getStorageFile();
      if (file != null && await file.exists()) {
        final content = await file.readAsString();
        final Map<String, dynamic> data = jsonDecode(content);
        _maintenanceMap.clear();
        data.forEach((key, value) {
          _maintenanceMap[key] =
              VehicleMaintenanceItem.fromJson(Map<String, dynamic>.from(value));
        });
        maintenanceCountNotifier.value = _maintenanceMap.length;
      }
    } catch (e) {
      debugPrint('Error loading maintenance from file: $e');
    }
  }
}
