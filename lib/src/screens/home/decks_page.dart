import 'dart:io';

// import 'package:flash_cards/src/composables/ads/ads_fullscreen.dart';
// import 'package:flash_cards/src/composables/ads/ads_sandman.dart';
import 'package:flash_cards/src/composables/ads/ads_scaffold.dart';
import 'package:flash_cards/src/composables/floating_bar.dart';
import 'package:flash_cards/src/data/database/db_helper.dart';
// import 'package:flash_cards/src/data/repositories/reward_service.dart';
import 'package:flash_cards/src/logic/language/string_extension.dart';
import 'package:flash_cards/src/logic/list_deleter.dart';
import 'package:flash_cards/src/logic/permission_helper.dart';
import 'package:flash_cards/src/screens/feedback/feedback.dart';
import 'package:flash_cards/src/screens/guide/guide.dart';
import 'package:flash_cards/theme/theme_provider.dart';
import 'package:flash_cards/src/screens/add/add_deck.dart';
import 'package:flash_cards/src/screens/home/cards_page.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
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
  final ListDeleter _deleter = ListDeleter();
  // final AdsFullscreen _adsFullScreen = AdsFullscreen();
  // final AdsSandman _adsSandman = AdsSandman();

  // @override
  // void initState() {
  //   super.initState();
  //   _adsSandman.loadAd();
  //   _adsFullScreen.loadAd();
  // }

  @override
  Widget build(BuildContext cx) {
    final decks = _dbHelper.getDecks();

    return AdsScaffold(
      appBar: AppBar(
        title: Text('decks'.tr(cx)),
        centerTitle: true,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.lightBlueAccent],
                ),
              ),
              padding: EdgeInsets.only(top: 50),
              child: Text('Study Cards',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center),
            ),
            // ListTile(
            //   title: Text('remove_ads'.tr(cx)),
            //   leading: const Icon(Icons.tv_off),
            //   onTap: () {
            //     _adsSandman.showAndReloadAd(() {
            //       RewardService().setRewarded(true).then((_) {
            //         FloatingBar.show('ad_rewarded'.tr(cx), cx);
            //         setState(() {});
            //       });
            //     });
            //   },
            // ),
            ListTile(
              title: Text('toggle_theme'.tr(cx)),
              leading: Icon(
                Provider.of<ThemeProvider>(cx).isDarkMode
                    ? Icons.light_mode
                    : Icons.dark_mode,
              ),
              onTap: () {
                Provider.of<ThemeProvider>(cx, listen: false).toggleTheme();
              },
            ),
            ListTile(
              title: Text('send_feedback'.tr(cx)),
              leading: const Icon(Icons.feedback),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FeedbackPage(),
                  ),
                );
              },
            ),
            ListTile(
              title: Text('guide'.tr(cx)),
              leading: const Icon(Icons.menu_book_rounded),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GuidePage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: ListView.builder(
            itemCount: decks.length,
            itemBuilder: (context, index) {
              final deck = decks[index];
              return Dismissible(
                  key: Key(deck.id.toString()),
                  direction: DismissDirection.endToStart,
                  onUpdate: (details) {
                    if (details.progress >= 0.5 && details.progress <= 0.55) {
                      Vibration.hasVibrator().then((value) {
                        if (value ?? false) {
                          Vibration.vibrate(duration: 10);
                        }
                      });
                    }
                  },
                  onDismissed: (direction) {
                    setState(() {
                      decks.removeAt(index);
                    });
                    _dbHelper.deleteDeck(deck.id).then((_) {
                      FloatingBar.show('deck_deleted'.tr(cx), cx);
                      _deleteFolder(List.of([deck.name]));
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
                          ? Colors.blue.withOpacity(0.1)
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
                              Text('${'total_cards'.tr(cx)}: ${deck.cards}'),
                              Text(
                                  '${'creation_date'.tr(cx)}: ${deck.creation.toString().substring(0, 10)}'),
                            ],
                          ),
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
                            ).then((value) => setState(() {}));
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
      floatingActionButton: _deleter.isDeleting
          ? FloatingActionButton(
              onPressed: () {
                final list = _deleter.dumpList();
                _dbHelper.deleteDecks(list.keys.toList()).then((value) {
                  setState(() {});
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
                    // _adsFullScreen.showAndReloadAd(() {
                    //   FloatingBar.show('deck_add_success'.tr(cx), cx);
                    //   setState(() {});
                    // });
                    setState(() {});
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
}
