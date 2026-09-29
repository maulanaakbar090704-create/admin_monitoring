import 'dart:math' as math;
import 'package:latlong2/latlong.dart';

/// Model sederhana representasi data arah kendaraan
class VehicleDirection {
  final double degrees; // 0.0 - 359.9 derajat
  final String cardinalName; // Contoh: "Utara", "Timur Laut", dll.
  final String cardinalAbbr; // Contoh: "U", "TL", "T", dll.
  final String formatted; // Contoh: "Timur Laut (45°)"

  const VehicleDirection({
    required this.degrees,
    required this.cardinalName,
    required this.cardinalAbbr,
    required this.formatted,
  });

  /// Rotasi dalam radian untuk Transform.rotate
  double get radians => degrees * (math.pi / 180.0);

  /// Rotasi dalam putaran (turns) untuk AnimatedRotation (0.0 - 1.0)
  double get turns => degrees / 360.0;
}

/// Helper kalkulasi dan format arah kendaraan (heading / bearing)
class DirectionHelper {
  /// Menghitung bearing (sudut arah perjalanan dalam derajat 0 - 360)
  /// dari titik koordinat awal [from] ke titik koordinat tujuan [to].
  ///
  /// Menggunakan rumus Forward Azimuth (Spherical Trigonometry):
  /// y = sin(Δλ) * cos(φ2)
  /// x = cos(φ1) * sin(φ2) - sin(φ1) * cos(φ2) * cos(Δλ)
  /// θ = atan2(y, x)
  static double calculateBearing(LatLng from, LatLng to) {
    if (from.latitude == to.latitude && from.longitude == to.longitude) {
      return 0.0;
    }

    final double lat1 = from.latitude * (math.pi / 180.0);
    final double lon1 = from.longitude * (math.pi / 180.0);
    final double lat2 = to.latitude * (math.pi / 180.0);
    final double lon2 = to.longitude * (math.pi / 180.0);

    final double dLon = lon2 - lon1;

    final double y = math.sin(dLon) * math.cos(lat2);
    final double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final double radians = math.atan2(y, x);
    final double degrees = (radians * (180.0 / math.pi) + 360.0) % 360.0;

    return degrees;
  }

  /// Menormalkan nilai derajat agar selalu berada di rentang [0.0, 360.0)
  static double normalizeDegrees(double deg) {
    double normalized = deg % 360.0;
    if (normalized < 0) {
      normalized += 360.0;
    }
    return normalized;
  }

  /// Mendapatkan nama mata angin (8 penjuru mata angin)
  static String getCardinalName(double degrees, {bool isIndonesian = true}) {
    final double deg = normalizeDegrees(degrees);

    if (deg >= 337.5 || deg < 22.5) {
      return isIndonesian ? 'Utara' : 'North';
    } else if (deg >= 22.5 && deg < 67.5) {
      return isIndonesian ? 'Timur Laut' : 'Northeast';
    } else if (deg >= 67.5 && deg < 112.5) {
      return isIndonesian ? 'Timur' : 'East';
    } else if (deg >= 112.5 && deg < 157.5) {
      return isIndonesian ? 'Tenggara' : 'Southeast';
    } else if (deg >= 157.5 && deg < 202.5) {
      return isIndonesian ? 'Selatan' : 'South';
    } else if (deg >= 202.5 && deg < 247.5) {
      return isIndonesian ? 'Barat Daya' : 'Southwest';
    } else if (deg >= 247.5 && deg < 292.5) {
      return isIndonesian ? 'Barat' : 'West';
    } else {
      return isIndonesian ? 'Barat Laut' : 'Northwest';
    }
  }

  /// Mendapatkan singkatan mata angin
  static String getCardinalAbbreviation(double degrees, {bool isIndonesian = true}) {
    final double deg = normalizeDegrees(degrees);

    if (deg >= 337.5 || deg < 22.5) {
      return isIndonesian ? 'U' : 'N';
    } else if (deg >= 22.5 && deg < 67.5) {
      return isIndonesian ? 'TL' : 'NE';
    } else if (deg >= 67.5 && deg < 112.5) {
      return isIndonesian ? 'T' : 'E';
    } else if (deg >= 112.5 && deg < 157.5) {
      return isIndonesian ? 'TG' : 'SE';
    } else if (deg >= 157.5 && deg < 202.5) {
      return isIndonesian ? 'S' : 'S';
    } else if (deg >= 202.5 && deg < 247.5) {
      return isIndonesian ? 'BD' : 'SW';
    } else if (deg >= 247.5 && deg < 292.5) {
      return isIndonesian ? 'B' : 'W';
    } else {
      return isIndonesian ? 'BL' : 'NW';
    }
  }

  /// Format teks ringkas telemetri arah, misal: "Timur Laut (45°)" atau "TL • 45°"
  static String formatDisplay(double degrees, {bool isIndonesian = true, bool compact = false}) {
    final double deg = normalizeDegrees(degrees);
    final String cardinal = getCardinalName(deg, isIndonesian: isIndonesian);
    final String abbr = getCardinalAbbreviation(deg, isIndonesian: isIndonesian);
    final int roundedDeg = deg.round();

    if (compact) {
      return '$abbr • $roundedDeg°';
    }
    return '$cardinal ($roundedDeg°)';
  }

  /// Membuat objek [VehicleDirection] lengkap dari derajat
  static VehicleDirection getDirection(double degrees, {bool isIndonesian = true}) {
    final double deg = normalizeDegrees(degrees);
    return VehicleDirection(
      degrees: deg,
      cardinalName: getCardinalName(deg, isIndonesian: isIndonesian),
      cardinalAbbr: getCardinalAbbreviation(deg, isIndonesian: isIndonesian),
      formatted: formatDisplay(deg, isIndonesian: isIndonesian),
    );
  }
}
