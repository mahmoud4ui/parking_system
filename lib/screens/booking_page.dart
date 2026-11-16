import 'package:flutter/material.dart';

import '../models/garage.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import 'booking_confirmation_page.dart';

class BookingPage extends StatefulWidget {
  final Garage garage;

  const BookingPage({super.key, required this.garage});

  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  int _durationHours = 1;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();

    // Default to the next quarter hour, at least 15 minutes from now, so the
    // preselected start time is never already in the past.
    final soon = DateTime.now().add(const Duration(minutes: 15));
    final roundedMinutes = (soon.minute / 15).ceil() * 15;
    final start = DateTime(soon.year, soon.month, soon.day, soon.hour)
        .add(Duration(minutes: roundedMinutes));

    _selectedDate = DateTime(start.year, start.month, start.day);
    _selectedTime = TimeOfDay.fromDateTime(start);
  }

  double get _totalPrice => widget.garage.pricePerHour * _durationHours;

  DateTime get _startDateTime => DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(today) ? today : _selectedDate,
      firstDate: today,
      lastDate: today.add(const Duration(days: 365)),
    );

    if (picked == null || !mounted) return;
    setState(() {
      _selectedDate = picked;
    });
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (picked == null || !mounted) return;
    setState(() {
      _selectedTime = picked;
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _confirmBooking() async {
    if (_isSubmitting) return;

    final start = _startDateTime;
    final now = DateTime.now();
    final currentMinute =
        DateTime(now.year, now.month, now.day, now.hour, now.minute);

    if (start.isBefore(currentMinute)) {
      _showMessage('Please choose a start time in the future.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final booking = await StorageService.createBooking(
        garage: widget.garage,
        start: start,
        durationHours: _durationHours,
      );

      if (!mounted) return;

      // Replace this page so "back" from the confirmation can't land here and
      // create a second booking.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => BookingConfirmationPage(
            garage: widget.garage,
            booking: booking,
          ),
        ),
      );
    } on BookingException catch (error) {
      if (!mounted) return;
      _showMessage(error.message);
    } catch (_) {
      if (!mounted) return;
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageBackground,
      appBar: AppBar(title: const Text('Book Parking')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.garage.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              widget.garage.area,
              style: const TextStyle(color: secondaryText),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select parking date',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: darkText,
              ),
            ),
            const SizedBox(height: 10),
            _PickerTile(
              icon: Icons.calendar_month,
              title: 'Parking date',
              value: formatDate(_selectedDate),
              onTap: _pickDate,
            ),
            const SizedBox(height: 16),
            _PickerTile(
              icon: Icons.access_time,
              title: 'Start time',
              value: _selectedTime.format(context),
              onTap: _pickTime,
            ),
            const SizedBox(height: 16),
            _buildDurationCard(),
            const SizedBox(height: 20),
            _buildPriceSummary(),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _confirmBooking,
                icon: _isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(_isSubmitting ? 'Booking…' : 'Confirm Booking'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: primaryTeal.withValues(alpha: 0.6),
                  disabledForegroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Parking duration',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: darkText,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Text('Hours:', style: TextStyle(color: secondaryText)),
              const Spacer(),
              IconButton(
                onPressed: _durationHours > 1
                    ? () => setState(() => _durationHours--)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
                color: primaryTeal,
              ),
              Text(
                '$_durationHours',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              IconButton(
                onPressed: _durationHours < 24
                    ? () => setState(() => _durationHours++)
                    : null,
                icon: const Icon(Icons.add_circle_outline),
                color: primaryTeal,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSummary() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: lightTeal,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Price summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Hourly rate',
                  style: TextStyle(color: secondaryText)),
              Text(
                formatPrice(widget.garage.pricePerHour),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: darkText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Duration', style: TextStyle(color: secondaryText)),
              Text(
                '$_durationHours hours',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: darkText,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
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
                formatPrice(_totalPrice),
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
    );
  }
}

class _PickerTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _PickerTile({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Material (not Container) so the tile's tap ripple is drawn on top of
    // the white background instead of being hidden behind it.
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(icon, color: primaryTeal),
        title: Text(title),
        subtitle: Text(value),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
