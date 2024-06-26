import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/study_card.dart';
import 'package:flutter/material.dart';

class AddCard extends StatefulWidget {
  final int deckId;

  const AddCard({super.key, required this.deckId});

  @override
  State<AddCard> createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();

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
              controller: _frontController,
              decoration: const InputDecoration(
                labelText: 'Question',
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _backController,
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
        front: _frontController.text,
        back: _backController.text);

    _dbHelper.insertCard(newCard).then((id) {
      // show toast
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Card added successfully'),
          duration: Duration(seconds: 1),
        ),
      );
      setState(() {
        _frontController.clear();
        _backController.clear();
      });
    });
  }
}
