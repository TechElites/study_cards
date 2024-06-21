import 'package:flutter/material.dart';

final ThemeData customLightTheme = ThemeData(
  colorScheme: ColorScheme.fromSwatch(
    primarySwatch: Colors.blue,
  ).copyWith(
    secondary: Colors.blueAccent,
  ),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    color: Colors.blue[300]!,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.blue[300]!,
    foregroundColor: Colors.black
  ),
);

final ThemeData customDarkTheme = ThemeData.dark().copyWith(
  colorScheme: ColorScheme.dark(
    primary: Colors.blue[700]!,
    secondary: Colors.blue[100]!,
    background: Colors.grey[800]!, // Lighter gray background
    surface: Colors.grey[600]!, // Lighter gray surface
  ),
  scaffoldBackgroundColor: Colors.grey[800], // Lighter gray scaffold background
  appBarTheme: AppBarTheme(
    color: Colors.blue[700]!,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all(Colors.grey[600]!),
      foregroundColor: MaterialStateProperty.all(Colors.blue[100]!),
    ),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.blue[700]!,
    foregroundColor: Colors.white
  ),
);