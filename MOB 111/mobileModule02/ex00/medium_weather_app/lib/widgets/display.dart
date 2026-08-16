import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app/screens/currently_screen.dart';
import 'package:weather_app/screens/today_screen.dart';
import 'package:weather_app/screens/weekly_screen.dart';
import 'package:weather_app/services/location_service.dart';

class DisplayWidget extends StatefulWidget {
  const DisplayWidget({super.key});

  @override
  State<DisplayWidget> createState() => _DisplayWidgetState();
}

class _DisplayWidgetState extends State<DisplayWidget> {
  final TextEditingController _textFieldController = TextEditingController();
  final LocationService _locationService = const LocationService();
  String currentAddress = 'Fetching location...';

  @override
  void initState() {
    super.initState();
    _fetchLocation();
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    setState(() => currentAddress = 'Fetching location...');
    final result = await _locationService.getCurrentLocation();
    if (!mounted) return;
    setState(() {
      currentAddress = switch (result.type) {
        LocationResultType.serviceDisabled =>
          'Location services are disabled. Turn on GPS or enter a city above.',
        LocationResultType.permissionDenied =>
          'Location permission was denied. You can still enter a city above.',
        LocationResultType.permissionDeniedForever =>
          'Location permission is permanently denied. Enable it in settings or enter a city above.',
        LocationResultType.permissionGranted =>
          '${result.displayName!}\n'
              'Latitude: ${result.position!.latitude}\n'
              'Longitude: ${result.position!.longitude}',
        LocationResultType.retrievalError =>
          'Could not retrieve your location. Check GPS and try again.',
      };
    });
  }

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
                      '|',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.navigation, color: Colors.white),
                    tooltip: 'Retry current location',
                    onPressed: _fetchLocation,
                  ),
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            CurrentWeather(location: currentAddress),
            TodayWeather(location: currentAddress),
            WeeklyWeather(location: currentAddress),
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
