import 'package:flutter/material.dart';

final ThemeData customLightTheme = ThemeData.light().copyWith(
  colorScheme: const ColorScheme.light(
    primary: Colors.blue,
    secondary: Colors.blueAccent,
  ),
  cardTheme: CardTheme(
    color: Colors.lightBlue[50]!,
  ),
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: AppBarTheme(
    color: Colors.blue[300]!,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Colors.lightBlue[50]!),
      foregroundColor: WidgetStateProperty.all(Colors.blue[900]!),
    ),
  ),
  dialogTheme: const DialogTheme(
      titleTextStyle: TextStyle(
    color: Colors.black,
    fontSize: 24,
  )),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Colors.blue,
    contentTextStyle: TextStyle(color: Colors.white),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.blue[300]!, foregroundColor: Colors.black),
);

final ThemeData customDarkTheme = ThemeData.dark().copyWith(
  colorScheme: ColorScheme.dark(
    primary: Colors.lightBlue[200]!,
    secondary: Colors.lightBlueAccent,
    surface: Colors.grey[800]!,
  ),
  scaffoldBackgroundColor: Colors.grey[800],
  appBarTheme: AppBarTheme(
    color: Colors.blue[700]!,
  ),
  cardTheme: CardTheme(
    color: Colors.blueGrey[400]!,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Colors.blueGrey[400]!),
      foregroundColor: WidgetStateProperty.all(Colors.lightBlue[50]!),
    ),
  ),
  dialogTheme: const DialogTheme(
      titleTextStyle: TextStyle(
    color: Colors.white,
    fontSize: 24,
  )),
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: Colors.lightBlue,
    contentTextStyle: TextStyle(color: Colors.black),
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Colors.blue[700]!, foregroundColor: Colors.white),
);
