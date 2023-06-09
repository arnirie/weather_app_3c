import 'package:flutter/material.dart';

import 'screens/current_location_screen.dart';
import 'screens/maps_screen.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapsScreen(),
    );
  }
}
