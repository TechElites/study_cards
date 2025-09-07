import 'package:study_cards/src/composables/ads/ads_scaffold.dart';
import 'package:study_cards/src/logic/language/string_extension.dart';
import 'package:study_cards/src/data/database/db_helper.dart';
import 'package:study_cards/src/data/model/card/study_card.dart';
import 'package:study_cards/src/data/model/deck/deck.dart';
import 'package:study_cards/src/logic/load/file_uploader.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

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
                  Text('pick_xml_or_json'.tr(cx)),
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
                    
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$first: ${item.front}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4.0),
                            Text('$second: ${item.back}'),
                            if (index > 0 && (item.frontMedia.isNotEmpty || item.backMedia.isNotEmpty)) ...[
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  if (item.frontMedia.isNotEmpty) ...[
                                    _buildImagePreview(item.frontMedia, 'Front'),
                                    const SizedBox(width: 8.0),
                                  ],
                                  if (item.backMedia.isNotEmpty) ...[
                                    _buildImagePreview(item.backMedia, 'Back'),
                                  ],
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
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
              if (!cx.mounted) return;
              Navigator.pop(cx, deckId);
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
      cards: frontsAndBacks.length > 1 ? frontsAndBacks.length - 1 : 0,
      creation: DateTime.now(),
    );
    return _dbHelper.insertDeck(newDeck);
  }

  /// Builds a small preview widget for image media
  Widget _buildImagePreview(String mediaData, String label) {
    if (mediaData.isEmpty) return const SizedBox.shrink();
    
    try {
      final bytes = base64Decode(mediaData);
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8.0),
                  topRight: Radius.circular(8.0),
                ),
              ),
              child: Text(
                label,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0),
              ),
              child: Image.memory(
                bytes,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image, size: 24),
                  );
                },
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      return Container(
        width: 60,
        height: 76,
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            const Icon(Icons.broken_image, size: 24),
          ],
        ),
      );
    }
  }
}
