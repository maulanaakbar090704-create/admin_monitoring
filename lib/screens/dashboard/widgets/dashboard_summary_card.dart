import 'package:flutter/material.dart';

class DashboardSummaryCard extends StatelessWidget {
  final String title;
  final String count;
  final Color themeColor;
  final IconData? icon;
  final String unit;
  final bool isSelected;
  final VoidCallback? onTap;

  const DashboardSummaryCard({
    super.key,
    required this.title,
    required this.count,
    required this.themeColor,
    this.icon,
    this.unit = 'Unit',
    this.isSelected = false,
    this.onTap,
  });

  IconData _getDefaultIcon() {
    final lower = title.toLowerCase();
    if (lower.contains('selesai') || lower.contains('completed')) {
      return Icons.check_circle_rounded;
    } else if (lower.contains('menunggu') || lower.contains('pending') || lower.contains('acc')) {
      return Icons.hourglass_top_rounded;
    } else {
      return Icons.directions_car_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cardIcon = icon ?? _getDefaultIcon();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? themeColor.withValues(alpha: 0.08) : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? themeColor : const Color(0xFFE2E8F0),
              width: isSelected ? 1.8 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? themeColor.withValues(alpha: 0.15)
                    : Colors.black.withValues(alpha: 0.03),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row: Icon + Optional Indicator Dot
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: themeColor.withValues(alpha: isSelected ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      cardIcon,
                      color: themeColor,
                      size: 17,
                    ),
                  ),
                  if (isSelected)
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: themeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              // Count & Unit (Dinamis & Responsif)
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      count,
                      style: TextStyle(
                        fontFamily: 'Hanken Grotesk',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: themeColor,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              // Title text (spans full card width, no awkward syllable breaking)
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? themeColor : const Color(0xFF1E293B),
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
