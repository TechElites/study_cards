import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/card.dart';
import 'package:flutter/material.dart';

class AddCard extends StatefulWidget {
  final int deckId;

  const AddCard({super.key, required this.deckId});

  @override
  State<AddCard> createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _answerController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Card'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _questionController,
              decoration: const InputDecoration(
                labelText: 'Question',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _answerController,
              decoration: const InputDecoration(
                labelText: 'Answer',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addCard,
              child: const Text('Add Card'),
            ),
          ],
        ),
      ),
    );
  }

  void _addCard() {
    final StudyCard newCard = StudyCard(
      deckId: widget.deckId,
      question: _questionController.text,
      answer: _answerController.text,
      rating: "New",
      lastReviewed: 'Never',
    );

    _dbHelper.insertCard(newCard).then((id) {
      // show toast
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Card added successfully'),
          duration: Duration(seconds: 1),
        ),
      );
      setState(() {
        _questionController.clear();
        _answerController.clear();
      });
    });
  }
}