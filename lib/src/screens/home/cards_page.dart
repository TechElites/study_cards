import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/study_card.dart';
import 'package:flash_cards/src/data/model/deck.dart';
import 'package:flash_cards/src/data/model/rating.dart';
import 'package:flash_cards/src/screens/add/add_card.dart';
import 'package:flash_cards/src/screens/details/card_details.dart';
import 'package:flash_cards/src/screens/review/deck_review.dart';
import 'package:flash_cards/src/screens/settings/settings_cards_page.dart';
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
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsCardsPage(deck: widget.deck),
                  ),
                ).then((value) => setState(() {}));
              },
              icon: const Icon(Icons.settings),
            )
          ],
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
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(card.front),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Rating: ${card.rating}'),
                                  Text('Last reviewed: ${card.lastReviewedFormatted}'),
                                  const SizedBox(height: 5.0),
                                  Container(
                                    height:
                                        6, // Height of the colored bar/ Color of the bar
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 0.5,
                                      ),
                                      borderRadius: BorderRadius.circular(4),
                                      color: Rating.colors[card.rating],
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CardDetailsPage(card: card),
                                  ),
                                ).then((value) => setState(() {}));
                              },
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
              child: const Icon(Icons.add),
              label: 'Add cards',
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
                    _dbHelper.getReviewCards(widget.deck.id).then((value) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewPage(
                              cards: randomCards.length > value
                                  ? randomCards.sublist(0, value)
                                  : randomCards),
                        ),
                      ).then((value) => setState(() {}));
                    });
                  }
                });
              },
            )
          ],
        ));
  }
}
