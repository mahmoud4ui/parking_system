import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Map pin showing a garage's hourly price, in the app's teal.
/// White when idle, filled teal when selected.
class PricePin extends StatelessWidget {
  final String label;
  final bool isSelected;

  const PricePin({super.key, required this.label, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryTeal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: primaryTeal, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : primaryTeal,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
