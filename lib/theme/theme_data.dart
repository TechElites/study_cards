import 'package:study_cards/theme/theme_season.dart';
import 'package:flutter/material.dart';

final currentMonth = DateTime.now().month;
final currentDay = DateTime.now().day;

final Season season = currentMonth >= 3 && currentMonth <= 5
    ? spring
    : currentMonth >= 6 && currentMonth <= 8
        ? summer
        : currentMonth >= 9 && currentMonth <= 11
            ? autumn
            : currentDay >= 23 && currentMonth == 12 || currentDay <= 6 && currentMonth == 1
                ? christmas
                : winter;

final ThemeData customLightTheme = ThemeData.light().copyWith(
    colorScheme: ColorScheme.light(
      primary: season.light.primaryColor,
      secondary: season.light.secondaryColor,
    ),
    cardTheme: CardThemeData(
      color: season.light.backgroundColor,
    ),
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: season.light.primaryColor,
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
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      titleTextStyle: const TextStyle(
        color: Colors.black,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: const TextStyle(
        color: Colors.black87,
        fontSize: 16,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: season.light.primaryColor,
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: Colors.white,
      headerBackgroundColor: season.light.primaryColor,
      headerForegroundColor: Colors.white,
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return Colors.black;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return season.light.primaryColor;
        }
        return null;
      }),
      todayForegroundColor: WidgetStateProperty.all(season.light.primaryColor),
      todayBorder: BorderSide(color: season.light.primaryColor, width: 1),
    ),
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
      overlayColor: season.light.primaryColor.withValues(alpha: 0.3),
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
      backgroundColor: season.dark.primaryColor,
    ),
    cardTheme: CardThemeData(
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
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.grey[850],
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
      contentTextStyle: const TextStyle(
        color: Colors.white70,
        fontSize: 16,
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: season.dark.foregroundColor,
      ),
    ),
    datePickerTheme: DatePickerThemeData(
      backgroundColor: Colors.grey[850],
      headerBackgroundColor: season.dark.primaryColor,
      headerForegroundColor: Colors.white,
      dayForegroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return Colors.white70;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return season.dark.primaryColor;
        }
        return null;
      }),
      todayForegroundColor: WidgetStateProperty.all(season.dark.foregroundColor),
      todayBorder: BorderSide(color: season.dark.foregroundColor, width: 1),
    ),
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
      overlayColor: season.dark.primaryColor.withValues(alpha: 0.3),
      valueIndicatorColor: season.dark.primaryColor,
      valueIndicatorTextStyle: const TextStyle(
        color: Colors.white,
      ),
    ));