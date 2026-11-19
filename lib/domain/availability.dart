import '../models/booking.dart';
import '../models/garage.dart';

/// Pure availability rules. No storage, no clock, no Flutter: everything is
/// passed in, which makes these trivial to unit test.
///
/// Availability is derived from the bookings themselves (there is no separate
/// counter to drift out of sync).

/// How far ahead a booking has to start to count towards "spaces left".
/// A booking made for next week should not make a garage look full today.
const Duration availabilityHorizon = Duration(hours: 24);

/// The most spaces in use at the same moment between `from` and `to` for [garageName].
int peakOccupancy(
  List<Booking> bookings,
  String garageName,
  DateTime from,
  DateTime to,
) {
  final relevant = bookings
      .where((b) =>
          b.garageName == garageName &&
          b.isConfirmed &&
          b.start.isBefore(to) &&
          b.end.isAfter(from))
      .toList();

  // Occupancy only increases when a booking starts, so checking the start
  // of the window and each booking start inside it finds the peak.
  final checkPoints = <DateTime>[
    from,
    ...relevant.map((b) => b.start).where(
          (t) => t.isAfter(from) && t.isBefore(to),
        ),
  ];

  var peak = 0;
  for (final t in checkPoints) {
    final inUse =
        relevant.where((b) => !b.start.isAfter(t) && b.end.isAfter(t)).length;
    if (inUse > peak) peak = inUse;
  }
  return peak;
}

/// Spaces shown on cards and pins: total minus confirmed bookings that are
/// still running or start within [availabilityHorizon] of [now].
int spacesFree(Garage garage, List<Booking> bookings, DateTime now) {
  final horizon = now.add(availabilityHorizon);
  final reserved = bookings
      .where((b) =>
          b.garageName == garage.name &&
          b.isConfirmed &&
          b.end.isAfter(now) &&
          b.start.isBefore(horizon))
      .length;
  return (garage.totalSpaces - reserved).clamp(0, garage.totalSpaces).toInt();
}

/// Spaces free during the whole of `from` to `to`. Used by the booking page.
int spacesFreeForSlot(
  Garage garage,
  List<Booking> bookings,
  DateTime from,
  DateTime to,
) {
  final peak = peakOccupancy(bookings, garage.name, from, to);
  return (garage.totalSpaces - peak).clamp(0, garage.totalSpaces).toInt();
}

/// True if at least one space is free for the whole of `from` to `to`.
bool isSlotAvailable(
  Garage garage,
  List<Booking> bookings,
  DateTime from,
  DateTime to,
) =>
    spacesFreeForSlot(garage, bookings, from, to) > 0;
