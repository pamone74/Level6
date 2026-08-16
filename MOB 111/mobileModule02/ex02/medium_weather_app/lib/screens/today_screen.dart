import 'package:flutter/material.dart';
import 'package:weather_app/data/models.dart';
import 'package:weather_app/data/weather_code.dart';
import 'package:weather_app/widgets/location_header.dart';

class TodayWeather extends StatelessWidget {
  const TodayWeather({super.key, required this.weather});
  final WeatherData weather;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: LocationHeader(location: weather.location),
      ),
      const _HourlyRow(
        time: 'TIME',
        temperature: 'TEMP',
        description: 'WEATHER',
        windSpeed: 'WIND',
        isHeader: true,
      ),
      const Divider(height: 1),
      Expanded(
        child: ListView.separated(
          itemCount: weather.today.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final hour = weather.today[index];
            return _HourlyRow(
              time:
                  '${hour.time.hour.toString().padLeft(2, '0')}:${hour.time.minute.toString().padLeft(2, '0')}',
              temperature: '${hour.temperature.toStringAsFixed(1)} °C',
              description: WeatherCode.description(hour.weatherCode),
              windSpeed: '${hour.windSpeed.toStringAsFixed(1)} km/h',
            );
          },
        ),
      ),
    ],
  );
}

class _HourlyRow extends StatelessWidget {
  const _HourlyRow({
    required this.time,
    required this.temperature,
    required this.description,
    required this.windSpeed,
    this.isHeader = false,
  });
  final String time;
  final String temperature;
  final String description;
  final String windSpeed;
  final bool isHeader;

  @override
  Widget build(BuildContext context) {
    final style = isHeader
        ? Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.bold)
        : Theme.of(context).textTheme.bodyMedium;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Expanded(flex: 2, child: Text(time, style: style)),
          Expanded(
            flex: 2,
            child: Text(temperature, style: style, textAlign: TextAlign.center),
          ),
          Expanded(
            flex: 4,
            child: Text(
              description,
              style: style,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              windSpeed,
              style: style,
              textAlign: TextAlign.end,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
