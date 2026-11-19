import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

import '../models/garage.dart';
import '../state/location_controller.dart';
import '../theme/app_theme.dart';
import 'garage_pin.dart';
import 'user_location_marker.dart';

/// OpenStreetMap preview with one marker per garage. When [focused] changes,
/// the map moves to that garage and highlights its pin.
class GarageMap extends StatefulWidget {
  final List<Garage> garages;
  final Garage? focused;
  final ValueChanged<Garage> onGarageTap;

  const GarageMap({
    super.key,
    required this.garages,
    required this.onGarageTap,
    this.focused,
  });

  @override
  State<GarageMap> createState() => _GarageMapState();
}

class _GarageMapState extends State<GarageMap> {
  static const LatLng _dubai = LatLng(25.185, 55.245);

  final MapController _controller = MapController();

  @override
  void didUpdateWidget(GarageMap oldWidget) {
    super.didUpdateWidget(oldWidget);

    final target = widget.focused;
    if (target != null && target.name != oldWidget.focused?.name) {
      // After the frame, so the map is guaranteed to be attached.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.move(target.location, 14);
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userPosition = context.watch<LocationController>().position;

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
            mapController: _controller,
            options: MapOptions(
              initialCenter: widget.focused?.location ?? _dubai,
              initialZoom: widget.focused == null ? 11 : 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.parking_system',
              ),
              MarkerLayer(
                markers: [
                  if (userPosition != null) userLocationMarker(userPosition),
                  for (final garage in widget.garages)
                    Marker(
                      point: garage.location,
                      width: 48,
                      height: 48,
                      alignment: Alignment.topCenter,
                      child: GestureDetector(
                        onTap: () => widget.onGarageTap(garage),
                        child: GaragePin(
                          isSelected: garage.name == widget.focused?.name,
                        ),
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
