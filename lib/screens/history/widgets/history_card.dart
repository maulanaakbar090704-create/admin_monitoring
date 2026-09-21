import 'package:flutter/material.dart';
import '../../../utils/booking_helper.dart';

class HistoryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback? onTap;

  const HistoryCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
    final statusBgColor = BookingHelper.getStatusBgColor(rawStatus);
    final statusTextColor = BookingHelper.getStatusTextColor(rawStatus);
    final statusText = BookingHelper.getStatusLabel(rawStatus);

    Color accentStripeColor;
    if (normalizedStatus == 'pending') {
      accentStripeColor = const Color(0xFFFFA000);
    } else if (normalizedStatus == 'active') {
      accentStripeColor = const Color(0xFFBB0016);
    } else {
      accentStripeColor = const Color(0xFF276A3C);
    }

    final formattedStartAt = BookingHelper.formatDateTime(item['start_at']);
    final startKm = BookingHelper.extractStartKm(item);
    final hasFacePhoto = BookingHelper.getFacePhotoPath(item) != null;
    final hasOdoPhoto = BookingHelper.extractOdoPhotoPath(item) != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: Container(color: accentStripeColor),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                              color: Color(0xFF191C1D),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            plateNumber,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF5C403D),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: statusTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: Color(0xFF5C403D)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$driverName ($driverNik)',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF191C1D),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF5C403D)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '$destination • $purpose',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF5C403D)),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: Color(0xFF5C403D)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            formattedStartAt,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Foto & Odometer badges
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    if (startKm != '-')
                      _buildChip(Icons.speed, startKm, const Color(0xFF0F3567)),
                    if (hasFacePhoto)
                      _buildChip(Icons.face, 'Foto Wajah', const Color(0xFF2E7D32)),
                    if (hasOdoPhoto)
                      _buildChip(Icons.photo_camera, 'Foto Odo', const Color(0xFFBB0016)),
                  ],
                ),

                const Divider(height: 20, thickness: 1, color: Color(0xFFEDEEEF)),
                InkWell(
                  onTap: onTap,
                  borderRadius: BorderRadius.circular(8),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Lihat Detail Peminjaman & Foto',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFBB0016),
                          ),
                        ),
                        Icon(Icons.chevron_right, size: 18, color: Color(0xFFBB0016)),
                      ],
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

  Widget _buildChip(IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }
}
