import 'dart:io';

import 'package:flutter/material.dart';
import 'package:weather_app/widgets/global.dart';

class CurrentWeather extends StatelessWidget {
  final String location;
  const CurrentWeather({super.key, required this.location});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CenteredText('Current', this.location),
    );
  }
}