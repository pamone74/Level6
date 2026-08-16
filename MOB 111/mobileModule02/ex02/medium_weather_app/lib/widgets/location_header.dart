import 'package:flutter/material.dart';
import 'package:weather_app/data/models.dart';

class LocationHeader extends StatelessWidget {
  const LocationHeader({super.key, required this.location});
  final LocationResult location;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        location.name,
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
      if (location.region.isNotEmpty)
        Text(
          location.region,
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      if (location.country.isNotEmpty)
        Text(
          location.country,
          style: const TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
    ],
  );
}
