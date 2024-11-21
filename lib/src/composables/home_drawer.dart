import 'package:study_cards/src/logic/language/string_extension.dart';
import 'package:study_cards/src/screens/feedback/feedback.dart';
import 'package:study_cards/src/screens/guide/guide.dart';
import 'package:study_cards/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class HomeDrawer {
  static Widget build(
      BuildContext cx, bool kIsWeb, bool isSandmanReady, Function adsRewarded) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(cx).colorScheme.primary,
                Theme.of(cx).colorScheme.secondary
              ],
              transform: const GradientRotation(0.5),
            ),
          ),
          padding: const EdgeInsets.only(top: 50),
          child: const Text('Study Cards',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center),
        ),
        if (!kIsWeb && isSandmanReady)
          ListTile(
            title: Text('remove_ads'.tr(cx)),
            leading: const Icon(Icons.tv_off),
            onTap: () {
              Navigator.pop(cx);
              adsRewarded();
            },
          ),
        ListTile(
          title: Text('toggle_theme'.tr(cx)),
          leading: Icon(
            Provider.of<ThemeProvider>(cx).currentTheme == ThemeMode.light
                ? Icons.light_mode
                : (Provider.of<ThemeProvider>(cx).currentTheme == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.phone_android),
          ),
          onTap: () {
            Provider.of<ThemeProvider>(cx, listen: false).toggleTheme();
          },
        ),
        ListTile(
          title: Text('send_feedback'.tr(cx)),
          leading: const Icon(Icons.feedback),
          onTap: () {
            Navigator.push(
              cx,
              MaterialPageRoute(
                builder: (cx) => const FeedbackPage(),
              ),
            );
          },
        ),
        ListTile(
          title: Text('guide'.tr(cx)),
          leading: const Icon(Icons.menu_book_rounded),
          onTap: () {
            Navigator.push(
              cx,
              MaterialPageRoute(
                builder: (cx) => const GuidePage(),
              ),
            );
          },
        ),
        if (kIsWeb)
          ListTile(
              title: Text('download_apk'.tr(cx)),
              leading: const Icon(Icons.android),
              onTap: () => {
                    _countDownload('android'),
                    launchUrl(Uri.parse(
                        "https://studycards.altervista.org/studycards.apk"))
                  }),
        if (kIsWeb)
          ListTile(
            title: Text('download_ipa'.tr(cx)),
            leading: const Icon(Icons.apple),
            onTap: () => {
              _countDownload('ios'),
              launchUrl(
                  Uri.parse("https://studycards.altervista.org/studycards.ipa"))
            },
          )
      ],
    ));
  }

  static Future<void> _countDownload(String os) async {
    http.post(
      Uri.parse('http://studycards.altervista.org/count_download.php'),
      body: {'content': os},
    );
  }
}
