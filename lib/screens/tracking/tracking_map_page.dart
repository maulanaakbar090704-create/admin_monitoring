import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/direction_helper.dart';
import '../../utils/security_manager.dart';

/// Halaman Tracking Map Real-time dengan Flutter Map, LatLong2, & Supabase Stream.
///
/// Fitur Utama:
/// 1. Real-time OpenStreetMap dengan Marker mobil kustom & Auto Re-center.
/// 2. Kalkulasi jarak tempuh lokal berbasis koordinat awal (latlong2 Distance).
/// 3. Floating Live Dashboard Card dengan metrik Kecepatan (km/h) & Jarak (KM).
/// 4. Menampilkan Data Peminjam (Nama, NIK, Tujuan, Keperluan).
/// 5. Desain Dark Mode Modern dengan estetika Gold / XAUUSD Trading Dashboard.
class TrackingMapPage extends StatefulWidget {
  final String targetPlateNumber;

  const TrackingMapPage({
    super.key,
    this.targetPlateNumber = 'B 1974 HZU',
  });

  @override
  State<TrackingMapPage> createState() => _TrackingMapPageState();
}

class _TrackingMapPageState extends State<TrackingMapPage>
    with SingleTickerProviderStateMixin {
  // Palet Warna Dark Mode & Gold XAUUSD
  static const Color _kBgDark = Color(0xFF0A0E17);
  static const Color _kCardDark = Color(0xFF121824);
  static const Color _kCardBorder = Color(0xFF263244);
  static const Color _kGoldPrimary = Color(0xFFF59E0B); // Amber Gold
  static const Color _kGoldSecondary = Color(0xFFD97706);
  static const Color _kGoldGlow = Color(0x33F59E0B);
  static const Color _kGoldLight = Color(0xFFFEF3C7);
  static const Color _kTextWhite = Color(0xFFF8FAFC);
  static const Color _kTextMuted = Color(0xFF94A3B8);
  static const Color _kGreenLive = Color(0xFF10B981);

  final MapController _mapController = MapController();
  final Distance _distanceCalc = const Distance();

  StreamSubscription<List<Map<String, dynamic>>>? _streamSubscription;

  LatLng? _startLocation;
  LatLng? _currentLocation;
  final List<LatLng> _routeTrail = [];

  // Data Telemetri (Default 0 jika null)
  double _speedKmh = 0.0;
  double _distanceKm = 0.0;
  double _bearing = 0.0; // Derajat arah kendaraan (0.0 - 360.0)
  String _cardinalDirection = 'Utara';
  String _cardinalAbbr = 'U';

  // State Integritas Keamanan Telemetri
  DateTime? _lastCoordinateTime;
  GpsSecurityReport _securityReport = const GpsSecurityReport(
    status: GpsSecurityStatus.verified,
    message: 'Koneksi GPS aman & terenkripsi.',
    isSafe: true,
  );

  // Data Peminjam
  String _borrowerName = 'Memuat peminjam...';
  String _borrowerNik = '-';
  String _destination = '-';
  String _purpose = '-';
  String? _lastEmployeeId;

  bool _isLoading = true;
  String? _errorMessage;
  bool _isMapReady = false;
  bool _autoRecenter = true;
  double _currentZoom = 16.0;

  // Animasi pulsing untuk radar marker mobil
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initRealtimeTracking();
  }

  @override
  void dispose() {
    _streamSubscription?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  /// Inisialisasi Real-time Stream dari tabel `bookings` Supabase
  void _initRealtimeTracking() {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final supabase = Supabase.instance.client;

      // Berlangganan stream pada tabel bookings dengan filter status = 'active'
      _streamSubscription = supabase
          .from('bookings')
          .stream(primaryKey: ['id'])
          .eq('status', 'active')
          .listen(
            (List<Map<String, dynamic>> records) {
              _processStreamData(records);
            },
            onError: (dynamic error) {
              if (mounted) {
                setState(() {
                  _isLoading = false;
                  _errorMessage = SecurityManager.instance.sanitizeErrorMessage(error);
                });
              }
            },
          );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = SecurityManager.instance.sanitizeErrorMessage(e);
        });
      }
    }
  }

  /// Mengambil data profil peminjam dari tabel `profiles`
  Future<void> _fetchBorrowerProfile(String employeeId) async {
    try {
      final supabase = Supabase.instance.client;
      final res = await supabase
          .from('profiles')
          .select('full_name, employee_no')
          .eq('id', employeeId)
          .maybeSingle();

      if (res != null && mounted) {
        setState(() {
          _borrowerName = res['full_name']?.toString() ?? 'Driver Telkom';
          _borrowerNik = res['employee_no']?.toString() ?? '-';
        });
      }
    } catch (e) {
      debugPrint('Error fetch borrower profile: $e');
    }
  }

  /// Memproses baris data yang diterima dari stream Supabase
  void _processStreamData(List<Map<String, dynamic>> records) {
    if (!mounted) return;

    // Filter baris khusus untuk kendaraan dengan plat_nomor target ('B 1974 HZU')
    final matchedRows = records.where((row) {
      final plat = (row['plat_nomor'] ?? '').toString().trim().toUpperCase();
      final target = widget.targetPlateNumber.trim().toUpperCase();
      return plat == target;
    }).toList();

    if (matchedRows.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Tidak ditemukan booking aktif untuk plat nomor "${widget.targetPlateNumber}".';
      });
      return;
    }

    final row = matchedRows.first;
    final rawLat = row['latitude'];
    final rawLng = row['longitude'];

    // Jika kecepatan masih null / kosong, buat default 0 km/h sesuai instruksi
    final double speed = (row['kecepatan'] as num?)?.toDouble() ?? 0.0;

    // Data peminjam & perjalanan
    final employeeId = row['employee_id']?.toString();
    _destination = row['destination']?.toString() ?? '-';
    _purpose = row['purpose']?.toString() ?? '-';

    if (employeeId != null && employeeId != _lastEmployeeId) {
      _lastEmployeeId = employeeId;
      _fetchBorrowerProfile(employeeId);
    }

    // 1. Validasi Keamanan Koordinat menggunakan SecurityManager
    final double? rawLatNum = (rawLat as num?)?.toDouble();
    final double? rawLngNum = (rawLng as num?)?.toDouble();

    if (!SecurityManager.instance.isValidCoordinate(rawLatNum, rawLngNum)) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Koordinat GPS tidak valid atau di luar wilayah operasional yang sah.';
      });
      return;
    }

    final double lat = rawLatNum!;
    final double lng = rawLngNum!;
    final LatLng newCoord = LatLng(lat, lng);
    final now = DateTime.now();

    // 2. Jalankan Analisis Integritas Telemetri & Deteksi Fake GPS / Spoofing
    final report = SecurityManager.instance.analyzeTelemtryIntegrity(
      previousCoord: _currentLocation,
      currentCoord: newCoord,
      previousTimestamp: _lastCoordinateTime,
      currentTimestamp: now,
      reportedSpeedKmh: speed,
    );

    // 3. Simpan koordinat pertama sebagai startLocation
    if (_startLocation == null) {
      _startLocation = newCoord;
      final rawJarak = (row['jarak'] as num?)?.toDouble();
      _distanceKm = rawJarak ?? 0.0;
    } else {
      final double distanceInMeters = _distanceCalc(_startLocation!, newCoord);
      _distanceKm = distanceInMeters / 1000.0;
    }

    // Rekam lintasan rute perjalanan
    if (_routeTrail.isEmpty || _routeTrail.last != newCoord) {
      _routeTrail.add(newCoord);
    }

    // Ambil atau kalkulasi arah kendaraan (bearing / heading)
    double newBearing = _bearing;
    final rawHeading = (row['heading'] ?? row['bearing'] ?? row['arah'] as num?)?.toDouble();
    if (rawHeading != null) {
      newBearing = DirectionHelper.normalizeDegrees(rawHeading);
    } else if (_currentLocation != null && _currentLocation != newCoord) {
      final double distanceMoved = _distanceCalc(_currentLocation!, newCoord);
      if (distanceMoved > 1.5 || speed > 0.5) {
        newBearing = DirectionHelper.calculateBearing(_currentLocation!, newCoord);
      }
    }

    final cardinal = DirectionHelper.getCardinalName(newBearing);
    final abbr = DirectionHelper.getCardinalAbbreviation(newBearing);

    setState(() {
      _currentLocation = newCoord;
      _lastCoordinateTime = now;
      _securityReport = report;
      _bearing = newBearing;
      _cardinalDirection = cardinal;
      _cardinalAbbr = abbr;
      _speedKmh = speed;
      _isLoading = false;
      _errorMessage = null;
    });

    // Otomatis re-center peta mengikuti marker saat koordinat berubah
    if (_autoRecenter && _isMapReady) {
      _mapController.move(newCoord, _currentZoom);
    }
  }

  /// Fungsi manual untuk memusatkan kembali peta ke posisi marker terkini
  void _recenterMap() {
    if (_currentLocation != null && _isMapReady) {
      setState(() => _autoRecenter = true);
      _mapController.move(_currentLocation!, _currentZoom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBgDark,
      body: Stack(
        children: [
          // 1. LAYER PETA REAL-TIME (flutter_map)
          _buildMapLayer(),

          // 2. GRADIENT VIGNETTE OVERLAY (Estetika Dark Mode)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _kBgDark.withValues(alpha: 0.95),
                      _kBgDark.withValues(alpha: 0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),

          // 3. TOP APP BAR & STATUS BADGE
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: _buildTopHeader(),
            ),
          ),

          // 4. MAP CONTROL BUTTONS (Recenter & Zoom)
          Positioned(
            right: 16,
            bottom: 270,
            child: _buildMapQuickActions(),
          ),

          // 5. FLOATING LIVE DASHBOARD CARD (Data Peminjam, Kecepatan & Jarak Tempuh)
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: _buildFloatingDashboardCard(),
          ),

          // 6. LOADING STATE OVERLAY
          if (_isLoading) _buildLoadingOverlay(),

          // 7. ERROR STATE OVERLAY
          if (_errorMessage != null && !_isLoading) _buildErrorOverlay(),
        ],
      ),
    );
  }

  /// Komponen Peta dengan OpenStreetMap & Marker Mobil Kustom
  Widget _buildMapLayer() {
    // Koordinat Jakarta / Bogor default jika belum siap
    final LatLng initialCenter = _currentLocation ?? LatLng(-6.592679, 106.794268);

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        center: initialCenter,
        zoom: _currentZoom,
        maxZoom: 18.0,
        minZoom: 4.0,
        onMapReady: () {
          _isMapReady = true;
          if (_currentLocation != null) {
            _mapController.move(_currentLocation!, _currentZoom);
          }
        },
        onPositionChanged: (position, hasGesture) {
          if (hasGesture && _autoRecenter) {
            setState(() => _autoRecenter = false);
          }
          if (position.zoom != null) {
            _currentZoom = position.zoom!;
          }
        },
      ),
      children: [
        // Standard OpenStreetMap Tile Layer (Clean, no API key watermark)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.admin_monitoring_telkom',
          backgroundColor: const Color(0xFFE2E8F0),
        ),

        // Garis Jejak Perjalanan Emas (Route Trail)
        if (_routeTrail.length > 1)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routeTrail,
                strokeWidth: 3.5,
                color: _kGoldPrimary.withValues(alpha: 0.75),
              ),
            ],
          ),

        // Marker Kendaraan Real-time
        if (_currentLocation != null)
          MarkerLayer(
            markers: [
              // Marker Titik Awal (Start Location)
              if (_startLocation != null && _distanceKm > 0.05)
                Marker(
                  point: _startLocation!,
                  width: 36,
                  height: 36,
                  builder: (context) => _buildStartMarkerBadge(),
                ),

              // Marker Mobil Aktif
              Marker(
                point: _currentLocation!,
                width: 90,
                height: 90,
                builder: (context) => _buildCarVehicleMarker(),
              ),
            ],
          ),
      ],
    );
  }

  /// Marker Ikon Mobil dengan Efek Radar & Orientasi Arah Kendaraan
  Widget _buildCarVehicleMarker() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Gelombang Radar Emas (Glow Pulse)
            Container(
              width: 68 * _pulseAnimation.value,
              height: 68 * _pulseAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _kGoldPrimary.withValues(alpha: 0.12),
                border: Border.all(
                  color: _kGoldPrimary.withValues(alpha: 0.3),
                  width: 1.5,
                ),
              ),
            ),

            // Base Marker Lingkaran Gelap Beraksen Emas dengan Rotasi Sesuai Arah Kendaraan
            Transform.rotate(
              angle: _bearing * (math.pi / 180.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Beam / Sorot Arah ke Depan Kendaraan
                  Positioned(
                    top: 2,
                    child: Container(
                      width: 18,
                      height: 16,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            _kGoldPrimary.withValues(alpha: 0.85),
                            _kGoldPrimary.withValues(alpha: 0.0),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                      ),
                    ),
                  ),

                  // Bodi Utama Marker Kendaraan
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                      ),
                      border: Border.all(
                        color: _kGoldPrimary,
                        width: 2.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _kGoldPrimary.withValues(alpha: 0.45),
                          blurRadius: 14,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Panah Orientasi Arah Navigasi (Menghadap lurus ke depan)
                        Positioned(
                          top: 5,
                          child: Icon(
                            Icons.arrow_drop_up_rounded,
                            color: _kGoldLight,
                            size: 16,
                          ),
                        ),
                        // Ikon Navigasi Arah Kendaraan
                        const Icon(
                          Icons.navigation_rounded,
                          color: _kGoldPrimary,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Mini Badge Status & Arah Mata Angin (Tetap tegak agar mudah dibaca pengguna)
            Positioned(
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: _kCardDark,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: _kGoldSecondary, width: 0.8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.45),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: _kGreenLive,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_cardinalAbbr • ${_bearing.round()}°',
                      style: const TextStyle(
                        color: _kGoldLight,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// Marker Titik Awal (Start Location)
  Widget _buildStartMarkerBadge() {
    return Container(
      decoration: BoxDecoration(
        color: _kCardDark,
        shape: BoxShape.circle,
        border: Border.all(color: _kTextMuted, width: 1.5),
        boxShadow: const [
          BoxShadow(color: Colors.black45, blurRadius: 6),
        ],
      ),
      child: const Center(
        child: Icon(
          Icons.flag_rounded,
          color: _kGoldSecondary,
          size: 18,
        ),
      ),
    );
  }

  /// Header Atas: Back Button, Info Plat Nomor & Status Online
  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Tombol Kembali
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _kCardDark.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _kCardBorder),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _kTextWhite,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Judul Panel Telemetri
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: _kCardDark.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _kCardBorder),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: _kGoldPrimary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.gps_fixed_rounded,
                      color: _kGoldPrimary,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'LIVE FLEET TRACKING',
                          style: TextStyle(
                            color: _kGoldPrimary,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.targetPlateNumber,
                          style: const TextStyle(
                            color: _kTextWhite,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Lencana Status Keamanan Telemetri GPS
                  Flexible(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _securityReport.isSafe
                            ? _kGreenLive.withValues(alpha: 0.15)
                            : const Color(0xFFDC2626).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: _securityReport.isSafe
                              ? _kGreenLive.withValues(alpha: 0.5)
                              : const Color(0xFFEF4444),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _securityReport.isSafe
                                ? Icons.verified_user_rounded
                                : Icons.gpp_bad_rounded,
                            size: 11,
                            color: _securityReport.isSafe
                                ? _kGreenLive
                                : const Color(0xFFF87171),
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _securityReport.isSafe ? 'TERVERIFIKASI' : 'ANOMALI',
                                style: TextStyle(
                                  color: _securityReport.isSafe
                                      ? _kGreenLive
                                      : const Color(0xFFFCA5A5),
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Tombol Cepat Kontrol Peta (Recenter & Zoom)
  Widget _buildMapQuickActions() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'btn_recenter',
          backgroundColor: _autoRecenter ? _kGoldPrimary : _kCardDark,
          foregroundColor: _autoRecenter ? _kBgDark : _kGoldPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: _autoRecenter ? _kGoldSecondary : _kCardBorder,
              width: 1.2,
            ),
          ),
          onPressed: _recenterMap,
          tooltip: 'Pusatkan ke Marker',
          child: const Icon(Icons.my_location_rounded, size: 20),
        ),
        const SizedBox(height: 10),
        FloatingActionButton.small(
          heroTag: 'btn_zoom_in',
          backgroundColor: _kCardDark,
          foregroundColor: _kTextWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _kCardBorder),
          ),
          onPressed: () {
            if (_isMapReady) {
              _currentZoom = (_currentZoom + 1).clamp(4.0, 18.0);
              _mapController.move(
                _currentLocation ?? _mapController.center,
                _currentZoom,
              );
            }
          },
          tooltip: 'Zoom In',
          child: const Icon(Icons.add_rounded, size: 20),
        ),
        const SizedBox(height: 6),
        FloatingActionButton.small(
          heroTag: 'btn_zoom_out',
          backgroundColor: _kCardDark,
          foregroundColor: _kTextWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: _kCardBorder),
          ),
          onPressed: () {
            if (_isMapReady) {
              _currentZoom = (_currentZoom - 1).clamp(4.0, 18.0);
              _mapController.move(
                _currentLocation ?? _mapController.center,
                _currentZoom,
              );
            }
          },
          tooltip: 'Zoom Out',
          child: const Icon(Icons.remove_rounded, size: 20),
        ),
      ],
    );
  }

  /// Floating Card Telemetri (Data Peminjam, Kecepatan & Jarak Tempuh)
  Widget _buildFloatingDashboardCard() {
    return Container(
      decoration: BoxDecoration(
        color: _kCardDark.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _kCardBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: _kGoldPrimary.withValues(alpha: 0.08),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Garis Aksen Emas di Atas Card
            Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    _kGoldPrimary,
                    _kGoldSecondary,
                    Colors.transparent,
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. DATA PEMINJAM (Nama, NIK, Plat)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: _kGoldPrimary.withValues(alpha: 0.18),
                        child: const Icon(
                          Icons.person_rounded,
                          color: _kGoldPrimary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _borrowerName,
                              style: const TextStyle(
                                color: _kTextWhite,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.3,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'NIK: $_borrowerNik • ${widget.targetPlateNumber}',
                              style: const TextStyle(
                                color: _kGoldLight,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _kBgDark,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: _kCardBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.bolt_rounded,
                              color: _kGoldPrimary,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _autoRecenter ? 'AUTO-TRACK' : 'MANUAL',
                              style: TextStyle(
                                color: _autoRecenter ? _kGoldPrimary : _kTextMuted,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Detail Tujuan & Keperluan
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _kBgDark.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _kCardBorder.withValues(alpha: 0.5)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.location_pin, color: _kGoldPrimary, size: 13),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Tujuan: $_destination (${_purpose.toUpperCase()})',
                            style: const TextStyle(
                              color: _kTextMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Banner Peringatan Keamanan jika Terdeteksi Anomali
                  if (!_securityReport.isSafe)
                    Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: const Color(0xFF450A0A),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFEF4444), width: 1.2),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.security_update_warning_rounded, color: Color(0xFFEF4444), size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _securityReport.message,
                              style: const TextStyle(
                                color: Color(0xFFFCA5A5),
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 12),

                  // 2. TIGA STAT METRIK UTAMA: KECEPATAN, ARAH KENDARAAN, & JARAK TEMPUH
                  Row(
                    children: [
                      // KECEPATAN (km/h) -> Default 0
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.speed_rounded,
                          title: 'KECEPATAN',
                          value: _speedKmh.toStringAsFixed(1),
                          unit: 'km/h',
                          valueColor: _kGoldPrimary,
                        ),
                      ),

                      // Garis Vertikal Pemisah
                      _buildVerticalDivider(),

                      // ARAH KENDARAAN (Heading & Mata Angin)
                      Expanded(
                        child: _buildHeadingMetricTile(),
                      ),

                      // Garis Vertikal Pemisah
                      _buildVerticalDivider(),

                      // JARAK TEMPUH (KM) -> Default 0
                      Expanded(
                        child: _buildMetricTile(
                          icon: Icons.alt_route_rounded,
                          title: 'JARAK',
                          value: _distanceKm.toStringAsFixed(2),
                          unit: 'KM',
                          valueColor: _kGoldLight,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // 3. Koordinat Lat/Long & Arah Terkini
                  if (_currentLocation != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _kBgDark.withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _kCardBorder.withValues(alpha: 0.6),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.rotate(
                            angle: _bearing * (math.pi / 180.0),
                            child: const Icon(
                              Icons.navigation_rounded,
                              color: _kGoldSecondary,
                              size: 12,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Lat: ${_currentLocation!.latitude.toStringAsFixed(4)}, Lng: ${_currentLocation!.longitude.toStringAsFixed(4)} • $_cardinalDirection (${_bearing.round()}°)',
                              style: const TextStyle(
                                color: _kTextMuted,
                                fontSize: 10,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget Item Metrik Telemetri Individual
  /// Pemisah Vertikal Metalik untuk Metrik
  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 48,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            _kCardBorder,
            _kGoldPrimary.withValues(alpha: 0.3),
            _kCardBorder,
            Colors.transparent,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
    );
  }

  /// Tile Metrik Arah Kendaraan Khusus dengan Ikon Kompas Berputar
  Widget _buildHeadingMetricTile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Transform.rotate(
              angle: _bearing * (math.pi / 180.0),
              child: const Icon(
                Icons.navigation_rounded,
                color: _kGoldPrimary,
                size: 13,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              'ARAH',
              style: TextStyle(
                color: _kTextMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _cardinalAbbr,
                style: const TextStyle(
                  color: _kGoldLight,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '${_bearing.round()}°',
                style: TextStyle(
                  color: _kGoldPrimary.withValues(alpha: 0.85),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 1),
        Text(
          _cardinalDirection,
          style: const TextStyle(
            color: _kTextMuted,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  /// Widget Item Metrik Telemetri Individual
  Widget _buildMetricTile({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: _kGoldPrimary, size: 13),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(
                color: _kTextMuted,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                  fontFamily: 'monospace',
                  shadows: [
                    Shadow(
                      color: _kGoldPrimary.withValues(alpha: 0.35),
                      blurRadius: 10,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: TextStyle(
                  color: _kGoldPrimary.withValues(alpha: 0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Tampilan Loading State Modern
  Widget _buildLoadingOverlay() {
    return Container(
      color: _kBgDark.withValues(alpha: 0.82),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          decoration: BoxDecoration(
            color: _kCardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _kCardBorder),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 56,
                    height: 56,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(_kGoldPrimary),
                      backgroundColor: _kGoldGlow,
                    ),
                  ),
                  const Icon(
                    Icons.satellite_alt_rounded,
                    color: _kGoldPrimary,
                    size: 24,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Menghubungkan ke GPS Satelit...',
                style: TextStyle(
                  color: _kTextWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Mengambil koordinat dan data peminjam dari Supabase untuk kendaraan ${widget.targetPlateNumber}',
                style: const TextStyle(
                  color: _kTextMuted,
                  fontSize: 11,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Tampilan Error State dengan Tombol Refresh
  Widget _buildErrorOverlay() {
    return Container(
      color: _kBgDark.withValues(alpha: 0.85),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
          decoration: BoxDecoration(
            color: _kCardDark,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black54,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.signal_cellular_connected_no_internet_4_bar_rounded,
                  color: Colors.redAccent,
                  size: 32,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Gagal Memuat Data Pelacakan',
                style: TextStyle(
                  color: _kTextWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage ?? 'Terjadi kesalahan sistem yang tidak diketahui.',
                style: const TextStyle(
                  color: _kTextMuted,
                  fontSize: 11.5,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _initRealtimeTracking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kGoldPrimary,
                  foregroundColor: _kBgDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text(
                  'Coba Lagi',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
