import 'package:flutter/material.dart';

import 'screens/home_page.dart';
import 'screens/onboarding_page.dart';
import 'services/notification_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  final seenOnboarding = await StorageService.hasSeenOnboarding();
  runApp(ParkingApp(showOnboarding: !seenOnboarding));
}

class ParkingApp extends StatefulWidget {
  /// Whether to show the intro slides before the home page.
  final bool showOnboarding;

  const ParkingApp({super.key, this.showOnboarding = false});

  @override
  State<ParkingApp> createState() => _ParkingAppState();
}

class _ParkingAppState extends State<ParkingApp> {
  late bool _showOnboarding = widget.showOnboarding;

  Future<void> _finishOnboarding() async {
    await StorageService.markOnboardingSeen();
    if (!mounted) return;
    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
    );
  }
}
