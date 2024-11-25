import 'package:flash_cards/src/composables/floating_bar.dart';
import 'package:flash_cards/src/logic/language/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final TextEditingController _contentController = TextEditingController();

  Future<void> _sendFeedback(BuildContext cx) async {
    http.post(
      Uri.parse('http://studycards.altervista.org/insert_feedback.php'),
      body: {'content': _contentController.text},
    ).then((response) {
      if (!cx.mounted) return;
      if (response.statusCode == 200) {
        FloatingBar.show("feedback_success".tr(cx), cx);
      } else {
        FloatingBar.show("feedback_fail".tr(cx), cx);
      }
    });
    _contentController.clear();
  }

  @override
  Widget build(BuildContext cx) {
    return Scaffold(
      appBar: AppBar(
        title: Text('feedback'.tr(cx)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              showDialog(
                context: cx,
                builder: (context) {
                  return AlertDialog(
                    title: Text('how_to_feedback'.tr(cx)),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text("feedback_instructions".tr(cx)),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text('close'.tr(cx)),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'feedback'.tr(cx)),
              maxLines: null,
              maxLength: 500,
            ),
            Text('or'.tr(cx)),
            const SizedBox(height: 16.0),
            ElevatedButton(
              child: Text('amazon_feedback'.tr(cx)),
              onPressed: () => launchUrl(Uri.parse(
                  "https://www.amazon.it/review/create-review/ref=cm_cr_othr_d_wr_but_top?ie=UTF8&channel=glance-detail&asin=B0DK3N6GXT")),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _sendFeedback(cx),
        child: const Icon(Icons.send),
      ),
    );
  }
}
