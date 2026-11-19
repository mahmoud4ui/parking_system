import 'package:flutter_test/flutter_test.dart';
import 'package:parking_system/models/user_profile.dart';
import 'package:parking_system/repositories/local_parking_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('bookings survive a round trip', () async {
    final repository = LocalParkingRepository();
    final booking = makeBooking(start: DateTime(2026, 6, 1, 14, 30), durationHours: 2);

    await repository.saveBookings([booking]);
    final loaded = await repository.loadBookings();

    expect(loaded.single.id, booking.id);
    expect(loaded.single.start, booking.start);
    expect(loaded.single.durationHours, 2);
  });

  test('an unreadable booking is skipped, not fatal', () async {
    SharedPreferences.setMockInitialValues({
      LocalParkingRepository.bookingsKey: ['not json'],
    });

    expect(await LocalParkingRepository().loadBookings(), isEmpty);
  });

  test('saved garages round trip', () async {
    final repository = LocalParkingRepository();

    await repository.saveSavedGarageNames({'A', 'B'});

    expect(await repository.loadSavedGarageNames(), {'A', 'B'});
  });

  test('profile falls back to defaults, then keeps what was saved', () async {
    final repository = LocalParkingRepository();
    expect((await repository.loadProfile()).name, UserProfile.defaults.name);

    await repository.saveProfile(const UserProfile(name: 'Sara', email: 's@t.co'));

    final profile = await repository.loadProfile();
    expect(profile.name, 'Sara');
    expect(profile.email, 's@t.co');
  });

  test('onboarding is shown once', () async {
    final repository = LocalParkingRepository();
    expect(await repository.hasSeenOnboarding(), isFalse);

    await repository.markOnboardingSeen();

    expect(await repository.hasSeenOnboarding(), isTrue);
  });
}
