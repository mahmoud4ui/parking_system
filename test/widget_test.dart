import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parking_system/data/sample_garages.dart';
import 'package:parking_system/screens/booking_page.dart';
import 'package:parking_system/screens/onboarding_page.dart';
import 'package:parking_system/state/bookings_controller.dart';
import 'package:parking_system/widgets/availability_badge.dart';
import 'package:provider/provider.dart';

import 'helpers/fakes.dart';

void main() {
  group('OnboardingPage', () {
    testWidgets('walks through the slides and finishes', (tester) async {
      var finished = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingPage(onFinished: () => finished = true),
        ),
      );

      expect(find.text('Find parking in Dubai'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('See spaces left'), findsOneWidget);

      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
      expect(find.text('Book and stay on time'), findsOneWidget);
      expect(find.text('Skip'), findsNothing);
      expect(finished, isFalse);

      await tester.tap(find.text('Get started'));
      expect(finished, isTrue);
    });

    testWidgets('Skip finishes straight away', (tester) async {
      var finished = false;

      await tester.pumpWidget(
        MaterialApp(
          home: OnboardingPage(onFinished: () => finished = true),
        ),
      );

      await tester.tap(find.text('Skip'));

      expect(finished, isTrue);
    });
  });

  group('AvailabilityBadge', () {
    Future<void> pumpBadge(WidgetTester tester, int? available) {
      return tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AvailabilityBadge(available: available, total: 25),
          ),
        ),
      );
    }

    testWidgets('shows free spaces', (tester) async {
      await pumpBadge(tester, 12);

      expect(find.text('12 of 25 free'), findsOneWidget);
    });

    testWidgets('shows Full when no spaces are left', (tester) async {
      await pumpBadge(tester, 0);

      expect(find.text('Full'), findsOneWidget);
    });

    testWidgets('shows nothing until availability has loaded', (tester) async {
      await pumpBadge(tester, null);

      expect(find.byType(Text), findsNothing);
    });
  });

  group('BookingPage', () {
    final garage = sampleGarages.first;

    testWidgets('shows spaces free for the chosen time', (tester) async {
      final controller = BookingsController(
        repository: InMemoryParkingRepository(),
        reminders: FakeReminderService(),
      )..load();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: controller,
          child: MaterialApp(home: BookingPage(garage: garage)),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Spaces free for this time'), findsOneWidget);
      expect(
        find.text('${garage.totalSpaces} of ${garage.totalSpaces} free'),
        findsOneWidget,
      );
    });
  });
}
