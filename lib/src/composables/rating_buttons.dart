import 'package:study_cards/src/data/model/rating.dart';
import 'package:study_cards/src/logic/language/string_extension.dart';
import 'package:flutter/material.dart';

/// Class to build rating buttons.
class RatingButtons {
  /// Builds a list of rating buttons.
  static Widget build(BuildContext cx, Function(String rating) onPressed,
      {String selected = ''}) {
    return FittedBox(
        fit: BoxFit.scaleDown,
        child: ButtonBar(alignment: MainAxisAlignment.spaceEvenly, children: [
          for (var rating
              in Rating.colors.entries.where((e) => e.key != Rating.none))
            ElevatedButton(
              onPressed: () {
                onPressed(rating.key);
              },
              style: ButtonStyle(
                fixedSize: WidgetStateProperty.all(
                    Size((MediaQuery.of(cx).size.width / 4.5), 50)),
                foregroundColor: rating.key == selected
                    ? WidgetStateProperty.all(Colors.white)
                    : WidgetStateProperty.all(Colors.black),
                backgroundColor: WidgetStateProperty.all(rating.value),
                elevation: rating.key == selected
                    ? WidgetStateProperty.all(5)
                    : WidgetStateProperty.all(0),
              ),
              child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(rating.key.tr(cx),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ))),
            )
        ]));
  }
}
