import 'package:flutter/material.dart';
import 'package:weather_app/data/models.dart';
import 'package:weather_app/data/weather_code.dart';
import 'package:weather_app/widgets/location_header.dart';

class CurrentWeather extends StatelessWidget {
  const CurrentWeather({super.key, required this.weather});
  final WeatherData weather;

  @override
  Widget build(BuildContext context) {
    final current = weather.current;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            LocationHeader(location: weather.location),
            const SizedBox(height: 32),
            Text(
              '${current.temperature.toStringAsFixed(1)} °C',
              style: const TextStyle(fontSize: 36),
            ),
            const SizedBox(height: 8),
            Text(
              WeatherCode.description(current.weatherCode),
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Wind: ${current.windSpeed.toStringAsFixed(1)} km/h',
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}
