import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

enum LocationResultType {
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  permissionGranted,
  retrievalError,
}

class LocationResult {
  const LocationResult._(this.type, {this.position, this.displayName});
  const LocationResult.serviceDisabled()
    : this._(LocationResultType.serviceDisabled);
  const LocationResult.permissionDenied()
    : this._(LocationResultType.permissionDenied);
  const LocationResult.permissionDeniedForever()
    : this._(LocationResultType.permissionDeniedForever);
  const LocationResult.permissionGranted(Position position, String displayName)
    : this._(
        LocationResultType.permissionGranted,
        position: position,
        displayName: displayName,
      );
  const LocationResult.retrievalError()
    : this._(LocationResultType.retrievalError);

  final LocationResultType type;
  final Position? position;
  final String? displayName;
}

class LocationService {
  const LocationService();

  static const LocationSettings _settings = LocationSettings(
    accuracy: LocationAccuracy.high,
  );

  Future<LocationResult> getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationResult.serviceDisabled();
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        return const LocationResult.permissionDeniedForever();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        return const LocationResult.permissionDenied();
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: _settings,
      );
      return LocationResult.permissionGranted(
        position,
        await _resolveDisplayName(position),
      );
    } catch (_) {
      return const LocationResult.retrievalError();
    }
  }

  Future<String> _resolveDisplayName(Position position) async {
    try {
      final places = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (places.isNotEmpty) {
        final place = _bestPlacemark(places);
        final name = _firstValue([
          place.locality,
          place.subAdministrativeArea,
          place.administrativeArea,
          place.name,
        ]);
        final parts = [name, place.administrativeArea, place.country]
            .whereType<String>()
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty)
            .toList();
        if (parts.isNotEmpty) return parts.join(', ');
      }
    } catch (_) {
      // A readable label is optional; the GPS position remains valid.
    }
    return 'Current location (${position.latitude.toStringAsFixed(5)}, '
        '${position.longitude.toStringAsFixed(5)})';
  }

  String? _firstValue(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return null;
  }

  Placemark _bestPlacemark(List<Placemark> places) {
    Placemark? placeWithAdministrativeArea;
    for (final place in places) {
      if (_hasValue(place.locality)) return place;
      if (placeWithAdministrativeArea == null &&
          _hasValue(place.subAdministrativeArea)) {
        placeWithAdministrativeArea = place;
      }
    }
    return placeWithAdministrativeArea ?? places.first;
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;
}
