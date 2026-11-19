import '../models/booking.dart';

/// Schedules reminders for bookings. Everything is best-effort: an
/// implementation must never throw because notifications are unavailable.
abstract class ReminderService {
  Future<void> scheduleBookingReminders(Booking booking);
  Future<void> cancelBookingReminders(String bookingId);

  /// Debug helper. Returns a message describing what happened.
  Future<String> sendTestNotifications();
}
