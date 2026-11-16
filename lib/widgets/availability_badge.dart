import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

const Color _warningAmber = Color(0xFFD97706);
const Color _fullRed = Color(0xFFDC2626);

Color availabilityColor(int available, int total) {
  if (available <= 0) return _fullRed;
  if (available / total <= 0.25) return _warningAmber;
  return successGreen;
}

/// Small pill such as "12 of 25 free". Renders nothing until [available]
/// has loaded.
class AvailabilityBadge extends StatelessWidget {
  final int? available;
  final int total;

  const AvailabilityBadge({
    super.key,
    required this.available,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final free = available;
    if (free == null) return const SizedBox.shrink();

    final color = availabilityColor(free, total);
    final label = free <= 0 ? 'Full' : '$free of $total free';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
