import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app/screens/currently_screen.dart';
import 'package:weather_app/screens/today_screen.dart';
import 'package:weather_app/screens/weekly_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geocoding/geocoding.dart';
import 'package:weather_app/widgets/module.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:weather_app/utils/permission_manager.dart';

class DisplayWidget extends StatefulWidget {
  const DisplayWidget({super.key});

  @override
  State<DisplayWidget> createState() => _DisplayWidgetState();
}

class _DisplayWidgetState extends State<DisplayWidget> {
  Map<String, dynamic>? currentWeatherData;
  Map<String, dynamic>? todayWeatherData;
  Map<String, dynamic>? weeklyWeatherData;
  String? errorMessage;

  static List<String> listOfLocations = <String>[];
  String selectedValue = "";
  String lat = "";
  String long = "";

  String currently = "";
  String today = " ";
  String weekly = "";

  Map<String, dynamic> coordinates = {};
  Timer? debounce;
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  @override
  void initState() {
    super.initState();
  }

  // Debounced search for locations
  void onSearchChange(String value) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.isNotEmpty) {
        listLocations(value);
      }
    });
  }

  Future<dynamic> fectData(String endPoint) async {
    try {
      final response = await http.get(Uri.parse(endPoint));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else if (response.statusCode == 429) {
        setState(() {
          errorMessage = "API limit reached. Please try again later.";
          currentWeatherData = null;
          todayWeatherData = null;
          weeklyWeatherData = null;
        });
        return "Error429";
      } else {
        setState(() {
          errorMessage = "Error: ${response.statusCode} ${response.reasonPhrase}";
          currentWeatherData = null;
          todayWeatherData = null;
          weeklyWeatherData = null;
        });
        return "Error";
      }
    } catch (e) {
      setState(() {
        errorMessage = "Network error: $e";
        currentWeatherData = null;
        todayWeatherData = null;
        weeklyWeatherData = null;
      });
      return "Error";
    }
  }

  Future<void> getAllWeather(Map<String, dynamic> coordinates) async {
    try {
      String lat = coordinates['lat'].toString();
      String long = coordinates['long'].toString();

      setState(() {
        errorMessage = null;
        currentWeatherData = null;
        todayWeatherData = null;
        weeklyWeatherData = null;
      });

      final currentFuture = fectData("https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$long&current_weather=true");
      final todayFuture = fectData("https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$long&hourly=temperature_2m,weathercode,windspeed_10m&forecast_days=1");
      final weeklyFuture = fectData("https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$long&daily=temperature_2m_max,temperature_2m_min,weathercode&forecast_days=7");

      final results = await Future.wait([currentFuture, todayFuture, weeklyFuture]);

      // If any error, don't update data (already cleared above)
      if (results.contains("Error429") || results.contains("Error")) {
        return;
      }

      setState(() {
        errorMessage = null;
        currentWeatherData = results[0]['current_weather'];
        todayWeatherData = results[1];
        weeklyWeatherData = results[2];
      });
    } catch (e) {
      setState(() {
        errorMessage = "Unexpected error: $e";
        currentWeatherData = null;
        todayWeatherData = null;
        weeklyWeatherData = null;
      });
    }
  }

  Future listLocations(String address) async {
    try {
      String endPoint =
          "https://geocoding-api.open-meteo.com/v1/search?name=$address&count=10&language=en&format=json";
      dynamic response = await http.get(Uri.parse(endPoint));
      if (response.statusCode == 200) {
        dynamic fin = await jsonDecode(response.body) as Map<String, dynamic>;

        if (fin != null) {
          final List results = fin['results'] ?? [];
          final List<String> fetchedLocations = [];

          for (final element in results) {
            final name = element['name'];
            final country = element['country'];
            final region =
                element['admin1'] ??
                element['admin2'] ??
                element['admin1'] ??
                '';
            coordinates['lat'] = element["latitude"];
            coordinates['long'] = element["longitude"];
            fetchedLocations.add("$name $region $country");
          }
          setState(() {
            listOfLocations = fetchedLocations;
          });
        }
      } else {
        print("Sometthing went wrong");
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 139, 142, 147),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.white),
                  Expanded(
                    child: Autocomplete(
                      optionsBuilder: (TextEditingValue textEditor) {
                        // Debounced search for locations
                        if (debounce?.isActive ?? false) debounce?.cancel();
                        debounce = Timer(const Duration(milliseconds: 500), () {
                          if (textEditor.text.isNotEmpty) {
                            listLocations(textEditor.text);
                          }
                        });
                        if (textEditor.text.isEmpty || textEditor.text.trim().isEmpty) {
                          return const Iterable<String>.empty();
                        }
                        return listOfLocations.where((String option) {
                          return option.toLowerCase().contains(textEditor.text.toLowerCase());
                        });
                      },
                      onSelected: (String selection) async {
                        debugPrint("You have Selected $selection");
                        debugPrint("The coordinates for the value selected is $coordinates");
                        setState(() {
                          selectedValue = selection;
                        });
                        await getAllWeather(coordinates);
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.navigation, color: Colors.white),
                    onPressed: () async {
                      await Permission.location.request();
                      try {
                        final position = await getCurrentLocation();
                        final double latitude = position.latitude;
                        final double longitude = position.longitude;
                        // Reverse geocode to get place name
                        String placeName = '';
                        try {
                          final placemarks = await placemarkFromCoordinates(latitude, longitude);
                          if (placemarks.isNotEmpty) {
                            final p = placemarks.first;
                            placeName = [p.locality, p.administrativeArea, p.country].where((e) => e != null && e.isNotEmpty).join(' ');
                          }
                        } catch (e) {
                          placeName = 'Unknown Location';
                        }
                        setState(() {
                          coordinates['lat'] = latitude;
                          coordinates['long'] = longitude;
                          selectedValue = placeName;
                        });
                        await getAllWeather({'lat': latitude, 'long': longitude});
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to get location: $e')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            if (errorMessage != null)
              Container(
                width: double.infinity,
                color: Colors.red[100],
                padding: const EdgeInsets.all(8),
                child: Text(errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            Expanded(
              child: TabBarView(
                children: [
                  CurrentWeather(
                    location: selectedValue,
                    weatherData: currentWeatherData,
                  ),
                  TodayWeather(
                    location: selectedValue,
                    weatherData: todayWeatherData,
                  ),
                  WeeklyWeather(
                    location: selectedValue,
                    weatherData: weeklyWeatherData,
                  ),
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
