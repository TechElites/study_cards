import 'package:flutter/material.dart';

class ThemeSeason {
  Color primaryColor;
  Color secondaryColor;
  Color backgroundColor;
  Color foregroundColor;

  ThemeSeason({
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.foregroundColor,
  });
}

class Season {
  final String name;
  final ThemeSeason light;
  final ThemeSeason dark;

  Season({
    required this.name,
    required this.light,
    required this.dark,
  });
}

final Season winter = Season(
  name: 'Winter',
  light: ThemeSeason(
    primaryColor: Colors.blue,
    secondaryColor: Colors.white,
    backgroundColor: Colors.blue[50]!,
    foregroundColor: Colors.blueGrey[900]!,
  ),
  dark: ThemeSeason(
    primaryColor: Colors.blueGrey[700]!,
    secondaryColor: Colors.blue[900]!,
    backgroundColor: Colors.black,
    foregroundColor: Colors.white70,
  ),
);

final Season spring = Season(
  name: 'Spring',
  light: ThemeSeason(
    primaryColor: Colors.green,
    secondaryColor: Colors.pinkAccent,
    backgroundColor: Colors.green[50]!,
    foregroundColor: Colors.pink[300]!,
  ),
  dark: ThemeSeason(
    primaryColor: Colors.green[700]!,
    secondaryColor: Colors.pink[700]!,
    backgroundColor: Colors.green[900]!,
    foregroundColor: Colors.pink[100]!,
  ),
);

final Season summer = Season(
  name: 'Summer',
  light: ThemeSeason(
    primaryColor: Colors.yellow,
    secondaryColor: Colors.lightBlueAccent,
    backgroundColor: Colors.yellow[50]!,
    foregroundColor: Colors.lightBlue[800]!,
  ),
  dark: ThemeSeason(
    primaryColor: Colors.yellow[700]!,
    secondaryColor: Colors.lightBlue[700]!,
    backgroundColor: Colors.blue[900]!,
    foregroundColor: Colors.yellow[100]!,
  ),
);

final Season autumn = Season(
  name: 'Autumn',
  light: ThemeSeason(
    primaryColor: Colors.orange,
    secondaryColor: Colors.brown,
    backgroundColor: Colors.orange[50]!,
    foregroundColor: Colors.brown[700]!,
  ),
  dark: ThemeSeason(
    primaryColor: Colors.orange[700]!,
    secondaryColor: Colors.brown[900]!,
    backgroundColor: Colors.brown[800]!,
    foregroundColor: Colors.orange[100]!,
  ),
);

final Season christmas = Season(
  name: 'Christmas',
  light: ThemeSeason(
    primaryColor: Colors.red,
    secondaryColor: Colors.green,
    backgroundColor: Colors.green,
    foregroundColor: const Color(0xFFD4AF37),
  ),
  dark: ThemeSeason(
    primaryColor: Colors.red[700]!,
    secondaryColor: Colors.green[700]!,
    backgroundColor: Colors.green[700]!,
    foregroundColor: const Color(0xFFD4AF37),
  ),
);
