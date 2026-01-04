import 'package:flutter/material.dart';

TextStyle HeadingStyle = const TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
);
Widget CenteredText(String text) {
  return Center(
    child: Text(
      text,
      style: HeadingStyle,
    ),
  );
}