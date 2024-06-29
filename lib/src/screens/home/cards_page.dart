import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'package:flash_cards/src/data/model/rating.dart';
import 'package:flash_cards/src/logic/deck_shuffler.dart';
import 'package:flash_cards/src/logic/list_deleter.dart';
import 'package:flash_cards/src/screens/add/add_card.dart';
import 'package:flash_cards/src/screens/details/card_details.dart';
import 'package:flash_cards/src/screens/review/deck_review.dart';
import 'package:flash_cards/src/screens/settings/cards_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:vibration/vibration.dart';

class CardsPage extends StatefulWidget {
  final int deckId;

  const CardsPage({super.key, required this.deckId});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<StudyCard>? _allCards;
  List<StudyCard>? _shownCards;
  String _filteredRating = "All";
  final ListDeleter _deleter = ListDeleter();

  void refresh() {
    setState(() {
      _allCards = null;
      _shownCards = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_allCards == null) {
      final value = _dbHelper.getCards(widget.deckId);
      setState(() {
        _allCards = value;
        _shownCards = value;
      });
    }
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
                ).then((value) => refresh());
              },
              icon: const Icon(Icons.settings),
            )
          ],
        ),
        body: _shownCards == null
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () async {
                  refresh();
                },
                child: ListView.builder(
                  itemCount: _shownCards?.length,
                  itemBuilder: (context, index) {
                    final card = _shownCards?.elementAt(index) ??
                        StudyCard(front: '', back: '');
                    return Dismissible(
                        key: Key(card.id.toString()),
                        direction: DismissDirection.endToStart,
                        onUpdate: (details) {
                          if (details.progress >= 0.5 &&
                              details.progress <= 0.55) {
                            Vibration.hasVibrator().then((value) {
                              if (value ?? false) {
                                Vibration.vibrate(duration: 10);
                              }
                            });
                          }
                        },
                        onDismissed: (direction) {
                          setState(() {
                            _shownCards?.removeAt(index);
                          });
                          _dbHelper.deleteCard(card.id).then((_) {
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
                            color: _deleter.isInList(card.id)
                                ? Colors.blue.withOpacity(0.1)
                                : null,
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
                                  ).then((value) => refresh());
                                },
                                onLongPress: () {
                                  setState(() {
                                    _deleter.isDeleting = true;
                                    _deleter.toggleItem(card.id);
                                  });
                                  Vibration.hasVibrator().then((value) {
                                    if (value ?? false) {
                                      Vibration.vibrate(duration: 10);
                                    }
                                  });
                                },
                              ),
                            )));
                  },
                ),
              ),
        floatingActionButton: _deleter.isDeleting
            ? FloatingActionButton(
                onPressed: () {
                  _dbHelper
                      .deleteCards(_deleter.dumpList().keys.toList())
                      .then((value) => refresh());
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cards deleted')),
                  );
                },
                tooltip: 'Delete Cards',
                child: const Icon(Icons.delete),
              )
            : SpeedDial(icon: Icons.menu, activeIcon: Icons.close, children: [
                SpeedDialChild(
                  child: const Icon(Icons.filter_alt_rounded),
                  label: 'Filter cards',
                  onTap: () async {
                    _openRatingFilter();
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.add),
                  label: 'Add cards',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddCard(deckId: widget.deckId),
                      ),
                    ).then((value) => refresh());
                  },
                ),
                SpeedDialChild(
                    child: const Icon(Icons.rate_review),
                    label: 'Review',
                    onTap: () {
                      if (_shownCards != null) {
                        if (_shownCards!.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('No cards to review')));
                        } else {
                          final maxCards =
                              _dbHelper.getReviewCards(widget.deckId);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewPage(
                                  cards: _filteredRating == "All"
                                      ? DeckShuffler.shuffleTimedCards(
                                          _shownCards!, maxCards)
                                      : DeckShuffler.shuffleCards(
                                          _shownCards!, maxCards)),
                            ),
                          ).then((value) => refresh());
                        }
                      }
                    })
              ]));
  }

  void _openRatingFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Wrap(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Select Rating',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      for (var rating in ["All", "Ignore rating"]
                          .followedBy(Rating.ratings))
                        ListTile(
                          title: Text(rating),
                          selected: rating == _filteredRating,
                          onTap: () {
                            setState(() {
                              _filteredRating = rating;
                              if (rating != "All" &&
                                  rating != "Ignore rating") {
                                _shownCards = _allCards!
                                    .where(
                                        (element) => element.rating == rating)
                                    .toList();
                              } else {
                                _shownCards = _allCards;
                              }
                            });
                            Navigator.pop(context);
                          },
                        )
                    ],
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
