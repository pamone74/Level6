import 'package:flutter/material.dart';
import 'package:weather_app/widgets/global.dart';
class TodayWeather extends StatelessWidget {
  final String location;
  const TodayWeather({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CenteredText( 'Today', this.location),
    );
  }
}