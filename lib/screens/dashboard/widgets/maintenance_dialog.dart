import 'package:flutter/material.dart';
import '../../../utils/language_manager.dart';
import '../../../utils/vehicle_maintenance_manager.dart';

class MaintenanceDialog extends StatefulWidget {
  final List<Map<String, dynamic>> vehicles;
  final String? initialVehicleId;
  final VoidCallback onSaved;

  const MaintenanceDialog({
    super.key,
    required this.vehicles,
    this.initialVehicleId,
    required this.onSaved,
  });

  static void show(
    BuildContext context, {
    required List<Map<String, dynamic>> vehicles,
    String? initialVehicleId,
    required VoidCallback onSaved,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => MaintenanceDialog(
        vehicles: vehicles,
        initialVehicleId: initialVehicleId,
        onSaved: onSaved,
      ),
    );
  }

  @override
  State<MaintenanceDialog> createState() => _MaintenanceDialogState();
}

class _MaintenanceDialogState extends State<MaintenanceDialog> {
  late String _selectedVehicleId;
  final TextEditingController _issueController = TextEditingController();
  final TextEditingController _estimatedEndController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  bool _isSaving = false;

  final List<String> _quickIssues = [
    'Servis Berkala & Ganti Oli',
    'Perbaikan Rem & Kaki-kaki',
    'Perbaikan AC & Kelistrikan',
    'Perbaikan Mesin & Transmisi',
    'Pergantian Ban & Spooring',
    'Body Repair & Pengecatan',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.vehicles.isNotEmpty) {
      if (widget.initialVehicleId != null &&
          widget.vehicles.any((v) => v['id'] == widget.initialVehicleId)) {
        _selectedVehicleId = widget.initialVehicleId!;
      } else {
        _selectedVehicleId = widget.vehicles.first['id'];
      }
    } else {
      _selectedVehicleId = '';
    }

    _loadExistingInfo();
    _issueController.addListener(() => setState(() {}));
    _estimatedEndController.addListener(() => setState(() {}));
  }

  void _loadExistingInfo() {
    final existing = VehicleMaintenanceManager.instance
        .getMaintenanceInfo(_selectedVehicleId, null);
    if (existing != null) {
      _issueController.text = existing.issue;
      _estimatedEndController.text = existing.estimatedEnd;
      _noteController.text = existing.adminNote ?? '';
    } else {
      _issueController.text = 'Servis Berkala & Ganti Oli';
      _estimatedEndController.text = '2-3 hari kerja';
      _noteController.clear();
    }
  }

  @override
  void dispose() {
    _issueController.dispose();
    _estimatedEndController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Map<String, dynamic>? _getSelectedVehicle() {
    try {
      return widget.vehicles.firstWhere((v) => v['id'] == _selectedVehicleId);
    } catch (_) {
      return null;
    }
  }

  VehicleMaintenanceItem _buildCurrentItem() {
    final vehicle = _getSelectedVehicle() ?? {};
    final makeModel = vehicle['make_model'] ?? 'Mobil Operasional';
    final regNo = vehicle['registration_no'] ?? '-';
    return VehicleMaintenanceItem(
      vehicleId: _selectedVehicleId,
      registrationNo: regNo,
      makeModel: makeModel,
      issue: _issueController.text.trim().isEmpty
          ? 'Perbaikan Berkala'
          : _issueController.text.trim(),
      startedAt: DateTime.now(),
      estimatedEnd: _estimatedEndController.text.trim().isEmpty
          ? 'Menunggu konfirmasi teknisi'
          : _estimatedEndController.text.trim(),
      adminNote: _noteController.text.trim().isEmpty ? null : _noteController.text.trim(),
    );
  }

  Future<void> _handleSaveMaintenance() async {
    if (_selectedVehicleId.isEmpty) return;
    final vehicle = _getSelectedVehicle();
    if (vehicle == null) return;

    setState(() => _isSaving = true);
    try {
      await VehicleMaintenanceManager.instance.setVehicleMaintenance(
        context: context,
        vehicleId: _selectedVehicleId,
        registrationNo: vehicle['registration_no'] ?? '-',
        makeModel: vehicle['make_model'] ?? 'Mobil Operasional',
        issue: _issueController.text.trim().isEmpty
            ? 'Perbaikan Berkala'
            : _issueController.text.trim(),
        estimatedEnd: _estimatedEndController.text.trim().isEmpty
            ? 'Menunggu estimasi bengkel'
            : _estimatedEndController.text.trim(),
        adminNote: _noteController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Armada ${vehicle['registration_no']} berhasil disetel ke status Dalam Perbaikan. Peminjam tidak dapat memilih armada ini.',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFFD97706),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan status: $e'),
            backgroundColor: const Color(0xFFBB0016),
          ),
        );
      }
    }
  }

  Future<void> _handleResolveMaintenance() async {
    final vehicle = _getSelectedVehicle();
    if (vehicle == null) return;

    setState(() => _isSaving = true);
    try {
      await VehicleMaintenanceManager.instance.resolveMaintenance(
        context: context,
        vehicleId: _selectedVehicleId,
        registrationNo: vehicle['registration_no'],
      );

      if (mounted) {
        Navigator.of(context).pop();
        widget.onSaved();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Perbaikan armada ${vehicle['registration_no']} selesai! Status kembali menjadi Tersedia di pool.',
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyelesaikan perbaikan: $e'),
            backgroundColor: const Color(0xFFBB0016),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lm = LanguageManager.instance;
    final isCurrentlyMaintenance = VehicleMaintenanceManager.instance
        .isUnderMaintenance(_selectedVehicleId, null);
    final currentItem = _buildCurrentItem();
    final notifMessage = VehicleMaintenanceManager.instance
        .generateNotificationMessage(currentItem);

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

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD97706).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.build_circle_rounded,
                      color: Color(0xFFD97706), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        lm.t('dialog_maintenance_title'),
                        style: const TextStyle(
                          fontFamily: 'Hanken Grotesk',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        'Setel status armada & kirim notifikasi ke peminjam',
                        style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
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
                  // 1. Pilih Armada
                  const Text(
                    'PILIH KENDARAAN OPERASIONAL',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Color(0xFFBB0016),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedVehicleId.isNotEmpty ? _selectedVehicleId : null,
                        items: widget.vehicles.map((v) {
                          final makeModel = v['make_model'] ?? 'Mobil Operasional';
                          final plate = v['registration_no'] ?? '-';
                          final isMaint = VehicleMaintenanceManager.instance
                              .isUnderMaintenance(v['id'], plate);

                          return DropdownMenuItem<String>(
                            value: v['id'],
                            child: Row(
                              children: [
                                Icon(
                                  Icons.directions_car_rounded,
                                  size: 18,
                                  color: isMaint
                                      ? const Color(0xFFD97706)
                                      : const Color(0xFF0F3567),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '$makeModel - $plate',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F172A),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (isMaint)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFFEF3C7),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Perbaikan',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFB45309),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _selectedVehicleId = val;
                              _loadExistingInfo();
                            });
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // 2. Kendala / Jenis Perbaikan
                  const Text(
                    'JENIS KENDALA / PERBAIKAN',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Color(0xFFBB0016),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _issueController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Servis Rutin / Ganti Oli Mesin',
                      prefixIcon: const Icon(Icons.build_outlined,
                          size: 18, color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFF0F3567), width: 1.5),
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: _quickIssues.map((issue) {
                      final isSelected = _issueController.text == issue;
                      return ActionChip(
                        label: Text(
                          issue,
                          style: TextStyle(
                            fontSize: 11,
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF475569),
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                        backgroundColor: isSelected
                            ? const Color(0xFF0F3567)
                            : const Color(0xFFF1F5F9),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: isSelected
                                ? Colors.transparent
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _issueController.text = issue;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 18),

                  // 3. Estimasi Selesai
                  const Text(
                    'ESTIMASI TANGGAL SELESAI',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Color(0xFFBB0016),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _estimatedEndController,
                    decoration: InputDecoration(
                      hintText: 'Contoh: 15 Sep 2026, 17:00 WIB atau 2 hari kerja',
                      prefixIcon: const Icon(Icons.event_outlined,
                          size: 18, color: Color(0xFF64748B)),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFF0F3567), width: 1.5),
                      ),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 20),

                  // 4. Pratinjau Pesan Notifikasi Peminjam
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'PRATINJAU NOTIFIKASI KE PEMINJAM',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                          color: Color(0xFF0F3567),
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.copy_rounded, size: 14),
                        label: const Text('Salin', style: TextStyle(fontSize: 11)),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF0F3567),
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          visualDensity: VisualDensity.compact,
                        ),
                        onPressed: () => VehicleMaintenanceManager.instance
                            .copyNotificationText(
                                context: context, item: currentItem),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFFBEB),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFDE68A)),
                    ),
                    child: Text(
                      notifMessage,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11.5,
                        color: Color(0xFF78350F),
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Tombol Kirim WhatsApp Cepat
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => VehicleMaintenanceManager.instance
                          .sendNotificationViaWhatsApp(
                              context: context, item: currentItem),
                      icon: const Icon(Icons.send_rounded,
                          size: 16, color: Color(0xFF2E7D32)),
                      label: const Text(
                        'Kirim Pesan via WhatsApp ke Driver / Peminjam',
                        style: TextStyle(
                          color: Color(0xFF2E7D32),
                          fontWeight: FontWeight.bold,
                          fontSize: 12.5,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF2E7D32)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),

          // Bottom Action Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _isSaving
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFBB0016)),
                  )
                : Row(
                    children: [
                      if (isCurrentlyMaintenance) ...[
                        // Tombol Selesaikan Perbaikan
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _handleResolveMaintenance,
                            icon: const Icon(Icons.check_circle_outline,
                                size: 18, color: Color(0xFF2E7D32)),
                            label: const Text(
                              'Selesai Perbaikan',
                              style: TextStyle(
                                color: Color(0xFF2E7D32),
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF2E7D32)),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      // Tombol Simpan / Setel Perbaikan
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _handleSaveMaintenance,
                          icon: const Icon(Icons.save_rounded,
                              size: 18, color: Colors.white),
                          label: Text(
                            isCurrentlyMaintenance
                                ? 'Update Data'
                                : 'Setel Dalam Perbaikan',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFBB0016),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
