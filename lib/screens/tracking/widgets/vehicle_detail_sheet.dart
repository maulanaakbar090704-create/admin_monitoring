import 'package:flutter/material.dart';

class VehicleDetailSheet extends StatelessWidget {
  final List<Map<String, dynamic>> activeBookings;
  final double currentSpeed;
  final double maxSpeed;
  final String? selectedBookingId;
  final Function(String id)? onSelectBooking;
  final Function(String?) onLaunchWA;
  final Function(String?) onLaunchMaps;
  final VoidCallback onNavigateToHistory;

  const VehicleDetailSheet({
    super.key,
    required this.activeBookings,
    required this.currentSpeed,
    required this.maxSpeed,
    this.selectedBookingId,
    this.onSelectBooking,
    required this.onLaunchWA,
    required this.onLaunchMaps,
    required this.onNavigateToHistory,
  });

  @override
  Widget build(BuildContext context) {
    if (activeBookings.isEmpty) return const SizedBox.shrink();

    return DraggableScrollableSheet(
      initialChildSize: 0.42,
      minChildSize: 0.18,
      maxChildSize: 0.85,
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 20,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  width: 48,
                  height: 5,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE1E3E4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Speed Telemetry Header - Responsive without horizontal RenderFlex overflow
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F9FA),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'KECEPATAN SAAT INI',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${currentSpeed.toStringAsFixed(1)} km/h',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F3567),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 32, color: Colors.grey.shade300),
                    Expanded(
                      child: Column(
                        children: [
                          const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'TOP SPEED (MAKS)',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '${maxSpeed.toStringAsFixed(1)} km/h',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFFBB0016),
                              ),
                            ),
                          ),
                        ],
                      ),
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
                    final bookingId = item['id']?.toString() ?? '';
                    final isSelected = selectedBookingId != null && selectedBookingId == bookingId;

                    final vehicle = (item['vehicles'] is Map) ? item['vehicles'] as Map<String, dynamic> : <String, dynamic>{};
                    final profile = (item['profiles'] is Map) ? item['profiles'] as Map<String, dynamic> : <String, dynamic>{};
                    final phone = profile['phone_number']?.toString();
                    final destination = item['destination']?.toString();

                    return InkWell(
                      onTap: () {
                        if (onSelectBooking != null && bookingId.isNotEmpty) {
                          onSelectBooking!(bookingId);
                        }
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: EdgeInsets.all(isSelected ? 10 : 0),
                        decoration: isSelected
                            ? BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFBB0016), width: 1.5),
                                color: const Color(0xFFBB0016).withValues(alpha: 0.03),
                              )
                            : null,
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
                                        vehicle['make_model']?.toString() ?? 'Mobil Telkom',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Hanken Grotesk',
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF191C1D),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        vehicle['registration_no']?.toString() ?? 'B XXXX XX',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 14,
                                          color: Color(0xFF5C403D),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFDAD6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.key,
                                        size: 14,
                                        color: Color(0xFF93000A),
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Sedang Dipinjam',
                                        style: TextStyle(
                                          fontFamily: 'Inter',
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF93000A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF3F4F5),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 20,
                                    backgroundColor: Color(0xFFD6E3FF),
                                    child: Icon(
                                      Icons.person,
                                      color: Color(0xFF254779),
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'DRIVER SAAT INI',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF5C403D),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          profile['full_name']?.toString() ?? 'Driver',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF191C1D),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  InkWell(
                                    onTap: () => onLaunchWA(phone),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 14,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF25D366),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.chat,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            'WA',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 14),

                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      side: const BorderSide(
                                        color: Color(0xFFE1E3E4),
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: const Icon(
                                      Icons.history,
                                      color: Color(0xFFBB0016),
                                      size: 18,
                                    ),
                                    label: const FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Riwayat',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFBB0016),
                                        ),
                                      ),
                                    ),
                                    onPressed: onNavigateToHistory,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFBB0016),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    icon: const Icon(Icons.directions, size: 18),
                                    label: const FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        'Rute',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    onPressed: () => onLaunchMaps(destination),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              height: 28,
                              thickness: 1,
                              color: Color(0xFFE1E3E4),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
