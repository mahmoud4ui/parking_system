import 'package:parking_system/models/booking.dart';
import 'package:parking_system/models/user_profile.dart';
import 'package:parking_system/repositories/parking_repository.dart';
import 'package:parking_system/services/reminder_service.dart';

/// Repository that keeps everything in memory, so controller tests need no
/// shared_preferences.
class InMemoryParkingRepository implements ParkingRepository {
  List<Booking> bookings;
  Set<String> savedNames;
  UserProfile profile;
  bool onboardingSeen;
  int saveBookingsCalls = 0;

  InMemoryParkingRepository({
    this.bookings = const [],
    this.savedNames = const {},
    this.profile = UserProfile.defaults,
    this.onboardingSeen = false,
  });

  @override
  Future<List<Booking>> loadBookings() async => List.of(bookings);

  @override
  Future<void> saveBookings(List<Booking> value) async {
    saveBookingsCalls++;
    bookings = List.of(value);
  }

  @override
  Future<Set<String>> loadSavedGarageNames() async => {...savedNames};

  @override
  Future<void> saveSavedGarageNames(Set<String> names) async {
    savedNames = {...names};
  }

  @override
  Future<UserProfile> loadProfile() async => profile;

  @override
  Future<void> saveProfile(UserProfile value) async {
    profile = value;
  }

  @override
  Future<bool> hasSeenOnboarding() async => onboardingSeen;

  @override
  Future<void> markOnboardingSeen() async {
    onboardingSeen = true;
  }
}

/// Records calls instead of scheduling real notifications.
class FakeReminderService implements ReminderService {
  final List<String> scheduled = [];
  final List<String> cancelled = [];

  @override
  Future<void> scheduleBookingReminders(Booking booking) async {
    scheduled.add(booking.id);
  }

  @override
  Future<void> cancelBookingReminders(String bookingId) async {
    cancelled.add(bookingId);
  }

  @override
  Future<String> sendTestNotifications() async => 'fake';
}

/// A confirmed booking for [garageName] starting at [start].
Booking makeBooking({
  String id = '1',
  String garageName = 'Marina Parking',
  required DateTime start,
  int durationHours = 1,
  String status = Booking.confirmed,
}) {
  return Booking(
    id: id,
    reference: 'PK-$id',
    garageName: garageName,
    date: DateTime(start.year, start.month, start.day),
    timeHour: start.hour,
    timeMinute: start.minute,
    durationHours: durationHours,
    totalPrice: 10.0 * durationHours,
    status: status,
  );
}
