import 'dart:async';

import 'package:flutter/foundation.dart';

import '../data/sample_garages.dart';
import '../domain/availability.dart';
import '../models/booking.dart';
import '../models/booking_exception.dart';
import '../models/garage.dart';
import '../repositories/parking_repository.dart';
import '../services/reminder_service.dart';

/// Owns the list of bookings. The in-memory list is the source of truth for
/// the UI; every change is written through to the repository.
///
/// Screens `watch` this controller, so availability badges, the map pins and
/// the booking lists all update from the same state.
class BookingsController extends ChangeNotifier {
  BookingsController({
    required ParkingRepository repository,
    required ReminderService reminders,
    DateTime Function()? clock,
    Duration? refreshInterval,
  })  : _repository = repository,
        _reminders = reminders,
        _clock = clock ?? DateTime.now {
    // Bookings expire with time, not only with user actions, so availability
    // is refreshed on a timer.
    if (refreshInterval != null) {
      _timer = Timer.periodic(refreshInterval, (_) => _notify());
    }
  }

  final ParkingRepository _repository;
  final ReminderService _reminders;
  final DateTime Function() _clock;
  Timer? _timer;

  List<Booking> _bookings = const [];
  bool _isLoaded = false;
  bool _isDisposed = false;
  Future<void>? _loading;
  int _idCounter = 0;

  List<Booking> get bookings => List.unmodifiable(_bookings);
  bool get isLoaded => _isLoaded;

  DateTime get now => _clock();

  /// Loads bookings once. Safe to call repeatedly.
  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    _bookings = await _repository.loadBookings();
    _isLoaded = true;
    _notify();
  }

  /// Spaces shown on cards, pins and the details sheet.
  int freeSpaces(Garage garage) => spacesFree(garage, _bookings, _clock());

  Map<String, int> get freeSpacesByGarage => {
        for (final garage in sampleGarages) garage.name: freeSpaces(garage),
      };

  /// Spaces free for a specific time slot, shown on the booking page.
  int freeSpacesForSlot(Garage garage, DateTime start, int durationHours) =>
      spacesFreeForSlot(
        garage,
        _bookings,
        start,
        start.add(Duration(hours: durationHours)),
      );

  bool isSlotAvailable(Garage garage, DateTime start, int durationHours) =>
      freeSpacesForSlot(garage, start, durationHours) > 0;

  /// Creates a confirmed booking.
  /// Throws [BookingException] if the garage is full for that time slot.
  Future<Booking> createBooking({
    required Garage garage,
    required DateTime start,
    required int durationHours,
  }) async {
    await load();

    if (!isSlotAvailable(garage, start, durationHours)) {
      throw const BookingException(
        'Sorry, this parking garage is full at that time.',
      );
    }

    final created = _clock();
    final booking = Booking(
      id: '${created.microsecondsSinceEpoch + _idCounter++}',
      reference: 'PK-${created.millisecondsSinceEpoch}',
      garageName: garage.name,
      date: DateTime(start.year, start.month, start.day),
      timeHour: start.hour,
      timeMinute: start.minute,
      durationHours: durationHours,
      totalPrice: garage.pricePerHour * durationHours,
      status: Booking.confirmed,
    );

    _bookings = [..._bookings, booking];
    _notify();
    await _repository.saveBookings(_bookings);

    // Best-effort: never fails the booking if notifications are unavailable.
    await _reminders.scheduleBookingReminders(booking);
    return booking;
  }

  /// Marks a booking as cancelled, which frees its space.
  Future<void> cancelBooking(String bookingId) async {
    await load();

    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index == -1 || !_bookings[index].isConfirmed) return;

    _bookings = [..._bookings]
      ..[index] = _bookings[index].copyWith(status: Booking.cancelled);
    _notify();
    await _repository.saveBookings(_bookings);
    await _reminders.cancelBookingReminders(bookingId);
  }

  void _notify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
