import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/garage.dart';
import '../theme/app_theme.dart';
import '../utils/directions.dart';
import '../widgets/availability_badge.dart';
import '../widgets/garage_details_sheet.dart';
import '../widgets/garage_pin.dart';

/// Full-screen map. Each garage is a price pin; tapping one opens a preview
/// card with availability, directions and booking.
class MapTab extends StatefulWidget {
  final List<Garage> garages;
  final Map<String, int> availability;

  const MapTab({
    super.key,
    required this.garages,
    required this.availability,
  });

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  final MapController _controller = MapController();
  Garage? _selected;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _select(Garage garage) {
    setState(() {
      _selected = garage;
    });
    _controller.move(garage.location, 13);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;

    return Stack(
      children: [
        FlutterMap(
          mapController: _controller,
          options: MapOptions(
            initialCenter: const LatLng(25.185, 55.245),
            initialZoom: 11,
            onTap: (_, _) {
              setState(() {
                _selected = null;
              });
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.parking_system',
            ),
            MarkerLayer(
              markers: [
                for (final garage in widget.garages)
                  Marker(
                    point: garage.location,
                    width: 56,
                    height: 56,
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      onTap: () => _select(garage),
                      child: GaragePin(
                        isSelected: garage.name == selected?.name,
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
          right: 12,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.map_outlined,
                        color: primaryTeal, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.garages.length} garages in Dubai',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: darkText,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const Positioned(
          top: 14,
          right: 12,
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
        Positioned(
          left: 12,
          right: 12,
          bottom: 12,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: selected == null
                ? const SizedBox.shrink()
                : _PreviewCard(
                    key: ValueKey(selected.name),
                    garage: selected,
                    available: widget.availability[selected.name],
                    onClose: () => setState(() => _selected = null),
                  ),
          ),
        ),
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final Garage garage;
  final int? available;
  final VoidCallback onClose;

  const _PreviewCard({
    super.key,
    required this.garage,
    required this.available,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: lightTeal,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(garage.icon, color: primaryTeal),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        garage.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: darkText,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        garage.area,
                        style: const TextStyle(
                          fontSize: 12,
                          color: secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close, color: secondaryText),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  garage.priceLabel,
                  style: const TextStyle(
                    color: primaryTeal,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                AvailabilityBadge(
                  available: available,
                  total: garage.totalSpaces,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => openDirections(context, garage),
                    icon: const Icon(Icons.directions_outlined),
                    label: const Text('Directions'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryTeal,
                      side: const BorderSide(color: primaryTeal),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () => showGarageDetails(context, garage),
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryTeal,
                    ),
                    child: const Text('View & book'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
