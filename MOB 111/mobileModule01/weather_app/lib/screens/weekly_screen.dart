import 'package:flutter/material.dart';
import 'package:weather_app/widgets/global.dart';

class WeeklyWeather extends StatelessWidget {
  final String location;
  const WeeklyWeather({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
<<<<<<< HEAD
      child: CenteredText('Weekly'),
=======
      child: CenteredText('Weekly', location),
>>>>>>> 2b6148deb8a6b2e0fc5a8420c2c7801d44b845a0
    );
  }
}