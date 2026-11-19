import 'package:flutter_test/flutter_test.dart';
import 'package:parking_system/data/sample_garages.dart';
import 'package:parking_system/domain/availability.dart';
import 'package:parking_system/models/booking.dart';

import 'helpers/fakes.dart';

void main() {
  final garage = sampleGarages.first;
  final now = DateTime(2026, 6, 1, 12, 0);

  List<Booking> many(int count, DateTime start, {int hours = 1}) => [
        for (var i = 0; i < count; i++)
          makeBooking(id: '$i', garageName: garage.name, start: start, durationHours: hours),
      ];

  group('spacesFree', () {
    test('all spaces are free with no bookings', () {
      expect(spacesFree(garage, const [], now), garage.totalSpaces);
    });

    test('a running or upcoming booking takes a space', () {
      final bookings = [
        makeBooking(id: 'a', garageName: garage.name, start: now.subtract(const Duration(minutes: 30))),
        makeBooking(id: 'b', garageName: garage.name, start: now.add(const Duration(hours: 2))),
      ];
      expect(spacesFree(garage, bookings, now), garage.totalSpaces - 2);
    });

    test('bookings for other garages are ignored', () {
      final bookings = [
        makeBooking(garageName: sampleGarages[1].name, start: now),
      ];
      expect(spacesFree(garage, bookings, now), garage.totalSpaces);
    });

    test('a booking beyond the 24 hour horizon is not counted', () {
      final bookings = [
        makeBooking(garageName: garage.name, start: now.add(const Duration(hours: 48))),
      ];
      expect(spacesFree(garage, bookings, now), garage.totalSpaces);
    });

    test('a booking that already ended is not counted', () {
      final bookings = [
        makeBooking(garageName: garage.name, start: now.subtract(const Duration(hours: 6))),
      ];
      expect(spacesFree(garage, bookings, now), garage.totalSpaces);
    });

    test('a cancelled booking is not counted', () {
      final bookings = [
        makeBooking(garageName: garage.name, start: now, status: Booking.cancelled),
      ];
      expect(spacesFree(garage, bookings, now), garage.totalSpaces);
    });

    test('never goes below zero', () {
      expect(spacesFree(garage, many(garage.totalSpaces + 5, now), now), 0);
    });
  });

  group('peakOccupancy', () {
    test('back-to-back bookings do not overlap', () {
      final bookings = [
        makeBooking(id: 'a', garageName: garage.name, start: now),
        makeBooking(id: 'b', garageName: garage.name, start: now.add(const Duration(hours: 1))),
      ];
      expect(
        peakOccupancy(bookings, garage.name, now, now.add(const Duration(hours: 2))),
        1,
      );
    });

    test('overlapping bookings add up at their overlap', () {
      final bookings = [
        makeBooking(id: 'a', garageName: garage.name, start: now, durationHours: 2),
        makeBooking(id: 'b', garageName: garage.name, start: now.add(const Duration(hours: 1)), durationHours: 2),
      ];
      expect(
        peakOccupancy(bookings, garage.name, now, now.add(const Duration(hours: 3))),
        2,
      );
    });
  });

  group('slot availability', () {
    test('a full slot is unavailable but a later slot is free', () {
      final bookings = many(garage.totalSpaces, now);
      final end = now.add(const Duration(hours: 1));

      expect(spacesFreeForSlot(garage, bookings, now, end), 0);
      expect(isSlotAvailable(garage, bookings, now, end), isFalse);

      final later = now.add(const Duration(hours: 3));
      expect(
        isSlotAvailable(garage, bookings, later, later.add(const Duration(hours: 1))),
        isTrue,
      );
    });

    test('free count for a slot reflects the busiest moment', () {
      final bookings = many(3, now);
      expect(
        spacesFreeForSlot(garage, bookings, now, now.add(const Duration(hours: 2))),
        garage.totalSpaces - 3,
      );
    });
  });
}
