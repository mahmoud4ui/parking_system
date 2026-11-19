import 'package:flutter/material.dart';

import '../models/garage.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'availability_badge.dart';

class GarageCard extends StatelessWidget {
  final Garage garage;
  final int? availableSpaces;

  /// Straight-line distance in metres, when the user's location is known.
  final double? distanceMeters;
  final bool isSaved;
  final VoidCallback onTap;
  final VoidCallback onToggleSaved;

  const GarageCard({
    super.key,
    required this.garage,
    required this.availableSpaces,
    this.distanceMeters,
    required this.isSaved,
    required this.onTap,
    required this.onToggleSaved,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 76,
                height: 88,
                decoration: BoxDecoration(
                  color: lightTeal,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(garage.icon, size: 36, color: primaryTeal),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      garage.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: secondaryText,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            garage.area,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (distanceMeters != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.near_me_outlined,
                            size: 14,
                            color: primaryTeal,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${formatDistance(distanceMeters!)} away',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryTeal,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          size: 14,
                          color: successGreen,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          garage.type,
                          style: const TextStyle(
                            fontSize: 12,
                            color: secondaryText,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          garage.priceLabel,
                          style: const TextStyle(
                            color: primaryTeal,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        AvailabilityBadge(
                          available: availableSpaces,
                          total: garage.totalSpaces,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    tooltip:
                        isSaved ? 'Remove saved parking' : 'Save parking',
                    onPressed: onToggleSaved,
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: primaryTeal,
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: secondaryText),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
