import 'package:flutter/material.dart';
import 'language_manager.dart';

class BookingHelper {
  /// Ekstrak KM Awal dari string admin_note atau fallback
  static String extractStartKm(Map<String, dynamic> item) {
    final note = item['admin_note']?.toString() ?? '';
    // Contoh format: [KM Awal: 091308 km | Foto Odo: ...]
    final match = RegExp(r'KM Awal:\s*([^\s\|\]]+(?:\s*km)?)', caseSensitive: false).firstMatch(note);
    if (match != null && match.group(1) != null) {
      return match.group(1)!.trim();
    }
    if (item['start_odometer'] != null) {
      return "${item['start_odometer']} km";
    }
    return '-';
  }

  /// Ekstrak Path / URL Foto Odometer dari admin_note atau fallback kolom
  static String? extractOdoPhotoPath(Map<String, dynamic> item) {
    final note = item['admin_note']?.toString() ?? '';
    // Contoh format: Foto Odo: local_storage/00df1627...odo_...jpg
    final match = RegExp(r'Foto Odo:\s*([^\s\|\]]+)', caseSensitive: false).firstMatch(note);
    if (match != null && match.group(1) != null) {
      return match.group(1)!.trim();
    }
    if (item['odo_photo_path'] != null) {
      return item['odo_photo_path'].toString();
    }
    return null;
  }

  /// Ambil Path / URL Foto Wajah dari kolom face_photo_path
  static String? getFacePhotoPath(Map<String, dynamic> item) {
    final face = item['face_photo_path'];
    if (face != null && face.toString().isNotEmpty) {
      return face.toString();
    }
    return null;
  }

  /// Normalisasi status
  static String normalizeStatus(String? rawStatus) {
    final status = (rawStatus ?? '').toLowerCase().trim();
    if (status == 'pending_admin' || status == 'pending') {
      return 'pending';
    } else if (status == 'active' || status == 'sedang dipinjam' || status == 'sedang_dipinjam') {
      return 'active';
    } else if (status == 'completed' || status == 'selesai') {
      return 'completed';
    } else if (status == 'cancelled' || status == 'rejected' || status == 'ditolak') {
      return 'cancelled';
    }
    return status;
  }

  /// Dapatkan label status yang rapi dan mudah dibaca sesuai bahasa terpilih
  static String getStatusLabel(String? rawStatus) {
    final normalized = normalizeStatus(rawStatus);
    final lm = LanguageManager.instance;
    switch (normalized) {
      case 'pending':
        return lm.t('summary_pending');
      case 'active':
        return lm.t('summary_active');
      case 'completed':
        return lm.t('summary_completed');
      case 'cancelled':
        return lm.t('status_rejected');
      default:
        return rawStatus?.toUpperCase() ?? 'UNKNOWN';
    }
  }

  /// Dapatkan warna latar belakang badge status
  static Color getStatusBgColor(String? rawStatus) {
    final normalized = normalizeStatus(rawStatus);
    switch (normalized) {
      case 'pending':
        return const Color(0xFFFFF3CD); // Amber muda
      case 'active':
        return const Color(0xFFFFDAD6); // Merah muda Telkom
      case 'completed':
        return const Color(0xFFE2F0D9); // Hijau lembut
      case 'cancelled':
        return const Color(0xFFEEEEEE);
      default:
        return const Color(0xFFE1E3E4);
    }
  }

  /// Dapatkan warna teks badge status
  static Color getStatusTextColor(String? rawStatus) {
    final normalized = normalizeStatus(rawStatus);
    switch (normalized) {
      case 'pending':
        return const Color(0xFF856404); // Amber tua
      case 'active':
        return const Color(0xFF93000A); // Merah tua Telkom
      case 'completed':
        return const Color(0xFF276A3C); // Hijau tua
      case 'cancelled':
        return const Color(0xFF616161);
      default:
        return const Color(0xFF5C403D);
    }
  }

  /// Format timestamp ke string tanggal & jam Indonesia
  static String formatDateTime(String? rawIsoString) {
    if (rawIsoString == null || rawIsoString.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(rawIsoString).toLocal();
      const monthNames = [
        'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
        'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
      ];
      final day = parsed.day.toString().padLeft(2, '0');
      final month = monthNames[parsed.month - 1];
      final year = parsed.year;
      final hour = parsed.hour.toString().padLeft(2, '0');
      final minute = parsed.minute.toString().padLeft(2, '0');
      return '$day $month $year, $hour:$minute WIB';
    } catch (_) {
      return rawIsoString;
    }
  }
}
