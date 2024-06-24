import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/study_card.dart';
import 'package:flash_cards/src/data/model/rating.dart';
import 'package:flash_cards/src/logic/deck_shuffler.dart';
import 'package:flash_cards/src/screens/add/add_card.dart';
import 'package:flash_cards/src/screens/details/card_details.dart';
import 'package:flash_cards/src/screens/review/deck_review.dart';
import 'package:flash_cards/src/screens/settings/cards_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class CardsPage extends StatefulWidget {
  final int deckId;

  const CardsPage({super.key, required this.deckId});

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
                    builder: (context) =>
                        CardsSettingsPage(deckId: widget.deckId),
                  ),
                ).then((value) => setState(() {}));
              },
              icon: const Icon(Icons.settings),
            )
          ],
        ),
        body: FutureBuilder<List<StudyCard>>(
          future: _dbHelper.getCards(widget.deckId),
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
                          ElevatedButton(
                            onPressed: () {
                              _dbHelper.deleteCard(card.id).then((_) {
                                setState(() {});
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              shape: const CircleBorder(),
                              padding: const EdgeInsets.all(10),
                            ),
                            child: const Icon(Icons.delete),
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
                                  Text(
                                      'Last reviewed: ${card.lastReviewedFormatted}'),
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
                                    builder: (context) =>
                                        CardDetailsPage(card: card),
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
                    builder: (context) => AddCard(deckId: widget.deckId),
                  ),
                );
                setState(() {});
              },
            ),
            SpeedDialChild(
              child: const Icon(Icons.rate_review),
              label: 'Review',
              onTap: () async {
                await _dbHelper.getCards(widget.deckId).then((cards) {
                  if (cards.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('No cards to review')));
                  } else {
                    _dbHelper.getReviewCards(widget.deckId).then((maxCards) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReviewPage(
                              cards:
                                  DeckShuffler.shuffleCards(cards, maxCards)),
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
