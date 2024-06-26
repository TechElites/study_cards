import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/study_card.dart';
import 'package:flash_cards/src/logic/xml_handler.dart';
import 'package:flutter/material.dart';

class CardsSettingsPage extends StatefulWidget {
  final int deckId;

  const CardsSettingsPage({super.key, required this.deckId});

  @override
  State<CardsSettingsPage> createState() => _CardsSettingsPageState();
}

class _CardsSettingsPageState extends State<CardsSettingsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dbHelper.getReviewCards(widget.deckId).then((value) {
      setState(() {
        _cardsController.text = value.toString();
      });
    });
    _dbHelper.getDeck(widget.deckId).then((value) {
      setState(() {
        _nameController.text = value.name;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Stack(alignment: const Alignment(1.0, 1.0), children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Deck name',
              ),
            ),
            IconButton(
              onPressed: () {
                _dbHelper
                    .updateDeckName(widget.deckId, _nameController.text)
                    .then(
                        (value) => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Deck name updated'))),
                        onError: (e) => ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                                content: Text('Error updating deck name'))));
              },
              icon: const Icon(Icons.check),
            )
          ]),
          const SizedBox(height: 16.0),
          Stack(alignment: const Alignment(1.0, 1.0), children: [
            TextField(
              keyboardType: TextInputType.number,
              controller: _cardsController,
              decoration: const InputDecoration(
                labelText: 'Cards per review',
              ),
            ),
            IconButton(
              onPressed: () {
                _updateReviewCards().then(
                    (value) => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Review cards updated'))),
                    onError: (e) => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Error updating review cards'))));
              },
              icon: const Icon(Icons.check),
            )
          ]),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _exportDeck().then(
              (value) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Deck saved to Downloads folder'))),
              onError: (e) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error saving deck'))));
        },
        child: const Icon(Icons.file_download),
      ),
    );
  }

  Future<void> _exportDeck() async {
    final deck = await _dbHelper.getDeck(widget.deckId);
    final List<StudyCard> cards = await _dbHelper.getCards(deck.id);
    final String deckXml = XmlHandler.createXml(cards, deck.name);
    await XmlHandler.saveXmlToFile(deckXml, '${deck.name}.xml');
  }

  Future<void> _updateReviewCards() async {
    final int reviewCards = int.parse(_cardsController.text);
    await _dbHelper.setReviewCards(widget.deckId, reviewCards);
  }
}
