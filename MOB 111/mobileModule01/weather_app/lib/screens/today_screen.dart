import 'package:flutter/material.dart';
import 'package:weather_app/widgets/global.dart';
class TodayWeather extends StatelessWidget {
  const TodayWeather({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CenteredText( 'Today '),
    );
  }
}