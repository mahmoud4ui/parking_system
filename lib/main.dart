import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'repositories/local_parking_repository.dart';
import 'repositories/parking_repository.dart';
import 'screens/home_page.dart';
import 'screens/onboarding_page.dart';
import 'services/local_notification_service.dart';
import 'services/reminder_service.dart';
import 'state/bookings_controller.dart';
import 'state/profile_controller.dart';
import 'state/saved_garages_controller.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final reminders = LocalNotificationService();
  await reminders.init();

  final repository = LocalParkingRepository();
  final seenOnboarding = await repository.hasSeenOnboarding();

  runApp(
    ParkingApp(
      repository: repository,
      reminders: reminders,
      showOnboarding: !seenOnboarding,
    ),
  );
}

class ParkingApp extends StatefulWidget {
  final ParkingRepository repository;
  final ReminderService reminders;

  /// Whether to show the intro slides before the home page.
  final bool showOnboarding;

  const ParkingApp({
    super.key,
    required this.repository,
    required this.reminders,
    this.showOnboarding = false,
  });

  @override
  State<ParkingApp> createState() => _ParkingAppState();
}

class _ParkingAppState extends State<ParkingApp> {
  late bool _showOnboarding = widget.showOnboarding;

  Future<void> _finishOnboarding() async {
    await widget.repository.markOnboardingSeen();
    if (!mounted) return;
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Providers sit above MaterialApp so every route (pushed pages, bottom
    // sheets) can reach them.
    return MultiProvider(
      providers: [
        Provider<ReminderService>.value(value: widget.reminders),
        ChangeNotifierProvider(
          create: (_) => BookingsController(
            repository: widget.repository,
            reminders: widget.reminders,
            // Bookings expire with time, so availability refreshes itself.
            refreshInterval: const Duration(seconds: 30),
          )..load(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              SavedGaragesController(repository: widget.repository)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              ProfileController(repository: widget.repository)..load(),
        ),
      ],
      child: MaterialApp(
        title: 'Parking System',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        // Keeps the app phone-width on wide screens (the web demo, desktop),
        // centred on a neutral background, instead of stretching edge to edge.
        builder: (context, child) {
          return ColoredBox(
            color: const Color(0xFFE9EEF0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: child,
              ),
            ),
          );
        },
        home: _showOnboarding
            ? OnboardingPage(onFinished: _finishOnboarding)
            : const ParkingHomePage(),
      ),
    );
  }
}
