import 'package:flash_cards/src/composables/floating_bar.dart';
import 'package:flash_cards/src/logic/language/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
      appBar: AppBar(title: Text('feedback'.tr(cx)), centerTitle: true),
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
