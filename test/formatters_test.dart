import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:parking_system/data/sample_garages.dart';
import 'package:parking_system/models/garage.dart';
import 'package:parking_system/utils/formatters.dart';

void main() {
  group('formatCountdown', () {
    test('shows minutes and seconds under an hour', () {
      expect(formatCountdown(const Duration(minutes: 23, seconds: 49)),
          '23m 49s');
    });

    test('shows hours, minutes and seconds under a day', () {
      expect(
        formatCountdown(const Duration(hours: 1, minutes: 2, seconds: 9)),
        '1h 02m 09s',
      );
    });

    test('shows days, hours and minutes from a day up', () {
      expect(
        formatCountdown(const Duration(days: 2, hours: 3, minutes: 5)),
        '2d 3h 05m',
      );
    });

    test('never goes negative', () {
      expect(formatCountdown(const Duration(seconds: -30)), '0m 00s');
    });
  });

  group('formatClock', () {
    test('formats midnight, noon and afternoon times', () {
      expect(formatClock(DateTime(2026, 1, 1, 0, 5)), '12:05 AM');
      expect(formatClock(DateTime(2026, 1, 1, 12, 30)), '12:30 PM');
      expect(formatClock(DateTime(2026, 1, 1, 13, 0)), '1:00 PM');
    });
  });

  group('formatDate and formatPrice', () {
    test('format as d/m/yyyy and two-decimal dollars', () {
      expect(formatDate(DateTime(2026, 3, 5)), '5/3/2026');
      expect(formatPrice(10), '\$10.00');
    });
  });

  group('formatHours', () {
    test('uses the singular for one hour and the plural otherwise', () {
      expect(formatHours(1), '1 hour');
      expect(formatHours(3), '3 hours');
    });
  });

  group('Garage price', () {
    test('whole prices have no decimals', () {
      expect(sampleGarages.first.shortPrice, '\$10');
      expect(sampleGarages.first.priceLabel, '\$10 / hour');
    });

    test('fractional prices keep two decimals', () {
      const garage = Garage(
        name: 'Test',
        area: 'Test area',
        pricePerHour: 7.5,
        type: 'Covered',
        hours: '24 hours',
        icon: Icons.local_parking,
        totalSpaces: 5,
        location: LatLng(25, 55),
      );

      expect(garage.priceLabel, '\$7.50 / hour');
    });
  });

  group('formatDistance', () {
    test('uses metres under a kilometre, rounded to 10', () {
      expect(formatDistance(842), '840 m');
      expect(formatDistance(999), '1.0 km');
    });

    test('uses kilometres from 1 km', () {
      expect(formatDistance(1000), '1.0 km');
      expect(formatDistance(2340), '2.3 km');
    });
  });
}
