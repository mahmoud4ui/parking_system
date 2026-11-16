import 'package:flutter_test/flutter_test.dart';
import 'package:parking_system/models/booking.dart';

Booking _booking({String status = Booking.confirmed}) {
  // 10:00 to 12:00 on 1 Jan 2026.
  return Booking(
    id: '1',
    reference: 'PK-1',
    garageName: 'Marina Parking',
    date: DateTime(2026, 1, 1),
    timeHour: 10,
    timeMinute: 0,
    durationHours: 2,
    totalPrice: 20,
    status: status,
  );
}

void main() {
  group('Booking times', () {
    test('start and end are built from date, time and duration', () {
      final booking = _booking();

      expect(booking.start, DateTime(2026, 1, 1, 10, 0));
      expect(booking.end, DateTime(2026, 1, 1, 12, 0));
    });
  });

  group('Booking phase', () {
    test('is upcoming before the start time', () {
      expect(
        _booking().phaseAt(DateTime(2026, 1, 1, 9, 59)),
        BookingPhase.upcoming,
      );
    });

    test('is active from the start time until the end time', () {
      final booking = _booking();

      expect(booking.phaseAt(DateTime(2026, 1, 1, 10, 0)), BookingPhase.active);
      expect(
        booking.phaseAt(DateTime(2026, 1, 1, 11, 59)),
        BookingPhase.active,
      );
    });

    test('is completed once the end time is reached', () {
      expect(
        _booking().phaseAt(DateTime(2026, 1, 1, 12, 0)),
        BookingPhase.completed,
      );
    });

    test('is cancelled whatever the time when the status is cancelled', () {
      final booking = _booking(status: Booking.cancelled);

      expect(
        booking.phaseAt(DateTime(2026, 1, 1, 9, 0)),
        BookingPhase.cancelled,
      );
      expect(
        booking.phaseAt(DateTime(2026, 1, 1, 11, 0)),
        BookingPhase.cancelled,
      );
    });
  });

  group('Booking JSON', () {
    test('survives a round trip', () {
      final original = _booking();
      final copy = Booking.fromJson(original.toJson());

      expect(copy.id, original.id);
      expect(copy.reference, original.reference);
      expect(copy.garageName, original.garageName);
      expect(copy.start, original.start);
      expect(copy.durationHours, original.durationHours);
      expect(copy.totalPrice, original.totalPrice);
      expect(copy.status, original.status);
    });

    test('reads bookings saved without a status or reference', () {
      final json = _booking().toJson()
        ..remove('status')
        ..remove('reference');

      final booking = Booking.fromJson(json);

      expect(booking.isConfirmed, isTrue);
      expect(booking.reference, 'Not available');
    });
  });
}
