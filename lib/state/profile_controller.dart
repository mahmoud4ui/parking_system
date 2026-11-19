import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../repositories/parking_repository.dart';

/// The user's name and email.
class ProfileController extends ChangeNotifier {
  ProfileController({required ParkingRepository repository})
      : _repository = repository;

  final ParkingRepository _repository;

  UserProfile _profile = UserProfile.defaults;
  bool _isLoaded = false;
  Future<void>? _loading;

  UserProfile get profile => _profile;
  bool get isLoaded => _isLoaded;

  /// Loads once. Safe to call repeatedly.
  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    _profile = await _repository.loadProfile();
    _isLoaded = true;
    notifyListeners();
  }

  /// Returns an error message, or null if both fields are valid.
  static String? validate({required String name, required String email}) {
    if (name.trim().isEmpty) return 'Please enter your name.';
    final trimmed = email.trim();
    final looksValid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(trimmed);
    if (!looksValid) return 'Please enter a valid email address.';
    return null;
  }

  /// Validates and saves. Returns an error message, or null on success.
  Future<String?> save({required String name, required String email}) async {
    final error = validate(name: name, email: email);
    if (error != null) return error;

    _profile = UserProfile(name: name.trim(), email: email.trim());
    notifyListeners();
    await _repository.saveProfile(_profile);
    return null;
  }
}
