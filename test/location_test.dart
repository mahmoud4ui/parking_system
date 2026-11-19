import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:parking_system/data/sample_garages.dart';
import 'package:parking_system/domain/nearby.dart';
import 'package:parking_system/services/location_service.dart';
import 'package:parking_system/state/location_controller.dart';

import 'helpers/fakes.dart';

void main() {
  // Close to Marina Parking, far from the two downtown garages.
  const nearMarina = LatLng(25.081, 55.141);
  // Close to Business Bay Parking.
  const nearBusinessBay = LatLng(25.188, 55.264);

  group('domain/nearby', () {
    test('distanceMeters is zero for the same point and symmetric', () {
      expect(distanceMeters(nearMarina, nearMarina), 0);
      expect(
        distanceMeters(nearMarina, nearBusinessBay),
        closeTo(distanceMeters(nearBusinessBay, nearMarina), 0.001),
      );
    });

    test('sortByDistance puts the closest garage first', () {
      final sorted = sortByDistance(sampleGarages, nearMarina);

      expect(sorted.first.name, 'Marina Parking');
      expect(sorted, hasLength(sampleGarages.length));
    });

    test('sortByDistance follows the user, not a fixed order', () {
      final sorted = sortByDistance(sampleGarages, nearBusinessBay);

      expect(sorted.first.name, 'Business Bay Parking');
    });

    test('sortByDistance does not change the original list', () {
      final before = sampleGarages.map((g) => g.name).toList();

      sortByDistance(sampleGarages, nearMarina);

      expect(sampleGarages.map((g) => g.name), before);
    });
  });

  group('LocationController', () {
    test('starts idle and never asks for location by itself', () {
      final service = FakeLocationService(
        const LocationResult.success(nearMarina),
      );
      final controller = LocationController(service: service);

      expect(controller.status, LocationStatus.idle);
      expect(controller.hasLocation, isFalse);
      expect(controller.distanceTo(sampleGarages.first), isNull);
      expect(service.calls, 0);
    });

    test('request stores the position and enables nearest-first', () async {
      final controller = LocationController(
        service: FakeLocationService(const LocationResult.success(nearMarina)),
      );

      await controller.request();

      expect(controller.status, LocationStatus.ready);
      expect(controller.position, nearMarina);
      expect(controller.sortByNearest, isTrue);
      expect(controller.distanceTo(sampleGarages.first), lessThan(500));
    });

    test('arrange sorts nearest first, and the toggle turns it off', () async {
      final controller = LocationController(
        service: FakeLocationService(
          const LocationResult.success(nearBusinessBay),
        ),
      );
      await controller.request();

      expect(
        controller.arrange(sampleGarages).first.name,
        'Business Bay Parking',
      );

      controller.setSortByNearest(false);
      expect(controller.arrange(sampleGarages), sampleGarages);
    });

    test('arrange leaves the list alone without a location', () {
      final controller = LocationController(
        service: FakeLocationService(
          const LocationResult.failure(LocationFailure.denied),
        ),
      );

      expect(controller.arrange(sampleGarages), sampleGarages);
    });

    test('a denied request reports a message and keeps no position',
        () async {
      final controller = LocationController(
        service: FakeLocationService(
          const LocationResult.failure(LocationFailure.denied),
        ),
      );

      await controller.request();

      expect(controller.status, LocationStatus.failed);
      expect(controller.hasLocation, isFalse);
      expect(controller.failureMessage, contains('denied'));
    });

    test('each failure has its own message', () async {
      for (final failure in LocationFailure.values) {
        final controller = LocationController(
          service: FakeLocationService(LocationResult.failure(failure)),
        );
        await controller.request();

        expect(controller.failureMessage, isNotNull, reason: '$failure');
      }
    });

    test('trying again after a failure can succeed', () async {
      final service = FakeLocationService(
        const LocationResult.failure(LocationFailure.denied),
      );
      final controller = LocationController(service: service);
      await controller.request();

      service.result = const LocationResult.success(nearMarina);
      await controller.request();

      expect(controller.status, LocationStatus.ready);
      expect(controller.failureMessage, isNull);
    });

    test('a second tap while loading does not ask twice', () async {
      final service = FakeLocationService(
        const LocationResult.success(nearMarina),
      );
      final controller = LocationController(service: service);

      final first = controller.request();
      final second = controller.request();
      await Future.wait([first, second]);

      expect(service.calls, 1);
    });
  });
}
