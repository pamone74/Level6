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

class DisplayWidget extends StatefulWidget {
  const DisplayWidget({super.key});

  @override
  State<DisplayWidget> createState() => _DisplayWidgetState();
}

class _DisplayWidgetState extends State<DisplayWidget> {
  static List<String> listOfLocations = <String>[];
  String selectedValue = "";
  Timer? debounce;
  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 100,
  );

  @override
  void initState() {
    super.initState();
  }

  void onSearchChange(String value) {
    if (debounce?.isActive ?? false) debounce?.cancel();
    debounce = Timer(const Duration(milliseconds: 500), () {
      if (value.isNotEmpty) {
        listLocations(value);
      }
    });
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
                  // SizedBox(height: 30,),
                  Expanded(
                    child: Autocomplete(
                      // key: ValueKey(listOfLocations.length),
                      optionsBuilder: (TextEditingValue textEditor) {
                        listLocations(textEditor.text);
                        if (textEditor.text.isEmpty ||
                            textEditor.text.isEmpty == ' ') {
                          return const Iterable<String>.empty();
                        }
                        return listOfLocations.where((String option) {
                          listLocations(textEditor.text);
                          return option.toLowerCase().contains(
                            textEditor.text.toLowerCase(),
                          );
                        });
                      },
                      onSelected: (String selection) {
                        
                        debugPrint("You have Selected $selection");
                        selectedValue = selection;
                      },
                    ),
                  ),
                  Icon(Icons.navigation, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            CurrentWeather(location: selectedValue),
            TodayWeather(location: ["TEST"]),
            WeeklyWeather(location: ["List"].toString()),
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
