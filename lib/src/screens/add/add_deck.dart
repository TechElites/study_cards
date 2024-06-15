import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flutter/material.dart';

class AddDeck extends StatefulWidget {
  const AddDeck({super.key});

  @override
  State<AddDeck> createState() => _AddDeckState();
}

class _AddDeckState extends State<AddDeck> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _nameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Deck'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Deck Name',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addDeck,
              child: const Text('Add Deck'),
            ),
          ],
        ),
      ),
    );
  }

  void _addDeck() {
    final newDeck = {
      'name': _nameController.text,
      'cards': 0,
      'creation': DateTime.now().toIso8601String(),
    };

    _dbHelper.insertDeck(newDeck).then((_) {
      Navigator.pop(context);
    });
  }
}