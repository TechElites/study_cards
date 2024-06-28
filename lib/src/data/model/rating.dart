import 'package:flutter/material.dart';

class Rating {
  static String none = "None";
  static String easy = "Easy";
  static String good = "Good";
  static String hard = "Hard";
  static String fail = "Fail";

  static Map<String, Color> colors = {
    'None': Colors.transparent,
    'Fail': Colors.red,
    'Hard': Colors.orange,
    'Good': Colors.yellow,
    'Easy': Colors.green,
  };

  static Map<String, int> times = {
    'None': 0,
    'Fail': 1,
    'Hard': 3,
    'Good': 10,
    'Easy': 30,
  };

  static List<String> ratings = ['None', 'Fail', 'Hard', 'Good', 'Easy'];
}
