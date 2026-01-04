import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

Future<Position> getCurrentLocation() async {
    try {
      Position position;
        bool locationEnabled = await Geolocator.isLocationServiceEnabled();
        if(locationEnabled && await Permission.location.isGranted){
          final LocationSettings lSettings = LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 100,
          );
          position = await Geolocator.getCurrentPosition(
            locationSettings: lSettings,
          );
          print("${position.latitude}, ${position.longitude}");
          return position;
        }
        else if(!locationEnabled){
          print("Location services are disabled");
        }
        return await Geolocator.getCurrentPosition();
    } catch (e) {
      return Future.error("Error occurred while fetching location: $e");
    }
  return Future.error("Location not available");
}

handlePermission() async {
  await Permission.location.onDeniedCallback( () {
    print("Location permission denied");
  }).onGrantedCallback( () {
    print("Location permission granted");
  }).onPermanentlyDeniedCallback( () {
    print("Location permission permanently denied");
  });
}

