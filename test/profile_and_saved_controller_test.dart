import 'package:flutter_test/flutter_test.dart';
import 'package:parking_system/data/sample_garages.dart';
import 'package:parking_system/models/user_profile.dart';
import 'package:parking_system/state/profile_controller.dart';
import 'package:parking_system/state/saved_garages_controller.dart';

import 'helpers/fakes.dart';

void main() {
  group('SavedGaragesController', () {
    final garage = sampleGarages.first;

    test('toggle saves, then removes, and persists each change', () async {
      final repository = InMemoryParkingRepository();
      final controller = SavedGaragesController(repository: repository);
      await controller.load();

      expect(controller.isSaved(garage), isFalse);

      await controller.toggle(garage);
      expect(controller.isSaved(garage), isTrue);
      expect(repository.savedNames, {garage.name});

      await controller.toggle(garage);
      expect(controller.isSaved(garage), isFalse);
      expect(repository.savedNames, isEmpty);
    });

    test('loads garages saved earlier', () async {
      final repository = InMemoryParkingRepository(savedNames: {garage.name});
      final controller = SavedGaragesController(repository: repository);

      await controller.load();

      expect(controller.isSaved(garage), isTrue);
    });
  });

  group('ProfileController', () {
    test('starts with defaults and loads the stored profile', () async {
      final repository = InMemoryParkingRepository(
        profile: const UserProfile(name: 'Sara', email: 'sara@test.com'),
      );
      final controller = ProfileController(repository: repository);
      expect(controller.profile.name, UserProfile.defaults.name);

      await controller.load();

      expect(controller.isLoaded, isTrue);
      expect(controller.profile.name, 'Sara');
    });

    test('validate explains what is wrong', () {
      expect(
        ProfileController.validate(name: ' ', email: 'a@b.co'),
        'Please enter your name.',
      );
      expect(
        ProfileController.validate(name: 'Sara', email: 'nope'),
        'Please enter a valid email address.',
      );
      expect(ProfileController.validate(name: 'Sara', email: 'a@b.co'), isNull);
    });

    test('save trims, stores and returns null on success', () async {
      final repository = InMemoryParkingRepository();
      final controller = ProfileController(repository: repository);

      final error = await controller.save(name: ' Sara ', email: ' sara@test.com ');

      expect(error, isNull);
      expect(controller.profile.name, 'Sara');
      expect(repository.profile.email, 'sara@test.com');
    });

    test('save returns the error and keeps the old profile when invalid', () async {
      final repository = InMemoryParkingRepository();
      final controller = ProfileController(repository: repository);

      final error = await controller.save(name: 'Sara', email: 'bad');

      expect(error, isNotNull);
      expect(repository.profile.name, UserProfile.defaults.name);
    });
  });
}
