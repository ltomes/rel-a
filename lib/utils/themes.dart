import 'package:flutter/material.dart';

final ColorScheme lightScheme = ColorScheme.fromSeed(
  brightness: Brightness.light,
  seedColor: Colors.indigo,
  primary: Colors.blue,
  secondary: Colors.green,
);

final ColorScheme darkScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: Colors.blueGrey,
  primary: Colors.grey[900],
  secondary: Colors.blueAccent,
);

final ThemeData lightTheme = ThemeData(
  colorScheme: lightScheme,
  brightness: Brightness.light,
  // Define additional light theme properties here
);
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: darkScheme,
  // Define additional dark theme properties here
);