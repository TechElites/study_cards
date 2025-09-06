// import 'package:flash_cards/src/screens/splash/splash_page.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Import for mobile ads
import 'package:flash_cards/src/data/repositories/reward_service.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:async';

import 'package:flash_cards/src/logic/language/localizations.dart';
import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/theme/theme_data.dart';
import 'package:flash_cards/theme/theme_provider.dart';
import 'package:flash_cards/src/screens/home/decks_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

void main() async {
  await DatabaseHelper().init();
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    await RewardService().isRewarded();
    unawaited(MobileAds.instance.initialize());
  } else {
    // this is needed since it's only a trial version on web
    await DatabaseHelper().clear();
  }
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
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'), // Inglese
            Locale('it', 'IT'), // Italiano
          ],
          initialRoute: '/',
          routes: {
            '/': (context) => DecksPage(), // Home Page - carica direttamente senza splash
            // '/': (context) => SplashPage(), // Splash page not used for now
            '/home': (context) => DecksPage(), // Home Page
          },
        );
      },
    );
  }
}
