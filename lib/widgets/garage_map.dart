import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/garage.dart';
import '../theme/app_theme.dart';
import 'garage_pin.dart';

/// OpenStreetMap preview with one marker per garage.
class GarageMap extends StatelessWidget {
  final List<Garage> garages;
  final ValueChanged<Garage> onGarageTap;

  const GarageMap({
    super.key,
    required this.garages,
    required this.onGarageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: BoxDecoration(
        color: lightTeal,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            options: const MapOptions(
              initialCenter: LatLng(25.185, 55.245),
              initialZoom: 11,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.parking_system',
              ),
              MarkerLayer(
                markers: [
                  for (final garage in garages)
                    Marker(
                      point: garage.location,
                      width: 48,
                      height: 48,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () => onGarageTap(garage),
                        child: const GaragePin(),
                      ),
                    ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: primaryTeal, size: 18),
                  SizedBox(width: 6),
                  Text(
                    'Dubai, UAE',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: darkText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Positioned(
            bottom: 4,
            right: 6,
            child: DecoratedBox(
              decoration: BoxDecoration(color: Colors.white70),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                child: Text(
                  '© OpenStreetMap contributors',
                  style: TextStyle(fontSize: 9),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
