import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

/// Status integritas data GPS kendaraan
enum GpsSecurityStatus {
  verified, // Koordinat valid dan wajar
  warning, // Potensi anomali / fluktuasi
  spoofDetected, // Lompatan tak wajar / indikasi fake GPS
  invalid, // Di luar batas geografis / format salah
}

/// Hasil analisis keamanan telemetri GPS
class GpsSecurityReport {
  final GpsSecurityStatus status;
  final String message;
  final bool isSafe;
  final double calculatedSpeedKmh;

  const GpsSecurityReport({
    required this.status,
    required this.message,
    required this.isSafe,
    this.calculatedSpeedKmh = 0.0,
  });
}

/// Manager keamanan sistem: rate-limiting brute force, validasi telemetri GPS, & sanitasi error
class SecurityManager {
  SecurityManager._();
  static final SecurityManager instance = SecurityManager._();

  // =========================================================
  // 1. BRUTE-FORCE RATE LIMITING UNTUK LOGIN ADMIN
  // =========================================================
  static const int maxFailedAttempts = 5;
  static const int lockoutDurationSeconds = 60;

  int _failedAttempts = 0;
  DateTime? _lockoutEndTime;
  Timer? _lockoutTimer;

  final ValueNotifier<int> remainingLockoutNotifier = ValueNotifier<int>(0);

  bool get isLockedOut {
    if (_lockoutEndTime == null) return false;
    final now = DateTime.now();
    if (now.isBefore(_lockoutEndTime!)) {
      return true;
    }
    // Waktu lockout sudah habis
    _resetLockout();
    return false;
  }

  int get remainingSeconds {
    if (_lockoutEndTime == null) return 0;
    final diff = _lockoutEndTime!.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  int get failedAttempts => _failedAttempts;

  /// Mencatat percobaan login yang gagal
  void recordFailedLogin() {
    _failedAttempts++;
    if (_failedAttempts >= maxFailedAttempts) {
      _lockoutEndTime = DateTime.now().add(const Duration(seconds: lockoutDurationSeconds));
      remainingLockoutNotifier.value = lockoutDurationSeconds;

      _lockoutTimer?.cancel();
      _lockoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final sec = remainingSeconds;
        remainingLockoutNotifier.value = sec;
        if (sec <= 0) {
          timer.cancel();
          _resetLockout();
        }
      });
    }
  }

  /// Reset counter percobaan login saat login berhasil
  void recordSuccessfulLogin() {
    _resetLockout();
  }

  void _resetLockout() {
    _failedAttempts = 0;
    _lockoutEndTime = null;
    _lockoutTimer?.cancel();
    _lockoutTimer = null;
    remainingLockoutNotifier.value = 0;
  }

  // =========================================================
  // 2. VALIDASI KOORDINAT & ANTI-SPOOFING GPS
  // =========================================================
  // Batas Geografis Indonesia (Latitude: -11.5 s/d 6.5, Longitude: 94.5 s/d 141.5)
  static const double _minLatIndonesia = -11.5;
  static const double _maxLatIndonesia = 6.5;
  static const double _minLngIndonesia = 94.5;
  static const double _maxLngIndonesia = 141.5;

  // Batas kecepatan maksimum fisik kendaraan operasional darat (km/jam)
  static const double _maxPlausibleSpeedKmh = 160.0;

  /// Memeriksa apakah koordinat GPS berada dalam batas wajar numerik dan regional
  bool isValidCoordinate(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (lat.isNaN || lng.isNaN || lat.isInfinite || lng.isInfinite) return false;

    // Periksa koordinat Null Island (0,0) yang sering dikirim oleh GPS error
    if (lat.abs() < 0.0001 && lng.abs() < 0.0001) return false;

    // Periksa rentang global mutlak
    if (lat < -90.0 || lat > 90.0 || lng < -180.0 || lng > 180.0) return false;

    // Periksa wilayah operasional Indonesia
    if (lat < _minLatIndonesia || lat > _maxLatIndonesia ||
        lng < _minLngIndonesia || lng > _maxLngIndonesia) {
      return false;
    }

    return true;
  }

  /// Menganalisis integritas pergerakan antar dua titik koordinat
  GpsSecurityReport analyzeTelemtryIntegrity({
    required LatLng? previousCoord,
    required LatLng currentCoord,
    required DateTime? previousTimestamp,
    required DateTime currentTimestamp,
    double reportedSpeedKmh = 0.0,
  }) {
    // 1. Validasi dasar titik koordinat
    if (!isValidCoordinate(currentCoord.latitude, currentCoord.longitude)) {
      return const GpsSecurityReport(
        status: GpsSecurityStatus.invalid,
        message: 'Koordinat di luar wilayah operasional yang sah.',
        isSafe: false,
      );
    }

    // Jika ini adalah titik pertama, anggap terverifikasi
    if (previousCoord == null || previousTimestamp == null) {
      return const GpsSecurityReport(
        status: GpsSecurityStatus.verified,
        message: 'Koneksi GPS aman & terenkripsi.',
        isSafe: true,
      );
    }

    // 2. Hitung jarak dan waktu perpindahan
    final double distanceMeters = const Distance()(previousCoord, currentCoord);
    final int elapsedMilliseconds = currentTimestamp.difference(previousTimestamp).inMilliseconds;

    // Jika waktu tidak bergerak / negatif, cegah pembagian nol
    if (elapsedMilliseconds < 1000) {
      return const GpsSecurityReport(
        status: GpsSecurityStatus.verified,
        message: 'Telemetri stabil.',
        isSafe: true,
      );
    }

    final double elapsedHours = elapsedMilliseconds / 3600000.0;
    final double calculatedSpeedKmh = (distanceMeters / 1000.0) / elapsedHours;

    // 3. Deteksi Lompatan Teleportasi Ekstrem (Indikasi Mock Location / Spoofing)
    // Contoh: Lompat > 1.2 KM dalam waktu 5 detik (> 864 km/jam)
    if (distanceMeters > 1200 && elapsedMilliseconds <= 6000) {
      return GpsSecurityReport(
        status: GpsSecurityStatus.spoofDetected,
        message: 'Lompatan koordinat drastis terdeteksi (${(distanceMeters / 1000).toStringAsFixed(1)} km). Indikasi manipulasi lokasi (Fake GPS).',
        isSafe: false,
        calculatedSpeedKmh: calculatedSpeedKmh,
      );
    }

    // 4. Deteksi Kecepatan Tidak Wajar untuk Kendaraan Darat
    if (calculatedSpeedKmh > _maxPlausibleSpeedKmh) {
      return GpsSecurityReport(
        status: GpsSecurityStatus.warning,
        message: 'Kecepatan perpindahan tidak wajar: ${calculatedSpeedKmh.toStringAsFixed(0)} km/h. Periksa akurasi sinyal peminjam.',
        isSafe: false,
        calculatedSpeedKmh: calculatedSpeedKmh,
      );
    }

    return GpsSecurityReport(
      status: GpsSecurityStatus.verified,
      message: 'Telemetri GPS terverifikasi & asli.',
      isSafe: true,
      calculatedSpeedKmh: calculatedSpeedKmh,
    );
  }

  // =========================================================
  // 3. DATA MASKING & SANITASI ERROR
  // =========================================================
  /// Membersihkan input teks dari potensi karakter berbahaya
  String sanitizeInput(String input) {
    return input.trim().replaceAll(RegExp(r'''[<>"'`;\\]'''), '');
  }

  /// Menyamarkan pesan error teknis Supabase agar tidak membocorkan skema sistem
  String sanitizeErrorMessage(dynamic error) {
    if (error == null) return 'Terjadi kesalahan sistem yang tidak diketahui.';
    final str = error.toString().toLowerCase();

    if (str.contains('network') || str.contains('socket') || str.contains('connection')) {
      return 'Koneksi ke server pemantauan terganggu. Periksa jaringan Anda.';
    } else if (str.contains('invalid login') || str.contains('invalid credentials') || str.contains('auth')) {
      return 'Kredensial Admin tidak valid. Periksa kembali ID dan Password Anda.';
    } else if (str.contains('timeout')) {
      return 'Waktu permintaan server habis. Silakan coba kembali.';
    } else if (str.contains('permission') || str.contains('denied') || str.contains('unauthorized')) {
      return 'Akses ditolak: Akun Anda tidak memiliki otoritas Administrator.';
    }

    // Default safe fallback tanpa membocorkan raw SQL / stack trace
    return 'Gagal memproses data server secara aman. Silakan muat ulang halaman.';
  }
}
