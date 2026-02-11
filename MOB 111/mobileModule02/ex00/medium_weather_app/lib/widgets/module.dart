import 'package:weather_app/widgets/global.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

class Location {
  // List<String>? coordinates;
  String? address;

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  // initializing buy instantiating the object
  Location(this.address);

  // Check if the location is enabled
  Future<String> fetchLocation() async {
    Position currentPosition;
    String currentAddress = Geolocator.getLastKnownPosition().toString();
    if (await Geolocator.isLocationServiceEnabled() &&
        await Permission.location.isGranted) {
      currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      currentAddress =
          "${currentPosition.latitude}\n${currentPosition.longitude}";
      // GetActualAddress(currentPosition.latitude.toString(), currentPosition.longitude.toString());
    } else if (!await Geolocator.isLocationServiceEnabled()) {
      currentAddress = "Location services are disabled";
    } else {
      PermissionStatus permission = await Permission.location.request();
      if (permission.isGranted) {
        fetchLocation();
      } else if (permission.isDenied) {
        currentAddress = "Location permission denied";
      } else if (permission.isPermanentlyDenied) {
        currentAddress = "Location permission permanently denied";
      }
    }
    debugPrint(currentAddress);
    return currentAddress;
  }

  // Get full address
  Future<String> GetActualAddress(String latitude, String longitude) async {
    String actualAddress;
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        double.parse(latitude),
        double.parse(longitude),
      );
      Placemark place = placemarks[0];
      actualAddress = "${place.locality}, ${place.country}";
    } catch (e) {
      actualAddress = "Error in fetching location";
    }
    
    return actualAddress;
  }
}
