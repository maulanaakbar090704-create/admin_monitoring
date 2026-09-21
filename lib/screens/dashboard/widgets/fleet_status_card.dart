import 'package:flutter/material.dart';
import '../../../utils/language_manager.dart';
import '../../../utils/vehicle_maintenance_manager.dart';
import 'maintenance_dialog.dart';

class FleetStatusCard extends StatefulWidget {
  final List<Map<String, dynamic>> vehicles;
  final List<Map<String, dynamic>> activeBookings;
  final VoidCallback onRefresh;

  const FleetStatusCard({
    super.key,
    required this.vehicles,
    required this.activeBookings,
    required this.onRefresh,
  });

  @override
  State<FleetStatusCard> createState() => _FleetStatusCardState();
}

class _FleetStatusCardState extends State<FleetStatusCard> {
  String _selectedTab = 'available'; // 'available', 'in_use', 'maintenance'

  @override
  Widget build(BuildContext context) {
    final lm = LanguageManager.instance;
    final maintenanceMgr = VehicleMaintenanceManager.instance;

    // 1. Kategorisasi Armada
    // a. Kendaraan sedang dipakai (ada di activeBookings)
    final List<Map<String, dynamic>> inUseVehicles = [];
    final Set<String> inUsePlates = {};
    for (final b in widget.activeBookings) {
      final regNo = (b['plat_nomor'] ?? b['vehicles']?['registration_no'] ?? '')
          .toString()
          .trim()
          .toUpperCase();
      if (regNo.isNotEmpty) {
        inUsePlates.add(regNo);
        inUseVehicles.add(b);
      }
    }

    // b. Kendaraan dalam perbaikan
    final List<Map<String, dynamic>> maintenanceVehicles = [];
    // c. Kendaraan tersedia di pool
    final List<Map<String, dynamic>> availableVehicles = [];

    for (final v in widget.vehicles) {
      final regNo = (v['registration_no'] ?? '').toString().trim().toUpperCase();
      final vehicleId = v['id']?.toString() ?? '';
      final isMaintenance = maintenanceMgr.isUnderMaintenance(vehicleId, regNo);

      if (isMaintenance) {
        maintenanceVehicles.add(v);
      } else if (inUsePlates.contains(regNo)) {
        // Sudah masuk kategori inUse
      } else {
        availableVehicles.add(v);
      }
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 360;

        return Container(
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 18,
                            decoration: BoxDecoration(
                              color: const Color(0xFF0F3567),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              lm.t('fleet_status_title'),
                              style: TextStyle(
                                fontFamily: 'Hanken Grotesk',
                                fontSize: isSmallScreen ? 15 : 16.5,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF0F172A),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Action Button: Kelola Perbaikan
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F3567),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 8 : 12,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.build_rounded, size: 14),
                      label: Text(
                        isSmallScreen ? 'Perbaikan' : 'Kelola Perbaikan',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () => MaintenanceDialog.show(
                        context,
                        vehicles: widget.vehicles,
                        onSaved: widget.onRefresh,
                      ),
                    ),
                  ],
                ),
              ),

              // Segmented Status Filter Tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildTabChip(
                        tabKey: 'available',
                        label: lm.t('fleet_available'),
                        count: availableVehicles.length,
                        color: const Color(0xFF2E7D32),
                        icon: Icons.check_circle_rounded,
                      ),
                      const SizedBox(width: 8),
                      _buildTabChip(
                        tabKey: 'in_use',
                        label: lm.t('fleet_in_use'),
                        count: inUseVehicles.length,
                        color: const Color(0xFFBB0016),
                        icon: Icons.directions_car_rounded,
                      ),
                      const SizedBox(width: 8),
                      _buildTabChip(
                        tabKey: 'maintenance',
                        label: lm.t('fleet_maintenance'),
                        count: maintenanceVehicles.length,
                        color: const Color(0xFFD97706),
                        icon: Icons.build_circle_rounded,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Divider(height: 1),

              // List Armada Sesuai Tab Terpilih
              if (_selectedTab == 'available')
                _buildAvailableList(availableVehicles)
              else if (_selectedTab == 'in_use')
                _buildInUseList(inUseVehicles)
              else
                _buildMaintenanceList(maintenanceVehicles),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabChip({
    required String tabKey,
    required String label,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = _selectedTab == tabKey;

    return InkWell(
      onTap: () => setState(() => _selectedTab = tabKey),
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : color.withValues(alpha: 0.25),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.25)
                    : color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 1. List Kendaraan Tersedia
  Widget _buildAvailableList(List<Map<String, dynamic>> vehicles) {
    if (vehicles.isEmpty) {
      return _buildEmptyState(
        icon: Icons.directions_car_filled_outlined,
        message: 'Tidak ada armada yang sedang standby di pool.',
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: vehicles.length,
      separatorBuilder: (context, index) => const Divider(height: 16),
      itemBuilder: (context, index) {
        final v = vehicles[index];
        final makeModel = v['make_model'] ?? 'Toyota Avanza';
        final plate = v['registration_no'] ?? '-';
        final picName = v['pic_name'] ?? 'Pool Standby';

        return Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF2E7D32),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    makeModel,
                    style: const TextStyle(
                      fontFamily: 'Hanken Grotesk',
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          plate,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'PIC: $picName',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: Colors.grey.shade600,
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
            const SizedBox(width: 8),
            // Tombol Setel Perbaikan
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFFD97706)),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () => MaintenanceDialog.show(
                context,
                vehicles: widget.vehicles,
                initialVehicleId: v['id'],
                onSaved: widget.onRefresh,
              ),
              child: const Text(
                'Set Perbaikan',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD97706),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 2. List Kendaraan Sedang Dipakai
  Widget _buildInUseList(List<Map<String, dynamic>> bookings) {
    if (bookings.isEmpty) {
      return _buildEmptyState(
        icon: Icons.no_crash_rounded,
        message: 'Tidak ada armada yang sedang dipakai saat ini.',
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: bookings.length,
      separatorBuilder: (context, index) => const Divider(height: 16),
      itemBuilder: (context, index) {
        final b = bookings[index];
        final vehicle = b['vehicles'] ?? {};
        final profile = b['profiles'] ?? {};
        final makeModel = vehicle['make_model'] ?? 'Mobil Operasional';
        final plate = b['plat_nomor'] ?? vehicle['registration_no'] ?? '-';
        final driverName = profile['full_name'] ?? 'Driver Telkom';
        final destination = b['destination'] ?? 'Operasional Lapangan';

        return Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFBB0016).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.directions_car_rounded,
                color: Color(0xFFBB0016),
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    makeModel,
                    style: const TextStyle(
                      fontFamily: 'Hanken Grotesk',
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          plate,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          'Peminjam: $driverName',
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF0F3567),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tujuan: $destination',
                    style: TextStyle(
                      fontSize: 10,
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
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFFFDAD6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'SEDANG DIPAKAI',
                style: TextStyle(
                  fontSize: 9.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF93000A),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // 3. List Kendaraan Dalam Perbaikan
  Widget _buildMaintenanceList(List<Map<String, dynamic>> vehicles) {
    if (vehicles.isEmpty) {
      return _buildEmptyState(
        icon: Icons.check_circle_outline,
        message: 'Tidak ada armada yang sedang dalam perbaikan.',
      );
    }

    final maintenanceMgr = VehicleMaintenanceManager.instance;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: vehicles.length,
      separatorBuilder: (context, index) => const Divider(height: 16),
      itemBuilder: (context, index) {
        final v = vehicles[index];
        final makeModel = v['make_model'] ?? 'Mobil Operasional';
        final plate = v['registration_no'] ?? '-';
        final maintInfo =
            maintenanceMgr.getMaintenanceInfo(v['id'], plate);
        final issue = maintInfo?.issue ?? 'Perbaikan & Servis Rutin';
        final estimatedEnd = maintInfo?.estimatedEnd ?? 'Dalam proses bengkel';

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFDE68A)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Judul & Badge Status Perbaikan
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD97706).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.build_rounded,
                      color: Color(0xFFD97706),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$makeModel ($plate)',
                          style: const TextStyle(
                            fontFamily: 'Hanken Grotesk',
                            fontSize: 13.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF92400E),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          'Status: Kendaraan Plat $plate sedang dalam perbaikan',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFB45309),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFF59E0B)),
                    ),
                    child: const Text(
                      'PERBAIKAN',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFB45309),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Detail Kendala & Estimasi
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.handyman_outlined,
                            size: 13, color: Color(0xFF78350F)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Kendala: $issue',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF78350F),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.schedule_outlined,
                            size: 13, color: Color(0xFF78350F)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Estimasi Selesai: $estimatedEnd',
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF78350F),
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
              const SizedBox(height: 10),

              // Tombol Aksi: WhatsApp Notifikasi & Selesaikan
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        visualDensity: VisualDensity.compact,
                      ),
                      icon: const Icon(Icons.send_rounded,
                          size: 13, color: Color(0xFF2E7D32)),
                      label: const Text(
                        'Kirim Notif WA',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2E7D32),
                        ),
                      ),
                      onPressed: () {
                        if (maintInfo != null) {
                          maintenanceMgr.sendNotificationViaWhatsApp(
                            context: context,
                            item: maintInfo,
                          );
                        } else {
                          final temp = VehicleMaintenanceItem(
                            vehicleId: v['id'],
                            registrationNo: plate,
                            makeModel: makeModel,
                            issue: issue,
                            startedAt: DateTime.now(),
                            estimatedEnd: estimatedEnd,
                          );
                          maintenanceMgr.sendNotificationViaWhatsApp(
                            context: context,
                            item: temp,
                          );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6)),
                        visualDensity: VisualDensity.compact,
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 13),
                      label: const Text(
                        'Selesai Perbaikan',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      onPressed: () async {
                        await maintenanceMgr.resolveMaintenance(
                          context: context,
                          vehicleId: v['id'],
                          registrationNo: plate,
                        );
                        widget.onRefresh();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Armada $plate telah selesai perbaikan dan kembali siap dipinjam.',
                              ),
                              backgroundColor: const Color(0xFF2E7D32),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 28, color: Colors.grey.shade400),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11.5,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
