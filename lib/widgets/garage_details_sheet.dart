import 'package:flutter/material.dart';

import '../models/garage.dart';
import '../screens/booking_page.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/directions.dart';
import 'availability_badge.dart';

/// Shows the garage details bottom sheet with live availability, a Directions
/// button and "Book Parking".
void showGarageDetails(BuildContext context, Garage garage) {
  // Grab the navigator now: the sheet's own context disappears once popped.
  final navigator = Navigator.of(context);
  final availability = StorageService.getAvailableSpaces(garage);

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 42,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Icon(garage.icon, size: 48, color: primaryTeal),
                const SizedBox(height: 16),
                Text(
                  garage.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  garage.area,
                  style: const TextStyle(fontSize: 15, color: secondaryText),
                ),
                const SizedBox(height: 24),
                _DetailRow(
                  icon: Icons.attach_money,
                  label: 'Price',
                  trailing: _valueText(garage.priceLabel),
                ),
                _DetailRow(
                  icon: Icons.event_seat_outlined,
                  label: 'Availability',
                  trailing: FutureBuilder<int>(
                    future: availability,
                    builder: (context, snapshot) => AvailabilityBadge(
                      available: snapshot.data,
                      total: garage.totalSpaces,
                    ),
                  ),
                ),
                _DetailRow(
                  icon: Icons.roofing_outlined,
                  label: 'Parking type',
                  trailing: _valueText(garage.type),
                ),
                _DetailRow(
                  icon: Icons.access_time,
                  label: 'Opening hours',
                  trailing: _valueText(garage.hours),
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: lightTeal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Demo listing — availability and pricing '
                    'have not been verified.',
                    style: TextStyle(color: primaryTeal, fontSize: 13),
                  ),
                ),
                const SizedBox(height: 16),
                FutureBuilder<int>(
                  future: availability,
                  builder: (context, snapshot) {
                    final isFull = snapshot.hasData && snapshot.data! <= 0;

                    return Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                openDirections(sheetContext, garage),
                            icon: const Icon(Icons.directions_outlined),
                            label: const Text('Directions'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: primaryTeal,
                              side: const BorderSide(color: primaryTeal),
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: isFull
                                ? null
                                : () {
                                    Navigator.pop(sheetContext);
                                    navigator.push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            BookingPage(garage: garage),
                                      ),
                                    );
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: primaryTeal,
                              padding: const EdgeInsets.all(16),
                            ),
                            child: Text(isFull ? 'Garage full' : 'Book Parking'),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Widget _valueText(String value) {
  return Text(
    value,
    style: const TextStyle(fontWeight: FontWeight.w600, color: darkText),
  );
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        children: [
          Icon(icon, color: primaryTeal),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: const TextStyle(color: secondaryText)),
          ),
          trailing,
        ],
      ),
    );
  }
}
