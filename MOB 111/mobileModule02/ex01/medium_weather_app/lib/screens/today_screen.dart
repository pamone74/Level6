import 'package:flutter/material.dart';
import 'package:weather_app/widgets/global.dart';

class TodayWeather extends StatelessWidget {
  final List<String> location;
  const TodayWeather({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Today", style: HeadingStyle),
        Text(location.join(), style: bodyStyle,textAlign: TextAlign.center,)
      ],
    );
  }
}
