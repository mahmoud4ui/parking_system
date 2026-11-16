import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/garage.dart';

/// Opens Google Maps (app or browser) with directions to [garage].
Future<void> openDirections(BuildContext context, Garage garage) async {
  final uri = Uri.https('www.google.com', '/maps/dir/', {
    'api': '1',
    'destination': '${garage.location.latitude},${garage.location.longitude}',
  });

  var launched = false;
  try {
    launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    launched = false;
  }

  if (!launched && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Could not open Google Maps.')),
    );
  }
}
