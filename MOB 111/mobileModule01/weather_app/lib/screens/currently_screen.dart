import 'dart:io';

import 'package:flutter/material.dart';
import 'package:weather_app/widgets/global.dart';

class CurrentWeather extends StatelessWidget {
  const CurrentWeather({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CenteredText('Current Paris Weather'),
    );
  }
}