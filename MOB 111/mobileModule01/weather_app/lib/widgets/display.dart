import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:weather_app/screens/currently_screen.dart';
import 'package:weather_app/screens/today_screen.dart';
import 'package:weather_app/screens/weekly_screen.dart';

class DisplayWidget extends StatefulWidget {
  const DisplayWidget({super.key});

  @override
  State<DisplayWidget> createState() => _DisplayWidgetState();
}

class _DisplayWidgetState extends State<DisplayWidget> {
  String location = "";
  TextEditingController _query = TextEditingController();

  @override
  void initState()
  {
    super.initState();
    _query = TextEditingController();
  }

  @override
  void dispose(){
    _query.dispose();
    super.dispose();
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
                controller:_query,
                onSubmitted: (value) {
                  setState(() {
                    location = _query.text.trim();
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
                      setState(() {
                        location = "Geolocation";
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        body:  TabBarView(
            children: [
              CurrentWeather(location: location), 
              TodayWeather(location: location),
              WeeklyWeather(location: location),
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
