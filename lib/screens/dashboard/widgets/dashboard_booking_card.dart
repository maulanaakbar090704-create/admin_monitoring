import 'package:flutter/material.dart';
import '../../../utils/booking_helper.dart';

import '../../../utils/language_manager.dart';

class DashboardBookingCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap;

  const DashboardBookingCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lm = LanguageManager.instance;
    final vehicle = item['vehicles'] ?? {};
    final profile = item['profiles'] ?? {};

    final carName = vehicle['make_model'] ?? 'Mobil Operasional';
    final plateNumber = vehicle['registration_no'] ?? '-';
    final driverName = profile['full_name'] ?? 'Karyawan';
    final employeeNo = profile['employee_no'];
    final destination = item['destination'] ?? '-';
    final purpose = item['purpose'] ?? '-';
    final rawStatus = item['status'];
    final normalizedStatus = BookingHelper.normalizeStatus(rawStatus);

    final statusBgColor = BookingHelper.getStatusBgColor(rawStatus);
    final statusTextColor = BookingHelper.getStatusTextColor(rawStatus);
    final statusText = BookingHelper.getStatusLabel(rawStatus);

    final hasFacePhoto = BookingHelper.getFacePhotoPath(item) != null;
    final hasOdoPhoto = BookingHelper.extractOdoPhotoPath(item) != null;
    final startKm = BookingHelper.extractStartKm(item);
    final formattedTime = BookingHelper.formatDateTime(item['start_at'] ?? item['created_at']);

    Color cardAccentColor;
    if (normalizedStatus == 'pending') {
      cardAccentColor = const Color(0xFFD97706);
    } else if (normalizedStatus == 'active') {
      cardAccentColor = const Color(0xFFBB0016);
    } else {
      cardAccentColor = const Color(0xFF0F3567);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: normalizedStatus == 'pending'
              ? const Color(0xFFD97706).withValues(alpha: 0.5)
              : const Color(0xFFE2E8F0),
          width: normalizedStatus == 'pending' ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: normalizedStatus == 'pending'
                ? const Color(0xFFD97706).withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pending Alert Banner jika perlu tindakan ACC
              if (normalizedStatus == 'pending')
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFF8E1),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.notification_important_rounded, size: 16, color: Color(0xFFB45309)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          lm.t('pending_action_banner'),
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF92400E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Bar: Mobil, Plat & Status Chip
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: cardAccentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.directions_car_filled_rounded,
                            color: cardAccentColor,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                carName,
                                style: const TextStyle(
                                  fontFamily: 'Hanken Grotesk',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1E293B),
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                child: Text(
                                  plateNumber,
                                  style: const TextStyle(
                                    fontFamily: 'Hanken Grotesk',
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.6,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: statusTextColor.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: statusTextColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                statusText,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: statusTextColor,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Divider(height: 1, color: Color(0xFFF1F5F9)),
                    ),

                    // Driver info
                    Row(
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.person_rounded,
                            size: 15,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: driverName,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                if (employeeNo != null && employeeNo.toString().isNotEmpty && employeeNo != '-')
                                  TextSpan(
                                    text: ' (NIK: $employeeNo)',
                                    style: const TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.normal,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Tujuan & Keperluan
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            size: 15,
                            color: Color(0xFFBB0016),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              destination.isNotEmpty && purpose.isNotEmpty
                                  ? '$destination • $purpose'
                                  : (destination.isNotEmpty ? destination : purpose),
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF334155),
                                height: 1.25,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Timestamp info
                    if (formattedTime != '-') ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              formattedTime,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 12),

                    // Badges & Action Prompt
                    Row(
                      children: [
                        Expanded(
                          child: Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              if (startKm != '-')
                                _buildDocBadge(
                                  icon: Icons.speed_rounded,
                                  text: startKm,
                                  color: const Color(0xFF0F3567),
                                ),
                              if (hasFacePhoto)
                                _buildDocBadge(
                                  icon: Icons.face_rounded,
                                  text: 'Foto Wajah',
                                  color: const Color(0xFF16A34A),
                                ),
                              if (hasOdoPhoto)
                                _buildDocBadge(
                                  icon: Icons.camera_alt_rounded,
                                  text: 'Foto Odometer',
                                  color: const Color(0xFFBB0016),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Detail',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F3567),
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(
                              Icons.chevron_right_rounded,
                              size: 18,
                              color: Color(0xFF0F3567),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Tombol Aksi Langsung jika Status Pending
                    if (normalizedStatus == 'pending') ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF0F3567), Color(0xFFBB0016)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFBB0016).withValues(alpha: 0.25),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.assignment_turned_in_rounded, size: 16, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              lm.t('btn_approve_full'),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocBadge({required IconData icon, required String text, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3.5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
