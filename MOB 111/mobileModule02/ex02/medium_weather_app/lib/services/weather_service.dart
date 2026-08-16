import 'dart:convert';
import 'dart:math' as math;

import 'package:http/http.dart' as http;
import 'package:weather_app/data/models.dart';

class WeatherException implements Exception {
  const WeatherException([this.detail]);
  final String? detail;
}

class WeatherService {
  WeatherService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  Future<WeatherData> fetch(LocationResult location) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': location.latitude.toString(),
      'longitude': location.longitude.toString(),
      'current': 'temperature_2m,weather_code,wind_speed_10m',
      'hourly': 'temperature_2m,weather_code,wind_speed_10m',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
      'timezone': 'auto',
      'forecast_days': '7',
    });
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        throw WeatherException('HTTP ${response.statusCode}');
      }
      final json = jsonDecode(response.body);
      if (json is! Map<String, dynamic>) {
        throw const WeatherException('Invalid response');
      }
      return _parse(json, location);
    } on WeatherException {
      rethrow;
    } catch (error) {
      throw WeatherException(error.toString());
    }
  }

  WeatherData _parse(Map<String, dynamic> json, LocationResult location) {
    final currentJson = _map(json['current']);
    final currentTime = _dateTime(currentJson['time']);
    final current = CurrentConditions(
      temperature: _double(currentJson['temperature_2m']),
      weatherCode: _int(currentJson['weather_code']),
      windSpeed: _double(currentJson['wind_speed_10m']),
    );

    final hourlyJson = _map(json['hourly']);
    final hourlyTimes = _list(hourlyJson['time']);
    final hourlyTemperatures = _list(hourlyJson['temperature_2m']);
    final hourlyCodes = _list(hourlyJson['weather_code']);
    final hourlyWinds = _list(hourlyJson['wind_speed_10m']);
    final hourlyCount = [
      hourlyTimes.length,
      hourlyTemperatures.length,
      hourlyCodes.length,
      hourlyWinds.length,
    ].reduce(math.min);
    final today = <HourlyForecast>[];
    for (var index = 0; index < hourlyCount; index++) {
      final time = _dateTime(hourlyTimes[index]);
      if (_sameDay(time, currentTime)) {
        today.add(
          HourlyForecast(
            time: time,
            temperature: _double(hourlyTemperatures[index]),
            weatherCode: _int(hourlyCodes[index]),
            windSpeed: _double(hourlyWinds[index]),
          ),
        );
      }
    }

    final dailyJson = _map(json['daily']);
    final dates = _list(dailyJson['time']);
    final minima = _list(dailyJson['temperature_2m_min']);
    final maxima = _list(dailyJson['temperature_2m_max']);
    final codes = _list(dailyJson['weather_code']);
    final dailyCount = [
      dates.length,
      minima.length,
      maxima.length,
      codes.length,
    ].reduce(math.min);
    final weekly = List<DailyForecast>.generate(
      dailyCount,
      (index) => DailyForecast(
        date: _dateTime(dates[index]),
        minimumTemperature: _double(minima[index]),
        maximumTemperature: _double(maxima[index]),
        weatherCode: _int(codes[index]),
      ),
      growable: false,
    );

    return WeatherData(
      location: location,
      current: current,
      today: today,
      weekly: weekly,
    );
  }

  Map<String, dynamic> _map(Object? value) {
    if (value is Map<String, dynamic>) return value;
    throw const WeatherException('Missing weather data');
  }

  List<dynamic> _list(Object? value) {
    if (value is List) return value;
    throw const WeatherException('Missing forecast list');
  }

  double _double(Object? value) {
    if (value is num) return value.toDouble();
    throw const WeatherException('Invalid numeric value');
  }

  int _int(Object? value) {
    if (value is num) return value.toInt();
    throw const WeatherException('Invalid weather code');
  }

  DateTime _dateTime(Object? value) {
    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw const WeatherException('Invalid forecast time');
  }

  bool _sameDay(DateTime first, DateTime second) =>
      first.year == second.year &&
      first.month == second.month &&
      first.day == second.day;

  void dispose() => _client.close();
}
