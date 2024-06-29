import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'package:flash_cards/src/data/model/deck/deck.dart';
import 'package:flash_cards/src/logic/uploader/file_uploader.dart';
import 'package:flutter/material.dart';

class AddDeck extends StatefulWidget {
  const AddDeck({super.key});

  @override
  State<AddDeck> createState() => _AddDeckState();
}

class _AddDeckState extends State<AddDeck> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _nameController = TextEditingController();
  List<StudyCard> frontsAndBacks = [StudyCard(front: '', back: '')];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Deck'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              // Show a scrollable dialog with information about how to format the XML file and Zip file
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('How to format the XML file or Zip file'),
                    content: const SingleChildScrollView(
                      child: Column(
                        children: [
                          Text(
'''
Note that if you're using the web version of this app only xml files are enabled, since images in cards are not supported for now.\n
To see an example of how to format the XML file try creating a deck and exporting it.
To add more lines to the same card side, use the tag <br/>.\n
The ZIP file should contain an XML file with the same format and the media files in the same directory.
The Zip file mustn't contain subdirectories. To create a ZIP file without subdirectories:
Windows: right-click on Explorer > New > Compressed (zipped) folder. Then drag and drop (or copy and paste) the XML file and media files into the ZIP file.
''',
                          ),
                        ],
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text('Close'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
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
              onPressed: () {
                FileUploader.uploadFile().then((value) {
                  setState(() {
                    frontsAndBacks = value;
                    _nameController.text = frontsAndBacks[0].front;
                  });
                });
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(kIsWeb ? 'Pick XML file ' : 'Pick XML or ZIP file '),
                  Icon(Icons.folder_copy_rounded),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: frontsAndBacks.length,
                itemBuilder: (context, index) {
                  final item = frontsAndBacks[index];
                  if (item.front != '') {
                    var first = 'Question:';
                    var second = 'Answer:';
                    if (index == 0) {
                      first = 'Deck Name:';
                      second = 'Number of Cards:';
                    }
                    return ListTile(
                      title: Text('$first ${item.front}'),
                      subtitle: Text('$second ${item.back}'),
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
      cards: frontsAndBacks.length - 1,
      creation: DateTime.now(),
    );
    _dbHelper.insertDeck(newDeck).then((deckId) {
      if (frontsAndBacks.length > 1) {
        final List<StudyCard> cards = [];
        for (var card in frontsAndBacks.sublist(1)) {
          cards.add(StudyCard(
              deckId: deckId,
              front: card.front,
              back: card.back,
              frontMedia: card.frontMedia,
              backMedia: card.backMedia));
        }
        _dbHelper.insertDeckCards(cards);
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
}
