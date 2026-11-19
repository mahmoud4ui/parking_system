import '../models/booking.dart';
import '../models/user_profile.dart';

/// Where the app's data lives. Controllers depend on this interface only, so
/// storage can be swapped (a backend, a database) or faked in tests.
abstract class ParkingRepository {
  Future<List<Booking>> loadBookings();
  Future<void> saveBookings(List<Booking> bookings);

  Future<Set<String>> loadSavedGarageNames();
  Future<void> saveSavedGarageNames(Set<String> names);

  Future<UserProfile> loadProfile();
  Future<void> saveProfile(UserProfile profile);

  Future<bool> hasSeenOnboarding();
  Future<void> markOnboardingSeen();
}
