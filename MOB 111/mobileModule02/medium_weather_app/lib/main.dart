import 'package:flutter/material.dart';
import 'widgets/display.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    home: DisplayWidget(),
  ));
}

