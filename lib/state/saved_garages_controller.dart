import 'package:flutter/foundation.dart';

import '../models/garage.dart';
import '../repositories/parking_repository.dart';

/// The garages the user has saved (hearted).
class SavedGaragesController extends ChangeNotifier {
  SavedGaragesController({required ParkingRepository repository})
      : _repository = repository;

  final ParkingRepository _repository;

  Set<String> _names = const {};
  bool _isLoaded = false;
  Future<void>? _loading;

  bool get isLoaded => _isLoaded;

  bool isSaved(Garage garage) => _names.contains(garage.name);

  /// Loads once. Safe to call repeatedly.
  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    _names = await _repository.loadSavedGarageNames();
    _isLoaded = true;
    notifyListeners();
  }

  Future<void> toggle(Garage garage) async {
    await load();
    final updated = {..._names};
    if (!updated.remove(garage.name)) updated.add(garage.name);
    _names = updated;
    notifyListeners();
    await _repository.saveSavedGarageNames(_names);
  }
}
