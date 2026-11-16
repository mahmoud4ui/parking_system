import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import '../models/garage.dart';

// These are sample listings, not verified real parking facilities.
const List<Garage> sampleGarages = [
  Garage(
    name: 'Marina Parking',
    area: 'Dubai Marina, Dubai',
    pricePerHour: 10,
    type: 'Covered',
    hours: '24 hours',
    icon: Icons.garage_outlined,
    totalSpaces: 25,
    location: LatLng(25.080, 55.140),
  ),
  Garage(
    name: 'Downtown Parking',
    area: 'Downtown Dubai',
    pricePerHour: 15,
    type: 'Covered',
    hours: '7 AM – 11 PM',
    icon: Icons.local_parking,
    totalSpaces: 40,
    location: LatLng(25.197, 55.274),
  ),
  Garage(
    name: 'Business Bay Parking',
    area: 'Business Bay, Dubai',
    pricePerHour: 8,
    type: 'Outdoor',
    hours: '6 AM – 12 AM',
    icon: Icons.garage_outlined,
    totalSpaces: 30,
    location: LatLng(25.187, 55.263),
  ),
];
