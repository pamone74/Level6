import 'package:flutter/material.dart';
import 'package:weather_app/widgets/global.dart';

class TodayWeather extends StatelessWidget {
  const TodayWeather({super.key, required this.location});
  final String location;

  @override
  Widget build(BuildContext context) => Center(
    child: Text(location, style: bodyStyle, textAlign: TextAlign.center),
  );
}
