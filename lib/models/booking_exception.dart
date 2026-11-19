/// Thrown when a booking cannot be made. [message] is safe to show to users.
class BookingException implements Exception {
  final String message;

  const BookingException(this.message);

  @override
  String toString() => message;
}
