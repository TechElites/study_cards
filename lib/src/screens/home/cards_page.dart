import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;

/// Imports for mobile ads
import 'package:flash_cards/src/composables/ads/ads_fullscreen.dart';

import 'package:flash_cards/src/composables/ads/ads_scaffold.dart';
import 'package:flash_cards/src/composables/floating_bar.dart';
import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'package:flash_cards/src/data/model/rating.dart';
import 'package:flash_cards/src/logic/deck/deck_shuffler.dart';
import 'package:flash_cards/src/logic/language/string_extension.dart';
import 'package:flash_cards/src/logic/deck/list_deleter.dart';
import 'package:flash_cards/src/screens/add/add_card.dart';
import 'package:flash_cards/src/screens/details/card_details.dart';
import 'package:flash_cards/src/screens/review/deck_review.dart';
import 'package:flash_cards/src/screens/settings/cards_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:vibration/vibration.dart';

/// Creates a page that displays the list of cards in a deck
class CardsPage extends StatefulWidget {
  final int deckId;

  const CardsPage({super.key, required this.deckId});

  @override
  State<CardsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<StudyCard> shownCards = [];
  List<StudyCard> _allCards = [];
  final List<String> _filteredRatings = ['all'];
  final ListDeleter _deleter = ListDeleter();
  late AdsFullscreen _adsFullScreen;

  @override
  void initState() {
    super.initState();
    final cards = _dbHelper.getCards(widget.deckId);
    _allCards = cards;
    shownCards = cards;
    if (!kIsWeb) {
      _adsFullScreen = AdsFullscreen();
      _adsFullScreen.loadAd();
    }
  }

  void refreshList() {
    setState(() {
      final cards = _dbHelper.getCards(widget.deckId);
      _allCards = cards;
      shownCards = cards;
    });
  }

  @override
  Widget build(BuildContext cx) {
    return AdsScaffold(
        appBar: AppBar(
          title: Text('cards'.tr(cx)),
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  cx,
                  MaterialPageRoute(
                    builder: (context) =>
                        CardsSettingsPage(deckId: widget.deckId),
                  ),
                );
              },
              icon: const Icon(Icons.settings),
            )
          ],
        ),
        body: RefreshIndicator(
            onRefresh: () async {
              refreshList();
            },
            // search textbox to filter cards by front text or back text
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'search'.tr(cx),
                  ),
                  onChanged: (value) {
                    setState(() {
                      shownCards = _allCards
                          .where((card) =>
                              card.front
                                  .toLowerCase()
                                  .contains(value.toLowerCase()) ||
                              card.back
                                  .toLowerCase()
                                  .contains(value.toLowerCase()))
                          .toList();
                    });
                  },
                ),
              ),
              //const Divider(),
              Expanded(
                child: ListView.builder(
                  itemCount: shownCards.length,
                  itemBuilder: (context, index) {
                    final card = shownCards.elementAt(index);
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
                        confirmDismiss: (direction) async {
                          int deletionTime = 3;
                          Completer<bool?> completer = Completer<bool?>();
                          Timer deletionTimer =
                              Timer(Duration(seconds: deletionTime), () {
                            completer.complete(true);
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          });
                          FloatingBar.showWithAction(
                              'card_deletion'.tr(cx), 'undo'.tr(cx), () {
                            completer.complete(false);
                            deletionTimer.cancel();
                          }, cx);
                          return completer.future;
                        },
                        onDismissed: (direction) {
                          setState(() {
                            shownCards.removeAt(index);
                          });
                          _dbHelper.deleteCard(card.id).then((_) {
                            FloatingBar.show('card_deleted'.tr(cx), cx);
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
                                ? Theme.of(cx)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1)
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
                                  ).then((value) {
                                    if (value != null) {
                                      FloatingBar.show(
                                          'card_modify_success'.tr(cx), cx);
                                      refreshList();
                                    }
                                  });
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
              )
            ])),
        floatingActionButton: _deleter.isDeleting
            ? FloatingActionButton(
                onPressed: () {
                  _dbHelper
                      .deleteCards(_deleter.dumpList().keys.toList())
                      .then((value) => refreshList());
                  FloatingBar.show('cards_deleted'.tr(cx), cx);
                },
                tooltip: 'delete_cards'.tr(cx),
                child: const Icon(Icons.delete),
              )
            : SpeedDial(icon: Icons.menu, activeIcon: Icons.close, children: [
                SpeedDialChild(
                  child: const Icon(Icons.filter_alt_rounded),
                  label: 'filter_cards'.tr(cx),
                  onTap: () async {
                    _openRatingFilter(cx);
                  },
                ),
                SpeedDialChild(
                  child: const Icon(Icons.add),
                  label: 'add_cards'.tr(cx),
                  onTap: () {
                    Navigator.push(
                      cx,
                      MaterialPageRoute(
                        builder: (context) => AddCard(deckId: widget.deckId),
                      ),
                    ).then((value) => refreshList());
                  },
                ),
                SpeedDialChild(
                    child: const Icon(Icons.rate_review),
                    label: 'review'.tr(cx),
                    onTap: () {
                      if (shownCards.isEmpty) {
                        FloatingBar.show('no_cards_review'.tr(cx), cx);
                      } else {
                        final maxCards =
                            _dbHelper.getReviewCards(widget.deckId);
                        Navigator.push(
                          cx,
                          MaterialPageRoute(
                            builder: (context) => ReviewPage(
                                cards: _filteredRatings.contains("no_timing")
                                    ? DeckShuffler.shuffleCards(
                                        shownCards, maxCards)
                                    : DeckShuffler.shuffleTimedCards(
                                        shownCards, maxCards)),
                          ),
                        ).then((value) {
                          if (!kIsWeb) {
                            _adsFullScreen.showAndReloadAd(() {
                              refreshList();
                            });
                          } else {
                            refreshList();
                          }
                        });
                      }
                    })
              ]));
  }

  /// Opens a dialog to filter the cards by rating
  void _openRatingFilter(BuildContext cx) {
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (context) {
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter modalSetState) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Wrap(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'select_rating'.tr(cx),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Column(
                          children: [
                            for (var rating in ['all', 'no_timing']
                                .followedBy(Rating.ratings))
                              CheckboxListTile(
                                value: _filteredRatings.contains(rating),
                                title: Text(rating.tr(cx)),
                                checkColor: Theme.of(cx).colorScheme.primary,
                                fillColor: WidgetStateProperty.all(
                                    Theme.of(cx).scaffoldBackgroundColor),
                                onChanged: (bool? selected) {
                                  setState(() {
                                    String r = rating;
                                    if (_filteredRatings.contains(r)) {
                                      _filteredRatings.remove(r);
                                    } else {
                                      _filteredRatings.add(r);
                                    }
                                    if (_filteredRatings.isEmpty) {
                                      r = 'all';
                                    }
                                    switch (r) {
                                      case 'all':
                                        _filteredRatings.clear();
                                        _filteredRatings.add('all');
                                        shownCards = _allCards;
                                        break;
                                      case 'no_timing':
                                        break;
                                      default:
                                        _filteredRatings.remove('all');
                                        shownCards = _allCards
                                            .where((card) => _filteredRatings
                                                .contains(card.rating))
                                            .toList();
                                        break;
                                    }
                                    modalSetState(() {});
                                  });
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
        });
  }
}
