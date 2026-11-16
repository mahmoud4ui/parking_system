import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

const Color _selectedTeal = Color(0xFF05606A);

/// Classic map-marker pin in the app's teal. The selected pin is slightly
/// larger and darker so it stands out.
///
/// Use it in a [Marker] with `alignment: Alignment.topCenter` so the tip of
/// the pin sits exactly on the garage's coordinates.
class GaragePin extends StatelessWidget {
  final bool isSelected;

  const GaragePin({super.key, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: isSelected ? 1.3 : 1.0,
      duration: const Duration(milliseconds: 150),
      alignment: Alignment.bottomCenter,
      child: Icon(
        Icons.location_on,
        color: isSelected ? _selectedTeal : primaryTeal,
        size: 44,
        shadows: const [
          Shadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
    );
  }
}
