import 'dart:async';
import 'dart:io';
import 'package:flash_cards/src/composables/home_drawer.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'package:flash_cards/src/data/model/deck/deck.dart';
import 'package:flash_cards/src/data/remote/supabase_helper.dart';
import 'package:flash_cards/src/logic/load/file_reader.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Import for mobile ads
import 'package:flash_cards/src/composables/ads/ads_fullscreen.dart';
import 'package:flash_cards/src/composables/ads/ads_sandman.dart';

import 'package:flash_cards/src/composables/ads/ads_scaffold.dart';
import 'package:flash_cards/src/composables/floating_bar.dart';
import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/logic/language/string_extension.dart';
import 'package:flash_cards/src/logic/deck/list_deleter.dart';
import 'package:flash_cards/src/logic/permission_helper.dart';
import 'package:flash_cards/src/screens/add/add_deck.dart';
import 'package:flash_cards/src/screens/home/cards_page.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:vibration/vibration.dart';

/// Creates a page to display the list of all the decks
class DecksPage extends StatefulWidget {
  const DecksPage({super.key});

  @override
  State<DecksPage> createState() => _DecksPageState();
}

class _DecksPageState extends State<DecksPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final SupabaseHelper _supa = SupabaseHelper();
  final ListDeleter _deleter = ListDeleter();
  List<Deck> decks = [];
  // String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  /// ads
  late AdsFullscreen _adsFullScreen;
  late AdsSandman _adsSandman;

  @override
  void initState() {
    super.initState();
    decks = _dbHelper.getDecks();
    if (!kIsWeb) {
      _adsFullScreen = AdsFullscreen();
      _adsSandman = AdsSandman();
      _adsFullScreen.loadAd();
    }
    _searchController.text = '';
  }

  void refreshList() {
    setState(() {
      decks = _dbHelper.getDecks();
    });
  }

  @override
  Widget build(BuildContext cx) {
    if (!kIsWeb) _adsSandman.loadAd(() => setState(() {}));

    return AdsScaffold(
      appBar: AppBar(
        title: Text('decks'.tr(cx)),
        centerTitle: true,
      ),
      drawer: HomeDrawer.build(cx, kIsWeb, kIsWeb ? false : _adsSandman.isReady,
          () {
        _adsSandman.showAd(() {
          FloatingBar.show('ad_rewarded'.tr(cx), cx);
          setState(() {});
        }).then((showed) {
          if (!showed) {
            FloatingBar.show('no_ads_left'.tr(cx), cx);
          }
        });
      }),
      body: RefreshIndicator(
        onRefresh: () async {
          refreshList();
        },
        child: decks.isEmpty && _searchController.text.isEmpty
            ? Center(
                child: Container(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_circle_outline_outlined,
                              size: 80, color: Colors.grey.withOpacity(0.5)),
                          Text('no_decks'.tr(cx),
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 20)),
                        ])))
            :
            // search textbox to filter decks by name
            Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'search'.tr(cx),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        decks = _dbHelper.getDecks().where((deck) {
                          return deck.name
                              .toLowerCase()
                              .contains(value.toLowerCase());
                        }).toList();
                      });
                    },
                  ),
                ),
                Expanded(
                    child: ListView.builder(
                  itemCount: decks.length,
                  itemBuilder: (context, index) {
                    final deck = decks[index];
                    return Dismissible(
                        key: Key(deck.id.toString()),
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
                              'deck_deletion'.tr(cx), 'undo'.tr(cx), () {
                            completer.complete(false);
                            deletionTimer.cancel();
                          }, cx);
                          return completer.future;
                        },
                        onDismissed: (direction) {
                          setState(() {
                            decks.removeAt(index);
                          });
                          _dbHelper.deleteDeck(deck.id).then((_) {
                            FloatingBar.show('deck_deleted'.tr(cx), cx);
                            _deleteFolder(List.of([deck.name]));
                            _supa.deleteDeck([deck.shared]);
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
                            color: _deleter.isInList(deck.id)
                                ? Theme.of(cx)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.1)
                                : null,
                            child: Card(
                              elevation: _deleter.isInList(deck.id) ? 5 : 1,
                              margin: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(deck.name),
                                selected: _deleter.isInList(deck.id),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        '${'total_cards'.tr(cx)}: ${deck.cards}'),
                                    Text(
                                        '${'creation_date'.tr(cx)}: ${deck.creation.toString().substring(0, 10)}'),
                                  ],
                                ),
                                trailing: deck.shared == ''
                                    ? null
                                    : IconButton(
                                        icon: const Icon(
                                            Icons.cloud_download_outlined),
                                        onPressed: () {
                                          _mergeDeck(deck, () {
                                            refreshList();
                                            FloatingBar.show(
                                                'deck_merged'.tr(cx), cx);
                                          });
                                        }),
                                onTap: () {
                                  if (_deleter.isDeleting) {
                                    setState(() {
                                      _deleter.toggleItem(deck.id);
                                    });
                                    return;
                                  }
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          CardsPage(deckId: deck.id),
                                    ),
                                  ).then((value) => refreshList());
                                },
                                onLongPress: () {
                                  setState(() {
                                    _deleter.isDeleting = true;
                                    _deleter.toggleItem(deck.id);
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
                )),
              ]),
      ),
      floatingActionButton: _deleter.isDeleting
          ? FloatingActionButton(
              onPressed: () {
                final list = _deleter.dumpList();
                _dbHelper.deleteDecks(list.keys.toList()).then((value) {
                  refreshList();
                  _deleteFolder(list.values.toList());
                });
                FloatingBar.show('decks_deleted'.tr(cx), cx);
              },
              tooltip: 'delete_decks'.tr(cx),
              child: const Icon(Icons.delete),
            )
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  cx,
                  MaterialPageRoute(
                    builder: (context) => const AddDeck(),
                  ),
                ).then((value) {
                  if (value != null) {
                    if (!kIsWeb) {
                      _adsFullScreen.showAndReloadAd(() {
                        FloatingBar.show('deck_add_success'.tr(cx), cx);
                        refreshList();
                      });
                    } else {
                      refreshList();
                    }
                  }
                });
              },
              tooltip: 'add_deck'.tr(cx),
              child: const Icon(Icons.add),
            ),
    );
  }

  /// Deletes the folders associated to a deck
  Future<void> _deleteFolder(List<String> list) async {
    var appPath = '';
    Directory? externalDir;
    if (Platform.isAndroid) {
      final hasPermission = await PermissionHelper.requestStoragePermissions();
      if (!hasPermission) {
        throw Exception("Missing storage permissions.");
      }
      externalDir = await getExternalStorageDirectory();
    } else {
      externalDir = await getApplicationSupportDirectory();
    }
    appPath = externalDir!.path;
    for (var deckName in list) {
      final folder = Directory(path.join(appPath.toString(), deckName));
      if (folder.existsSync()) {
        folder.deleteSync(recursive: true);
      }
    }
  }

  /// Merges a deck from the Supabase storage with the local deck
  void _mergeDeck(Deck deck, Function onMerge) {
    _supa.downloadDeck(deck.shared).then((list) {
      FileReader.readFromList(list, deck.shared).then((sharedCards) {
        final deckCards = _dbHelper.getCards(deck.id);
        _dbHelper.deleteCards(deckCards.map((c) => c.id).toList());
        final merged = <StudyCard>[];
        for (var shC in sharedCards) {
          StudyCard mergedCard = shC;
          if (deckCards.any((c) => c.front == shC.front)) {
            final oldCard = deckCards.firstWhere((c) => c.front == shC.front);
            mergedCard = StudyCard(
              deckId: oldCard.deckId,
              rating: oldCard.rating,
              front: shC.front,
              back: shC.back,
              frontMedia: shC.frontMedia,
              backMedia: shC.backMedia,
            );
          }
          merged.add(mergedCard);
        }
        _dbHelper.insertDeckCards(merged);
        onMerge();
      });
    });
  }
}
