import 'package:study_cards/src/logic/language/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('guide'.tr(context)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(children: [
            Text(
              "guide_title".tr(context),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "guide_content".tr(context),
              style: const TextStyle(fontSize: 17),
            ),
            const SizedBox(height: 30),
            Text(
              "guide_installation".tr(context),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              "guide_installation_content".tr(context),
              style: const TextStyle(fontSize: 17),
            ),
            TextButton(
                onPressed: () => launchUrl(Uri.parse("https://altstore.io")),
                child: const Text("https://altstore.io")),
          ])),
    );
  }
}
