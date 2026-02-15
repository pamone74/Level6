import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app/screens/currently_screen.dart';
import 'package:weather_app/screens/today_screen.dart';
import 'package:weather_app/screens/weekly_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';

class DisplayWidget extends StatefulWidget {
  const DisplayWidget({super.key});

  @override
  State<DisplayWidget> createState() => _DisplayWidgetState();
}

class _DisplayWidgetState extends State<DisplayWidget> {
  final TextEditingController _textFieldController = TextEditingController();
  String currentAddress = "Fetching Location";
  String buttonPressed = "";
  bool processRunning = false;

  bool locationDenied = false;

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  @override
  void initState() {
    super.initState();
    // Ask for location and update coordinates on startup
    fetchLocation();
  }

  String permissionError() {
    return "Location permission denied. Please enter a city name to get the weather.";
  }

  Future<String> fetchLocation() async {
    late Position currentPosition;
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    PermissionStatus permission = await Permission.location.status;

    if (!serviceEnabled) {
      if (mounted) {
        setState(() {
          currentAddress = permissionError();
          locationDenied = true;
        });
      }
      return currentAddress;
    }

    if (permission == PermissionStatus.denied || permission == PermissionStatus.restricted) {
      permission = await Permission.location.request();
    }

    if (permission == PermissionStatus.granted) {
      currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      if (mounted) {
        setState(() {
          currentAddress = "${currentPosition.latitude} ${currentPosition.longitude}";
          locationDenied = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          currentAddress = permissionError();
          locationDenied = true;
        });
      }
    }
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

  // Widget displayCurrentCoordinates() {
  //   if (locationDenied) {
  //     return Container(
  //       width: double.infinity,
  //       color: Colors.red[100],
  //       padding: const EdgeInsets.all(12),
  //       child: Row(
  //         children: [
  //           const Icon(Icons.warning, color: Colors.red),
  //           const SizedBox(width: 8),
  //           Expanded(
  //             child: Text(
  //               permissionError(),
  //               style: const TextStyle(fontSize: 15, color: Colors.red, fontWeight: FontWeight.bold),
  //             ),
  //           ),
  //         ],
  //       ),
  //     );
  //   // } else {
  //   //   return Center(
  //   //     child: Column(
  //   //       mainAxisAlignment: MainAxisAlignment.center,
  //   //       children: [
  //   //         const Text(
  //   //           'Current Coordinates:',
  //   //           style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
  //   //         ),
  //   //         const SizedBox(height: 8),
  //   //         Text(
  //   //           currentAddress,
  //   //           style: const TextStyle(fontSize: 16, color: Colors.blueAccent),
  //   //         ),
  //   //       ],
  //   //     ),
  //   //   );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 139, 142, 147),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: SearchBar(
                controller: _textFieldController,
                onSubmitted: (value) {
                  setState(() {
                    // location = _textFieldController.text.toString();
                  });
                },
                backgroundColor: WidgetStateProperty.all(
                  const Color.fromARGB(255, 139, 142, 147),
                ),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(0),
                  ),
                ),
                shadowColor: WidgetStateProperty.all(Colors.transparent),
                hintText: 'Search Something here...',
                hintStyle: WidgetStateProperty.all(
                  const TextStyle(color: Colors.white70),
                ),
                leading: const Icon(Icons.search, color: Colors.white),
                trailing: [
                  const Padding(
                    padding: EdgeInsets.only(right: 4),
                    child: Text(
                      "|",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.navigation, color: Colors.white),
                    onPressed: () {
                      fetchLocation();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            // displayCurrentCoordinates(),
            Expanded(
              child: TabBarView(
                children: [
                  CurrentWeather(location: currentAddress.toString()),
                  TodayWeather(location: buttonPressed),
                  WeeklyWeather(location: buttonPressed),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: const Material(
          color: Colors.white,
          child: TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(icon: Icon(Icons.thermostat), text: 'Currently'),
              Tab(icon: Icon(Icons.today), text: 'Today'),
              Tab(icon: Icon(Icons.calendar_today), text: 'Weekly'),
            ],
          ),
        ),
      ),
    );
  }
}
