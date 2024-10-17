import 'package:flash_cards/theme/theme_season.dart';
import 'package:flutter/material.dart';

final currentMonth = DateTime.now().month;

final Season season = currentMonth >= 3 && currentMonth <= 5
    ? spring
    : currentMonth >= 6 && currentMonth <= 8
        ? summer
        : currentMonth >= 9 && currentMonth <= 11
            ? autumn
            : winter;

final ThemeData customLightTheme = ThemeData.light().copyWith(
    colorScheme: ColorScheme.light(
      primary: season.light.primaryColor,
      secondary: season.light.secondaryColor,
    ),
    cardTheme: CardTheme(
      color: season.light.backgroundColor,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      color: season.light.primaryColor,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(season.light.backgroundColor),
        foregroundColor: WidgetStateProperty.all(season.light.foregroundColor),
      ),
    ),
    dialogTheme: const DialogTheme(
        titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 24,
    )),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: season.light.primaryColor,
      contentTextStyle: const TextStyle(color: Colors.white),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: season.light.primaryColor,
        foregroundColor: Colors.black),
    sliderTheme: SliderThemeData(
      activeTrackColor: season.light.primaryColor,
      inactiveTrackColor: season.light.backgroundColor,
      thumbColor: season.light.primaryColor,
      overlayColor: season.light.primaryColor.withOpacity(0.3),
      valueIndicatorColor: season.light.primaryColor,
      valueIndicatorTextStyle: const TextStyle(
        color: Colors.white,
      ),
    ));

final ThemeData customDarkTheme = ThemeData.dark().copyWith(
    colorScheme: ColorScheme.dark(
      primary: season.dark.primaryColor,
      secondary: season.dark.secondaryColor,
      surface: Colors.grey[800]!,
    ),
    scaffoldBackgroundColor: Colors.grey[800]!,
    appBarTheme: AppBarTheme(
      color: season.dark.primaryColor,
    ),
    cardTheme: CardTheme(
      color: season.dark.backgroundColor,
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Colors.white),
      bodyMedium: TextStyle(color: Colors.white),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(season.dark.backgroundColor),
        foregroundColor: WidgetStateProperty.all(season.dark.foregroundColor),
      ),
    ),
    dialogTheme: const DialogTheme(
        titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 24,
    )),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: season.dark.primaryColor,
      contentTextStyle: const TextStyle(color: Colors.black),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: season.dark.primaryColor,
        foregroundColor: Colors.white),
    sliderTheme: SliderThemeData(
      activeTrackColor: season.dark.primaryColor,
      inactiveTrackColor: season.dark.backgroundColor,
      thumbColor: season.dark.primaryColor,
      overlayColor: season.dark.primaryColor.withOpacity(0.3),
      valueIndicatorColor: season.dark.primaryColor,
      valueIndicatorTextStyle: const TextStyle(
        color: Colors.white,
      ),
    ));
