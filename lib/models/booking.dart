enum BookingPhase { upcoming, active, completed, cancelled }

class Booking {
  static const String confirmed = 'Confirmed';
  static const String cancelled = 'Cancelled';

  final String id;
  final String reference;
  final String garageName;
  final DateTime date;
  final int timeHour;
  final int timeMinute;
  final int durationHours;
  final double totalPrice;
  final String status;

  const Booking({
    required this.id,
    required this.reference,
    required this.garageName,
    required this.date,
    required this.timeHour,
    required this.timeMinute,
    required this.durationHours,
    required this.totalPrice,
    required this.status,
  });

  bool get isConfirmed => status == confirmed;

  DateTime get start =>
      DateTime(date.year, date.month, date.day, timeHour, timeMinute);

  DateTime get end => start.add(Duration(hours: durationHours));

  BookingPhase phaseAt(DateTime now) {
    if (!isConfirmed) return BookingPhase.cancelled;
    if (now.isBefore(start)) return BookingPhase.upcoming;
    if (now.isBefore(end)) return BookingPhase.active;
    return BookingPhase.completed;
  }

  Booking copyWith({String? status}) {
    return Booking(
      id: id,
      reference: reference,
      garageName: garageName,
      date: date,
      timeHour: timeHour,
      timeMinute: timeMinute,
      durationHours: durationHours,
      totalPrice: totalPrice,
      status: status ?? this.status,
    );
  }

  // The JSON keys match the format used by earlier versions of the app,
  // so bookings that are already saved on a device keep loading.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reference': reference,
      'garageName': garageName,
      'date': date.toIso8601String(),
      'timeHour': timeHour,
      'timeMinute': timeMinute,
      'durationHours': durationHours,
      'totalPrice': totalPrice,
      'status': status,
    };
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'] as String,
      reference: (json['reference'] as String?) ?? 'Not available',
      garageName: json['garageName'] as String,
      date: DateTime.parse(json['date'] as String),
      timeHour: json['timeHour'] as int,
      timeMinute: json['timeMinute'] as int,
      durationHours: json['durationHours'] as int,
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: (json['status'] as String?) ?? confirmed,
    );
  }
}
