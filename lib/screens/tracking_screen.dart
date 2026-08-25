import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart'; // Package buat buka WA & Maps
import 'admin_dashboard_screen.dart';
import 'monitoring_screen.dart';
import 'history_screen.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final int _selectedIndex = 1; // Index 1 = Tracking
  final supabase = Supabase.instance.client;

  // Fungsi untuk ambil data HANYA yang SEDANG DIPINJAM (active)
  Future<List<Map<String, dynamic>>> _fetchActiveBookings() async {
    try {
      final response = await supabase
          .from('bookings')
          .select() // Hapus tulisan panjang di dalam select() biar aman
          .order('start_at', ascending: false); // Pakai start_at
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching tracking data: $e');
      return [];
    }
  }

  // Fungsi navigasi Navbar Universal (Biar nggak kedip dan akurat)
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    Widget nextScreen;
    switch (index) {
      case 0:
        nextScreen = const AdminDashboardScreen();
        break;
      case 1:
        nextScreen = const TrackingScreen();
        break;
      case 2:
        nextScreen = const MonitoringScreen();
        break;
      case 3:
        nextScreen = const HistoryScreen();
        break;
      default:
        return;
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

  // Fungsi Buka WhatsApp
  Future<void> _launchWA(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    
    // Format nomor HP ke format internasional WA (ganti awalan 0 jadi 62)
    String formattedPhone = phone;
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '62${formattedPhone.substring(1)}';
    }
    
    final Uri url = Uri.parse('https://wa.me/$formattedPhone');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Tidak dapat membuka WhatsApp');
    }
  }

  // Fungsi Buka Google Maps
  Future<void> _launchMaps(String? destination) async {
    final query = destination ?? 'Telkom Indonesia';
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Tidak dapat membuka Google Maps');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      
      // --- APP BAR ---
      appBar: AppBar(
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.08),
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
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.explore, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Tracking', style: TextStyle(fontFamily: 'Hanken Grotesk', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_outlined, color: Colors.white), onPressed: () {}),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.2),
              backgroundImage: const NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuB3gv5lyQbE3v1zuGLRFxEmDCNvVRallpivUIpVuBXmd2V3paDa8UflN7A7x7pK67Rgjs8Fdid2i0B6xP7VBz9ia_rRqPz1r-I48SbcuyUDVgkUD50Dfr2mL58NPssBKNQDrY2YGUO7hbHx0XMiF5ZD2kIXGOXyavtXOeaYUBeZ4qBYbDAulHJcVqbTXy89KNZm2sYyJOgWzlt-G8IMySO_Q1-XIC0EX36z5mnV5XZPPesqTO1JCeY'),
            ),
          ),
        ],
      ),

      // --- NAVBAR BAWAH ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -2))]),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedItemColor: const Color(0xFFBB0016),
          unselectedItemColor: const Color(0xFF254779),
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
            BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Tracking'),
            BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Monitoring'),
            BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
      ),

      // --- BODY UTAMA ---
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchActiveBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFBB0016)));
          }

          final activeBookings = snapshot.data ?? [];
          final bool hasActiveBookings = activeBookings.isNotEmpty;

          return Stack(
            children: [
              // 1. Latar Belakang Peta 
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuDBlXuu7gX6e89Hss97iVrDXraAr8s9lPsnjWaCIh1GG6j_uFuQu-9HjVf5bdl2Cp4Z1wzkx8NqKXBx_xRGYS9kPvYvVxXIHt0RtalgNu22QCRZIxVwfy0MxJ3Nw_abZ9R_G7H0DJh0sW74Mjx45Kx8yCtczdKUSgx46QDUCc9ZDLUk6hFqQ6GoKoOg03RT7t_v5NIpxZbUg2LK5bEUmEEBaMICFYl3YO3chNjjFjY4K6khX55WVTo'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Container(color: Colors.black.withOpacity(0.1)), 
                ),
              ),

              // 2. Kotak Pencarian Floating
              Positioned(
                top: 16, left: 16, right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(999),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))],
                    border: Border.all(color: const Color(0xFFE1E3E4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Color(0xFF5C403D)),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: TextField(
                          decoration: InputDecoration(hintText: 'Cari Kendaraan atau Driver', hintStyle: TextStyle(color: Color(0xFF5C403D), fontSize: 14), border: InputBorder.none),
                        ),
                      ),
                      Container(
                        width: 32, height: 32,
                        decoration: const BoxDecoration(color: Color(0xFFEDEEEF), shape: BoxShape.circle),
                        child: IconButton(padding: EdgeInsets.zero, icon: const Icon(Icons.mic, size: 18, color: Color(0xFF5C403D)), onPressed: () {}),
                      ),
                    ],
                  ),
                ),
              ),

              // 3. Pin Peta di Tengah (Hanya muncul jika ada armada aktif)
              if (hasActiveBookings)
                Center(
                  child: Stack(
                    clipBehavior: Clip.none,
                    alignment: Alignment.center,
                    children: [
                      Container(width: 90, height: 90, decoration: BoxDecoration(color: const Color(0xFFBB0016).withOpacity(0.15), shape: BoxShape.circle)),
                      Container(width: 50, height: 50, decoration: BoxDecoration(color: const Color(0xFFBB0016).withOpacity(0.3), shape: BoxShape.circle)),
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: const Color(0xFFBB0016), width: 2), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 6)]),
                        child: const Icon(Icons.directions_car, color: Color(0xFFBB0016), size: 18),
                      ),
                      Positioned(
                        top: -55,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 4))]),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(activeBookings[0]['vehicles']?['make_model'] ?? 'Mobil Aktif', style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF191C1D))),
                              Text(activeBookings[0]['vehicles']?['registration_no'] ?? 'B XXXX', style: const TextStyle(fontFamily: 'Inter', fontSize: 10, color: Color(0xFF5C403D))),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // 4. Panel Bawah Bisa Ditarik (Hanya muncul jika ada armada aktif)
              if (hasActiveBookings)
                DraggableScrollableSheet(
                  initialChildSize: 0.35, // Ukuran awal saat layar dibuka
                  minChildSize: 0.15, // Bisa digeser ke bawah sampai segini
                  maxChildSize: 0.8, // Bisa ditarik full ke atas
                  builder: (BuildContext context, ScrollController scrollController) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20, offset: Offset(0, -5))],
                      ),
                      child: Column(
                        children: [
                          // Handle Bar (Tanda buat narik)
                          Center(
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 16),
                              width: 48, height: 5,
                              decoration: BoxDecoration(color: const Color(0xFFE1E3E4), borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                          
                          // List Kendaraan Aktif
                          Expanded(
                            child: ListView.builder(
                              controller: scrollController, // Penting biar bisa di-scroll
                              itemCount: activeBookings.length,
                              itemBuilder: (context, index) {
                                final item = activeBookings[index];
                                final vehicle = item['vehicles'] ?? {};
                                final profile = item['profiles'] ?? {};
                                final phone = profile['phone_number'];
                                final destination = item['destination'];

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 24),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Header Mobil & Status
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                vehicle['make_model'] ?? 'Mobil Telkom',
                                                style: const TextStyle(fontFamily: 'Hanken Grotesk', fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF191C1D)),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(vehicle['registration_no'] ?? 'B XXXX XX', style: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF5C403D))),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(color: const Color(0xFFFFDAD6), borderRadius: BorderRadius.circular(20)),
                                            child: const Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(Icons.key, size: 14, color: Color(0xFF93000A)),
                                                SizedBox(width: 4),
                                                Text('Sedang Dipinjam', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF93000A))),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),

                                      // Info Driver & Action Buttons (WA)
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(color: const Color(0xFFF3F4F5), borderRadius: BorderRadius.circular(12)),
                                        child: Row(
                                          children: [
                                            const CircleAvatar(
                                              radius: 24,
                                              backgroundColor: Color(0xFFD6E3FF),
                                              child: Icon(Icons.person, color: Color(0xFF254779)),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text('DRIVER SAAT INI', style: TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF5C403D))),
                                                  const SizedBox(height: 2),
                                                  Text(profile['full_name'] ?? 'Driver', style: const TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF191C1D))),
                                                ],
                                              ),
                                            ),
                                            // Tombol WhatsApp Hijau
                                            InkWell(
                                              onTap: () => _launchWA(phone),
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                decoration: BoxDecoration(color: const Color(0xFF25D366), borderRadius: BorderRadius.circular(20)),
                                                child: const Row(
                                                  children: [
                                                    Icon(Icons.chat, color: Colors.white, size: 18),
                                                    SizedBox(width: 6),
                                                    Text('WA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // Bottom Action Buttons (Riwayat & Rute Maps)
                                      Row(
                                        children: [
                                          Expanded(
                                            child: OutlinedButton.icon(
                                              style: OutlinedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                                side: const BorderSide(color: Color(0xFFE1E3E4)),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                              icon: const Icon(Icons.history, color: Color(0xFFBB0016), size: 20),
                                              label: const Text('Riwayat', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFBB0016))),
                                              onPressed: () {},
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(0xFFBB0016),
                                                foregroundColor: Colors.white,
                                                padding: const EdgeInsets.symmetric(vertical: 14),
                                                elevation: 0,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                              ),
                                              icon: const Icon(Icons.directions, size: 20),
                                              label: const Text('Rute', style: TextStyle(fontWeight: FontWeight.bold)),
                                              onPressed: () => _launchMaps(destination),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 32, thickness: 1, color: Color(0xFFE1E3E4)),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}