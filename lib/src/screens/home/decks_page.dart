import 'dart:io';

import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/logic/list_deleter.dart';
import 'package:flash_cards/theme/theme_provider.dart';
import 'package:flash_cards/src/screens/add/add_deck.dart';
import 'package:flash_cards/src/screens/home/cards_page.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:vibration/vibration.dart';

class DecksPage extends StatefulWidget {
  const DecksPage({super.key});

  @override
  State<DecksPage> createState() => _DecksPageState();
}

class _DecksPageState extends State<DecksPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ListDeleter _deleter = ListDeleter();

  @override
  Widget build(BuildContext context) {
    final decks = _dbHelper.getDecks();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Decks'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Provider.of<ThemeProvider>(context).isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            },
          ),
        ],
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
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Deck ${deck.name} deleted')),
                      );
                      deleteFolder(List.of([deck.name]));
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
                              Text('Total cards: ${deck.cards}'),
                              Text(
                                  'Creation date: ${deck.creation.toString().substring(0, 10)}'),
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
                  deleteFolder(list.values.toList());
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Decks deleted')),
                );
              },
              tooltip: 'Delete Decks',
              child: const Icon(Icons.delete),
            )
          : FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddDeck(),
                  ),
                ).then((value) => setState(() {}));
              },
              tooltip: 'Add Deck',
              child: const Icon(Icons.add),
            ),
    );
  }

  void deleteFolder(List<String> list) {
    var appPath = '';
    getExternalStorageDirectory().then((directory) {
      appPath = directory!.path;
      for (var deckName in list) {
        final folder = Directory(path.join(appPath.toString(), deckName));
        if (folder.existsSync()) {
          //print('Deleting folder: ${folder.path}');
          folder.deleteSync(recursive: true);
        }
      }
    });
  }
}
