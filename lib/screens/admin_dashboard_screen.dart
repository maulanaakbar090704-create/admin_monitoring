import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'tracking_screen.dart';
import 'monitoring_screen.dart';
import 'history_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final supabase = Supabase.instance.client;
  final int _selectedIndex = 0; // Index 0 = Dashboard

  // Fungsi Query Super Aman
  Future<List<Map<String, dynamic>>> _fetchBookings() async {
    try {
      // Kita panggil tabel bookings polos tanpa join, dan urutkan pakai 'start_at'
      final response = await supabase
          .from('bookings')
          .select()
          .order('start_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fatal Supabase: $e');
      return [];
    }
  }

  // Fungsi Navigasi Universal
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
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => nextScreen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      bottomNavigationBar: _buildBottomNavBar(),
      
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFBB0016)));
          }

          final List<Map<String, dynamic>> bookings = snapshot.data ?? [];
          
          // Hitung otomatis (Kecuali statusnya "Selesai", kita anggap aktif)
          int activeCount = bookings.where((item) => item['status'] != 'Selesai').length;
          int completedCount = bookings.where((item) => item['status'] == 'Selesai').length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Dashboard Tim Kantor', style: TextStyle(fontFamily: 'Hanken Grotesk', fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF191C1D))),
                    Container(width: 40, height: 40, decoration: BoxDecoration(color: const Color(0xFFEDEEEF), borderRadius: BorderRadius.circular(999)), child: IconButton(icon: const Icon(Icons.filter_list, color: Color(0xFF191C1D)), onPressed: () {})),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildSummaryCard(true, activeCount.toString())),
                    const SizedBox(width: 16),
                    Expanded(child: _buildSummaryCard(false, completedCount.toString())),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Monitoring List', style: TextStyle(fontFamily: 'Hanken Grotesk', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191C1D))),
                    Row(children: const [Text('Lihat Semua', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFFBB0016))), SizedBox(width: 4), Icon(Icons.arrow_forward, size: 16, color: Color(0xFFBB0016))]),
                  ],
                ),
                const SizedBox(height: 16),

                if (bookings.isEmpty)
                  Container(width: double.infinity, padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), child: const Center(child: Text('Belum ada data peminjaman di database.', style: TextStyle(color: Color(0xFF5C403D)))))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final item = bookings[index];
                      return _buildListItem(item);
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 4, shadowColor: Colors.black.withOpacity(0.08), automaticallyImplyLeading: false,
      flexibleSpace: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Color(0xFF0F3567), Color(0xFFBB0016)], begin: Alignment.centerLeft, end: Alignment.centerRight))),
      title: Row(
        children: [
          Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Icon(Icons.business_rounded, color: Colors.white, size: 20)),
          const SizedBox(width: 12), Container(width: 1, height: 24, color: Colors.white.withOpacity(0.2)), const SizedBox(width: 12),
          const Text('Dashboard', style: TextStyle(fontFamily: 'Hanken Grotesk', fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
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
    );
  }

  Widget _buildSummaryCard(bool isActive, String count) {
    return Container(
      padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1))]), clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(top: -24, right: -24, child: Container(width: 64, height: 64, decoration: BoxDecoration(color: isActive ? const Color(0xFFBB0016).withOpacity(0.05) : const Color(0xFFD9E3F4).withOpacity(0.5), borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(64))))),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(width: 32, height: 32, decoration: BoxDecoration(color: isActive ? const Color(0xFFBB0016) : const Color(0xFFE1E3E4), shape: BoxShape.circle), child: Icon(isActive ? Icons.directions_car : Icons.check_circle, color: isActive ? Colors.white : const Color(0xFF5C403D), size: 18)),
                  const SizedBox(width: 8), Expanded(child: Text(isActive ? 'SEDANG DIPINJAM' : 'SELESAI HARI INI', style: const TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF5C403D)))),
                ],
              ),
              const SizedBox(height: 12),
              Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [Text(count, style: TextStyle(fontFamily: 'Hanken Grotesk', fontSize: 26, fontWeight: FontWeight.bold, color: isActive ? const Color(0xFFBB0016) : const Color(0xFF191C1D))), const SizedBox(width: 4), const Text('Kendaraan', style: TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF5C403D)))]),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(Map<String, dynamic> item) {
    // Mapping super aman (kalau relasi tabel gagal, ini nggak bakal bikin layar putih/crash)
    final carName = item['vehicle_id'] != null ? 'Mobil: ${item['vehicle_id'].toString().substring(0,5)}...' : 'Mobil Telkom';
    final driverName = item['employee_id'] != null ? 'Driver ID: ${item['employee_id'].toString().substring(0,5)}...' : 'Driver';
    final destination = item['destination'] ?? 'Tujuan Rahasia';
    final status = item['status'] ?? 'active';
    final isActive = status != 'Selesai'; 

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 1))]),
      child: Material(
        color: Colors.transparent, borderRadius: BorderRadius.circular(12),
        child: Opacity(
          opacity: isActive ? 1.0 : 0.8,
          child: Stack(
            children: [
              Positioned(right: 16, top: 0, bottom: 0, child: Center(child: Icon(Icons.chevron_right, color: const Color(0xFF5C403D).withOpacity(0.5)))),
              Padding(
                padding: const EdgeInsets.only(top: 16, left: 16, bottom: 16, right: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(carName, style: const TextStyle(fontFamily: 'Hanken Grotesk', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF191C1D))),
                            const SizedBox(height: 4),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: const Color(0xFFEDEEEF), borderRadius: BorderRadius.circular(4)), child: const Text('B XXXX XX', style: TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF5C403D)))),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: isActive ? const Color(0xFFFFC7C1).withOpacity(0.4) : const Color(0xFFE1E3E4), borderRadius: BorderRadius.circular(20)),
                          child: Text(isActive ? 'SEDANG DIPINJAM' : 'SELESAI', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.bold, color: isActive ? const Color(0xFF8E000E) : const Color(0xFF5C403D))),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12), const Divider(height: 1, color: Color(0xFFE1E3E4)), const SizedBox(height: 12),
                    Row(children: [const Icon(Icons.person, size: 16, color: Color(0xFF5C403D)), const SizedBox(width: 8), Expanded(child: Text(driverName, style: const TextStyle(fontSize: 14, color: Color(0xFF191C1D))))]),
                    const SizedBox(height: 8),
                    Row(children: [const Icon(Icons.pin_drop, size: 16, color: Color(0xFF5C403D)), const SizedBox(width: 8), Expanded(child: Text(destination, style: const TextStyle(fontSize: 14, color: Color(0xFF191C1D))))]),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}