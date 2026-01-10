import 'package:flutter/material.dart';
import 'package:weather_app/widgets/global.dart';

class WeeklyWeather extends StatelessWidget {
  final String location;
  const WeeklyWeather({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CenteredText('Weekly', location),
    );
  }
}