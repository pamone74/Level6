import 'package:flutter/material.dart';
import 'package:weather_app/widgets/global.dart';

class WeeklyWeather extends StatelessWidget {
  final String location;
  const WeeklyWeather({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Weekly", style: HeadingStyle),
        Text(location, style: bodyStyle,textAlign: TextAlign.center,)
      ],
    );
  }
}
