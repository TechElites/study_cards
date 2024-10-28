import 'package:flutter/material.dart';

/// Class to shpow a custom SnackBar with a text message
class FloatingBar {
  /// Shows a SnackBar with a text message
  static void show(String text, BuildContext cx) {
    final snackBar = SnackBar(
      content: Text(text, textAlign: TextAlign.center),
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.endToStart,
      duration: const Duration(seconds: 2),
    );
    ScaffoldMessenger.of(cx).showSnackBar(snackBar);
  }

  static void showWithAction(
      String text, String actionText, Function action, BuildContext cx) {
    final snackBar = SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.endToStart,
      duration: const Duration(seconds: 2),
      action: SnackBarAction(
        label: actionText,
        onPressed: () => action(),
      ),
    );
    ScaffoldMessenger.of(cx).showSnackBar(snackBar);
  }
}
