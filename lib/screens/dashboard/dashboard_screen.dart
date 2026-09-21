import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/booking_helper.dart';
import '../../utils/language_manager.dart';
import '../common/custom_bottom_nav.dart';
import 'widgets/dashboard_summary_card.dart';
import 'widgets/dashboard_booking_card.dart';
import 'widgets/booking_detail_sheet.dart';
import 'widgets/fleet_status_card.dart';

typedef DashboardScreen = AdminDashboardScreen;

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _bookings = [];
  List<Map<String, dynamic>> _filteredBookings = [];
  List<Map<String, dynamic>> _vehicles = [];
  bool _isLoading = true;

  final TextEditingController _searchController = TextEditingController();
  String _selectedFilterKey = 'all';

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
    _searchController.addListener(_filterData);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 1. QUERY SUPABASE (Filter Khusus Mobil Pegangan Admin)
  Future<void> _fetchDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("Sesi Admin tidak ditemukan, silakan login ulang.");

      final response = await supabase
          .from('bookings')
          .select('*, vehicles!inner(make_model, registration_no, admin_id)')
          .eq('vehicles.admin_id', user.id)
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> bookingsData = List<Map<String, dynamic>>.from(response);

      final profilesResponse = await supabase.from('profiles').select('id, full_name, employee_no');
      List<Map<String, dynamic>> profilesData = List<Map<String, dynamic>>.from(profilesResponse);

      for (var i = 0; i < bookingsData.length; i++) {
        final employeeId = bookingsData[i]['employee_id'];
        final matchedProfile = profilesData.where((p) => p['id'] == employeeId).toList();

        if (matchedProfile.isNotEmpty) {
          bookingsData[i]['profiles'] = matchedProfile.first;
        } else {
          bookingsData[i]['profiles'] = {'full_name': 'Karyawan Tidak Diketahui', 'employee_no': '-'};
        }
      }

      // Tarik data seluruh armada kendaraan
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

      if (mounted) {
        setState(() {
          _bookings = bookingsData;
          _filteredBookings = _bookings;
          _vehicles = vehiclesData;
          _isLoading = false;
        });
        _filterData();
      }
    } catch (e) {
      debugPrint('Error fetch Supabase: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error menarik data: $e'), backgroundColor: const Color(0xFFBB0016)),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  // 2. FUNGSI FILTER
  void _filterData() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredBookings = _bookings.where((item) {
        final vehicle = item['vehicles'] ?? {};
        final profile = item['profiles'] ?? {};

        final carName = (vehicle['make_model'] ?? '').toString().toLowerCase();
        final plate = (vehicle['registration_no'] ?? '').toString().toLowerCase();
        final driverName = (profile['full_name'] ?? '').toString().toLowerCase();
        final normalizedStatus = BookingHelper.normalizeStatus(item['status']);

        final matchesSearch = carName.contains(query) || plate.contains(query) || driverName.contains(query);

        if (_selectedFilterKey == 'pending') {
          return matchesSearch && normalizedStatus == 'pending';
        } else if (_selectedFilterKey == 'active') {
          return matchesSearch && normalizedStatus == 'active';
        } else if (_selectedFilterKey == 'completed') {
          return matchesSearch && normalizedStatus == 'completed';
        }
        return matchesSearch;
      }).toList();
    });
  }

  PreferredSizeWidget _buildAppBar() {
    final lm = LanguageManager.instance;
    return AppBar(
      elevation: 4,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      automaticallyImplyLeading: false,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F3567), Color(0xFFBB0016)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.business_rounded, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Container(width: 1, height: 24, color: Colors.white.withValues(alpha: 0.2)),
          const SizedBox(width: 12),
          Text(
            lm.t('dashboard_title'),
            style: const TextStyle(fontFamily: 'Hanken Grotesk', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lm = LanguageManager.instance;
    int pendingCount = _bookings.where((item) => BookingHelper.normalizeStatus(item['status']) == 'pending').length;
    int activeCount = _bookings.where((item) => BookingHelper.normalizeStatus(item['status']) == 'active').length;
    int completedCount = _bookings.where((item) => BookingHelper.normalizeStatus(item['status']) == 'completed').length;

    final filterItems = [
      {'key': 'all', 'label': lm.t('filter_all'), 'count': _bookings.length},
      {'key': 'pending', 'label': lm.t('filter_pending'), 'count': pendingCount},
      {'key': 'active', 'label': lm.t('filter_active'), 'count': activeCount},
      {'key': 'completed', 'label': lm.t('filter_completed'), 'count': completedCount},
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 0),
      body: RefreshIndicator(
        onRefresh: _fetchDashboardData,
        color: const Color(0xFFBB0016),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Title & Action (Dinamis & Responsif)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lm.t('dashboard_admin_title'),
                          style: const TextStyle(
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lm.t('dashboard_admin_subtitle'),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.refresh_rounded, color: Color(0xFF0F3567), size: 20),
                      tooltip: lm.t('refresh_tooltip'),
                      onPressed: _fetchDashboardData,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Kartu Summary (3 Status: Menunggu ACC, Sedang Dipakai, Selesai)
              Row(
                children: [
                  Expanded(
                    child: DashboardSummaryCard(
                      title: lm.t('filter_pending'),
                      count: pendingCount.toString(),
                      themeColor: const Color(0xFFD97706),
                      isSelected: _selectedFilterKey == 'pending',
                      onTap: () {
                        setState(() {
                          _selectedFilterKey = _selectedFilterKey == 'pending' ? 'all' : 'pending';
                          _filterData();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DashboardSummaryCard(
                      title: lm.t('filter_active'),
                      count: activeCount.toString(),
                      themeColor: const Color(0xFFBB0016),
                      isSelected: _selectedFilterKey == 'active',
                      onTap: () {
                        setState(() {
                          _selectedFilterKey = _selectedFilterKey == 'active' ? 'all' : 'active';
                          _filterData();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DashboardSummaryCard(
                      title: lm.t('filter_completed'),
                      count: completedCount.toString(),
                      themeColor: const Color(0xFF0F3567),
                      isSelected: _selectedFilterKey == 'completed',
                      onTap: () {
                        setState(() {
                          _selectedFilterKey = _selectedFilterKey == 'completed' ? 'all' : 'completed';
                          _filterData();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Status Armada & Ketersediaan Unit (Tersedia, Sedang Dipakai, Dalam Perbaikan)
              FleetStatusCard(
                vehicles: _vehicles,
                activeBookings: _bookings.where((item) =>
                    BookingHelper.normalizeStatus(item['status']) == 'active').toList(),
                onRefresh: _fetchDashboardData,
              ),

              // Search Bar
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
                  style: const TextStyle(fontSize: 13.5, color: Color(0xFF1E293B)),
                  decoration: InputDecoration(
                    hintText: lm.t('search_dashboard_hint'),
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
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
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
              const SizedBox(height: 12),

              // Filter Chips dengan Count Indikator
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: filterItems.map((filter) {
                    final filterKey = filter['key'] as String;
                    final filterName = filter['label'] as String;
                    final filterCount = filter['count'] as int;
                    bool isSelected = _selectedFilterKey == filterKey;

                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        showCheckmark: false,
                        label: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(filterName),
                            const SizedBox(width: 5),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.25)
                                    : const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                filterCount.toString(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected ? Colors.white : const Color(0xFF475569),
                                ),
                              ),
                            ),
                          ],
                        ),
                        selected: isSelected,
                        selectedColor: const Color(0xFF0F3567),
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : const Color(0xFF475569),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0),
                          ),
                        ),
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilterKey = filterKey;
                            _filterData();
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              // Section Heading: Data Peminjaman
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
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
                      Text(
                        lm.t('booking_data_title'),
                        style: const TextStyle(
                          fontFamily: 'Hanken Grotesk',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F3567).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_filteredBookings.length} ${lm.t('data_suffix')}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F3567),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // List View
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40.0),
                    child: CircularProgressIndicator(color: Color(0xFFBB0016)),
                  ),
                )
              else if (_filteredBookings.isEmpty)
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
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.inbox_outlined,
                          size: 28,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        lm.t('empty_bookings'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _searchController.text.isNotEmpty
                            ? 'Tidak ada hasil yang sesuai dengan "${_searchController.text}".'
                            : _selectedFilterKey != 'all'
                                ? 'Tidak ada data dengan filter ini.'
                                : lm.t('empty_bookings'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12.5,
                        ),
                      ),
                      if (_selectedFilterKey != 'all' || _searchController.text.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: () {
                            setState(() {
                              _selectedFilterKey = 'all';
                              _searchController.clear();
                              _filterData();
                            });
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Reset Filter'),
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
                  itemCount: _filteredBookings.length,
                  itemBuilder: (context, index) {
                    final item = _filteredBookings[index];
                    return TweenAnimationBuilder(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: Duration(milliseconds: 250 + (index * 80)),
                      curve: Curves.easeOutCubic,
                      builder: (context, double value, child) {
                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - value)),
                          child: Opacity(opacity: value, child: child),
                        );
                      },
                      child: DashboardBookingCard(
                        item: item,
                        onTap: () => BookingDetailSheet.show(
                          context,
                          item,
                          onStatusUpdated: _fetchDashboardData,
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}
