import 'package:latlong2/latlong.dart';

import '../models/garage.dart';

const Distance _distance = Distance();

/// Straight-line distance in metres between two points.
double distanceMeters(LatLng from, LatLng to) =>
    _distance.as(LengthUnit.Meter, from, to);

/// [garages] ordered nearest first to [from]. Returns a new list.
List<Garage> sortByDistance(List<Garage> garages, LatLng from) {
  final sorted = [...garages];
  sorted.sort(
    (a, b) => distanceMeters(from, a.location)
        .compareTo(distanceMeters(from, b.location)),
  );
  return sorted;
}
