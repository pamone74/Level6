import 'dart:async';

import 'package:flutter/material.dart';
import 'package:weather_app/data/models.dart';
import 'package:weather_app/screens/currently_screen.dart';
import 'package:weather_app/screens/today_screen.dart';
import 'package:weather_app/screens/weekly_screen.dart';
import 'package:weather_app/services/device_location_service.dart';
import 'package:weather_app/services/location_search_service.dart';
import 'package:weather_app/services/weather_service.dart';
import 'package:weather_app/widgets/suggestion_list.dart';

class DisplayWidget extends StatefulWidget {
  const DisplayWidget({super.key});
  @override
  State<DisplayWidget> createState() => _DisplayWidgetState();
}

class _DisplayWidgetState extends State<DisplayWidget> {
  static const _debounceDuration = Duration(milliseconds: 400);
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final LocationSearchService _searchService = LocationSearchService();
  final WeatherService _weatherService = WeatherService();
  final DeviceLocationService _deviceLocationService =
      const DeviceLocationService();

  Timer? _debounce;
  int _requestGeneration = 0;
  List<LocationResult> _suggestions = const [];
  WeatherData? _weatherData;
  String? _searchError;
  String? _weatherError;
  bool _isSearching = false;
  bool _isWeatherLoading = false;
  String _loadingLocationName = '';

  @override
  void initState() {
    super.initState();
    _useDeviceLocation();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocus.dispose();
    _searchService.dispose();
    _weatherService.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    final generation = ++_requestGeneration;
    final query = value.trim();
    setState(() {
      _suggestions = const [];
      _searchError = null;
      _weatherError = null;
      _isSearching = false;
      _isWeatherLoading = false;
    });
    if (query.isEmpty) return;
    _debounce = Timer(
      _debounceDuration,
      () => _search(query, generation: generation),
    );
  }

  void _submitSearch() {
    _debounce?.cancel();
    final query = _searchController.text.trim();
    final generation = ++_requestGeneration;
    if (query.isEmpty) {
      setState(() {
        _suggestions = const [];
        _searchError = 'Enter a city or location name.';
        _isSearching = false;
      });
      return;
    }
    _search(query, generation: generation, selectFirstResult: true);
  }

  Future<void> _search(
    String query, {
    required int generation,
    bool selectFirstResult = false,
  }) async {
    if (!mounted || generation != _requestGeneration) return;
    setState(() {
      _isSearching = true;
      _searchError = null;
    });
    try {
      final results = await _searchService.search(query);
      if (!mounted || generation != _requestGeneration) return;
      if (results.isEmpty) {
        setState(() {
          _suggestions = const [];
          _searchError = 'No locations found for "$query".';
          _isSearching = false;
        });
        return;
      }
      if (selectFirstResult) {
        _chooseLocation(results.first);
        return;
      }
      setState(() {
        _suggestions = results;
        _isSearching = false;
      });
    } on LocationSearchException {
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _suggestions = const [];
        _searchError = 'Unable to search right now. Check your connection.';
        _isSearching = false;
      });
    }
  }

  void _chooseLocation(LocationResult location) {
    _debounce?.cancel();
    final generation = ++_requestGeneration;
    _searchController.text = location.displayName;
    _searchController.selection = TextSelection.collapsed(
      offset: _searchController.text.length,
    );
    _searchFocus.unfocus();
    _loadWeather(location, generation: generation);
  }

  Future<void> _loadWeather(
    LocationResult location, {
    required int generation,
  }) async {
    if (!mounted || generation != _requestGeneration) return;
    setState(() {
      _suggestions = const [];
      _searchError = null;
      _weatherError = null;
      _isSearching = false;
      _isWeatherLoading = true;
      _loadingLocationName = location.displayName;
    });
    try {
      final weather = await _weatherService.fetch(location);
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _weatherData = weather;
        _weatherError = null;
        _isWeatherLoading = false;
      });
    } on WeatherException {
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _weatherError =
            'Unable to load weather for ${location.displayName}. Try again.';
        _isWeatherLoading = false;
      });
    }
  }

  Future<void> _useDeviceLocation() async {
    _debounce?.cancel();
    final generation = ++_requestGeneration;
    _searchFocus.unfocus();
    setState(() {
      _suggestions = const [];
      _searchError = null;
      _weatherError = null;
      _isSearching = false;
      _isWeatherLoading = true;
      _loadingLocationName = 'current location';
    });
    try {
      final location = await _deviceLocationService.getCurrentLocation();
      if (!mounted || generation != _requestGeneration) return;
      _searchController.text = location.displayName;
      await _loadWeather(location, generation: generation);
    } on DeviceLocationException catch (error) {
      if (!mounted || generation != _requestGeneration) return;
      setState(() {
        _weatherError = error.message;
        _isWeatherLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) => DefaultTabController(
    length: 3,
    child: Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 139, 142, 147),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 10),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'Search',
                  onPressed: _submitSearch,
                  icon: const Icon(Icons.search, color: Colors.white),
                ),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    focusNode: _searchFocus,
                    onChanged: _onQueryChanged,
                    onSubmitted: (_) => _submitSearch(),
                    textInputAction: TextInputAction.search,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search for a city...',
                      hintStyle: TextStyle(color: Colors.white70),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Use current location',
                  onPressed: _useDeviceLocation,
                  icon: const Icon(Icons.navigation, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          if (_isSearching) const LinearProgressIndicator(),
          if (_searchError case final error?) _MessageBanner(message: error),
          if (_suggestions.isNotEmpty)
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: Material(
                elevation: 3,
                child: SuggestionList(
                  suggestions: _suggestions,
                  onTap: _chooseLocation,
                ),
              ),
            ),
          Expanded(child: _buildWeatherContent()),
        ],
      ),
      bottomNavigationBar: const Material(
        color: Colors.white,
        child: TabBar(
          labelColor: Colors.blue,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.blue,
          tabs: [
            Tab(icon: Icon(Icons.thermostat), text: 'Current'),
            Tab(icon: Icon(Icons.today), text: 'Today'),
            Tab(icon: Icon(Icons.calendar_today), text: 'Weekly'),
          ],
        ),
      ),
    ),
  );

  Widget _buildWeatherContent() {
    if (_isWeatherLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text('Loading weather for $_loadingLocationName...'),
          ],
        ),
      );
    }
    if (_weatherError case final error?) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(error, textAlign: TextAlign.center),
        ),
      );
    }
    final weather = _weatherData;
    if (weather == null) {
      return const Center(
        child: Text('Search for a location to load weather.'),
      );
    }
    return TabBarView(
      children: [
        CurrentWeather(weather: weather),
        TodayWeather(weather: weather),
        WeeklyWeather(weather: weather),
      ],
    );
  }
}

class _MessageBanner extends StatelessWidget {
  const _MessageBanner({required this.message});
  final String message;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(12),
    child: Text(
      message,
      style: TextStyle(color: Theme.of(context).colorScheme.error),
      textAlign: TextAlign.center,
    ),
  );
}
