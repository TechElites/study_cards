import 'dart:developer';

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

  Future<void> _sendFeedback() async {
    final response = await http.post(
      Uri.parse('http://studycards.altervista.org/insert_feedback.php'),
      body: {'content': _contentController.text},
    );

    if (response.statusCode == 200) {
      // Mostra un messaggio di successo
      log('Feedback successful');
    } else {
      // Mostra un messaggio di errore
      log('Error sending feedback');
    }
  }

  @override
  Widget build(BuildContext cx) {
    return Scaffold(
      appBar: AppBar(title: Text('feedback'.tr(cx)), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              decoration: InputDecoration(labelText: 'feedback'.tr(cx)),
              maxLines: null,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sendFeedback,
        child: const Icon(Icons.send),
      ),
    );
  }
}
