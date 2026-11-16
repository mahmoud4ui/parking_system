import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/sample_garages.dart';
import '../models/booking.dart';
import '../models/garage.dart';
import 'notification_service.dart';

/// Thrown when a booking cannot be made. [message] is safe to show to users.
class BookingException implements Exception {
  final String message;

  const BookingException(this.message);

  @override
  String toString() => message;
}

class UserProfile {
  final String name;
  final String email;

  const UserProfile({required this.name, required this.email});
}

/// All local persistence (shared_preferences) lives here, so screens never
/// touch storage keys directly.
class StorageService {
  StorageService._();

  static const String _savedGaragesKey = 'saved_garages';
  static const String _bookingsKey = 'parking_bookings';
  static const String _profileNameKey = 'profile_name';
  static const String _profileEmailKey = 'profile_email';
  static const String _onboardingKey = 'onboarding_seen';

  static const UserProfile defaultProfile = UserProfile(
    name: 'Parking User',
    email: 'user@example.com',
  );

  /// Incremented whenever bookings change, so screens showing availability
  /// can refresh themselves.
  static final ValueNotifier<int> changes = ValueNotifier<int>(0);

  static void _notifyChanged() => changes.value++;

  // ---------------------------------------------------------------------------
  // Availability
  //
  // Availability is derived from the bookings themselves (there is no separate
  // counter to drift out of sync). A confirmed booking holds a space from the
  // moment it is made until its session ends, so the count drops right after
  // booking and rises again when a booking ends or is cancelled. Only bookings
  // starting within the next 24 hours count, so one made for next week does
  // not make a garage look full today.
  //
  // Whether a specific time slot is really free is checked separately, with
  // _peakOccupancy, when a booking is created.
  // ---------------------------------------------------------------------------

  /// The most spaces that are in use at the same moment of [from, to).
  static int _peakOccupancy(
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
          relevant.where((b) => !b.start.isAfter(t) && b.end.isAfter(t));
      if (inUse.length > peak) peak = inUse.length;
    }
    return peak;
  }

  /// Spaces still free for every garage, keyed by garage name.
  static Future<Map<String, int>> loadAvailability() async {
    final bookings = await loadBookings();
    final now = DateTime.now();
    final horizon = now.add(const Duration(hours: 24));

    return {
      for (final garage in sampleGarages)
        garage.name: (garage.totalSpaces -
                bookings
                    .where((b) =>
                        b.garageName == garage.name &&
                        b.isConfirmed &&
                        b.end.isAfter(now) &&
                        b.start.isBefore(horizon))
                    .length)
            .clamp(0, garage.totalSpaces)
            .toInt(),
    };
  }

  static Future<int> getAvailableSpaces(Garage garage) async {
    final availability = await loadAvailability();
    return availability[garage.name] ?? garage.totalSpaces;
  }

  // ---------------------------------------------------------------------------
  // Onboarding
  // ---------------------------------------------------------------------------

  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingKey) ?? false;
  }

  static Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingKey, true);
  }

  // ---------------------------------------------------------------------------
  // Saved garages
  // ---------------------------------------------------------------------------

  static Future<Set<String>> loadSavedGarageNames() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_savedGaragesKey) ?? []).toSet();
  }

  static Future<void> saveGarageNames(Set<String> names) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_savedGaragesKey, names.toList());
  }

  // ---------------------------------------------------------------------------
  // Profile
  // ---------------------------------------------------------------------------

  static Future<UserProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return UserProfile(
      name: prefs.getString(_profileNameKey) ?? defaultProfile.name,
      email: prefs.getString(_profileEmailKey) ?? defaultProfile.email,
    );
  }

  static Future<void> saveProfile({
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileNameKey, name);
    await prefs.setString(_profileEmailKey, email);
  }

  // ---------------------------------------------------------------------------
  // Bookings
  // ---------------------------------------------------------------------------

  static Future<List<Booking>> loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_bookingsKey) ?? [];

    final bookings = <Booking>[];
    for (final item in raw) {
      try {
        bookings.add(
          Booking.fromJson(jsonDecode(item) as Map<String, dynamic>),
        );
      } catch (_) {
        // Skip entries that can't be read instead of breaking the whole list.
      }
    }
    return bookings;
  }

  static Future<void> _writeBookings(
    SharedPreferences prefs,
    List<Booking> bookings,
  ) {
    return prefs.setStringList(
      _bookingsKey,
      bookings.map((booking) => jsonEncode(booking.toJson())).toList(),
    );
  }

  /// Creates a confirmed booking.
  /// Throws [BookingException] if the garage is full for that time slot.
  static Future<Booking> createBooking({
    required Garage garage,
    required DateTime start,
    required int durationHours,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final bookings = await loadBookings();

    final end = start.add(Duration(hours: durationHours));
    final peak = _peakOccupancy(bookings, garage.name, start, end);
    if (peak >= garage.totalSpaces) {
      throw const BookingException(
        'Sorry, this parking garage is full at that time.',
      );
    }

    final now = DateTime.now();
    final booking = Booking(
      id: now.microsecondsSinceEpoch.toString(),
      reference: 'PK-${now.millisecondsSinceEpoch}',
      garageName: garage.name,
      date: DateTime(start.year, start.month, start.day),
      timeHour: start.hour,
      timeMinute: start.minute,
      durationHours: durationHours,
      totalPrice: garage.pricePerHour * durationHours,
      status: Booking.confirmed,
    );

    bookings.add(booking);
    await _writeBookings(prefs, bookings);
    _notifyChanged();

    // Best-effort: never fails the booking if notifications are unavailable.
    await NotificationService.scheduleBookingReminders(booking);

    return booking;
  }

  /// Marks a booking as cancelled, which frees its space.
  static Future<void> cancelBooking(String bookingId) async {
    final prefs = await SharedPreferences.getInstance();
    final bookings = await loadBookings();

    final index = bookings.indexWhere((booking) => booking.id == bookingId);
    if (index == -1 || !bookings[index].isConfirmed) return;

    bookings[index] = bookings[index].copyWith(status: Booking.cancelled);
    await _writeBookings(prefs, bookings);
    _notifyChanged();

    await NotificationService.cancelBookingReminders(bookingId);
  }
}
