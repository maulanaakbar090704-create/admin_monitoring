import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../utils/booking_helper.dart';
import '../../../utils/language_manager.dart';
import '../../../widgets/photo_preview_widget.dart';

class BookingDetailSheet extends StatefulWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onStatusUpdated;

  const BookingDetailSheet({
    super.key,
    required this.item,
    this.onStatusUpdated,
  });

  static void show(BuildContext context, Map<String, dynamic> item, {VoidCallback? onStatusUpdated}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookingDetailSheet(
        item: item,
        onStatusUpdated: onStatusUpdated,
      ),
    );
  }

  @override
  State<BookingDetailSheet> createState() => _BookingDetailSheetState();
}

class _BookingDetailSheetState extends State<BookingDetailSheet> {
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
          'Apakah Anda yakin data peminjaman dari ${widget.item['profiles']?['full_name'] ?? 'Karyawan'} sudah sesuai dan ingin meng-ACC peminjaman ini?',
          style: const TextStyle(fontSize: 14, color: Color(0xFF191C1D)),
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
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Text('Peminjaman berhasil disetujui (ACC)! Armada kini berstatus Sedang Dipakai.'),
              ],
            ),
            backgroundColor: Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error approve booking: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyetujui peminjaman: $e'),
            backgroundColor: const Color(0xFFBB0016),
          ),
        );
      }
    }
  }

  Future<void> _rejectBooking() async {
    final bookingId = widget.item['id'];
    if (bookingId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.cancel, color: Color(0xFFBB0016)),
            SizedBox(width: 8),
            Text('Tolak Peminjaman', style: TextStyle(fontFamily: 'Hanken Grotesk', fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin menolak permohonan peminjaman ini?',
          style: TextStyle(fontSize: 14, color: Color(0xFF191C1D)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFBB0016),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Tolak'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);
    try {
      await supabase.from('bookings').update({'status': 'cancelled'}).eq('id', bookingId);

      // Kembalikan armada ke status siap/tersedia (active = true)
      final vehicleId = widget.item['vehicle_id'];
      final regNo = widget.item['vehicles']?['registration_no'] ?? widget.item['plat_nomor'];
      if (vehicleId != null) {
        await supabase.from('vehicles').update({'active': true}).eq('id', vehicleId);
      } else if (regNo != null) {
        await supabase.from('vehicles').update({'active': true}).eq('registration_no', regNo);
      }

      if (mounted) {
        Navigator.of(context).pop();
        widget.onStatusUpdated?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permohonan peminjaman telah ditolak.'),
            backgroundColor: Color(0xFFBB0016),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error reject booking: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menolak peminjaman: $e'),
            backgroundColor: const Color(0xFFBB0016),
          ),
        );
      }
    }
  }

  Future<void> _completeBooking() async {
    final bookingId = widget.item['id'];
    if (bookingId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF0F3567)),
            SizedBox(width: 8),
            Text('Selesaikan Peminjaman', style: TextStyle(fontFamily: 'Hanken Grotesk', fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Text(
          'Apakah perjalanan telah selesai dan armada telah dikembalikan ke pool? Status armada akan kembali Siap (Standby).',
          style: TextStyle(fontSize: 14, color: Color(0xFF191C1D)),
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
            child: const Text('Selesaikan'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isProcessing = true);
    try {
      await supabase.from('bookings').update({'status': 'completed'}).eq('id', bookingId);

      // Kembalikan armada ke status siap/tersedia (active = true)
      final vehicleId = widget.item['vehicle_id'];
      final regNo = widget.item['vehicles']?['registration_no'] ?? widget.item['plat_nomor'];
      if (vehicleId != null) {
        await supabase.from('vehicles').update({'active': true}).eq('id', vehicleId);
      } else if (regNo != null) {
        await supabase.from('vehicles').update({'active': true}).eq('registration_no', regNo);
      }

      if (mounted) {
        Navigator.of(context).pop();
        widget.onStatusUpdated?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Peminjaman telah diselesaikan. Armada kembali ke pool.'),
            backgroundColor: Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error complete booking: $e');
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyelesaikan peminjaman: $e'),
            backgroundColor: const Color(0xFFBB0016),
          ),
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
          // Drag Handle
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

          // Modal Header (Dinamis & Responsif)
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
                        'Detail Peminjaman',
                        style: TextStyle(
                          fontFamily: 'Hanken Grotesk',
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF191C1D),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Verifikasi data yang dikirim oleh peminjam',
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
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: BookingHelper.getStatusTextColor(rawStatus),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Data Peminjam
                  _buildSectionHeader('INFORMASI PEMINJAM', Icons.person_outline),
                  const SizedBox(height: 10),
                  _buildCardContainer([
                    _buildDetailRow(Icons.person, 'Nama Lengkap', driverName),
                    const Divider(height: 16),
                    _buildDetailRow(Icons.badge_outlined, 'NIK / No. Pegawai', driverNik),
                  ]),
                  const SizedBox(height: 20),

                  // 2. Data Kendaraan
                  _buildSectionHeader('INFORMASI KENDARAAN', Icons.directions_car_outlined),
                  const SizedBox(height: 10),
                  _buildCardContainer([
                    _buildDetailRow(Icons.directions_car, 'Unit Mobil', carName),
                    const Divider(height: 16),
                    _buildDetailRow(Icons.pin, 'Nomor Polisi (Plat)', plateNumber),
                  ]),
                  const SizedBox(height: 20),

                  // 3. Waktu, Keperluan, & Tujuan
                  _buildSectionHeader('JADWAL & KEPERLUAN', Icons.event_note_outlined),
                  const SizedBox(height: 10),
                  _buildCardContainer([
                    _buildDetailRow(Icons.access_time, 'Waktu Mulai Pinjam', formattedStartAt),
                    const Divider(height: 16),
                    _buildDetailRow(Icons.location_on_outlined, 'Tujuan Perjalanan', destination),
                    const Divider(height: 16),
                    _buildDetailRow(Icons.assignment_outlined, 'Keperluan Peminjaman', purpose),
                    if (adminNote != null && adminNote.isNotEmpty) ...[
                      const Divider(height: 16),
                      _buildDetailRow(Icons.notes, 'Catatan Sistem/Driver', adminNote),
                    ],
                  ]),
                  const SizedBox(height: 20),

                  // 4. Data Dokumentasi Peminjam (Foto & Odometer)
                  _buildSectionHeader('DOKUMENTASI PEMINJAM', Icons.camera_alt_outlined),
                  const SizedBox(height: 10),

                  // Info Odometer
                  _buildCardContainer([
                    _buildDetailRow(Icons.speed, 'Odometer KM Awal', startKm),
                  ]),
                  const SizedBox(height: 12),

                  // Foto Wajah
                  PhotoPreviewWidget(
                    title: 'Foto Muka / Wajah Peminjam',
                    photoPath: facePhotoPath,
                    defaultIcon: Icons.face_rounded,
                    accentColor: const Color(0xFF0F3567),
                    subtitle: 'Verifikasi Identitas Peminjam',
                  ),
                  const SizedBox(height: 12),

                  // Foto Odometer
                  PhotoPreviewWidget(
                    title: 'Foto Odometer Kendaraan',
                    photoPath: odoPhotoPath,
                    defaultIcon: Icons.speed_rounded,
                    accentColor: const Color(0xFFBB0016),
                    subtitle: 'KM Awal: $startKm',
                  ),
                  const SizedBox(height: 20),

                  // 5. Kode Loker Kunci
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
                              Text(
                                qrLocker,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF191C1D)),
                              ),
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

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: _buildBottomActions(normalizedStatus),
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
        Flexible(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: Color(0xFFBB0016),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value) {
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

  Widget _buildBottomActions(String status) {
    final lm = LanguageManager.instance;
    if (_isProcessing) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: CircularProgressIndicator(color: Color(0xFFBB0016)),
        ),
      );
    }

    if (status == 'pending') {
      return Row(
        children: [
          // Tombol Tolak
          Expanded(
            flex: 1,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Color(0xFFBB0016), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _rejectBooking,
              child: Text(
                lm.t('btn_reject_booking'),
                style: const TextStyle(
                  color: Color(0xFFBB0016),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Tombol Setujui (ACC)
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFBB0016), Color(0xFF0F3567)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFBB0016).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _approveBooking,
                icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 20),
                label: Text(
                  lm.t('btn_approve_full'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    } else if (status == 'active') {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFDAD6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.directions_car, color: Color(0xFF93000A), size: 18),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    lm.t('vehicle_in_use_banner'),
                    style: const TextStyle(
                      color: Color(0xFF93000A),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F3567),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.assignment_turned_in_rounded, size: 18),
              label: Text(
                lm.t('btn_finish_trip'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
              onPressed: _completeBooking,
            ),
          ),
        ],
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEEEF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            status == 'cancelled'
                ? lm.t('booking_rejected_banner')
                : lm.t('booking_completed_banner'),
            style: const TextStyle(
              color: Color(0xFF5C403D),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      );
    }
  }
}
