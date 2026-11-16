import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class Garage {
  final String name;
  final String area;
  final double pricePerHour;
  final String type;
  final String hours;
  final IconData icon;
  final int totalSpaces;
  final LatLng location;

  const Garage({
    required this.name,
    required this.area,
    required this.pricePerHour,
    required this.type,
    required this.hours,
    required this.icon,
    required this.totalSpaces,
    required this.location,
  });

  /// Short price such as "$10" or "$7.50".
  String get shortPrice {
    final isWhole = pricePerHour == pricePerHour.roundToDouble();
    final amount = isWhole
        ? pricePerHour.toStringAsFixed(0)
        : pricePerHour.toStringAsFixed(2);
    return '\$$amount';
  }

  /// Display text such as "$10 / hour" or "$7.50 / hour".
  String get priceLabel => '$shortPrice / hour';
}
