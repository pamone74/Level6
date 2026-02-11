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
  String currentAddress = "Fecthing Location";
  String buttonPressed = "";
  bool processRunning = false;

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  @override
  void initState() {
    super.initState();
  }

  String permissionError() {
    return "Geolocation is not available, please enable in your app setting";
  }

  Future<String> fetchLocation() async {
    late Position currentPosition;
    if (await Geolocator.isLocationServiceEnabled() &&
        await Permission.location.isGranted) {
      currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );
      if (mounted) {
        setState(() {
          currentAddress =
              "${currentPosition.latitude} ${currentPosition.longitude}";
          // GetActualAddress(currentPosition.latitude.toString(), currentPosition.longitude.toString());
        });
      }
    } else if (!await Geolocator.isLocationServiceEnabled() ||
        await Permission.location.isDenied ||
        await Permission.location.isPermanentlyDenied) {
      currentAddress = permissionError();
    } else {
      if (!processRunning) {
        processRunning = true;
        PermissionStatus permission = await Permission.location.request();
        if (permission.isGranted) {
          fetchLocation();
        } else if (permission.isDenied || permission.isPermanentlyDenied) {
          currentAddress = permissionError();
        }
      }
      processRunning = false;
    }

    // This is last edge case when the await calls fails to check for the permission of the location
    if (currentAddress == "Fetching Location") {
      currentAddress = permissionError();
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

  Widget GetLocation(Future<void>? fnc, String text) {
    return Center(
      child: Column(children: [Text(text, style: TextStyle(fontSize: 14))]),
    );
  }

  @override
  Widget build(BuildContext context) {
    GetLocation(fetchLocation(), currentAddress);
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
                  FutureBuilder(
                    future: fetchLocation(),
                    builder: (context, asyncSnapshot) {
                      return IconButton(
                        icon: const Icon(Icons.navigation, color: Colors.white),
                        onPressed: () {
                          if (mounted) {
                            setState(() {
                              if (!asyncSnapshot.hasError) {
                                if (asyncSnapshot.hasData) {
                                  buttonPressed = asyncSnapshot.data.toString();
                                } 
                              }else {
                                  buttonPressed = "Something Wrong happened";
                                }
                            });
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            CurrentWeather(location: currentAddress.toString()),
            TodayWeather(location: buttonPressed),
            WeeklyWeather(location: buttonPressed),
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
