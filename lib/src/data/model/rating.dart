import 'package:flutter/material.dart';

/// Utility class to manage the rating of a card
/// and its caracteristics.
class Rating {
  /// Rating values
  static String none = "none";
  static String easy = "easy";
  static String good = "good";
  static String hard = "hard";
  static String fail = "fail";

  /// Rating colors based on the rating value.
  static Map<String, Color> colors = {
    'none': Colors.transparent,
    'fail': Colors.red,
    'hard': Colors.orange,
    'good': Colors.yellow,
    'easy': Colors.green,
  };

  /// times before a new review based on the rating value.
  static Map<String, int> times = {
    'none': 0,
    'fail': 1,
    'hard': 3,
    'good': 10,
    'easy': 30,
  };

  /// List of all the possible ratings.
  static List<String> ratings = ['none', 'fail', 'hard', 'good', 'easy'];
}
