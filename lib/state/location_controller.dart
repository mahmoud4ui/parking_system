import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

import '../domain/nearby.dart';
import '../models/garage.dart';
import '../services/location_service.dart';

enum LocationStatus { idle, loading, ready, failed }

/// The user's location, and whether the list is sorted by distance.
/// Location is only requested when the user taps "Use my location".
class LocationController extends ChangeNotifier {
  LocationController({required LocationService service}) : _service = service;

  final LocationService _service;

  LocationStatus _status = LocationStatus.idle;
  LatLng? _position;
  LocationFailure? _failure;
  bool _sortByNearest = true;

  LocationStatus get status => _status;
  LatLng? get position => _position;
  LocationFailure? get failure => _failure;
  bool get hasLocation => _position != null;

  /// True when the list should be ordered nearest first.
  bool get sortByNearest => hasLocation && _sortByNearest;

  /// Asks for the location (and the permission, if needed).
  Future<void> request() async {
    if (_status == LocationStatus.loading) return;

    _status = LocationStatus.loading;
    _failure = null;
    notifyListeners();

    final result = await _service.getCurrentLocation();
    _position = result.position ?? _position;
    _failure = result.failure;
    _status =
        result.position != null ? LocationStatus.ready : LocationStatus.failed;
    _sortByNearest = true;
    notifyListeners();
  }

  void setSortByNearest(bool value) {
    _sortByNearest = value;
    notifyListeners();
  }

  /// Straight-line distance to [garage] in metres, or null without location.
  double? distanceTo(Garage garage) {
    final from = _position;
    return from == null ? null : distanceMeters(from, garage.location);
  }

  /// [garages] nearest first when sorting is on, otherwise unchanged.
  List<Garage> arrange(List<Garage> garages) {
    final from = _position;
    if (!sortByNearest || from == null) return garages;
    return sortByDistance(garages, from);
  }

  /// A short message for a failed request, or null.
  String? get failureMessage => switch (_failure) {
        null => null,
        LocationFailure.denied =>
          'Location permission was denied. Tap to try again.',
        LocationFailure.deniedForever =>
          'Location is blocked. Allow it in your browser or phone settings.',
        LocationFailure.serviceDisabled =>
          'Location is turned off on this device.',
        LocationFailure.unavailable =>
          'Could not find your location. Tap to try again.',
      };
}
