import 'package:flutter_test/flutter_test.dart';
import 'package:parking_system/data/sample_garages.dart';
import 'package:parking_system/models/garage.dart';
import 'package:parking_system/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // The first sample garage has 25 spaces.
  final Garage garage = sampleGarages.first;

  late DateTime soon;

  setUp(() {
    SharedPreferences.setMockInitialValues({});

    // A time slot an hour from now, on a whole minute.
    final now = DateTime.now().add(const Duration(hours: 1));
    soon = DateTime(now.year, now.month, now.day, now.hour, now.minute);
  });

  Future<int> freeSpaces() async {
    final availability = await StorageService.loadAvailability();
    return availability[garage.name]!;
  }

  group('availability', () {
    test('every garage starts with all spaces free', () async {
      final availability = await StorageService.loadAvailability();

      for (final g in sampleGarages) {
        expect(availability[g.name], g.totalSpaces);
      }
    });

    test('booking takes a space and cancelling gives it back', () async {
      final booking = await StorageService.createBooking(
        garage: garage,
        start: soon,
        durationHours: 1,
      );
      expect(await freeSpaces(), garage.totalSpaces - 1);

      await StorageService.cancelBooking(booking.id);
      expect(await freeSpaces(), garage.totalSpaces);
    });

    test('a booking for another garage does not change this one', () async {
      await StorageService.createBooking(
        garage: sampleGarages[1],
        start: soon,
        durationHours: 1,
      );

      expect(await freeSpaces(), garage.totalSpaces);
    });

    test('a booking more than 24 hours away is not counted yet', () async {
      await StorageService.createBooking(
        garage: garage,
        start: soon.add(const Duration(hours: 48)),
        durationHours: 1,
      );

      expect(await freeSpaces(), garage.totalSpaces);
    });

    test('a booking that has already ended is not counted', () async {
      await StorageService.createBooking(
        garage: garage,
        start: soon.subtract(const Duration(hours: 6)),
        durationHours: 1,
      );

      expect(await freeSpaces(), garage.totalSpaces);
    });
  });

  group('creating bookings', () {
    test('stores the booking with the right price and status', () async {
      final booking = await StorageService.createBooking(
        garage: garage,
        start: soon,
        durationHours: 3,
      );

      expect(booking.totalPrice, garage.pricePerHour * 3);
      expect(booking.isConfirmed, isTrue);

      final saved = await StorageService.loadBookings();
      expect(saved, hasLength(1));
      expect(saved.single.reference, booking.reference);
    });

    test('rejects a booking when the time slot is full', () async {
      for (var i = 0; i < garage.totalSpaces; i++) {
        await StorageService.createBooking(
          garage: garage,
          start: soon,
          durationHours: 1,
        );
      }

      expect(
        () => StorageService.createBooking(
          garage: garage,
          start: soon,
          durationHours: 1,
        ),
        throwsA(isA<BookingException>()),
      );
    });

    test('a full slot does not block a different time', () async {
      for (var i = 0; i < garage.totalSpaces; i++) {
        await StorageService.createBooking(
          garage: garage,
          start: soon,
          durationHours: 1,
        );
      }

      final later = await StorageService.createBooking(
        garage: garage,
        start: soon.add(const Duration(hours: 3)),
        durationHours: 1,
      );

      expect(later.isConfirmed, isTrue);
    });

    test('a cancelled booking frees its slot for someone else', () async {
      final bookings = [
        for (var i = 0; i < garage.totalSpaces; i++)
          await StorageService.createBooking(
            garage: garage,
            start: soon,
            durationHours: 1,
          ),
      ];

      await StorageService.cancelBooking(bookings.first.id);

      final replacement = await StorageService.createBooking(
        garage: garage,
        start: soon,
        durationHours: 1,
      );
      expect(replacement.isConfirmed, isTrue);
    });
  });

  group('profile and onboarding', () {
    test('profile falls back to defaults, then keeps what was saved',
        () async {
      var profile = await StorageService.loadProfile();
      expect(profile.name, StorageService.defaultProfile.name);

      await StorageService.saveProfile(name: 'Sara', email: 'sara@test.com');

      profile = await StorageService.loadProfile();
      expect(profile.name, 'Sara');
      expect(profile.email, 'sara@test.com');
    });

    test('onboarding is shown once', () async {
      expect(await StorageService.hasSeenOnboarding(), isFalse);

      await StorageService.markOnboardingSeen();

      expect(await StorageService.hasSeenOnboarding(), isTrue);
    });
  });
}
