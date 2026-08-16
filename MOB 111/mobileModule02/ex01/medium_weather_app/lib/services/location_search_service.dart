import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:weather_app/data/models.dart';

class LocationSearchException implements Exception {
  const LocationSearchException([this.detail]);
  final String? detail;
}

class LocationSearchService {
  LocationSearchService({http.Client? client})
    : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<LocationResult>> search(String query) async {
    final normalized = query.trim();
    if (normalized.isEmpty) return const [];
    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': normalized,
      'count': '10',
      'language': 'en',
      'format': 'json',
    });
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 10));
      if (response.statusCode != 200) {
        throw LocationSearchException('HTTP ${response.statusCode}');
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const LocationSearchException('Invalid response');
      }
      final rawResults = decoded['results'];
      if (rawResults == null) return const [];
      if (rawResults is! List) {
        throw const LocationSearchException('Invalid results');
      }
      return rawResults
          .whereType<Map<String, dynamic>>()
          .map(LocationResult.fromOpenMeteoJson)
          .whereType<LocationResult>()
          .toList(growable: false);
    } on LocationSearchException {
      rethrow;
    } catch (error) {
      throw LocationSearchException(error.toString());
    }
  }

  void dispose() => _client.close();
}
