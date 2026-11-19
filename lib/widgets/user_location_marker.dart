import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// The blue "you are here" dot, as a map [Marker].
Marker userLocationMarker(LatLng point) {
  return Marker(
    point: point,
    width: 22,
    height: 22,
    child: Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2563EB),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 4),
        ],
      ),
    ),
  );
}
