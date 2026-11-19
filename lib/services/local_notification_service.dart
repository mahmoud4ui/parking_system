import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/booking.dart';
import '../utils/formatters.dart';
import 'reminder_service.dart';

/// [ReminderService] using local notifications. Reminders:
///  - 15 minutes before the session ends
///  - when the session has ended
///
/// Everything here is best-effort. On unsupported platforms (web, desktop) or
/// if the user denies permission, every method quietly does nothing, so a
/// notification problem can never break booking.
class LocalNotificationService implements ReminderService {
  static const Duration _warningBeforeEnd = Duration(minutes: 15);

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _ready = false;

  bool get _platformSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'booking_reminders',
      'Booking reminders',
      channelDescription: 'Reminders about your parking sessions',
      importance: Importance.high,
      priority: Priority.high,
    ),
    iOS: DarwinNotificationDetails(),
  );

  /// Call once at startup, before runApp.
  Future<void> init() async {
    if (!_platformSupported) return;

    try {
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          // Permission is requested later, when the user makes a booking.
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      _ready = true;
    } catch (error) {
      debugPrint('Notifications unavailable: $error');
    }
  }

  Future<bool> _ensurePermission() async {
    if (!_ready) return false;

    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }

      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        return await ios.requestPermissions(
              alert: true,
              badge: true,
              sound: true,
            ) ??
            false;
      }
    } catch (error) {
      debugPrint('Notification permission failed: $error');
    }
    return false;
  }

  /// Notification ids are 32-bit ints. Each booking uses two consecutive ids
  /// (warning, ended), both derived from the booking id.
  int _baseId(String bookingId) {
    final parsed = int.tryParse(bookingId) ?? bookingId.hashCode.abs();
    return (parsed % 1000000000) * 2;
  }

  Future<void> _schedule({
    required int id,
    required String title,
    required String body,
    required DateTime when,
  }) {
    return _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      // The same moment in time, expressed in UTC. A one-off notification
      // only needs the instant, so no device time zone lookup is required.
      scheduledDate: tz.TZDateTime.from(when, tz.UTC),
      notificationDetails: _details,
      // Inexact scheduling needs no special "alarms" permission; the
      // reminder may arrive a few minutes late on some devices.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  @override
  Future<void> scheduleBookingReminders(Booking booking) async {
    if (!_ready) return;

    try {
      if (!await _ensurePermission()) return;

      final now = DateTime.now();
      final baseId = _baseId(booking.id);
      final warnAt = booking.end.subtract(_warningBeforeEnd);

      if (warnAt.isAfter(now)) {
        await _schedule(
          id: baseId,
          title: 'Parking ends in 15 minutes',
          body: 'Your parking at ${booking.garageName} ends at '
              '${formatClock(booking.end)}. Time to head back to your car.',
          when: warnAt,
        );
      }

      if (booking.end.isAfter(now)) {
        await _schedule(
          id: baseId + 1,
          title: 'Parking session ended',
          body: 'Your booking at ${booking.garageName} has ended.',
          when: booking.end,
        );
      }
    } catch (error) {
      debugPrint('Could not schedule reminders: $error');
    }
  }

  @override
  Future<void> cancelBookingReminders(String bookingId) async {
    if (!_ready) return;

    try {
      final baseId = _baseId(bookingId);
      await _plugin.cancel(id: baseId);
      await _plugin.cancel(id: baseId + 1);
    } catch (error) {
      debugPrint('Could not cancel reminders: $error');
    }
  }

  // Ids above the range used for bookings (which stay below 2 billion).
  static const int _testNowId = 2000000001;
  static const int _testLaterId = 2000000002;

  /// Debug helper: shows one notification immediately and schedules another
  /// 10 seconds from now, so the whole reminder chain (permission, channel,
  /// scheduling) can be checked without waiting for a real booking.
  /// Returns a message describing what happened.
  @override
  Future<String> sendTestNotifications() async {
    if (!_platformSupported) {
      return 'Notifications are only available on Android and iOS.';
    }
    if (!_ready) {
      return 'Notifications could not be initialised.';
    }

    try {
      if (!await _ensurePermission()) {
        return 'Notification permission was denied. '
            'Allow it in the phone settings and try again.';
      }

      await _plugin.show(
        id: _testNowId,
        title: 'Test notification',
        body: 'If you can read this, notifications work.',
        notificationDetails: _details,
      );

      await _schedule(
        id: _testLaterId,
        title: 'Scheduled test notification',
        body: 'This one was scheduled 10 seconds ago.',
        when: DateTime.now().add(const Duration(seconds: 10)),
      );

      return 'Sent one now and scheduled another in 10 seconds. '
          'Leave the app or lock the screen to see it arrive.';
    } catch (error) {
      debugPrint('Test notification failed: $error');
      return 'Test notification failed: $error';
    }
  }
}
