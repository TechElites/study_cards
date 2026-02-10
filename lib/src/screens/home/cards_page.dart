import 'dart:async';

// Imports for mobile ads
import 'package:study_cards/src/composables/ads/ads_fullscreen.dart';

import 'package:study_cards/src/composables/ads/ads_scaffold.dart';
import 'package:study_cards/src/composables/floating_bar.dart';
import 'package:study_cards/src/data/database/db_helper.dart';
import 'package:study_cards/src/data/model/card/study_card.dart';
import 'package:study_cards/src/data/model/rating.dart';
import 'package:study_cards/src/logic/deck/deck_shuffler.dart';
import 'package:study_cards/src/logic/language/string_extension.dart';
import 'package:study_cards/src/logic/deck/list_selector.dart';
import 'package:study_cards/src/logic/utils/platform_helper.dart';
import 'package:study_cards/src/screens/add/add_card.dart';
import 'package:study_cards/src/screens/details/card_details.dart';
import 'package:study_cards/src/screens/review/deck_review.dart';
import 'package:study_cards/src/screens/settings/cards_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final List<String> _filteredRatings = ['all'];
  DateTime? _selectedDate;
  final ListSelector _selector = ListSelector();
  late AdsFullscreen _adsFullScreen;

  @override
  void initState() {
    super.initState();
    _allCards = _dbHelper.getCards(widget.deckId);
    shownCards = _allCards;
    _searchController.text = '';
    if (PlatformHelper.isMobile) {
      _adsFullScreen = AdsFullscreen();
      _adsFullScreen.loadAd();
    }
  }

  void refreshList() {
    setState(() {
      _allCards = _dbHelper.getCards(widget.deckId);
      shownCards = _allCards;
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
                  controller: _searchController,
                  focusNode: _searchFocus,
                  decoration: InputDecoration(
                    labelText: 'search'.tr(cx),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() {
                          _searchFocus.unfocus();
                          _searchController.clear();
                          shownCards = _allCards;
                        });
                      },
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (value == '') {
                        shownCards = _allCards;
                        return;
                      }
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
              Expanded(
                child: ListView.builder(
                  itemCount: shownCards.length,
                  itemBuilder: (context, index) {
                    final card = shownCards[index];
                    return Container(
                        padding: const EdgeInsets.all(8.0),
                        color: _selector.isInList(card.id)
                            ? Theme.of(cx)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.1)
                            : null,
                        child: Slidable(
                            key: Key(card.id.toString()),
                            startActionPane: ActionPane(
                              motion: const BehindMotion(),
                              children: [
                                SlidableAction(
                                  borderRadius: BorderRadius.circular(10.0),
                                  onPressed: (scx) {
                                    _dbHelper.updateCardsRating([card.id],
                                        Rating.none).then((_) => refreshList());
                                  },
                                  icon: Icons.restore,
                                  backgroundColor: Colors.grey[400]!,
                                  foregroundColor: Colors.white,
                                  label: 'reset'.tr(cx),
                                ),
                              ],
                            ),
                            endActionPane: ActionPane(
                              motion: const BehindMotion(),
                              dismissible: DismissiblePane(
                                confirmDismiss: () {
                                  int deletionTime = 3;
                                  Completer<bool> completer = Completer<bool>();
                                  Timer deletionTimer = Timer(
                                      Duration(seconds: deletionTime), () {
                                    completer.complete(true);
                                    ScaffoldMessenger.of(context)
                                        .hideCurrentSnackBar();
                                  });
                                  String shownName = card.front.length < 10
                                      ? ' ${card.front}'
                                      : ' ${card.front.substring(0, 10)}...';
                                  FloatingBar.showWithAction(
                                      'card_deletion'.tr(cx) + shownName,
                                      'undo'.tr(cx), () {
                                    completer.complete(false);
                                    deletionTimer.cancel();
                                  }, cx);
                                  return completer.future;
                                },
                                onDismissed: () {
                                  setState(() {
                                    shownCards.removeAt(index);
                                  });
                                  _dbHelper.deleteCard(card.id).then((_) {
                                    if (cx.mounted) {
                                      FloatingBar.show(
                                          'card_deleted'.tr(cx), cx);
                                    }
                                  });
                                },
                              ),
                              children: [
                                SlidableAction(
                                  borderRadius: BorderRadius.circular(10.0),
                                  onPressed: (scx) {},
                                  icon: Icons.delete,
                                  backgroundColor: Colors.red[400]!,
                                  foregroundColor: Colors.white,
                                  label: 'delete'.tr(cx),
                                ),
                              ],
                            ),
                            child: Card(
                              elevation: _selector.isInList(card.id) ? 5 : 1,
                              margin: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Row(
                                  children: [
                                    Expanded(
                                      flex: 4,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(card.front),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            card.lastReviewedFormatted,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[600],
                                            ),
                                            textAlign: TextAlign.right,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                selected: _selector.isInList(card.id),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 6,
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
                                  if (_selector.isSelecting) {
                                    setState(() {
                                      _selector.toggleItem(card.id);
                                    });
                                    return;
                                  }
                                  Navigator.push(
                                    cx,
                                    MaterialPageRoute(
                                      builder: (cx) =>
                                          CardDetailsPage(card: card),
                                    ),
                                  ).then((value) {
                                    if (value != null) {
                                      refreshList();
                                      if (!cx.mounted) return;
                                      FloatingBar.show(
                                          'card_modify_success'.tr(cx), cx);
                                    }
                                  });
                                },
                                onLongPress: () {
                                  setState(() {
                                    _selector.isSelecting = true;
                                    _selector.toggleItem(card.id);
                                  });
                                  Vibration.hasVibrator().then((value) {
                                    if (value) {
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
        floatingActionButton: SpeedDial(
            icon: Icons.menu,
            activeIcon: Icons.close,
            children: _selector.isSelecting
                ? [
                    SpeedDialChild(
                      onTap: () {
                        _dbHelper
                            .deleteCards(_selector.dumpList().keys.toList())
                            .then((value) => refreshList());
                        FloatingBar.show('cards_deleted'.tr(cx), cx);
                      },
                      label: 'delete_cards'.tr(cx),
                      child: const Icon(Icons.delete),
                    ),
                    SpeedDialChild(
                      onTap: () {
                        _dbHelper
                            .updateCardsRating(
                                _selector.dumpList().keys.toList(), Rating.none)
                            .then((value) => refreshList());
                        FloatingBar.show('cards_reset'.tr(cx), cx);
                      },
                      label: 'reset_cards'.tr(cx),
                      child: const Icon(Icons.restore),
                    ),
                    SpeedDialChild(
                      onTap: () {
                        setState(() {
                          _selector
                              .selectAll(shownCards.map((e) => e.id).toList());
                        });
                      },
                      label: 'select_all'.tr(cx),
                      child: const Icon(Icons.select_all),
                    )
                  ]
                : [
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
                            builder: (context) =>
                                AddCard(deckId: widget.deckId),
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
                                    cards:
                                        _filteredRatings.contains("no_timing")
                                            ? DeckShuffler.shuffleCards(
                                                shownCards, maxCards)
                                            : DeckShuffler.shuffleTimedCards(
                                                shownCards, maxCards)),
                              ),
                            ).then((value) {
                              _searchController.clear();
                              if (PlatformHelper.isMobile) {
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
                            for (var rating in ['all', 'no_timing', 'by_date']
                                .followedBy(Rating.ratings))
                              CheckboxListTile(
                                value: _filteredRatings.contains(rating),
                                title: Row(
                                  children: [
                                    Text(rating.tr(cx)),
                                    if (rating == 'by_date' &&
                                        _selectedDate != null)
                                      Text(
                                        ' (${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year})',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                  ],
                                ),
                                checkColor: Theme.of(cx).colorScheme.primary,
                                fillColor: WidgetStateProperty.all(
                                    Theme.of(cx).scaffoldBackgroundColor),
                                onChanged: (bool? selected) async {
                                  String r = rating;
                                  if (r == 'by_date' &&
                                      !_filteredRatings.contains(r)) {
                                    final DateTime? pickedDate =
                                        await showDatePicker(
                                      context: context,
                                      initialDate:
                                          _selectedDate ?? DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime.now(),
                                    );
                                    if (pickedDate == null) {
                                      return;
                                    }
                                    _selectedDate = pickedDate;
                                  } else if (r == 'by_date' &&
                                      _filteredRatings.contains(r)) {
                                    _selectedDate = null;
                                  }
                                  setState(() {
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
                                        _selectedDate = null;
                                        shownCards = _allCards;
                                        break;
                                      case 'no_timing':
                                      case 'by_date':
                                        break;
                                      default:
                                        _filteredRatings.remove('all');
                                        shownCards = _allCards.where((card) {
                                          bool matchesRating = _filteredRatings
                                              .where((r) =>
                                                  r != 'no_timing' &&
                                                  r != 'by_date')
                                              .contains(card.rating);
                                          if (_filteredRatings
                                              .where((r) =>
                                                  r != 'no_timing' &&
                                                  r != 'by_date')
                                              .isEmpty) {
                                            matchesRating = true;
                                          }
                                          bool matchesDate = true;
                                          if (_filteredRatings
                                                  .contains('by_date') &&
                                              _selectedDate != null) {
                                            if (card.lastReviewed != 'never') {
                                              final cardDate = DateTime.parse(
                                                  card.lastReviewed);
                                              matchesDate = cardDate.isAfter(
                                                      _selectedDate!) ||
                                                  cardDate.isAtSameMomentAs(
                                                      _selectedDate!);
                                              ;
                                            } else {
                                              matchesDate = false;
                                            }
                                          }
                                          return matchesRating && matchesDate;
                                        }).toList();
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
