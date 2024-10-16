import 'package:flutter/material.dart';

/// Class to shpow a custom SnackBar with a text message
class FloatingBar {
  /// Shows a SnackBar with a text message
  static void show(String text, BuildContext cx) {
    final snackBar = SnackBar(
      content: Text(text, textAlign: TextAlign.center),
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(cx).showSnackBar(snackBar);
  }
}