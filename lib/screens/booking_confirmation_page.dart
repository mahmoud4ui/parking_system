import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/booking.dart';
import '../models/garage.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class BookingConfirmationPage extends StatelessWidget {
  final Garage garage;
  final Booking booking;

  const BookingConfirmationPage({
    super.key,
    required this.garage,
    required this.booking,
  });

  Future<void> _copyReference(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: booking.reference));

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking reference copied!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final startTime = TimeOfDay(
      hour: booking.timeHour,
      minute: booking.timeMinute,
    );

    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(
        title: const Text('Booking Confirmation'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 24),
            const CircleAvatar(
              radius: 42,
              backgroundColor: lightTeal,
              child: Icon(Icons.check_circle, color: primaryTeal, size: 52),
            ),
            const SizedBox(height: 20),
            const Text(
              'Booking Confirmed!',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: lightTeal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Booking Reference',
                    style: TextStyle(color: secondaryText, fontSize: 13),
                  ),
                  const SizedBox(height: 6),
                  SelectableText(
                    booking.reference,
                    style: const TextStyle(
                      color: primaryTeal,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _copyReference(context),
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Reference'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryTeal,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your parking reservation has been confirmed.',
              textAlign: TextAlign.center,
              style: TextStyle(color: secondaryText, fontSize: 14),
            ),
            const SizedBox(height: 30),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reservation details',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _ConfirmationRow(
                    icon: Icons.local_parking,
                    label: 'Parking location',
                    value: garage.name,
                  ),
                  _ConfirmationRow(
                    icon: Icons.location_on_outlined,
                    label: 'Area',
                    value: garage.area,
                  ),
                  _ConfirmationRow(
                    icon: Icons.calendar_month,
                    label: 'Date',
                    value: formatDate(booking.date),
                  ),
                  _ConfirmationRow(
                    icon: Icons.access_time,
                    label: 'Start time',
                    value: startTime.format(context),
                  ),
                  _ConfirmationRow(
                    icon: Icons.timelapse,
                    label: 'Duration',
                    value: formatHours(booking.durationHours),
                  ),
                  const Divider(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total price',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      Text(
                        formatPrice(booking.totalPrice),
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: primaryTeal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home_outlined),
                label: const Text('Back to Home'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ConfirmationRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: primaryTeal, size: 21),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: secondaryText, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: darkText,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
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
