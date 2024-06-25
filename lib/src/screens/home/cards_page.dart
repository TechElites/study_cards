import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/study_card.dart';
import 'package:flash_cards/src/data/model/rating.dart';
import 'package:flash_cards/src/logic/deck_shuffler.dart';
import 'package:flash_cards/src/logic/list_deleter.dart';
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
  final ListDeleter _deleter = ListDeleter();

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
                    return Dismissible(
                        key: Key(card.id.toString()),
                        direction: DismissDirection.endToStart,
                        onDismissed: (direction) {
                          _dbHelper.deleteCard(card.id).then((_) {
                            setState(() {
                              snapshot.data!.removeAt(index);
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Card deleted')),
                            );
                          });
                        },
                        background: Container(
                          color: Colors.red[400],
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0),
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        child: Container(
                            padding: const EdgeInsets.all(8.0),
                            color:
                                _deleter.isInList(card.id) ? Colors.blue.withOpacity(0.1) : null,
                            child: Card(
                              elevation: _deleter.isInList(card.id) ? 5 : 1,
                              margin: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(card.front),
                                selected: _deleter.isInList(card.id),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
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
                                  if (_deleter.isDeleting) {
                                    setState(() {
                                      _deleter.toggleItem(card.id);
                                    });
                                    return;
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CardDetailsPage(card: card),
                                    ),
                                  ).then((value) => setState(() {}));
                                },
                                onLongPress: () {
                                  setState(() {
                                    _deleter.isDeleting = true;
                                    _deleter.toggleItem(card.id);
                                  });
                                },
                              ),
                            )));
                  },
                ));
          },
        ),
        floatingActionButton: _deleter.isDeleting
            ? FloatingActionButton(
                onPressed: () {
                  _dbHelper
                      .deleteCards(_deleter.dumpList())
                      .then((value) => setState(() {}));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cards deleted')),
                  );
                },
                tooltip: 'Delete Cards',
                child: const Icon(Icons.delete),
              )
            : SpeedDial(
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
                              const SnackBar(
                                  content: Text('No cards to review')));
                        } else {
                          _dbHelper
                              .getReviewCards(widget.deckId)
                              .then((maxCards) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReviewPage(
                                    cards: DeckShuffler.shuffleCards(
                                        cards, maxCards)),
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
