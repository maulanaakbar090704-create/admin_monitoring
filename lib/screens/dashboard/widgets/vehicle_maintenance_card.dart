import 'package:flutter/material.dart';
import '../../../utils/booking_helper.dart';
import '../../../utils/vehicle_maintenance_manager.dart';
import 'maintenance_dialog.dart';

class VehicleMaintenanceCard extends StatelessWidget {
  final Map<String, dynamic> vehicle;
  final List<Map<String, dynamic>> allVehicles;
  final List<Map<String, dynamic>> activeBookings;
  final VoidCallback onRefresh;

  const VehicleMaintenanceCard({
    super.key,
    required this.vehicle,
    required this.allVehicles,
    required this.activeBookings,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final maintenanceMgr = VehicleMaintenanceManager.instance;
    final vehicleId = vehicle['id']?.toString() ?? '';
    final regNo = (vehicle['registration_no'] ?? '').toString().trim().toUpperCase();
    final makeModel = vehicle['make_model']?.toString() ?? 'Mobil Operasional';

    // Periksa status perbaikan
    final rawStatus = (vehicle['status'] ?? '').toString().trim().toLowerCase();
    final bool isMaintenance = vehicle['is_maintenance'] == true ||
        rawStatus == 'maintenance' ||
        rawStatus == 'perbaikan' ||
        rawStatus == 'dalam perbaikan' ||
        maintenanceMgr.isUnderMaintenance(vehicleId, regNo);

    final maintenanceInfo = maintenanceMgr.getMaintenanceInfo(vehicleId, regNo);
    final String issue = maintenanceInfo?.issue ??
        vehicle['maintenance_reason']?.toString() ??
        'Perbaikan & Servis Rutin';
    final String estimatedEnd = maintenanceInfo?.estimatedEnd ??
        'Dalam proses teknisi';
    final String? adminNote = maintenanceInfo?.adminNote;
    final DateTime? startDate = maintenanceInfo?.startedAt ??
        (vehicle['maintenance_start_date'] != null
            ? DateTime.tryParse(vehicle['maintenance_start_date'].toString())
            : null);

    // Periksa apakah sedang dipakai
    Map<String, dynamic>? currentBooking;
    for (final b in activeBookings) {
      final bReg = (b['plat_nomor'] ?? b['vehicles']?['registration_no'] ?? '')
          .toString()
          .trim()
          .toUpperCase();
      if (bReg.isNotEmpty && bReg == regNo) {
        currentBooking = b;
        break;
      }
    }
    final bool isInUse = currentBooking != null;
    final String driverName = currentBooking?['profiles']?['full_name'] ?? 'Karyawan';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMaintenance
              ? const Color(0xFFEF4444).withValues(alpha: 0.4)
              : const Color(0xFFE2E8F0),
          width: isMaintenance ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isMaintenance
                ? const Color(0xFFEF4444).withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========================================================
            // Header: Info Mobil & Badge Status (Responsif & Anti-Overflow)
            // ========================================================
            Container(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              decoration: BoxDecoration(
                color: isMaintenance
                    ? const Color(0xFFFEF2F2)
                    : const Color(0xFFF8FAFC),
                border: Border(
                  bottom: BorderSide(
                    color: isMaintenance
                        ? const Color(0xFFFCA5A5).withValues(alpha: 0.4)
                        : const Color(0xFFF1F5F9),
                  ),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Icon Mobil
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isMaintenance
                          ? const Color(0xFFDC2626).withValues(alpha: 0.12)
                          : isInUse
                              ? const Color(0xFF0F3567).withValues(alpha: 0.1)
                              : const Color(0xFF16A34A).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isMaintenance
                          ? Icons.build_circle_rounded
                          : Icons.directions_car_rounded,
                      color: isMaintenance
                          ? const Color(0xFFDC2626)
                          : isInUse
                              ? const Color(0xFF0F3567)
                              : const Color(0xFF16A34A),
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Nama Mobil & Plat Nomor
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          makeModel,
                          style: const TextStyle(
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Wrap(
                          spacing: 6,
                          runSpacing: 2,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            // Badge Plat Nomor
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E293B),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                regNo.isNotEmpty ? regNo : 'TANPA PLAT',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            if (isInUse && !isMaintenance)
                              Text(
                                'Dipakai: $driverName',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Status Badge Utama
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isMaintenance
                          ? const Color(0xFFDC2626)
                          : isInUse
                              ? const Color(0xFF0F3567)
                              : const Color(0xFF16A34A),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isMaintenance
                              ? Icons.handyman_rounded
                              : isInUse
                                  ? Icons.access_time_rounded
                                  : Icons.check_circle_rounded,
                          color: Colors.white,
                          size: 11,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          isMaintenance
                              ? 'Perbaikan'
                              : isInUse
                                  ? 'Dipakai'
                                  : 'Prima',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ========================================================
            // Body: Detail Perbaikan / Kondisi
            // ========================================================
            Padding(
              padding: const EdgeInsets.all(14.0),
              child: isMaintenance
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Label Detail Perbaikan
                        Row(
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              size: 14,
                              color: Color(0xFFDC2626),
                            ),
                            const SizedBox(width: 6),
                            const Expanded(
                              child: Text(
                                'DETAIL PERBAIKAN & KERUSAKAN',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF991B1B),
                                  letterSpacing: 0.4,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Kotak Rincian Kerusakan
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFFDE68A)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                issue,
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF92400E),
                                ),
                              ),
                              if (adminNote != null && adminNote.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Catatan: $adminNote',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF78350F),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.event_note_rounded, size: 13, color: Colors.amber.shade900),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      startDate != null
                                          ? 'Mulai: ${BookingHelper.formatDateTime(startDate.toIso8601String())}'
                                          : 'Mulai: Sedang berjalan',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.amber.shade900,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.timer_outlined, size: 13, color: Colors.amber.shade900),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      'Estimasi: $estimatedEnd',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.amber.shade900,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Tombol Aksi Perbaikan (Fitted & Anti-Overflow)
                        Row(
                          children: [
                            // Tombol Selesaikan Perbaikan
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF16A34A),
                                  side: const BorderSide(color: Color(0xFF16A34A)),
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                icon: const Icon(Icons.check_circle_outline, size: 15),
                                label: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Selesaikan',
                                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Selesaikan Perbaikan?'),
                                      content: Text(
                                        'Apakah perbaikan untuk armada $makeModel ($regNo) sudah selesai dan siap beroperasi kembali?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx, false),
                                          child: const Text('Batal'),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF16A34A),
                                            foregroundColor: Colors.white,
                                          ),
                                          onPressed: () => Navigator.pop(ctx, true),
                                          child: const Text('Ya, Siap Beroperasi'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true && context.mounted) {
                                    await maintenanceMgr.resolveMaintenance(
                                      context: context,
                                      vehicleId: vehicleId,
                                      registrationNo: regNo,
                                    );
                                    onRefresh();
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Tombol Edit Perbaikan
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0F3567),
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  visualDensity: VisualDensity.compact,
                                ),
                                icon: const Icon(Icons.edit_note_rounded, size: 16),
                                label: const FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    'Ubah Info',
                                    style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                onPressed: () {
                                  MaintenanceDialog.show(
                                    context,
                                    vehicles: allVehicles,
                                    initialVehicleId: vehicleId,
                                    onSaved: onRefresh,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Keterangan Normal
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.verified_rounded,
                                    size: 15,
                                    color: Color(0xFF16A34A),
                                  ),
                                  const SizedBox(width: 5),
                                  const Expanded(
                                    child: Text(
                                      'Kondisi Mesin & Fisik Prima',
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isInUse
                                    ? 'Sedang melayani peminjaman dinas.'
                                    : 'Siap digunakan untuk operasional dinas.',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey.shade500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Tombol Catat Perbaikan Baru
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFF1F5F9),
                            foregroundColor: const Color(0xFF0F3567),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: const BorderSide(color: Color(0xFFCBD5E1)),
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: const Icon(Icons.build_rounded, size: 12),
                          label: const Text(
                            '+ Perbaikan',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            MaintenanceDialog.show(
                              context,
                              vehicles: allVehicles,
                              initialVehicleId: vehicleId,
                              onSaved: onRefresh,
                            );
                          },
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
