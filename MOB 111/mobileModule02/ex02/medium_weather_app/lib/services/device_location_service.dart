import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather_app/data/models.dart';

class DeviceLocationException implements Exception {
  const DeviceLocationException(this.message);
  final String message;
}

class DeviceLocationService {
  const DeviceLocationService();

  Future<LocationResult> getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const DeviceLocationException(
          'Location services are disabled. Turn on GPS and try again.',
        );
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw const DeviceLocationException(
          'Location permission is permanently denied. Enable it in settings.',
        );
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.unableToDetermine) {
        throw const DeviceLocationException('Location permission was denied.');
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      return await _locationFromPosition(position);
    } on DeviceLocationException {
      rethrow;
    } catch (_) {
      throw const DeviceLocationException(
        'Could not retrieve the current location.',
      );
    }
  }

  Future<LocationResult> _locationFromPosition(Position position) async {
    try {
      final places = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (places.isNotEmpty) {
        final place = _bestPlacemark(places);
        return LocationResult(
          name: _firstValue([
            place.locality,
            place.subAdministrativeArea,
            place.administrativeArea,
            place.name,
          ]),
          region: place.administrativeArea?.trim() ?? '',
          country: place.country?.trim() ?? '',
          latitude: position.latitude,
          longitude: position.longitude,
        );
      }
    } catch (_) {
      // Reverse geocoding does not invalidate the exact GPS coordinates.
    }
    return LocationResult(
      name: 'Current location',
      region: '',
      country: '',
      latitude: position.latitude,
      longitude: position.longitude,
    );
  }

  String _firstValue(List<String?> values) {
    for (final value in values) {
      if (value != null && value.trim().isNotEmpty) return value.trim();
    }
    return 'Current location';
  }

  Placemark _bestPlacemark(List<Placemark> places) {
    Placemark? administrative;
    for (final place in places) {
      if (_hasValue(place.locality)) return place;
      if (administrative == null && _hasValue(place.subAdministrativeArea)) {
        administrative = place;
      }
    }
    return administrative ?? places.first;
  }

  bool _hasValue(String? value) => value != null && value.trim().isNotEmpty;
}
