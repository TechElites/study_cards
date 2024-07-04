import 'package:flutter/material.dart';
import 'localizations.dart';

/// Extension to translate strings
/// example:
/// ```dart
/// 'hello_world'.tr(context)
/// ```
extension LocalizationExtension on String {
  String tr(BuildContext context) {
    return AppLocalizations.of(context)!.translate(this) ?? 'missing translation';
  }
}