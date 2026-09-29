import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/booking_helper.dart';
import '../../utils/borrower_tracking_notification_manager.dart';
import '../../utils/language_manager.dart';
import '../../utils/notification_permission_helper.dart';
import '../../utils/vehicle_maintenance_manager.dart';
import '../common/custom_bottom_nav.dart';
import '../history/history_screen.dart';
import '../tracking/tracking_map_page.dart';
import 'widgets/maintenance_dialog.dart';
import 'widgets/vehicle_maintenance_card.dart';

typedef DashboardScreen = AdminDashboardScreen;

class AdminDashboardScreen extends StatefulWidget {
  final bool promptNotificationPermission;

  const AdminDashboardScreen({
    super.key,
    this.promptNotificationPermission = false,
  });

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _vehicles = [];
  List<Map<String, dynamic>> _filteredVehicles = [];
  List<Map<String, dynamic>> _activeBookings = [];
  int _pendingBookingsCount = 0;
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  String _selectedVehicleFilter = 'all'; // 'all', 'maintenance', 'ready'

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
    _searchController.addListener(_filterVehicles);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        BorrowerTrackingNotificationManager.instance.init(context);
        // Tampilkan perizinan notifikasi di HP setelah login
        NotificationPermissionHelper.checkAndPromptAfterLogin(
          context,
          forcePrompt: widget.promptNotificationPermission,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Tarik Data Armada & Data Perbaikan Khusus Admin
  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("Sesi Admin tidak ditemukan, silakan login ulang.");

      // 1. Tarik Data Seluruh Armada Kendaraan
      var vehiclesResponse = await supabase
          .from('vehicles')
          .select('*')
          .eq('admin_id', user.id);
      List<Map<String, dynamic>> vehiclesData =
          List<Map<String, dynamic>>.from(vehiclesResponse);

      if (vehiclesData.isEmpty) {
        final allVehiclesRes = await supabase.from('vehicles').select('*');
        vehiclesData = List<Map<String, dynamic>>.from(allVehiclesRes);
      }

      // Sinkronisasi status armada dalam perbaikan dari Supabase
      VehicleMaintenanceManager.instance.syncFromSupabase(vehiclesData);

      // 2. Tarik Peminjaman Aktif untuk Mengetahui Pengemudi yang Sedang Memakai Kendaraan
      final bookingsResponse = await supabase
          .from('bookings')
          .select('*, vehicles!inner(make_model, registration_no, admin_id)')
          .eq('vehicles.admin_id', user.id)
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> allBookings = List<Map<String, dynamic>>.from(bookingsResponse);

      final profilesResponse = await supabase.from('profiles').select('id, full_name, employee_no');
      List<Map<String, dynamic>> profilesData = List<Map<String, dynamic>>.from(profilesResponse);

      for (var i = 0; i < allBookings.length; i++) {
        final employeeId = allBookings[i]['employee_id'];
        final matchedProfile = profilesData.where((p) => p['id'] == employeeId).toList();
        if (matchedProfile.isNotEmpty) {
          allBookings[i]['profiles'] = matchedProfile.first;
        } else {
          allBookings[i]['profiles'] = {'full_name': 'Karyawan', 'employee_no': '-'};
        }
      }

      final activeList = allBookings
          .where((item) => BookingHelper.normalizeStatus(item['status']) == 'active')
          .toList();
      final pendingCount = allBookings
          .where((item) => BookingHelper.normalizeStatus(item['status']) == 'pending')
          .length;

      if (mounted) {
        setState(() {
          _vehicles = vehiclesData;
          _filteredVehicles = vehiclesData;
          _activeBookings = activeList;
          _pendingBookingsCount = pendingCount;
          _isLoading = false;
        });
        _filterVehicles();
      }
    } catch (e) {
      debugPrint('Error fetch Supabase: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error memuat data armada: $e'), backgroundColor: const Color(0xFFBB0016)),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // Filter Armada berdasarkan Pencarian & Status Perbaikan
  void _filterVehicles() {
    final query = _searchController.text.trim().toLowerCase();
    final maintenanceMgr = VehicleMaintenanceManager.instance;

    setState(() {
      _filteredVehicles = _vehicles.where((v) {
        final makeModel = (v['make_model'] ?? '').toString().toLowerCase();
        final regNo = (v['registration_no'] ?? '').toString().toLowerCase();
        final matchesSearch = makeModel.contains(query) || regNo.contains(query);

        final vehicleId = v['id']?.toString() ?? '';
        final cleanReg = (v['registration_no'] ?? '').toString().trim().toUpperCase();
        final rawStatus = (v['status'] ?? '').toString().trim().toLowerCase();

        final bool isMaintenance = v['is_maintenance'] == true ||
            rawStatus == 'maintenance' ||
            rawStatus == 'perbaikan' ||
            rawStatus == 'dalam perbaikan' ||
            maintenanceMgr.isUnderMaintenance(vehicleId, cleanReg);

        if (_selectedVehicleFilter == 'maintenance') {
          return matchesSearch && isMaintenance;
        } else if (_selectedVehicleFilter == 'ready') {
          return matchesSearch && !isMaintenance;
        }
        return matchesSearch;
      }).toList();
    });
  }

  // Navigasi Cepat ke Tab Riwayat (Data Peminjam)
  void _goToHistory({String filter = 'all'}) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, a1, a2) => HistoryScreen(initialFilter: filter),
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lm = LanguageManager.instance;
    final maintenanceMgr = VehicleMaintenanceManager.instance;

    // Hitung statistik armada
    int totalVehicles = _vehicles.length;
    int maintenanceCount = 0;
    int readyCount = 0;

    for (final v in _vehicles) {
      final vehicleId = v['id']?.toString() ?? '';
      final cleanReg = (v['registration_no'] ?? '').toString().trim().toUpperCase();
      final rawStatus = (v['status'] ?? '').toString().trim().toLowerCase();
      final bool isMaint = v['is_maintenance'] == true ||
          rawStatus == 'maintenance' ||
          rawStatus == 'perbaikan' ||
          rawStatus == 'dalam perbaikan' ||
          maintenanceMgr.isUnderMaintenance(vehicleId, cleanReg);

      if (isMaint) {
        maintenanceCount++;
      } else {
        readyCount++;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        color: const Color(0xFFBB0016),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ==========================================
              // 1. HERO GRADIENT BANNER MERAH & BIRU TELKOM
              // Menurun ke bawah melengkung elegan (seperti UI peminjam)
              // ==========================================
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0F3567), // Biru Navy Telkom
                      Color(0xFFBB0016), // Merah Telkom
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(28),
                    bottomRight: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Bar: Brand & Tombol Refresh (Anti-Overflow)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.business_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Flexible(
                                    child: Text(
                                      'Dashboard Admin',
                                      style: TextStyle(
                                        fontFamily: 'Hanken Grotesk',
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 0.2,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.refresh_rounded,
                                  color: Colors.white,
                                  size: 19,
                                ),
                                tooltip: lm.t('refresh_tooltip'),
                                onPressed: _fetchDashboardData,
                                visualDensity: VisualDensity.compact,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Informasi Peminjam Aktif (Nama, Data, Tujuan & Pop-up Notifikasi)
                        if (_activeBookings.isNotEmpty) ...[
                          Builder(
                            builder: (context) {
                              final primaryBooking = _activeBookings.first;
                              final borrowerProfile = primaryBooking['profiles'] ?? {};
                              final borrowerName = borrowerProfile['full_name'] ?? 'Karyawan Peminjam';
                              final borrowerNik = borrowerProfile['employee_no'] ?? '-';
                              final vehicleObj = primaryBooking['vehicles'] ?? {};
                              final vehicleName = vehicleObj['make_model'] ?? 'Kendaraan Operasional';
                              final vehiclePlate = vehicleObj['registration_no'] ?? primaryBooking['plat_nomor'] ?? '-';
                              final destination = primaryBooking['destination'] ?? 'Wilayah Operasional';
                              final purpose = primaryBooking['purpose'] ?? 'Kunjungan / Operasional';
                              final double speed = (primaryBooking['kecepatan'] as num?)?.toDouble() ?? 0.0;
                              final String speedText = speed > 0
                                  ? '${speed.toStringAsFixed(0)} km/jam'
                                  : '0 km/jam';

                              return Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(13),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.35),
                                    width: 1.2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row Atas: Status Live & Tombol Pop-up Notifikasi
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFDC2626),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(Icons.fiber_manual_record, color: Colors.white, size: 9),
                                              SizedBox(width: 4),
                                              Text(
                                                'PEMINJAM AKTIF',
                                                style: TextStyle(
                                                  fontFamily: 'Inter',
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  letterSpacing: 0.4,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            BorrowerTrackingNotificationManager.instance
                                                .showTrackingNotificationPopup(
                                              context,
                                              booking: primaryBooking,
                                            );
                                          },
                                          borderRadius: BorderRadius.circular(8),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                                            decoration: BoxDecoration(
                                              color: Colors.white.withValues(alpha: 0.22),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Colors.white.withValues(alpha: 0.4)),
                                            ),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.notifications_active_rounded, color: Colors.white, size: 12),
                                                SizedBox(width: 4),
                                                Text(
                                                  'Pop-Up Notifikasi',
                                                  style: TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // Nama Peminjam & NIK / Kendaraan
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(7),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(Icons.person_rounded, color: Colors.white, size: 18),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                borrowerName,
                                                style: const TextStyle(
                                                  fontFamily: 'Hanken Grotesk',
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                'NIK: $borrowerNik • $vehicleName ($vehiclePlate)',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.white.withValues(alpha: 0.9),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),

                                    // Box Tujuan & Keperluan Peminjaman
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.black.withValues(alpha: 0.16),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.near_me_rounded, color: Color(0xFFFDE047), size: 15),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Tujuan: $destination • Speed: $speedText',
                                                  style: const TextStyle(
                                                    fontFamily: 'Inter',
                                                    fontSize: 11.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                if (purpose.isNotEmpty && purpose != '-')
                                                  Text(
                                                    'Keperluan: $purpose',
                                                    style: TextStyle(
                                                      fontSize: 10.5,
                                                      color: Colors.white.withValues(alpha: 0.85),
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          // Tombol Pantau di Peta
                                          InkWell(
                                            onTap: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (ctx) => TrackingMapPage(
                                                    targetPlateNumber: vehiclePlate,
                                                  ),
                                                ),
                                              );
                                            },
                                            borderRadius: BorderRadius.circular(8),
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                                              decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.explore_rounded, color: Color(0xFF0F3567), size: 13),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'Lacak',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF0F3567),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ] else ...[
                          // Tampilan jika tidak ada peminjaman aktif
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(7),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.check_circle_rounded, color: Color(0xFF86EFAC), size: 18),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Tidak Ada Peminjaman Aktif',
                                        style: TextStyle(
                                          fontFamily: 'Hanken Grotesk',
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Seluruh armada standby di pool dan siap digunakan dinas.',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.white.withValues(alpha: 0.85),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),

                        // Ringkasan Armada (Glassmorphism Cards - Fitted & Responsive)
                        Row(
                          children: [
                            // Total Armada
                            Expanded(
                              child: _buildHeaderStatCard(
                                title: 'Total Armada',
                                count: totalVehicles.toString(),
                                icon: Icons.directions_car_rounded,
                                iconColor: Colors.white,
                                isHighlight: false,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Dalam Perbaikan
                            Expanded(
                              child: _buildHeaderStatCard(
                                title: 'Perbaikan',
                                count: maintenanceCount.toString(),
                                icon: Icons.build_circle_rounded,
                                iconColor: const Color(0xFFFCA5A5),
                                isHighlight: maintenanceCount > 0,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Kondisi Prima
                            Expanded(
                              child: _buildHeaderStatCard(
                                title: 'Prima',
                                count: readyCount.toString(),
                                icon: Icons.verified_rounded,
                                iconColor: const Color(0xFF86EFAC),
                                isHighlight: false,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ==========================================
              // 2. KONTEN BODY DASHBOARD
              // ==========================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Banner Navigasi ke Data Peminjaman (Riwayat - Anti-Overflow)
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _goToHistory(filter: _pendingBookingsCount > 0 ? 'pending' : 'all'),
                        borderRadius: BorderRadius.circular(14),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _pendingBookingsCount > 0
                                  ? const Color(0xFFF59E0B)
                                  : const Color(0xFFE2E8F0),
                              width: _pendingBookingsCount > 0 ? 1.4 : 1.0,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 6,
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
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: _pendingBookingsCount > 0
                                          ? const Color(0xFFFEF3C7)
                                          : const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.history_edu_rounded,
                                      color: _pendingBookingsCount > 0
                                          ? const Color(0xFFD97706)
                                          : const Color(0xFF0F3567),
                                      size: 19,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            const Flexible(
                                              child: Text(
                                                'Data Peminjam & ACC',
                                                style: TextStyle(
                                                  fontFamily: 'Hanken Grotesk',
                                                  fontSize: 13.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: Color(0xFF0F172A),
                                                ),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            if (_pendingBookingsCount > 0) ...[
                                              const SizedBox(width: 6),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFDC2626),
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  '$_pendingBookingsCount ACC',
                                                  style: const TextStyle(
                                                    fontSize: 9.5,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          'Kelola persetujuan & riwayat peminjam di menu Riwayat.',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    size: 13,
                                    color: Color(0xFF0F3567),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              // Tombol Uji Notifikasi ACC Langsung
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  InkWell(
                                    onTap: () {
                                      BorrowerTrackingNotificationManager.instance
                                          .checkPendingBookingsAndNotify(forceShowFirst: true);
                                    },
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFFBFDBFE)),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.notifications_active_rounded, size: 11, color: Color(0xFF0F3567)),
                                          SizedBox(width: 4),
                                          Text(
                                            'Uji Pop-Up ACC',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF0F3567),
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
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Section Heading: Armada & Perbaikan (Responsive Row)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFBB0016),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Status Armada & Perbaikan',
                                  style: TextStyle(
                                    fontFamily: 'Hanken Grotesk',
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Tombol Tambah Perbaikan Baru
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0F3567),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: const Icon(Icons.build_rounded, size: 12),
                          label: const Text(
                            '+ Perbaikan',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            MaintenanceDialog.show(
                              context,
                              vehicles: _vehicles,
                              onSaved: _fetchDashboardData,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Search Bar Pencarian Kendaraan
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 6,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                        decoration: InputDecoration(
                          hintText: 'Cari nama mobil atau plat nomor...',
                          hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12.5),
                          prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF0F3567), size: 19),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.close_rounded, size: 17, color: Color(0xFF64748B)),
                                  onPressed: () {
                                    _searchController.clear();
                                    FocusScope.of(context).unfocus();
                                  },
                                )
                              : null,
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFF0F3567), width: 1.5),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Filter Chips: Semua Armada, Dalam Perbaikan, Kondisi Prima
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildVehicleFilterChip(
                            key: 'all',
                            label: 'Semua Armada',
                            count: totalVehicles,
                            color: const Color(0xFF0F3567),
                          ),
                          const SizedBox(width: 8),
                          _buildVehicleFilterChip(
                            key: 'maintenance',
                            label: 'Dalam Perbaikan',
                            count: maintenanceCount,
                            color: const Color(0xFFDC2626),
                          ),
                          const SizedBox(width: 8),
                          _buildVehicleFilterChip(
                            key: 'ready',
                            label: 'Kondisi Prima',
                            count: readyCount,
                            color: const Color(0xFF16A34A),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Daftar Kendaraan & Status Perbaikan
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(40.0),
                          child: CircularProgressIndicator(color: Color(0xFFBB0016)),
                        ),
                      )
                    else if (_filteredVehicles.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Color(0xFFF1F5F9),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.directions_car_outlined,
                                size: 24,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'Armada tidak ditemukan'
                                  : 'Belum Ada Data Armada',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? 'Tidak ada armada yang sesuai dengan kata kunci "${_searchController.text}".'
                                  : 'Data armada kendaraan pegangan admin akan tampil di sini.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 12,
                              ),
                            ),
                            if (_searchController.text.isNotEmpty || _selectedVehicleFilter != 'all') ...[
                              const SizedBox(height: 14),
                              OutlinedButton.icon(
                                onPressed: () {
                                  setState(() {
                                    _selectedVehicleFilter = 'all';
                                    _searchController.clear();
                                    _filterVehicles();
                                  });
                                },
                                icon: const Icon(Icons.refresh_rounded, size: 15),
                                label: const Text('Reset Pencarian'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF0F3567),
                                  side: const BorderSide(color: Color(0xFF0F3567)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredVehicles.length,
                        itemBuilder: (context, index) {
                          final vehicle = _filteredVehicles[index];
                          return VehicleMaintenanceCard(
                            vehicle: vehicle,
                            allVehicles: _vehicles,
                            activeBookings: _activeBookings,
                            onRefresh: _fetchDashboardData,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color iconColor,
    required bool isHighlight,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: isHighlight
            ? Colors.white.withValues(alpha: 0.28)
            : Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlight
              ? Colors.white.withValues(alpha: 0.6)
              : Colors.white.withValues(alpha: 0.2),
          width: 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              Icon(icon, size: 14, color: iconColor),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  count,
                  style: const TextStyle(
                    fontFamily: 'Hanken Grotesk',
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  'Unit',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVehicleFilterChip({
    required String key,
    required String label,
    required int count,
    required Color color,
  }) {
    final bool isSelected = _selectedVehicleFilter == key;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedVehicleFilter = key;
          _filterVehicles();
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : const Color(0xFFCBD5E1),
            width: 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : const Color(0xFF475569),
              ),
            ),
            const SizedBox(width: 5),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : const Color(0xFF64748B),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
