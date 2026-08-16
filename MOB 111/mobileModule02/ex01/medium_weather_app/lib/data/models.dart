class LocationResult {
  const LocationResult({
    required this.name,
    required this.region,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  final String name;
  final String region;
  final String country;
  final double latitude;
  final double longitude;

  static LocationResult? fromOpenMeteoJson(Map<String, dynamic> json) {
    final name = json['name'];
    final country = json['country'];
    final latitude = json['latitude'];
    final longitude = json['longitude'];
    if (name is! String ||
        country is! String ||
        latitude is! num ||
        longitude is! num) {
      return null;
    }
    final regionValue = json['admin1'] ?? json['admin2'] ?? json['admin3'];
    return LocationResult(
      name: name,
      region: regionValue is String ? regionValue : '',
      country: country,
      latitude: latitude.toDouble(),
      longitude: longitude.toDouble(),
    );
  }

  String get displayName => [
    name,
    if (region.trim().isNotEmpty) region,
    if (country.trim().isNotEmpty) country,
  ].join(', ');
}
