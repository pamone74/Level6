import 'package:flutter/material.dart';
import 'package:weather_app/widgets/global.dart';

class TodayWeather extends StatelessWidget {
  final String location;
  final Map<String, dynamic>? weatherData;
  const TodayWeather({
    super.key,
    required this.location,
    required this.weatherData,
  });

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
    return Column(
      children: [
        const SizedBox(height: 16),
        buildLocationHeader(),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: weatherData!['hourly']['time'].length,
            itemBuilder: (context, index) {
              final timeRaw = weatherData!['hourly']['time'][index];
              final temp = weatherData!['hourly']['temperature_2m'][index];
              final wind = weatherData!['hourly']['windspeed_10m'][index];
              // Format time as HH:MM
              final time = timeRaw.length >= 16 ? timeRaw.substring(11, 16) : timeRaw;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                child: Row(
                  children: [
                    SizedBox(width: 60, child: Text(time, textAlign: TextAlign.left)),
                    Expanded(child: Center(child: Text("$temp°C"))),
                    SizedBox(width: 80, child: Text("$wind km/h", textAlign: TextAlign.right)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
