import 'dart:io';

import 'package:flutter/material.dart';
import 'package:weather_app/widgets/global.dart';

class CurrentWeather extends StatelessWidget {
  final String location;
  const CurrentWeather({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
<<<<<<< HEAD
      child: CenteredText('Current'),
=======
      child: CenteredText('Current', this.location),
>>>>>>> 2b6148deb8a6b2e0fc5a8420c2c7801d44b845a0
    );
  }
}