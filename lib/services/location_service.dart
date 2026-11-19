import 'package:latlong2/latlong.dart';

/// Why a location could not be obtained.
enum LocationFailure {
  /// The user said no to the permission prompt (they can be asked again).
  denied,

  /// Permission is blocked until the user changes it in browser/phone settings.
  deniedForever,

  /// Location is switched off on the device.
  serviceDisabled,

  /// Anything else (timeout, no signal, unsupported platform).
  unavailable,
}

/// The outcome of asking for the user's location: exactly one of
/// [position] or [failure] is set.
class LocationResult {
  final LatLng? position;
  final LocationFailure? failure;

  const LocationResult.success(LatLng this.position) : failure = null;
  const LocationResult.failure(LocationFailure this.failure) : position = null;
}

/// Gets the user's current location. An interface, so tests and the
/// controller never depend on a real GPS.
abstract class LocationService {
  Future<LocationResult> getCurrentLocation();
}
