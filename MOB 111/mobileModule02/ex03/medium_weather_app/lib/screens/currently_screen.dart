import 'dart:io';

import 'package:flutter/material.dart';

import 'package:weather_app/widgets/global.dart';

class CurrentWeather extends StatelessWidget {
  final String location;
  final Map<String, dynamic>? weatherData;

  const CurrentWeather({super.key, required this.location, this.weatherData});

  String getWeatherDescription(int code) {
    switch (code) {
      case 0:
        return "Clear";
      case 1:
        return "Mainly clear";
      case 2:
        return "Partly cloudy";
      case 3:
        return "Overcast";
      case 45:
        return "Fog";
      case 48:
        return "Depositing rime fog";
      case 51:
        return "Drizzle: Light";
      case 53:
        return "Drizzle: Moderate";
      case 55:
        return "Drizzle: Dense";
      case 61:
        return "Rain: Slight";
      case 63:
        return "Rain: Moderate";
      case 65:
        return "Rain: Heavy";
      case 80:
        return "Rain showers: Slight";
      case 81:
        return "Rain showers: Moderate";
      case 82:
        return "Rain showers: Violent";
      default:
        return "Unknown";
    }
  }

  Widget buildLocationHeader() {
    final parts = location.split(' ');
    final city = parts.isNotEmpty ? parts[0] : '';
    final region = parts.length > 2 ? parts[1] : '';
    final country = parts.length > 2 ? parts.sublist(2).join(' ') : (parts.length > 1 ? parts[1] : '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(city, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        if (region.isNotEmpty) Text(region, style: const TextStyle(fontSize: 20)),
        if (country.isNotEmpty) Text(country, style: const TextStyle(fontSize: 20)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (weatherData == null) return Center(child: Text("No data yet"));
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          buildLocationHeader(),
          const SizedBox(height: 32),
          Text("${weatherData!['temperature']}°C", style: const TextStyle(fontSize: 32)),
          const SizedBox(height: 8),
          Text(getWeatherDescription(weatherData!["weathercode"] ?? -1), style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 8),
          Text("${weatherData!["windspeed"]} km/h", style: const TextStyle(fontSize: 20)),
        ],
      ),
    );
  }
}

