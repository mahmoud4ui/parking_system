/// Formats a date as d/m/yyyy (e.g. 5/3/2026).
String formatDate(DateTime date) => '${date.day}/${date.month}/${date.year}';

/// Formats an amount as a dollar price with two decimals (e.g. $10.00).
String formatPrice(double amount) => '\$${amount.toStringAsFixed(2)}';

/// Formats a number of hours: "1 hour", "3 hours".
String formatHours(int hours) => hours == 1 ? '1 hour' : '$hours hours';

/// Formats a clock time such as "3:05 PM".
String formatClock(DateTime time) {
  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minute = time.minute.toString().padLeft(2, '0');
  final suffix = time.hour < 12 ? 'AM' : 'PM';
  return '$hour:$minute $suffix';
}

/// Formats a duration for a live countdown, e.g. "2d 3h 05m",
/// "1h 02m 09s" or "12m 30s".
String formatCountdown(Duration duration) {
  final d = duration.isNegative ? Duration.zero : duration;
  String two(int n) => n.toString().padLeft(2, '0');

  final minutes = d.inMinutes % 60;
  final seconds = d.inSeconds % 60;

  if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h ${two(minutes)}m';
  if (d.inHours > 0) return '${d.inHours}h ${two(minutes)}m ${two(seconds)}s';
  return '${minutes}m ${two(seconds)}s';
}
