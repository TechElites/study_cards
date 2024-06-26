import 'package:flash_cards/theme/theme_data.dart';
import 'package:flash_cards/theme/theme_provider.dart';
import 'package:flash_cards/src/screens/home/decks_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      child: const StudyCards(),
    ),
  );
}

class StudyCards extends StatelessWidget {
  const StudyCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'Study Cards',
          themeMode: themeProvider.currentTheme,
          theme: customLightTheme,
          darkTheme: customDarkTheme,
          home: const DecksPage(),
        );
      },
    );
  }
}
