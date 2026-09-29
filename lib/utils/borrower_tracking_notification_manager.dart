import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../screens/history/history_screen.dart';
import '../screens/tracking/tracking_map_page.dart';

/// Pengelola Notifikasi Otomatis untuk:
/// 1. Notifikasi berkala pemantauan lokasi peminjam (tiap 30 menit, format nama lokasi manusia, bukan lat/lng).
/// 2. Notifikasi pop-up pengajuan peminjaman baru (ACC) ketika ada karyawan yang ingin meminjam kendaraan.
class BorrowerTrackingNotificationManager {
  static final BorrowerTrackingNotificationManager instance =
      BorrowerTrackingNotificationManager._internal();

  BorrowerTrackingNotificationManager._internal();

  Timer? _periodicTimer;
  Timer? _pendingBookingCheckTimer;
  RealtimeChannel? _realtimeChannel;
  BuildContext? _currentContext;
  bool _isInitialized = false;

  // Catat ID booking pending yang sudah pernah dimunculkan notifikasinya agar tidak spam
  final Set<String> _notifiedPendingBookingIds = {};

  // Cache reverse geocoding agar hemat request
  final Map<String, String> _addressCache = {};

  void setContext(BuildContext context) {
    _currentContext = context;
  }

  /// Inisialisasi timer otomatis & realtime listener
  void init(BuildContext context) {
    _currentContext = context;
    if (_isInitialized) return;
    _isInitialized = true;

    // 1. Timer berkala pemantauan posisi setiap 30 menit
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(minutes: 30), (_) {
      checkAndTriggerPeriodicNotification();
    });

    // 2. Timer pengecekan peminjaman pending (ACC) berkala setiap 45 detik
    _pendingBookingCheckTimer?.cancel();
    _pendingBookingCheckTimer = Timer.periodic(const Duration(seconds: 45), (_) {
      checkPendingBookingsAndNotify();
    });

    // 3. Pengecekan awal saat baru masuk dashboard (jika ada pengajuan yang belum di-ACC)
    Future.delayed(const Duration(seconds: 2), () {
      checkPendingBookingsAndNotify();
    });

    // 4. Supabase Realtime Listener untuk tabel bookings
    _setupRealtimeListener();

    debugPrint('BorrowerTrackingNotificationManager: Timer 30 menit & Listener ACC aktif.');
  }

  void _setupRealtimeListener() {
    try {
      final supabase = Supabase.instance.client;
      _realtimeChannel?.unsubscribe();
      _realtimeChannel = supabase.channel('admin_booking_acc_channel')
        ..onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'bookings',
          callback: (payload) {
            final record = payload.newRecord;
            final status = (record['status'] ?? '').toString().toLowerCase();
            if (status == 'pending') {
              checkPendingBookingsAndNotify();
            }
          },
        )
        ..subscribe();
    } catch (e) {
      debugPrint('Realtime listener booking error: $e');
    }
  }

  void dispose() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    _pendingBookingCheckTimer?.cancel();
    _pendingBookingCheckTimer = null;
    _realtimeChannel?.unsubscribe();
    _realtimeChannel = null;
    _isInitialized = false;
  }

  // =========================================================================
  // 1. FITUR NOTIFIKASI ACC PEMINJAMAN KENDARAAN (PENGAJUAN BARU OLEH KARYAWAN)
  // =========================================================================
  Future<void> checkPendingBookingsAndNotify({bool forceShowFirst = false}) async {
    final context = _currentContext;
    if (context == null || !context.mounted) return;

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      // Ambil peminjaman yang berstatus 'pending' untuk admin ini
      final res = await supabase
          .from('bookings')
          .select('*, vehicles!inner(make_model, registration_no, admin_id)')
          .eq('status', 'pending')
          .eq('vehicles.admin_id', user.id)
          .order('created_at', ascending: false)
          .limit(5);

      final List<Map<String, dynamic>> pendingList = List<Map<String, dynamic>>.from(res);
      if (pendingList.isEmpty) {
        if (forceShowFirst && context.mounted) {
          // Demo preview notifikasi ACC jika belum ada pengajuan pending di database
          await showBookingApprovalNotificationPopup(
            context,
            booking: {
              'id': 'demo-acc-sample',
              'destination': 'Jakarta Utara',
              'purpose': 'Pemeliharaan Jaringan & Kunjungan Lapangan',
              'borrow_date': 'Hari ini, 15:30 WIB',
              'profiles': {
                'full_name': 'Deden Pratama',
                'employee_no': 'NIK-882910',
              },
              'vehicles': {
                'make_model': 'Toyota Avanza',
                'registration_no': 'B 1966 HZU',
              },
            },
          );
        }
        return;
      }

      for (final booking in pendingList) {
        final bookingId = booking['id']?.toString() ?? '';
        if (bookingId.isEmpty) continue;

        // Cek apakah booking ini sudah pernah dimunculkan pop-up nya
        if (_notifiedPendingBookingIds.contains(bookingId) && !forceShowFirst) {
          continue;
        }

        // Ambil profil karyawan peminjam
        final employeeId = booking['employee_id'];
        if (employeeId != null) {
          final profileRes = await supabase
              .from('profiles')
              .select('full_name, employee_no')
              .eq('id', employeeId)
              .maybeSingle();
          if (profileRes != null) {
            booking['profiles'] = profileRes;
          }
        }

        _notifiedPendingBookingIds.add(bookingId);

        if (context.mounted) {
          await showBookingApprovalNotificationPopup(context, booking: booking);
        }

        // Tampilkan 1 pop-up saja per siklus agar tidak menumpuk
        break;
      }
    } catch (e) {
      debugPrint('Error check pending bookings: $e');
    }
  }

  /// Menampilkan Pop-Up Notifikasi Pengajuan ACC Peminjaman di Layar HP
  Future<void> showBookingApprovalNotificationPopup(
    BuildContext context, {
    required Map<String, dynamic> booking,
  }) async {
    // Efek getar notifikasi di HP
    try {
      HapticFeedback.heavyImpact();
    } catch (_) {}

    final profile = booking['profiles'] ?? {};
    final vehicle = booking['vehicles'] ?? {};

    final borrowerName = (profile['full_name'] ?? 'Karyawan Peminjam').toString();
    final borrowerNik = (profile['employee_no'] ?? '-').toString();
    final makeModel = (vehicle['make_model'] ?? 'Kendaraan Operasional').toString();
    final plate = (vehicle['registration_no'] ?? booking['plat_nomor'] ?? '-').toString();
    final destination = (booking['destination'] ?? 'Wilayah Operasional').toString();
    final purpose = (booking['purpose'] ?? 'Keperluan Dinas / Operasional').toString();
    final borrowDate = (booking['borrow_date'] ?? '-').toString();
    final bookingId = (booking['id'] ?? '').toString();

    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
          elevation: 12,
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header: Badge Pengajuan Baru (ACC)
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(9),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFBB0016), Color(0xFFD97706)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFBB0016).withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.pending_actions_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pengajuan Peminjaman Baru (ACC)',
                            style: TextStyle(
                              fontFamily: 'Hanken Grotesk',
                              fontSize: 15.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Pemberitahuan Persetujuan Kendaraan',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Banner Pesan Persis Permintaan User:
                // "Ada karyawan yang ingin meminjam, ayok periksa status data nya sekarang!"
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7), // Amber Light
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF59E0B)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline_rounded, color: Color(0xFFD97706), size: 20),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Ada karyawan yang ingin meminjam, ayok periksa status data nya sekarang!',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF92400E),
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Card Rincian Peminjam & Kendaraan
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      _buildDetailRow(
                        icon: Icons.person_rounded,
                        label: 'Peminjam',
                        value: '$borrowerName (NIK: $borrowerNik)',
                        isBold: true,
                        valueColor: const Color(0xFF0F172A),
                      ),
                      const Divider(height: 14, thickness: 0.6, color: Color(0xFFE2E8F0)),
                      _buildDetailRow(
                        icon: Icons.directions_car_rounded,
                        label: 'Armada',
                        value: '$makeModel ($plate)',
                        isBold: true,
                        valueColor: const Color(0xFF0F3567),
                      ),
                      const Divider(height: 14, thickness: 0.6, color: Color(0xFFE2E8F0)),
                      _buildDetailRow(
                        icon: Icons.place_rounded,
                        label: 'Tujuan',
                        value: destination,
                        valueColor: const Color(0xFF334155),
                      ),
                      const Divider(height: 14, thickness: 0.6, color: Color(0xFFE2E8F0)),
                      _buildDetailRow(
                        icon: Icons.notes_rounded,
                        label: 'Keperluan',
                        value: purpose,
                        valueColor: const Color(0xFF334155),
                      ),
                      if (borrowDate.isNotEmpty && borrowDate != '-') ...[
                        const Divider(height: 14, thickness: 0.6, color: Color(0xFFE2E8F0)),
                        _buildDetailRow(
                          icon: Icons.calendar_today_rounded,
                          label: 'Tgl Pengajuan',
                          value: borrowDate,
                          valueColor: const Color(0xFF64748B),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Tombol Aksi
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        onPressed: () => Navigator.pop(dialogCtx),
                        child: const Text(
                          'Nanti Saja',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F3567),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 16),
                        label: const Text(
                          'Periksa & ACC',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
                        ),
                        onPressed: () {
                          Navigator.pop(dialogCtx);
                          // Buka langsung layar Riwayat dengan tab 'pending' aktif
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => HistoryScreen(
                                initialFilter: 'pending',
                                targetBookingId: bookingId,
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
        );
      },
    );
  }

  static Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF64748B)),
        const SizedBox(width: 8),
        SizedBox(
          width: 85,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const Text(': ', style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: valueColor ?? const Color(0xFF1E293B),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // =========================================================================
  // 2. FITUR NOTIFIKASI BERKALA LOKASI PEMINJAM (SETIAP 30 MENIT)
  // =========================================================================
  Future<void> checkAndTriggerPeriodicNotification() async {
    final context = _currentContext;
    if (context == null || !context.mounted) return;

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) return;

      final res = await supabase
          .from('bookings')
          .select('*, vehicles!inner(make_model, registration_no, admin_id)')
          .eq('status', 'active')
          .eq('vehicles.admin_id', user.id)
          .order('created_at', ascending: false)
          .limit(1);

      final List<Map<String, dynamic>> activeList = List<Map<String, dynamic>>.from(res);
      if (activeList.isEmpty) return;

      final booking = activeList.first;

      final employeeId = booking['employee_id'];
      if (employeeId != null) {
        final profileRes = await supabase
            .from('profiles')
            .select('full_name, employee_no')
            .eq('id', employeeId)
            .maybeSingle();
        if (profileRes != null) {
          booking['profiles'] = profileRes;
        }
      }

      if (context.mounted) {
        await showTrackingNotificationPopup(context, booking: booking);
      }
    } catch (e) {
      debugPrint('Error periodic tracking notification: $e');
    }
  }

  Future<String> resolveReadableLocation({
    required double? lat,
    required double? lng,
    String? fallbackDestination,
  }) async {
    if (lat == null || lng == null) {
      return (fallbackDestination != null && fallbackDestination.trim().isNotEmpty)
          ? fallbackDestination.trim()
          : 'Jakarta Utara';
    }

    final cacheKey = '${lat.toStringAsFixed(3)},${lng.toStringAsFixed(3)}';
    if (_addressCache.containsKey(cacheKey)) {
      return _addressCache[cacheKey]!;
    }

    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 4);
      final request = await client.getUrl(Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lng&zoom=14&addressdetails=1',
      ));
      request.headers.set('User-Agent', 'AdminMonitoringApp/1.0');
      final response = await request.close().timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final data = jsonDecode(body);
        final address = data['address'] as Map<String, dynamic>? ?? {};

        final district = address['city_district'] ??
            address['suburb'] ??
            address['county'] ??
            address['city'] ??
            address['town'] ??
            address['village'];
        final city = address['city'] ?? address['state'] ?? '';

        String result = '';
        if (district != null && city.isNotEmpty && district != city) {
          result = '$district, $city';
        } else if (district != null) {
          result = district.toString();
        } else if (city.isNotEmpty) {
          result = city.toString();
        } else {
          result = data['display_name']?.toString().split(',').take(2).join(',') ??
              (fallbackDestination ?? 'Jakarta Utara');
        }

        _addressCache[cacheKey] = result;
        return result;
      }
    } catch (e) {
      debugPrint('Reverse geocode error: $e');
    }

    if (fallbackDestination != null && fallbackDestination.trim().isNotEmpty) {
      return fallbackDestination.trim();
    }
    return 'Jakarta Utara';
  }

  /// Menampilkan Pop-Up Notifikasi Pemantauan Posisi di Layar HP
  Future<void> showTrackingNotificationPopup(
    BuildContext context, {
    required Map<String, dynamic> booking,
  }) async {
    try {
      HapticFeedback.vibrate();
    } catch (_) {}

    final profile = booking['profiles'] ?? {};
    final vehicle = booking['vehicles'] ?? {};

    final borrowerName = (profile['full_name'] ?? 'Peminjam').toString();
    final makeModel = (vehicle['make_model'] ?? 'Kendaraan Operasional').toString();
    final plate = (vehicle['registration_no'] ?? booking['plat_nomor'] ?? '').toString();

    final double? lat = (booking['latitude'] as num?)?.toDouble();
    final double? lng = (booking['longitude'] as num?)?.toDouble();
    final double speed = (booking['kecepatan'] as num?)?.toDouble() ?? 0.0;
    final String destination = (booking['destination'] ?? '').toString();

    final String locationName = await resolveReadableLocation(
      lat: lat,
      lng: lng,
      fallbackDestination: destination.isNotEmpty ? destination : 'Jakarta Utara',
    );

    final now = DateTime.now();
    final String timeFormatted =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} WIB';

    final String speedText = speed > 0
        ? '${speed.toStringAsFixed(0)} km/jam'
        : '0 km/jam (Berhenti / Parkir)';

    final String notificationMessage =
        '$borrowerName berada di lokasi $locationName dengan kecepatan $speedText pada jam $timeFormatted';

    if (!context.mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogCtx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          backgroundColor: Colors.white,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF0F3567), Color(0xFFBB0016)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.notifications_active_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pantau Akses Kendaraan Anda',
                            style: TextStyle(
                              fontFamily: 'Hanken Grotesk',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Notifikasi Pemantauan Berkala (30 Menit)',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFFCA5A5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Color(0xFFDC2626),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              notificationMessage,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF991B1B),
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFFFECACA)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.directions_car_rounded, size: 14, color: Color(0xFF0F3567)),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                '$makeModel ${plate.isNotEmpty ? "($plate)" : ""}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1E293B),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF64748B),
                          side: const BorderSide(color: Color(0xFFCBD5E1)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        onPressed: () => Navigator.pop(dialogCtx),
                        child: const Text(
                          'Tutup',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F3567),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 11),
                        ),
                        icon: const Icon(Icons.map_rounded, size: 16),
                        label: const Text(
                          'Lihat di Peta',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        onPressed: () {
                          Navigator.pop(dialogCtx);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (ctx) => TrackingMapPage(
                                targetPlateNumber: plate,
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
        );
      },
    );
  }
}
