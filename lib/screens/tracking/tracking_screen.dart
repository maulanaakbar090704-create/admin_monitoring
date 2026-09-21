import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../common/custom_bottom_nav.dart';
import '../dashboard/dashboard_screen.dart';
import '../../utils/language_manager.dart';
import 'tracking_map_page.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final supabase = Supabase.instance.client;
  final TextEditingController _searchController = TextEditingController();
  final MapController _mapController = MapController();

  StreamSubscription<List<Map<String, dynamic>>>? _bookingsSubscription;

  List<Map<String, dynamic>> _activeBookings = [];
  Map<String, dynamic>? _selectedBooking;
  bool _isLoading = true;
  String _searchQuery = '';
  bool _isMapReady = false;
  final double _mapZoom = 15.0;

  // Nilai Telemetri (Default 0 km/h & 0 km jika database masih kosong)
  double _currentSpeed = 0.0;
  double _currentDistance = 0.0;
  final double _maxSpeed = 60.0;

  @override
  void initState() {
    super.initState();
    _fetchTrackingData();
    _initRealtimeSubscription();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _bookingsSubscription?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Berlangganan perubahan status 'active' di tabel bookings secara real-time
  void _initRealtimeSubscription() {
    _bookingsSubscription = supabase
        .from('bookings')
        .stream(primaryKey: ['id'])
        .eq('status', 'active')
        .listen((_) {
          if (mounted) {
            _fetchTrackingData(isSilent: true);
          }
        });
  }

  // Tarik data peminjaman aktif langsung dari Supabase tabel bookings
  Future<void> _fetchTrackingData({bool isSilent = false}) async {
    if (!isSilent) {
      setState(() => _isLoading = true);
    }

    try {
      // 1. Ambil data peminjaman yang berstatus active dari tabel bookings
      final response = await supabase
          .from('bookings')
          .select('*')
          .eq('status', 'active')
          .order('start_at', ascending: false);

      List<Map<String, dynamic>> bookingsData =
          List<Map<String, dynamic>>.from(response);

      // 2. Ambil metadata profil driver / peminjam
      final profilesResponse = await supabase
          .from('profiles')
          .select('id, full_name, employee_no');
      List<Map<String, dynamic>> profilesData =
          List<Map<String, dynamic>>.from(profilesResponse);

      // 3. Ambil metadata kendaraan
      final vehiclesResponse = await supabase
          .from('vehicles')
          .select('id, make_model, registration_no');
      List<Map<String, dynamic>> vehiclesData =
          List<Map<String, dynamic>>.from(vehiclesResponse);

      // 4. Hubungkan data peminjaman dengan profil peminjam & kendaraan
      for (var i = 0; i < bookingsData.length; i++) {
        final employeeId = bookingsData[i]['employee_id'];
        final matchedProfile =
            profilesData.where((p) => p['id'] == employeeId).toList();
        bookingsData[i]['profiles'] = matchedProfile.isNotEmpty
            ? matchedProfile.first
            : {
                'full_name': 'Driver Telkom',
                'phone_number': '',
                'employee_no': '-',
              };

        final vehicleId = bookingsData[i]['vehicle_id'];
        final matchedVehicle =
            vehiclesData.where((v) => v['id'] == vehicleId).toList();
        final platFromBooking = bookingsData[i]['plat_nomor'];
        bookingsData[i]['vehicles'] = matchedVehicle.isNotEmpty
            ? matchedVehicle.first
            : {
                'make_model': 'Mobil Operasional',
                'registration_no': platFromBooking ?? 'B 1974 HZU',
              };
      }

      // Pastikan 1 Plat Nomor hanya dibaca oleh 1 peminjam aktif (tidak boleh ada plat ganda)
      // Prioritaskan peminjam yang koordinat GPS-nya aktif / terbaru
      bookingsData.sort((a, b) {
        final hasCoordA = (a['latitude'] != null && a['longitude'] != null) ? 1 : 0;
        final hasCoordB = (b['latitude'] != null && b['longitude'] != null) ? 1 : 0;
        return hasCoordB.compareTo(hasCoordA);
      });

      final Set<String> seenPlates = <String>{};
      final List<Map<String, dynamic>> uniqueBookings = [];
      for (final booking in bookingsData) {
        final vehicle = (booking['vehicles'] is Map)
            ? booking['vehicles'] as Map<String, dynamic>
            : <String, dynamic>{};
        final regNo = (booking['plat_nomor'] ?? vehicle['registration_no'] ?? '')
            .toString()
            .trim()
            .toUpperCase();
        if (regNo.isNotEmpty) {
          if (!seenPlates.contains(regNo)) {
            seenPlates.add(regNo);
            uniqueBookings.add(booking);
          }
        } else {
          uniqueBookings.add(booking);
        }
      }
      bookingsData = uniqueBookings;

      if (mounted) {
        // Tentukan selected booking
        Map<String, dynamic>? selected;
        if (bookingsData.isNotEmpty) {
          // Cari booking dengan koordinat valid
          selected = bookingsData.firstWhere(
            (b) => b['latitude'] != null && b['longitude'] != null,
            orElse: () => bookingsData.first,
          );
        }

        // Ambil kecepatan & jarak (default 0 jika null)
        double speed = 0.0;
        double distance = 0.0;
        if (selected != null) {
          speed = (selected['kecepatan'] as num?)?.toDouble() ?? 0.0;
          distance = (selected['jarak'] as num?)?.toDouble() ?? 0.0;
        }

        setState(() {
          _activeBookings = bookingsData;
          _selectedBooking = selected;
          _currentSpeed = speed;
          _currentDistance = distance;
          _isLoading = false;
        });

        // Re-center peta ke koordinat kendaraan aktif jika map sudah siap
        if (_isMapReady && selected != null) {
          final lat = (selected['latitude'] as num?)?.toDouble();
          final lng = (selected['longitude'] as num?)?.toDouble();
          if (lat != null && lng != null) {
            _mapController.move(LatLng(lat, lng), _mapZoom);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetch tracking data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Mendapatkan koordinat dari booking yang terpilih atau default Jakarta/Bogor
  LatLng get _currentMapCenter {
    if (_selectedBooking != null) {
      final lat = (_selectedBooking!['latitude'] as num?)?.toDouble();
      final lng = (_selectedBooking!['longitude'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        return LatLng(lat, lng);
      }
    }
    // Fallback jika tidak ada koordinat
    return LatLng(-6.592679, 106.794268);
  }

  // Pusatkan peta ke koordinat kendaraan tertentu
  void _focusVehicle(Map<String, dynamic> booking) {
    final lat = (booking['latitude'] as num?)?.toDouble();
    final lng = (booking['longitude'] as num?)?.toDouble();
    final speed = (booking['kecepatan'] as num?)?.toDouble() ?? 0.0;
    final distance = (booking['jarak'] as num?)?.toDouble() ?? 0.0;

    setState(() {
      _selectedBooking = booking;
      _currentSpeed = speed;
      _currentDistance = distance;
    });

    if (lat != null && lng != null && _isMapReady) {
      _mapController.move(LatLng(lat, lng), 16.0);
    }
  }

  Future<void> _launchWA(String? phone) async {
    if (phone == null || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nomor WhatsApp driver tidak tersedia')),
      );
      return;
    }
    String formattedPhone = phone;
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '62${formattedPhone.substring(1)}';
    }
    final Uri url = Uri.parse('https://wa.me/$formattedPhone');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka aplikasi WhatsApp')),
        );
      }
    }
  }

  Future<void> _launchMaps(String? destination) async {
    final query = (destination != null && destination.isNotEmpty)
        ? destination
        : 'Telkom Landmark Tower';
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tidak dapat membuka Google Maps')),
        );
      }
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year;
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      return '$day/$month/$year $hour:$minute WIB';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Filter pencarian
    final filteredBookings = _activeBookings.where((item) {
      if (_searchQuery.isEmpty) return true;
      final vehicle = (item['vehicles'] is Map)
          ? item['vehicles'] as Map<String, dynamic>
          : <String, dynamic>{};
      final profile = (item['profiles'] is Map)
          ? item['profiles'] as Map<String, dynamic>
          : <String, dynamic>{};
      final makeModel = (vehicle['make_model']?.toString() ?? '').toLowerCase();
      final plate = (item['plat_nomor'] ?? vehicle['registration_no'] ?? '')
          .toString()
          .toLowerCase();
      final driver = (profile['full_name']?.toString() ?? '').toLowerCase();
      final destination = (item['destination']?.toString() ?? '').toLowerCase();

      return makeModel.contains(_searchQuery) ||
          plate.contains(_searchQuery) ||
          driver.contains(_searchQuery) ||
          destination.contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.1),
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
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.explore, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                LanguageManager.instance.t('tracking_title'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Hanken Grotesk',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            tooltip: LanguageManager.instance.t('reload_btn'),
            onPressed: () => _fetchTrackingData(),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: CircleAvatar(
              radius: 17,
              backgroundColor: Colors.white.withValues(alpha: 0.25),
              child: const Icon(
                Icons.admin_panel_settings,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 1),
      body: RefreshIndicator(
        onRefresh: () => _fetchTrackingData(),
        color: const Color(0xFFBB0016),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFBB0016)),
              )
            : ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  // 1. SEARCH BAR
                  _buildSearchBar(),

                  const SizedBox(height: 16),

                  // 2. REAL-TIME MAP WIDGET (OpenStreetMap via flutter_map)
                  _buildInteractiveMapSection(),

                  const SizedBox(height: 16),

                  // 3. STATUS TELEMETRI & STATS ARMADA AKTIF
                  _buildTelemetrySummaryCard(),

                  const SizedBox(height: 20),

                  // 4. HEADER DAFTAR KENDARAAN BERGERAK
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${LanguageManager.instance.t('vehicle_list_title')} (${filteredBookings.length})',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF191C1D),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.circle, color: Color(0xFF2E7D32), size: 8),
                            SizedBox(width: 4),
                            Text(
                              'Live Sync',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // 5. DAFTAR KENDARAAN AKTIF DENGAN DETAIL PEMINJAM
                  if (filteredBookings.isEmpty)
                    _buildEmptyState()
                  else
                    ...filteredBookings.map((booking) => _buildBookingCard(booking)),
                ],
              ),
      ),
    );
  }

  // 1. Widget Search Bar
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B)),
        decoration: InputDecoration(
          hintText: LanguageManager.instance.t('search_tracking_hint'),
          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0F3567), size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: Color(0xFF64748B)),
                  onPressed: () {
                    _searchController.clear();
                    FocusScope.of(context).unfocus();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        ),
      ),
    );
  }

  // 2. Widget Peta Real-time (flutter_map dengan titik koordinat dari database)
  Widget _buildInteractiveMapSection() {
    final center = _currentMapCenter;
    final bool hasActiveVehicle = _selectedBooking != null;
    final bool hasActiveCoord = hasActiveVehicle &&
        _selectedBooking!['latitude'] != null &&
        _selectedBooking!['longitude'] != null;

    final platNomor = _selectedBooking?['plat_nomor'] ??
        _selectedBooking?['vehicles']?['registration_no'] ??
        '-';

    final profile = (_selectedBooking?['profiles'] is Map)
        ? _selectedBooking!['profiles'] as Map<String, dynamic>
        : <String, dynamic>{};
    final borrowerName = profile['full_name']?.toString() ?? '-';
    final borrowerNik = profile['employee_no']?.toString() ?? '-';
    final borrowerPhone = profile['phone_number']?.toString();
    final destination = _selectedBooking?['destination']?.toString() ?? '-';
    final purpose = _selectedBooking?['purpose']?.toString() ?? '-';

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFF334155)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Column(
          children: [
            // Peta Viewport
            SizedBox(
              height: 310,
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      center: center,
                      zoom: _mapZoom,
                      maxZoom: 18.0,
                      minZoom: 4.0,
                      onMapReady: () {
                        _isMapReady = true;
                      },
                    ),
                    children: [
                      // Tile OSM Clean Standard (Bebas watermark "API KEY REQUIRED")
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName:
                            'com.example.admin_monitoring_telkom',
                        backgroundColor: const Color(0xFFE2E8F0),
                      ),

                      // Markers
                      MarkerLayer(
                        markers: [
                          if (_activeBookings.any((b) => b['latitude'] != null && b['longitude'] != null))
                            ..._activeBookings
                                .where((b) => b['latitude'] != null && b['longitude'] != null)
                                .map((b) {
                              final lat = (b['latitude'] as num).toDouble();
                              final lng = (b['longitude'] as num).toDouble();
                              final pNomor = b['plat_nomor'] ??
                                  b['vehicles']?['registration_no'] ??
                                  '-';
                              final isCurrent = _selectedBooking?['id'] == b['id'];
                              return Marker(
                                point: LatLng(lat, lng),
                                width: 80,
                                height: 80,
                                builder: (context) => GestureDetector(
                                  onTap: () => _focusVehicle(b),
                                  child: _buildMapCarMarker(pNomor, isSelected: isCurrent),
                                ),
                              );
                            })
                          else
                            Marker(
                              point: LatLng(-6.592679, 106.794268),
                              width: 140,
                              height: 70,
                              builder: (context) => _buildPoolMarker(),
                            ),
                        ],
                      ),
                    ],
                  ),

                  // Floating Header Badge di Atas Peta
                  Positioned(
                    top: 12,
                    left: 12,
                    right: 12,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Badge Status Peta
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A).withValues(alpha: 0.88),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: hasActiveVehicle
                                  ? const Color(0xFF10B981).withValues(alpha: 0.7)
                                  : const Color(0xFF64748B).withValues(alpha: 0.5),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: hasActiveVehicle
                                      ? const Color(0xFF10B981)
                                      : const Color(0xFF94A3B8),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                hasActiveVehicle
                                    ? (hasActiveCoord
                                        ? '$platNomor • ${LanguageManager.instance.t('map_live_gps')}'
                                        : '$platNomor • ${LanguageManager.instance.t('map_gps_standby')}')
                                    : LanguageManager.instance.t('map_pool_standby'),
                                style: TextStyle(
                                  color: hasActiveVehicle
                                      ? const Color(0xFFFEF3C7)
                                      : Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Tombol Fullscreen Map
                        if (hasActiveVehicle)
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFF59E0B),
                              foregroundColor: const Color(0xFF0F172A),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            icon: const Icon(Icons.fullscreen, size: 16),
                            label: Text(
                              LanguageManager.instance.t('fullscreen_map_btn'),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TrackingMapPage(
                                    targetPlateNumber: platNomor,
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),

                  // Tombol Re-center Kamera Peta
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: FloatingActionButton.small(
                      heroTag: 'recenter_inline_map',
                      backgroundColor: const Color(0xFF0F172A),
                      foregroundColor: const Color(0xFFF59E0B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: Color(0xFF334155)),
                      ),
                      onPressed: () {
                        if (_isMapReady) {
                          _mapController.move(center, 16.0);
                        }
                      },
                      tooltip: hasActiveVehicle ? 'Pusatkan ke Kendaraan' : 'Pusatkan ke Pool',
                      child: const Icon(Icons.my_location, size: 18),
                    ),
                  ),
                ],
              ),
            ),

            // KARTU INFORMASI DI BAWAH PETA
            Container(
              padding: const EdgeInsets.all(14),
              color: const Color(0xFF1E293B),
              child: hasActiveVehicle
                  ? Column(
                      children: [
                        // Baris Data Peminjam
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 17,
                              backgroundColor:
                                  const Color(0xFFF59E0B).withValues(alpha: 0.2),
                              child: const Icon(
                                Icons.person_rounded,
                                color: Color(0xFFF59E0B),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    borrowerName,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    '${LanguageManager.instance.t('borrower_label')} (NIK: $borrowerNik) • $destination ($purpose)',
                                    style: const TextStyle(
                                      color: Color(0xFF94A3B8),
                                      fontSize: 10.5,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            if (borrowerPhone != null && borrowerPhone.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(right: 6.0),
                                child: InkWell(
                                  onTap: () => _launchWA(borrowerPhone),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF25D366).withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 16),
                                  ),
                                ),
                              ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0F172A),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFF334155)),
                              ),
                              child: Text(
                                platNomor,
                                style: const TextStyle(
                                  color: Color(0xFFFEF3C7),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // Dua Baris Metrik: Kecepatan & Jarak Tempuh
                        Row(
                          children: [
                            // Kecepatan
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF334155)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.speed_rounded,
                                      color: Color(0xFFF59E0B),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          LanguageManager.instance.t('speed_label'),
                                          style: const TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${_currentSpeed.toStringAsFixed(1)} km/h',
                                          style: const TextStyle(
                                            color: Color(0xFFF59E0B),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 10),

                            // Jarak Tempuh
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFF334155)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.route_rounded,
                                      color: Color(0xFFFEF3C7),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          LanguageManager.instance.t('distance_label'),
                                          style: const TextStyle(
                                            color: Color(0xFF94A3B8),
                                            fontSize: 9,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          '${_currentDistance.toStringAsFixed(2)} km',
                                          style: const TextStyle(
                                            color: Color(0xFFFEF3C7),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F3567).withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: const Icon(
                            Icons.local_parking_rounded,
                            color: Color(0xFF60A5FA),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LanguageManager.instance.t('pool_standby_title'),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                LanguageManager.instance.t('pool_standby_desc'),
                                style: const TextStyle(
                                  color: Color(0xFF94A3B8),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F172A),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF334155)),
                          ),
                          child: Text(
                            LanguageManager.instance.t('pool_status_ready'),
                            style: const TextStyle(
                              color: Color(0xFF60A5FA),
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
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

  // Marker Pool Standby
  Widget _buildPoolMarker() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFF60A5FA), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
              ),
            ],
          ),
          child: Text(
            LanguageManager.instance.t('pool_marker_label'),
            style: const TextStyle(
              color: Color(0xFF93C5FD),
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF0F3567),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F3567).withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.local_parking_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  // Marker Ikon Mobil untuk Peta
  Widget _buildMapCarMarker(String platNomor, {bool isSelected = true}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A),
            borderRadius: BorderRadius.circular(5),
            border: Border.all(color: isSelected ? const Color(0xFFF59E0B) : Colors.white, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 4,
              ),
            ],
          ),
          child: Text(
            platNomor,
            style: const TextStyle(
              color: Color(0xFFFEF3C7),
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFBB0016) : const Color(0xFF0F3567),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: (isSelected ? const Color(0xFFBB0016) : const Color(0xFF0F3567)).withValues(alpha: 0.4),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.directions_car_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }

  // 3. Telemetri Summary Card
  Widget _buildTelemetrySummaryCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F3567).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.sensors_rounded,
                  color: Color(0xFF0F3567),
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      LanguageManager.instance.t('telemetry_title'),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      LanguageManager.instance.t('telemetry_desc'),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        LanguageManager.instance.t('stat_active_fleet'),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_activeBookings.length} ${LanguageManager.instance.t('unit_suffix')}',
                        style: const TextStyle(
                          fontFamily: 'Hanken Grotesk',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F3567),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        LanguageManager.instance.t('stat_avg_speed'),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_currentSpeed.toStringAsFixed(1)} km/h',
                        style: const TextStyle(
                          fontFamily: 'Hanken Grotesk',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        LanguageManager.instance.t('stat_max_speed'),
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_maxSpeed.toStringAsFixed(0)} km/h',
                        style: const TextStyle(
                          fontFamily: 'Hanken Grotesk',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFBB0016),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // 4. Widget Card Kendaraan Aktif
  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final vehicle = (booking['vehicles'] is Map)
        ? booking['vehicles'] as Map<String, dynamic>
        : <String, dynamic>{};
    final profile = (booking['profiles'] is Map)
        ? booking['profiles'] as Map<String, dynamic>
        : <String, dynamic>{};

    final makeModel = vehicle['make_model']?.toString() ?? 'Mobil Operasional';
    final regNo = booking['plat_nomor'] ??
        vehicle['registration_no'] ??
        '-';
    final driverName = profile['full_name']?.toString() ?? 'Driver';
    final employeeNo = profile['employee_no']?.toString() ?? '-';
    final phone = profile['phone_number']?.toString();
    final destination = booking['destination']?.toString() ?? '-';
    final purpose = booking['purpose']?.toString() ?? '-';

    final speed = (booking['kecepatan'] as num?)?.toDouble() ?? 0.0;
    final distance = (booking['jarak'] as num?)?.toDouble() ?? 0.0;

    final isSelected = _selectedBooking?['id'] == booking['id'];

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF0F3567) : const Color(0xFFE2E8F0),
          width: isSelected ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isSelected
                ? const Color(0xFF0F3567).withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _focusVehicle(booking),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Vehicle icon, makeModel, plate pill, and active status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFBB0016).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.directions_car_filled_rounded,
                        color: Color(0xFFBB0016),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            makeModel,
                            style: const TextStyle(
                              fontFamily: 'Hanken Grotesk',
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  regNo,
                                  style: const TextStyle(
                                    fontFamily: 'Hanken Grotesk',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (booking['start_time'] != null) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _formatDate(booking['start_time']?.toString()),
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Color(0xFF64748B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFDAD6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFBA1A1A).withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.circle, color: Color(0xFFBA1A1A), size: 7),
                          const SizedBox(width: 5),
                          Text(
                            LanguageManager.instance.t('badge_in_use'),
                            style: const TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF93000A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                ),

                // Driver row with WA button
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        size: 16,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: driverName,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            if (employeeNo != '-' && employeeNo.isNotEmpty)
                              TextSpan(
                                text: ' (NIK: $employeeNo)',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (phone != null && phone.isNotEmpty)
                      InkWell(
                        onTap: () => _launchWA(phone),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF25D366).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF25D366).withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_rounded, color: Color(0xFF25D366), size: 14),
                              SizedBox(width: 4),
                              Text(
                                'WA',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E7E34),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Destination & Purpose
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: Color(0xFFBB0016),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Text(
                          destination.isNotEmpty && purpose.isNotEmpty
                              ? '$destination • $purpose'
                              : (destination.isNotEmpty ? destination : purpose),
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: Color(0xFF334155),
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    if (destination != '-' && destination.isNotEmpty)
                      InkWell(
                        onTap: () => _launchMaps(destination),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0F3567).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.map_outlined,
                            size: 16,
                            color: Color(0xFF0F3567),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // Telemetry Badges
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.speed_rounded, size: 13, color: Color(0xFFD97706)),
                          const SizedBox(width: 4),
                          Text(
                            '${speed.toStringAsFixed(1)} km/h',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.route_rounded, size: 13, color: Color(0xFF0F3567)),
                          const SizedBox(width: 4),
                          Text(
                            '${distance.toStringAsFixed(2)} km',
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F3567),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Action Buttons: Fokus Peta & Peta Penuh
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          foregroundColor: const Color(0xFF0F3567),
                          side: const BorderSide(color: Color(0xFF0F3567)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.my_location_rounded, size: 15),
                        label: Text(
                          LanguageManager.instance.t('focus_map_btn'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () => _focusVehicle(booking),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F3567),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.fullscreen_rounded, size: 16),
                        label: Text(
                          LanguageManager.instance.t('fullscreen_map_btn'),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TrackingMapPage(
                                targetPlateNumber: regNo,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 5. Widget Tampilan Kosong
  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0F3567).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.garage_rounded,
              size: 38,
              color: Color(0xFF0F3567),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            LanguageManager.instance.t('empty_tracking_title'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            LanguageManager.instance.t('empty_tracking_desc'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF64748B), height: 1.3),
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, a1, a2) => const AdminDashboardScreen(),
                      transitionDuration: Duration.zero,
                    ),
                  );
                },
                icon: const Icon(Icons.dashboard_rounded, size: 16),
                label: Text(LanguageManager.instance.t('check_dashboard_btn')),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF0F3567),
                  side: const BorderSide(color: Color(0xFF0F3567)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => _fetchTrackingData(),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: Text(LanguageManager.instance.t('reload_btn')),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F3567),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
