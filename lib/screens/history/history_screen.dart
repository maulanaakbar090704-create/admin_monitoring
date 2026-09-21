import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../utils/booking_helper.dart';
import '../../utils/language_manager.dart';
import '../common/custom_bottom_nav.dart';
import 'widgets/history_card.dart';
import 'widgets/history_detail_sheet.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _allBookings = [];
  List<Map<String, dynamic>> _filteredBookings = [];
  bool _isLoading = true;
  String _selectedFilterKey = 'all';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchHistory();
    _searchController.addListener(_applyFilter);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchHistory() async {
    setState(() => _isLoading = true);

    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      // Query bookings khusus untuk kendaraan pegangan admin ini
      final response = await supabase
          .from('bookings')
          .select('*, vehicles!inner(make_model, registration_no, admin_id)')
          .eq('vehicles.admin_id', user.id)
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> bookingsData = List<Map<String, dynamic>>.from(response);

      // Fetch profiles untuk melengkapi nama & NIK peminjam
      final profilesResponse = await supabase.from('profiles').select('id, full_name, employee_no');
      List<Map<String, dynamic>> profilesData = List<Map<String, dynamic>>.from(profilesResponse);

      for (var i = 0; i < bookingsData.length; i++) {
        final employeeId = bookingsData[i]['employee_id'];
        final matchedProfile = profilesData.where((p) => p['id'] == employeeId).toList();

        if (matchedProfile.isNotEmpty) {
          bookingsData[i]['profiles'] = matchedProfile.first;
        } else {
          bookingsData[i]['profiles'] = {'full_name': 'Karyawan', 'employee_no': '-'};
        }
      }

      if (mounted) {
        setState(() {
          _allBookings = bookingsData;
          _isLoading = false;
        });
        _applyFilter();
      }
    } catch (e) {
      debugPrint('Error fetch history: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error memuat riwayat: $e'), backgroundColor: const Color(0xFFBB0016)),
        );
      }
    }
  }

  void _applyFilter() {
    final query = _searchController.text.toLowerCase();

    setState(() {
      _filteredBookings = _allBookings.where((item) {
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

  @override
  Widget build(BuildContext context) {
    final lm = LanguageManager.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
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
              child: const Icon(Icons.history, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              lm.t('history_title'),
              style: const TextStyle(
                fontFamily: 'Hanken Grotesk',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchHistory,
            tooltip: lm.t('refresh_tooltip'),
          ),
        ],
      ),
      bottomNavigationBar: const AdminBottomNav(currentIndex: 2),
      body: RefreshIndicator(
        onRefresh: _fetchHistory,
        color: const Color(0xFFBB0016),
        child: Column(
          children: [
            // Search Bar & Filter Chips Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                children: [
                  // Search
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: lm.t('search_history_hint'),
                      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                      prefixIcon: const Icon(Icons.search, size: 20, color: Color(0xFF0F3567)),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                FocusScope.of(context).unfocus();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF8F9FA),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips (Semua, Pending, Sedang Dipakai, Selesai)
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('all', lm.t('filter_all')),
                        const SizedBox(width: 8),
                        _buildFilterChip('pending', lm.t('filter_pending')),
                        const SizedBox(width: 8),
                        _buildFilterChip('active', lm.t('filter_active')),
                        const SizedBox(width: 8),
                        _buildFilterChip('completed', lm.t('filter_completed')),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // List Content
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: Color(0xFFBB0016)),
                    )
                  : _filteredBookings.isEmpty
                      ? ListView(
                          children: [
                            const SizedBox(height: 80),
                            Center(
                              child: Column(
                                children: [
                                  const Icon(Icons.history_outlined, size: 48, color: Colors.grey),
                                  const SizedBox(height: 12),
                                  Text(
                                    lm.t('empty_history'),
                                    style: const TextStyle(color: Color(0xFF5C403D), fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredBookings.length,
                          itemBuilder: (context, index) {
                            final item = _filteredBookings[index];
                            return HistoryCard(
                              item: item,
                              onTap: () => HistoryDetailSheet.show(
                                context,
                                item,
                                onStatusUpdated: _fetchHistory,
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String key, String title) {
    bool isSelected = _selectedFilterKey == key;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterKey = key;
          _applyFilter();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0F3567) : const Color(0xFFEDEEEF),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : const Color(0xFF5C403D),
          ),
        ),
      ),
    );
  }
}
