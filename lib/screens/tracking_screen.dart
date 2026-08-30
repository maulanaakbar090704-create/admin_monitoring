import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'admin_dashboard_screen.dart';
import 'monitoring_screen.dart';
import 'history_screen.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  final int _selectedIndex = 1; 
  final supabase = Supabase.instance.client;

  final MapController _mapController = MapController();

  Position? _currentPosition;
  StreamSubscription<Position>? _positionStream;
  double _currentSpeed = 0.0; 
  double _maxSpeed = 0.0;     
  bool _isAutoTracking = true;

  LatLng _currentCenter = LatLng(-6.175110, 106.827152);

  @override
  void initState() {
    super.initState();
    _initGpsAndTracking();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  Future<void> _initGpsAndTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    
    if (permission == LocationPermission.deniedForever) return;

    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 2,
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings).listen(
      (Position position) {
        if (!mounted) return;

        setState(() {
          _currentPosition = position;
          _currentCenter = LatLng(position.latitude, position.longitude);
          
          _currentSpeed = position.speed * 3.6;
          if (_currentSpeed < 0) _currentSpeed = 0.0;
          if (_currentSpeed > _maxSpeed) {
            _maxSpeed = _currentSpeed;
          }
        });

        if (_isAutoTracking) {
          _mapController.move(_currentCenter, 17.5);
        }
      },
    );
  }

  void _recenterMap() {
    setState(() => _isAutoTracking = true);
    _mapController.move(_currentCenter, 17.5);
  }

  Future<List<Map<String, dynamic>>> _fetchActiveBookings() async {
    try {
      final response = await supabase
          .from('bookings')
          .select('*, vehicles(make_model, registration_no), profiles(full_name, phone_number)')
          .order('start_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('Error fetching tracking data: $e');
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
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) => nextScreen,
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }

  Future<void> _launchWA(String? phone) async {
    if (phone == null || phone.isEmpty) return;
    String formattedPhone = phone;
    if (formattedPhone.startsWith('0')) {
      formattedPhone = '62${formattedPhone.substring(1)}';
    }
    final Uri url = Uri.parse('https://wa.me/$formattedPhone');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint('Tidak dapat membuka WhatsApp');
    }
  }

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
            const Text('Live Tracking & Telemetri', style: TextStyle(fontFamily: 'Hanken Grotesk', fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchActiveBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFFBB0016)));
          }

          var activeBookings = snapshot.data ?? [];
          
          // MENCEGAH LAYAR KOSONG: Jika Supabase kosong, pakai data dummy sementara
          if (activeBookings.isEmpty) {
            activeBookings = [
              {
                'destination': 'Gedung Telkom Pusat',
                'vehicles': {'make_model': 'Avanza Telkom (Demo)', 'registration_no': 'B 1234 TKM'},
                'profiles': {'full_name': 'Driver Demo', 'phone_number': '081234567890'}
              }
            ];
          }

          return Stack(
            children: [
              Positioned.fill(
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _currentCenter,
                    zoom: 15.0,
                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture) {
                        setState(() => _isAutoTracking = false);
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.admin_monitoring_telkom',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentCenter,
                          width: 50,
                          height: 50,
                          builder: (context) => const Icon(
                            Icons.location_on,
                            color: Color(0xFFBB0016),
                            size: 45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (!_isAutoTracking)
                Positioned(
                  top: 80,
                  right: 16,
                  child: FloatingActionButton.small(
                    backgroundColor: Colors.white,
                    onPressed: _recenterMap,
                    child: const Icon(Icons.my_location, color: Color(0xFF0F3567)),
                  ),
                ),

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

              // DRAGGABLE SHEET SELALU MUNCUL SEKARANG
              DraggableScrollableSheet(
                initialChildSize: 0.42,
                minChildSize: 0.20,
                maxChildSize: 0.85,
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
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            width: 48, height: 5,
                            decoration: BoxDecoration(color: const Color(0xFFE1E3E4), borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        
                        Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  const Text('KECEPATAN SAAT INI', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Text('${_currentSpeed.toStringAsFixed(1)} km/h', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: _currentSpeed > 60 ? Colors.red : const Color(0xFF0F3567))),
                                ],
                              ),
                              Container(width: 1, height: 30, color: Colors.grey.shade300),
                              Column(
                                children: [
                                  const Text('TOP SPEED (MAKS)', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Text('${_maxSpeed.toStringAsFixed(1)} km/h', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFFBB0016))),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Expanded(
                          child: ListView.builder(
                            controller: scrollController,
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
                                            onPressed: () {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => const HistoryScreen()));
                                            },
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