import 'package:flash_cards/src/data/model/rating.dart';
import 'package:flutter/material.dart';

/// Class to build rating buttons.
class RatingButtons {
  /// Builds a list of rating buttons.
  static List<Widget> build(Function(String rating) onPressed, {String selected = ''}) {
    return [
      for (var rating
          in Rating.colors.entries.where((e) => e.key != Rating.none))
        ElevatedButton(
          onPressed: () { onPressed(rating.key); },
          style: ButtonStyle(
            foregroundColor: rating.key == selected
                ? WidgetStateProperty.all(Colors.white)
                : WidgetStateProperty.all(Colors.black),
            backgroundColor: WidgetStateProperty.all(rating.value),
            elevation: rating.key == selected
                ? WidgetStateProperty.all(5)
                : WidgetStateProperty.all(0),
          ),
          child: Text(rating.key),
        )
    ];
  }
}