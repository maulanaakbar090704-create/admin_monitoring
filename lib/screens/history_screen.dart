import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_dashboard_screen.dart';
import 'tracking_screen.dart';
import 'monitoring_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final supabase = Supabase.instance.client;
  String _selectedFilter = 'Semua';
  final int _selectedIndex = 3; // Index 3 = History

  // Fungsi Query Super Aman
  Future<List<Map<String, dynamic>>> _fetchHistory() async {
    try {
      final response = await supabase
          .from('bookings')
          .select()
          .order('start_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetch history: $e');
      return [];
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;
    Widget nextScreen;
    switch (index) {
      case 0: nextScreen = const AdminDashboardScreen(); break;
      case 1: nextScreen = const TrackingScreen(); break;
      case 2: nextScreen = const MonitoringScreen(); break;
      case 3: nextScreen = const HistoryScreen(); break;
      default: return;
    }
    Navigator.pushReplacement(context, PageRouteBuilder(pageBuilder: (context, a1, a2) => nextScreen, transitionDuration: Duration.zero, reverseTransitionDuration: Duration.zero));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        elevation: 4, shadowColor: Colors.black.withOpacity(0.08), automaticallyImplyLeading: false,
        flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F3567), Color(0xFFBB0016)], begin: Alignment.centerLeft, end: Alignment.centerRight))),
        title: Row(
          children: [
            Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.history, color: Colors.white, size: 20)),
            const SizedBox(width: 12), const Text('History', style: TextStyle(fontFamily: 'Hanken Grotesk', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))]),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex, onTap: _onItemTapped, type: BottomNavigationBarType.fixed, backgroundColor: Colors.white, elevation: 0,
          selectedItemColor: const Color(0xFFBB0016), unselectedItemColor: const Color(0xFF254779), selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11), unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Tracking'),
            BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Monitoring'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Semua'), const SizedBox(width: 8), _buildFilterChip('Sedang Dipinjam'), const SizedBox(width: 8), _buildFilterChip('Selesai'),
                ],
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _fetchHistory(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: Color(0xFFBB0016)));
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('Belum ada riwayat peminjaman.', style: TextStyle(color: Color(0xFF5C403D))));

                var bookings = snapshot.data!;
                if (_selectedFilter == 'Sedang Dipinjam') {
                  bookings = bookings.where((item) => item['status'] != 'Selesai').toList();
                } else if (_selectedFilter == 'Selesai') {
                  bookings = bookings.where((item) => item['status'] == 'Selesai').toList();
                }

                if (bookings.isEmpty) return const Center(child: Text('Tidak ada data untuk filter ini.', style: TextStyle(color: Color(0xFF5C403D))));

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: bookings.length,
                  itemBuilder: (context, index) {
                    final item = bookings[index];
                    final carName = item['vehicle_id'] != null ? 'Mobil: ${item['vehicle_id'].toString().substring(0,5)}...' : 'Mobil Telkom';
                    final driverName = item['employee_id'] != null ? 'Driver ID: ${item['employee_id'].toString().substring(0,5)}...' : 'Driver';
                    final destination = item['destination'] ?? 'Tujuan';
                    final status = item['status'] ?? 'active';
                    final isActive = status != 'Selesai';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8, offset: const Offset(0, 2))]),
                      clipBehavior: Clip.antiAlias,
                      child: Stack(
                        children: [
                          Positioned(left: 0, top: 0, bottom: 0, width: 4, child: Container(color: isActive ? const Color(0xFFBB0016) : const Color(0xFFE1E3E4))),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(carName, style: const TextStyle(fontFamily: 'Hanken Grotesk', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF191C1D))), const SizedBox(height: 2), const Text('B XXXX XX', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Color(0xFF5C403D)))]),
                                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: isActive ? const Color(0xFFFFDAD6) : const Color(0xFFE1E3E4), borderRadius: BorderRadius.circular(4)), child: Text(isActive ? 'SEDANG DIPINJAM' : 'SELESAI', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? const Color(0xFF93000A) : const Color(0xFF5C403D), letterSpacing: 0.05))),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Column(
                                  children: [
                                    Row(children: [const Icon(Icons.person_outline, size: 16, color: Color(0xFF5C403D)), const SizedBox(width: 8), Text(driverName, style: const TextStyle(fontSize: 13, color: Color(0xFF5C403D)))]), const SizedBox(height: 6),
                                    Row(children: [const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF5C403D)), const SizedBox(width: 8), Expanded(child: Text(destination, style: const TextStyle(fontSize: 13, color: Color(0xFF5C403D)), overflow: TextOverflow.ellipsis))]),
                                  ],
                                ),
                                const Divider(height: 24, thickness: 1, color: Color(0xFFE1E3E4)),
                                InkWell(onTap: () {}, child: const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Lihat Detail', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFFBB0016))), Icon(Icons.chevron_right, size: 18, color: Color(0xFFBB0016))])),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String title) {
    bool isSelected = _selectedFilter == title;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: isSelected ? const Color(0xFFD6E3FF) : const Color(0xFFEDEEEF), borderRadius: BorderRadius.circular(20)),
        child: Text(title, style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold, color: isSelected ? const Color(0xFF001B3E) : const Color(0xFF5C403D))),
      ),
    );
  }
}