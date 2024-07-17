import 'package:flash_cards/src/logic/language/string_extension.dart';
import 'package:flutter/material.dart';

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
        child: Text(
          "guide_content".tr(context),
          style: const TextStyle(fontSize: 17),
          ),
      ),
    );
  }
}
