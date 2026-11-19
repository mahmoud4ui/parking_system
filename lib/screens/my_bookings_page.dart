import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/booking.dart';
import '../state/bookings_controller.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';

class MyBookingsPage extends StatefulWidget {
  const MyBookingsPage({super.key});

  @override
  State<MyBookingsPage> createState() => _MyBookingsPageState();
}

class _MyBookingsPageState extends State<MyBookingsPage> {
  DateTime _now = DateTime.now();
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    // Drives the live countdowns.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _confirmAndCancel(Booking booking) async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Cancel Booking?'),
          content: const Text(
            'Are you sure you want to cancel this booking?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Keep Booking'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text(
                'Cancel Booking',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true || !mounted) return;

    await context.read<BookingsController>().cancelBooking(booking.id);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking cancelled successfully.')),
    );
  }

  bool _isUpcoming(Booking booking) {
    final phase = booking.phaseAt(_now);
    return phase == BookingPhase.upcoming || phase == BookingPhase.active;
  }

  @override
  Widget build(BuildContext context) {
    // Upcoming: soonest first. History: most recent first. Bookings move
    // from one tab to the other by themselves when their session ends.
    final all = context.watch<BookingsController>().bookings;
    final upcoming = all.where(_isUpcoming).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    final history = all.where((b) => !_isUpcoming(b)).toList()
      ..sort((a, b) => b.start.compareTo(a.start));

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: pageBackground,
        appBar: AppBar(
          title: const Text('My Bookings'),
          backgroundColor: primaryTeal,
          foregroundColor: Colors.white,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Upcoming (${upcoming.length})'),
              Tab(text: 'History (${history.length})'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(
              upcoming,
              emptyIcon: Icons.event_available_outlined,
              emptyTitle: 'No upcoming bookings',
              emptyMessage: 'Book a parking spot and it will show up here.',
            ),
            _buildList(
              history,
              emptyIcon: Icons.history,
              emptyTitle: 'No past bookings',
              emptyMessage: 'Completed and cancelled bookings appear here.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(
    List<Booking> bookings, {
    required IconData emptyIcon,
    required String emptyTitle,
    required String emptyMessage,
  }) {
    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(emptyIcon, size: 48, color: secondaryText),
              const SizedBox(height: 12),
              Text(
                emptyTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: darkText,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                emptyMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: secondaryText),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return _BookingCard(
          booking: booking,
          now: _now,
          onCancel: () => _confirmAndCancel(booking),
        );
      },
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;
  final DateTime now;
  final VoidCallback onCancel;

  const _BookingCard({
    required this.booking,
    required this.now,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final phase = booking.phaseAt(now);
    final time = TimeOfDay(hour: booking.timeHour, minute: booking.timeMinute);
    final canCancel =
        phase == BookingPhase.upcoming || phase == BookingPhase.active;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.garageName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: darkText,
                    ),
                  ),
                ),
                _PhaseChip(phase: phase),
              ],
            ),
            const SizedBox(height: 12),
            _Countdown(booking: booking, phase: phase, now: now),
            const SizedBox(height: 12),
            Text('Date: ${formatDate(booking.date)}'),
            Text('Start time: ${time.format(context)}'),
            Text('Duration: ${formatHours(booking.durationHours)}'),
            const SizedBox(height: 8),
            Text(
              'Total: ${formatPrice(booking.totalPrice)}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: primaryTeal,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Reference: ${booking.reference}',
              style: const TextStyle(
                fontSize: 12,
                color: secondaryText,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (canCancel) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.cancel_outlined, color: Colors.red),
                  label: const Text(
                    'Cancel Booking',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "Starts in …" / "Time left …" with a progress bar while parked.
class _Countdown extends StatelessWidget {
  final Booking booking;
  final BookingPhase phase;
  final DateTime now;

  const _Countdown({
    required this.booking,
    required this.phase,
    required this.now,
  });

  @override
  Widget build(BuildContext context) {
    switch (phase) {
      case BookingPhase.upcoming:
        return _panel(
          icon: Icons.schedule,
          color: primaryTeal,
          label: 'Starts in',
          value: formatCountdown(booking.start.difference(now)),
        );

      case BookingPhase.active:
        final total = booking.end.difference(booking.start).inSeconds;
        final elapsed = now.difference(booking.start).inSeconds;
        final progress = total == 0 ? 1.0 : (elapsed / total).clamp(0.0, 1.0);

        return _panel(
          icon: Icons.timer_outlined,
          color: successGreen,
          label: 'Time left',
          value: formatCountdown(booking.end.difference(now)),
          progress: progress,
        );

      case BookingPhase.completed:
        return _panel(
          icon: Icons.check_circle_outline,
          color: secondaryText,
          label: 'Parking session ended',
        );

      case BookingPhase.cancelled:
        return _panel(
          icon: Icons.block,
          color: Colors.red,
          label: 'This booking was cancelled',
        );
    }
  }

  Widget _panel({
    required IconData icon,
    required Color color,
    required String label,
    String? value,
    double? progress,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              if (value != null)
                Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                color: color,
                backgroundColor: color.withValues(alpha: 0.15),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PhaseChip extends StatelessWidget {
  final BookingPhase phase;

  const _PhaseChip({required this.phase});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (phase) {
      BookingPhase.upcoming => ('Upcoming', primaryTeal),
      BookingPhase.active => ('Active', successGreen),
      BookingPhase.completed => ('Completed', secondaryText),
      BookingPhase.cancelled => ('Cancelled', Colors.red),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }
}
