import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/deck.dart';
import 'package:flash_cards/src/screens/add/add_deck.dart';
import 'package:flash_cards/src/screens/home/cards_page.dart';
import 'package:flutter/material.dart';

class DecksPage extends StatefulWidget {
  const DecksPage({super.key});

  @override
  State<DecksPage> createState() => _DecksPageState();
}

class _DecksPageState extends State<DecksPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Decks'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Deck>>(
        future: _dbHelper.getDecks(),
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
                  final deck = snapshot.data![index];
                  return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(children: [
                        IconButton(
                          onPressed: () {
                            _dbHelper.deleteDeck(deck.id).then((_) {
                              setState(() {});
                            });
                          },
                          icon: const Icon(Icons.delete),
                        ),
                        Expanded(
                            child: Card(
                          margin: const EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text(deck.name),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Cards: ${deck.cards}'),
                                Text(
                                    'Creation date: ${deck.creation.toString().substring(0, 10)}'),
                              ],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CardsPage(deck: deck),
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
      floatingActionButton: FloatingActionButton(
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
}
