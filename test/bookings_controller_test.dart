import 'package:flutter_test/flutter_test.dart';
import 'package:parking_system/data/sample_garages.dart';
import 'package:parking_system/models/booking_exception.dart';
import 'package:parking_system/state/bookings_controller.dart';

import 'helpers/fakes.dart';

void main() {
  final garage = sampleGarages.first;
  var now = DateTime(2026, 6, 1, 12, 0);
  late InMemoryParkingRepository repository;
  late FakeReminderService reminders;
  late BookingsController controller;

  DateTime soon() => now.add(const Duration(hours: 1));

  setUp(() {
    now = DateTime(2026, 6, 1, 12, 0);
    repository = InMemoryParkingRepository();
    reminders = FakeReminderService();
    controller = BookingsController(
      repository: repository,
      reminders: reminders,
      clock: () => now,
    );
  });

  tearDown(() => controller.dispose());

  test('loads saved bookings once', () async {
    repository.bookings = [makeBooking(garageName: garage.name, start: soon())];

    await controller.load();
    await controller.load();

    expect(controller.isLoaded, isTrue);
    expect(controller.bookings, hasLength(1));
    expect(controller.freeSpaces(garage), garage.totalSpaces - 1);
  });

  test('booking takes a space, saves, and schedules reminders', () async {
    var notifications = 0;
    controller.addListener(() => notifications++);

    final booking = await controller.createBooking(
      garage: garage,
      start: soon(),
      durationHours: 3,
    );

    expect(booking.totalPrice, garage.pricePerHour * 3);
    expect(booking.isConfirmed, isTrue);
    expect(controller.freeSpaces(garage), garage.totalSpaces - 1);
    expect(repository.bookings.single.id, booking.id);
    expect(reminders.scheduled, [booking.id]);
    expect(notifications, greaterThan(0));
  });

  test('cancelling gives the space back and cancels reminders', () async {
    final booking = await controller.createBooking(
      garage: garage,
      start: soon(),
      durationHours: 1,
    );

    await controller.cancelBooking(booking.id);

    expect(controller.freeSpaces(garage), garage.totalSpaces);
    expect(repository.bookings.single.isConfirmed, isFalse);
    expect(reminders.cancelled, [booking.id]);
  });

  test('cancelling twice only cancels reminders once', () async {
    final booking = await controller.createBooking(
      garage: garage,
      start: soon(),
      durationHours: 1,
    );

    await controller.cancelBooking(booking.id);
    await controller.cancelBooking(booking.id);

    expect(reminders.cancelled, hasLength(1));
  });

  test('rejects a booking when the slot is full', () async {
    for (var i = 0; i < garage.totalSpaces; i++) {
      await controller.createBooking(
        garage: garage,
        start: soon(),
        durationHours: 1,
      );
    }

    expect(
      () => controller.createBooking(
        garage: garage,
        start: soon(),
        durationHours: 1,
      ),
      throwsA(isA<BookingException>()),
    );
    expect(controller.bookings, hasLength(garage.totalSpaces));
  });

  test('a full slot does not block a different time', () async {
    for (var i = 0; i < garage.totalSpaces; i++) {
      await controller.createBooking(
        garage: garage,
        start: soon(),
        durationHours: 1,
      );
    }

    expect(controller.isSlotAvailable(garage, soon(), 1), isFalse);
    expect(controller.freeSpacesForSlot(garage, soon(), 1), 0);

    final later = await controller.createBooking(
      garage: garage,
      start: soon().add(const Duration(hours: 3)),
      durationHours: 1,
    );
    expect(later.isConfirmed, isTrue);
  });

  test('a cancelled booking frees its slot for someone else', () async {
    final first = await controller.createBooking(
      garage: garage,
      start: soon(),
      durationHours: 1,
    );
    for (var i = 1; i < garage.totalSpaces; i++) {
      await controller.createBooking(
        garage: garage,
        start: soon(),
        durationHours: 1,
      );
    }

    await controller.cancelBooking(first.id);

    final replacement = await controller.createBooking(
      garage: garage,
      start: soon(),
      durationHours: 1,
    );
    expect(replacement.isConfirmed, isTrue);
  });

  test('booking ids are unique even within the same instant', () async {
    final a = await controller.createBooking(garage: garage, start: soon(), durationHours: 1);
    final b = await controller.createBooking(garage: garage, start: soon(), durationHours: 1);

    expect(a.id, isNot(b.id));
  });

  test('a booking stops counting once the clock passes its end', () async {
    await controller.createBooking(garage: garage, start: soon(), durationHours: 1);
    expect(controller.freeSpaces(garage), garage.totalSpaces - 1);

    now = now.add(const Duration(hours: 3));

    expect(controller.freeSpaces(garage), garage.totalSpaces);
  });

  test('freeSpacesByGarage covers every sample garage', () async {
    await controller.load();

    expect(controller.freeSpacesByGarage.keys, sampleGarages.map((g) => g.name));
  });
}
