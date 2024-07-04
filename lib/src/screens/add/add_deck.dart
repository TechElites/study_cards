import 'package:flash_cards/src/composables/ads/ads_scaffold.dart';
import 'package:flash_cards/src/logic/language/string_extension.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'package:flash_cards/src/data/model/deck/deck.dart';
import 'package:flash_cards/src/logic/uploader/file_uploader.dart';
import 'package:flutter/material.dart';

/// Creates a page to handle the creation of a new deck
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
  Widget build(BuildContext cx) {
    return AdsScaffold(
      appBar: AppBar(
        title: Text('add_deck'.tr(cx)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info),
            onPressed: () {
              // Show a scrollable dialog with information about how to format the XML file and Zip file
              showDialog(
                context: cx,
                builder: (context) {
                  return AlertDialog(
                    title: Text('how_to_format'.tr(cx)),
                    content: SingleChildScrollView(
                      child: Column(
                        children: [
                          Text("format_instructions".tr(cx)),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'deck_name'.tr(cx),
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(kIsWeb ? 'pick_xml'.tr(cx) : 'pick_xml_or_zip'.tr(cx)),
                  const Icon(Icons.folder_copy_rounded),
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
                    var first = 'question'.tr(cx);
                    var second = 'answer'.tr(cx);
                    if (index == 0) {
                      first = 'deck_name'.tr(cx);
                      second = 'number_of_cards'.tr(cx);
                    }
                    return ListTile(
                      title: Text('$first: ${item.front}'),
                      subtitle: Text('$second: ${item.back}'),
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
            _addDeck().then((deckId) {
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
                SnackBar(
                  content: Text('deck_add_success'.tr(cx)),
                  duration: const Duration(seconds: 1),
                ),
              );
              Navigator.pop(context, deckId);
            });
          }
        },
        child: const Icon(Icons.save),
      ),
    );
  }

  /// Adds the deck to the database
  Future<int> _addDeck() {
    final Deck newDeck = Deck(
      name: _nameController.text,
      cards: frontsAndBacks.length - 1,
      creation: DateTime.now(),
    );
    return _dbHelper.insertDeck(newDeck);
  }
}
