import 'package:flutter/material.dart';

/// Utility class to manage the rating of a card
/// and its caracteristics.
class Rating {
  /// Rating values
  static String none = "None";
  static String easy = "Easy";
  static String good = "Good";
  static String hard = "Hard";
  static String fail = "Fail";

  /// Rating colors based on the rating value.
  static Map<String, Color> colors = {
    'None': Colors.transparent,
    'Fail': Colors.red,
    'Hard': Colors.orange,
    'Good': Colors.yellow,
    'Easy': Colors.green,
  };

  /// times before a new review based on the rating value.
  static Map<String, int> times = {
    'None': 0,
    'Fail': 1,
    'Hard': 3,
    'Good': 10,
    'Easy': 30,
  };

  /// List of all the possible ratings.
  static List<String> ratings = ['None', 'Fail', 'Hard', 'Good', 'Easy'];
}
