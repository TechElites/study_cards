import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/study_card.dart';
import 'package:flash_cards/src/data/model/deck.dart';
import 'package:flash_cards/src/logic/xml_handler.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class AddDeck extends StatefulWidget {
  const AddDeck({super.key});

  @override
  State<AddDeck> createState() => _AddDeckState();
}

class _AddDeckState extends State<AddDeck> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _nameController = TextEditingController();
  List<StudyCard> questionsAndAnswers = [StudyCard(question: '', answer: '')];

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xml'],
    );

    if (result != null && result.files.isNotEmpty) {
      File file = File(result.files.single.path!);
      String fileContent = await file.readAsString();
      setState(() {
        questionsAndAnswers = XmlHandler.parseXml(fileContent);
        _nameController.text = questionsAndAnswers[0].question;
      });
    }
  }

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
                labelText: 'Deck name',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _pickFile,
              child: const Text('Pick XML File'),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: questionsAndAnswers.length,
                itemBuilder: (context, index) {
                  final item = questionsAndAnswers[index];
                  if (item.question != '') {
                    var first = 'Question:';
                    var second = 'Answer:';
                    if (index == 0) {
                      first = 'Deck Name:';
                      second = 'Number of Cards:';
                    }
                    return ListTile(
                      title: Text('$first ${item.question}'),
                      subtitle: Text('$second ${item.answer}'),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_nameController.text != '') {
            _addDeck();
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  void _addDeck() {
    final Deck newDeck = Deck(
      name: _nameController.text,
      cards: questionsAndAnswers.length - 1,
      creation: DateTime.now(),
    );
    _dbHelper.insertDeck(newDeck).then((deckId) {
      if (questionsAndAnswers.length > 1) {
        for (var card in questionsAndAnswers.sublist(1)) {
          _addCard(deckId, card.question, card.answer);
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Deck added successfully'),
          duration: Duration(seconds: 1),
        ),
      );
      Navigator.pop(context, newDeck);
    });
  }

  void _addCard(deckId, question, answer) {
    final StudyCard newCard = StudyCard(
      deckId: deckId,
      question: question,
      answer: answer,
      rating: 'New',
      lastReviewed: 'Never',
    );
    _dbHelper.insertCard(newCard);
  }
}
