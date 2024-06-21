import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/deck.dart';
import 'package:flash_cards/src/data/model/study_card.dart';
import 'package:flash_cards/src/logic/xml_handler.dart';
import 'package:flutter/material.dart';

class SettingsCardsPage extends StatefulWidget {
  final Deck deck;

  const SettingsCardsPage({super.key, required this.deck});

  @override
  State<SettingsCardsPage> createState() => _SettingsCardsPageState();
}

class _SettingsCardsPageState extends State<SettingsCardsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _cardsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _dbHelper.getReviewCards(widget.deck.id).then((value) {
      setState(() {
        _cardsController.text = value.toString();
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
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
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
                        onError: (e) => ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                                content: Text('Error updating review cards'))));
                  },
                  icon: const Icon(Icons.check),
                )
              ]),
              ElevatedButton(
                onPressed: () {
                  _exportDeck().then(
                      (value) => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Deck saved to Downloads folder'))),
                      onError: (e) => ScaffoldMessenger.of(context)
                          .showSnackBar(const SnackBar(
                              content: Text('Error saving deck'))));
                },
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.file_download),
                    Text('Export deck'),
                  ],
                ),
              ),
            ]),
      ),
    );
  }

  Future<void> _exportDeck() async {
    final List<StudyCard> cards = await _dbHelper.getCards(widget.deck.id);
    final String deckXml = XmlHandler.createXml(cards, widget.deck.name);
    await XmlHandler.saveXmlToFile(deckXml, '${widget.deck.name}.xml');
  }

  Future<void> _updateReviewCards() async {
    final int reviewCards = int.parse(_cardsController.text);
    await _dbHelper.setReviewCards(widget.deck.id, reviewCards);
  }
}
