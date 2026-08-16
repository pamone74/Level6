import 'package:flutter/material.dart';
import 'package:weather_app/data/models.dart';
import 'package:weather_app/data/weather_code.dart';
import 'package:weather_app/widgets/location_header.dart';

class WeeklyWeather extends StatelessWidget {
  const WeeklyWeather({super.key, required this.weather});
  final WeatherData weather;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: LocationHeader(location: weather.location),
      ),
      const _DailyRow(
        date: 'DATE',
        minimumTemperature: 'MIN',
        maximumTemperature: 'MAX',
        description: 'WEATHER',
        isHeader: true,
      ),
      const Divider(height: 1),
      Expanded(
        child: ListView.separated(
          itemCount: weather.weekly.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final day = weather.weekly[index];
            return _DailyRow(
              date:
                  '${day.date.year}-${day.date.month.toString().padLeft(2, '0')}-${day.date.day.toString().padLeft(2, '0')}',
              minimumTemperature:
                  '${day.minimumTemperature.toStringAsFixed(1)} °C',
              maximumTemperature:
                  '${day.maximumTemperature.toStringAsFixed(1)} °C',
              description: WeatherCode.description(day.weatherCode),
            );
          },
        ),
      ),
    ],
  );
}

class _DailyRow extends StatelessWidget {
  const _DailyRow({
    required this.date,
    required this.minimumTemperature,
    required this.maximumTemperature,
    required this.description,
    this.isHeader = false,
  });
  final String date;
  final String minimumTemperature;
  final String maximumTemperature;
  final String description;
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
          Expanded(flex: 3, child: Text(date, style: style)),
          Expanded(
            flex: 2,
            child: Text(
              minimumTemperature,
              style: style,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              maximumTemperature,
              style: style,
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            flex: 4,
            child: Text(
              description,
              style: style,
              textAlign: TextAlign.end,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
