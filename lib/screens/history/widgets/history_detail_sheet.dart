import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../utils/booking_helper.dart';
import '../../../utils/language_manager.dart';
import '../../../widgets/photo_preview_widget.dart';

class HistoryDetailSheet extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onStatusUpdated;

  const HistoryDetailSheet({
    super.key,
    required this.item,
    this.onStatusUpdated,
  });

  static void show(BuildContext context, Map<String, dynamic> item, {VoidCallback? onStatusUpdated}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => HistoryDetailSheet(
        item: item,
        onStatusUpdated: onStatusUpdated,
      ),
    );
  }

  @override
  State<HistoryDetailSheet> createState() => _HistoryDetailSheetState();
}

class _HistoryDetailSheetState extends State<HistoryDetailSheet> {
  final supabase = Supabase.instance.client;
  bool _isProcessing = false;

  Future<void> _approveBooking() async {
    final bookingId = widget.item['id'];
    if (bookingId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF2E7D32)),
            SizedBox(width: 8),
            Text('Setujui Peminjaman', style: TextStyle(fontFamily: 'Hanken Grotesk', fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Text(
          'Setujui peminjaman ini untuk ${widget.item['profiles']?['full_name'] ?? 'Karyawan'}?',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F3567),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Ya, Setujui (ACC)'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);
    try {
      await supabase.from('bookings').update({'status': 'active'}).eq('id', bookingId);

      // Sinkronisasi status armada di tabel vehicles agar tercatat 'Terpakai' (active = false)
      final vehicleId = widget.item['vehicle_id'];
      final regNo = widget.item['vehicles']?['registration_no'] ?? widget.item['plat_nomor'];
      if (vehicleId != null) {
        await supabase.from('vehicles').update({'active': false}).eq('id', vehicleId);
      } else if (regNo != null) {
        await supabase.from('vehicles').update({'active': false}).eq('registration_no', regNo);
      }

      if (mounted) {
        Navigator.of(context).pop();
        widget.onStatusUpdated?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peminjaman berhasil di-ACC! Armada kini berstatus Sedang Dipakai.'),
            backgroundColor: Color(0xFF2E7D32),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: const Color(0xFFBB0016)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final vehicle = item['vehicles'] ?? {};
    final profile = item['profiles'] ?? {};

    final carName = vehicle['make_model'] ?? 'Mobil Operasional';
    final plateNumber = vehicle['registration_no'] ?? '-';
    final driverName = profile['full_name'] ?? 'Karyawan';
    final driverNik = profile['employee_no'] ?? '-';
    final destination = item['destination'] ?? '-';
    final purpose = item['purpose'] ?? '-';
    final rawStatus = item['status'];
    final normalizedStatus = BookingHelper.normalizeStatus(rawStatus);
    final qrLocker = item['qr_locker_code'] ?? 'Tidak ada data QR';
    final adminNote = item['admin_note']?.toString();

    final formattedStartAt = BookingHelper.formatDateTime(item['start_at']);
    final formattedReturnedAt = BookingHelper.formatDateTime(item['returned_at']);
    final startKm = BookingHelper.extractStartKm(item);
    final odoPhotoPath = BookingHelper.extractOdoPhotoPath(item);
    final facePhotoPath = BookingHelper.getFacePhotoPath(item);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Detail Riwayat Peminjaman',
                        style: TextStyle(
                          fontFamily: 'Hanken Grotesk',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF191C1D),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Informasi lengkap & lampiran foto',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: BookingHelper.getStatusBgColor(rawStatus),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    BookingHelper.getStatusLabel(rawStatus),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: BookingHelper.getStatusTextColor(rawStatus),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Data Peminjam
                  _buildSectionHeader('INFORMASI PEMINJAM', Icons.person_outline),
                  const SizedBox(height: 10),
                  _buildCard([
                    _buildRow(Icons.person, 'Nama Pengemudi', driverName),
                    const Divider(height: 16),
                    _buildRow(Icons.badge_outlined, 'NIK / No. Karyawan', driverNik),
                  ]),
                  const SizedBox(height: 20),

                  // 2. Data Kendaraan
                  _buildSectionHeader('INFORMASI KENDARAAN', Icons.directions_car_outlined),
                  const SizedBox(height: 10),
                  _buildCard([
                    _buildRow(Icons.directions_car, 'Nama Unit', carName),
                    const Divider(height: 16),
                    _buildRow(Icons.pin, 'Plat Nomor', plateNumber),
                  ]),
                  const SizedBox(height: 20),

                  // 3. Waktu & Keperluan
                  _buildSectionHeader('DETAIL PERJALANAN', Icons.map_outlined),
                  const SizedBox(height: 10),
                  _buildCard([
                    _buildRow(Icons.access_time, 'Waktu Mulai', formattedStartAt),
                    if (item['returned_at'] != null) ...[
                      const Divider(height: 16),
                      _buildRow(Icons.event_available, 'Waktu Selesai', formattedReturnedAt),
                    ],
                    const Divider(height: 16),
                    _buildRow(Icons.location_on_outlined, 'Tujuan', destination),
                    const Divider(height: 16),
                    _buildRow(Icons.assignment_outlined, 'Keperluan', purpose),
                    if (adminNote != null && adminNote.isNotEmpty) ...[
                      const Divider(height: 16),
                      _buildRow(Icons.notes, 'Catatan Sistem', adminNote),
                    ],
                  ]),
                  const SizedBox(height: 20),

                  // 4. Dokumentasi Foto & Odometer
                  _buildSectionHeader('FOTO & ODOMETER', Icons.camera_alt_outlined),
                  const SizedBox(height: 10),
                  _buildCard([
                    _buildRow(Icons.speed, 'Odometer KM Awal', startKm),
                  ]),
                  const SizedBox(height: 12),
                  PhotoPreviewWidget(
                    title: 'Foto Muka / Wajah Peminjam',
                    photoPath: facePhotoPath,
                    defaultIcon: Icons.face_rounded,
                    accentColor: const Color(0xFF0F3567),
                    subtitle: 'Verifikasi Wajah Driver',
                  ),
                  const SizedBox(height: 12),
                  PhotoPreviewWidget(
                    title: 'Foto Odometer Kendaraan',
                    photoPath: odoPhotoPath,
                    defaultIcon: Icons.speed_rounded,
                    accentColor: const Color(0xFFBB0016),
                    subtitle: 'KM: $startKm',
                  ),
                  const SizedBox(height: 20),

                  // 5. Kode Loker QR
                  _buildSectionHeader('KODE LOKER KUNCI', Icons.lock_outline),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F9FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.qr_code_scanner, color: Color(0xFF0F3567), size: 28),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Kode QR Akses Loker', style: TextStyle(fontSize: 11, color: Colors.grey)),
                              const SizedBox(height: 2),
                              Text(qrLocker, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),

          // Action if pending
          if (normalizedStatus == 'pending')
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: _isProcessing
                    ? const Center(child: CircularProgressIndicator(color: Color(0xFFBB0016)))
                    : SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFBB0016),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: _approveBooking,
                          icon: const Icon(Icons.check_circle_outline),
                          label: Text(LanguageManager.instance.t('btn_approve_full'), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFFBB0016)),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: Color(0xFFBB0016),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildRow(IconData icon, String title, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF5C403D), size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF191C1D),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
