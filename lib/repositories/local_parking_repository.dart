import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/booking.dart';
import '../models/user_profile.dart';
import 'parking_repository.dart';

/// [ParkingRepository] backed by shared_preferences. Keys and JSON format are
/// unchanged from earlier versions, so existing saved data keeps working.
class LocalParkingRepository implements ParkingRepository {
  static const String savedGaragesKey = 'saved_garages';
  static const String bookingsKey = 'parking_bookings';
  static const String profileNameKey = 'profile_name';
  static const String profileEmailKey = 'profile_email';
  static const String onboardingKey = 'onboarding_seen';

  @override
  Future<List<Booking>> loadBookings() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(bookingsKey) ?? [];

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

  @override
  Future<void> saveBookings(List<Booking> bookings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      bookingsKey,
      bookings.map((b) => jsonEncode(b.toJson())).toList(),
    );
  }

  @override
  Future<Set<String>> loadSavedGarageNames() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(savedGaragesKey) ?? []).toSet();
  }

  @override
  Future<void> saveSavedGarageNames(Set<String> names) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(savedGaragesKey, names.toList());
  }

  @override
  Future<UserProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return UserProfile(
      name: prefs.getString(profileNameKey) ?? UserProfile.defaults.name,
      email: prefs.getString(profileEmailKey) ?? UserProfile.defaults.email,
    );
  }

  @override
  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(profileNameKey, profile.name);
    await prefs.setString(profileEmailKey, profile.email);
  }

  @override
  Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(onboardingKey) ?? false;
  }

  @override
  Future<void> markOnboardingSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(onboardingKey, true);
  }
}
