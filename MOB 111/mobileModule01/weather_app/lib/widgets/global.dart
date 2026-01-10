import 'package:flutter/material.dart';

TextStyle HeadingStyle = const TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);
Widget CenteredText(String text, String location) {
  // String data = text + location;
  return Center(
    child: Text(
      '$text \n $location',
      style: HeadingStyle,
    ),
  );
}