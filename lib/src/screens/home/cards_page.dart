import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/study_card.dart';
import 'package:flash_cards/src/data/model/deck.dart';
import 'package:flash_cards/src/data/model/rating.dart';
import 'package:flash_cards/src/logic/xml_handler.dart';
import 'package:flash_cards/src/screens/add/add_card.dart';
import 'package:flash_cards/src/screens/review/deck_review.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class CardsPage extends StatefulWidget {
  final Deck deck;

  const CardsPage({super.key, required this.deck});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Cards'),
          centerTitle: true,
        ),
        body: FutureBuilder<List<StudyCard>>(
          future: _dbHelper.getCards(widget.deck.id),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            return RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final card = snapshot.data![index];
                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(children: [
                          IconButton(
                            onPressed: () {
                              _dbHelper.deleteCard(card.id).then((_) {
                                setState(() {});
                              });
                            },
                            icon: const Icon(Icons.delete),
                          ),
                          Expanded(
                              child: Card(
                            surfaceTintColor: Rating.colors[card.rating],
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(card.front),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Rating: ${card.rating}'),
                                  card.lastReviewed.length < 6
                                      ? Text(
                                          'Last Reviewed: ${card.lastReviewed}')
                                      : Text(
                                          'Last Reviewed: ${card.lastReviewed.replaceFirst('T', ' ').substring(0, 16)}'),
                                ],
                              ),
                            ),
                          ))
                        ]));
                  },
                ));
          },
        ),
        floatingActionButton: SpeedDial(
          icon: Icons.menu,
          activeIcon: Icons.close,
          children: [
            SpeedDialChild(
              child: const Icon(Icons.download),
              label: 'Export',
              onTap: () {
                _exportDeck().then(
                    (value) => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Deck saved to Downloads folder'))),
                    onError: (e) => ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Error saving deck'))));
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.add),
              label: 'Add',
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddCard(deckId: widget.deck.id),
                  ),
                );
                setState(() {});
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.rate_review),
              label: 'Review',
              onTap: () async {
                await _dbHelper.getCards(widget.deck.id).then((cards) {
                  if (cards.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No cards to review')));
                  } else {
                    final randomCards = cards..shuffle();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReviewPage(
                            cards: randomCards.length > 10
                                ? randomCards.sublist(0, 10)
                                : randomCards),
                      ),
                    ).then((value) => setState(() {}));
                  }
                });
              },
            )
          ],
        ));
  }

  Future<void> _exportDeck() async {
    final List<StudyCard> cards = await _dbHelper.getCards(widget.deck.id);
    final String deckXml = XmlHandler.createXml(cards, widget.deck.name);
    final List<String> MediaList = [];
    for (final card in cards) {
      if (card.frontImage.isNotEmpty) {
        MediaList.add(card.frontImage);
      }
      if (card.backImage.isNotEmpty) {
        MediaList.add(card.backImage);
      }
    }
    await XmlHandler.saveXmlToFile(deckXml, '${widget.deck.name}.xml', MediaList);
  }
}
