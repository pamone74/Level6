import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
// import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

TextStyle HeadingStyle = const TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);
Widget CenteredText(String text) {
  return Center(
    child: Text(
      text,
      style: HeadingStyle,
    ),
  );
}

Widget GetLocation(Future<void> fnc, String text) {
  return Center(
    child: Text(
      text,
      style: HeadingStyle,
    ),
  );
}

class DisplayLocation extends StatefulWidget {
  DisplayLocation({super.key});

  @override
  State<DisplayLocation> createState() => _DisplayLocationState();
}

class _DisplayLocationState extends State<DisplayLocation> {
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  late Position currentPosition;
  String currentAddress = "Fetching location...";

  Future<bool> locationEnabled() async{
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<void> GetActualAddress(String latitude, String longitude) async
  {
    try {
    List<Placemark> placemarks = await placemarkFromCoordinates(double.parse(latitude), double.parse(longitude));
    Placemark place = placemarks[0];
    if(mounted)
    {
      setState(() {
      currentAddress = "${place.locality}, ${place.country}";
    });
    }
    } catch (e) {
      if(mounted) {
        print(e.toString());
        setState(() => currentAddress = "Error in fetching location");
      }
    }
  }
  Future<void> fetchLocation() async {
    if(mounted) { 
    if(await locationEnabled() && await Permission.location.isGranted)
    {
      currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      if(mounted)
      {
        setState(() {
        // currentAddress = "Lat: ${currentPosition.latitude}, Lon: ${currentPosition.longitude}";
        GetActualAddress(currentPosition.latitude.toString(), currentPosition.longitude.toString());

      });
      }
      
    }
    else if(!await locationEnabled()){
      setState(() {
        currentAddress = "Location services are disabled";
      });
    }
    else{
      PermissionStatus permission = await Permission.location.request();
      if(permission.isGranted){
        fetchLocation();
      }
      else if(permission.isDenied){
        setState(() {
          currentAddress = "Location permission denied";
        });
      }
      else if(permission.isPermanentlyDenied){
        setState(() {
          currentAddress = "Location permission permanently denied";
        });
      }
    }
  }
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: GetLocation(fetchLocation(), currentAddress),
    );
  }
}