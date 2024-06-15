import 'package:flash_cards/src/data/database/db_helper.dart';
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _dbHelper.getDecks(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final deck = snapshot.data![index];
              return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(children: [
                    Expanded(child:
                      Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(deck['name']),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Cards: ${deck['cards']}'),
                              Text('Creation date: ${deck['creation'].toString().substring(0,10)}'),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CardsPage(deckId: deck['id']),
                              ),
                            );
                          },
                        ),
                      )
                    ),
                    IconButton(
                      onPressed: () {
                        _dbHelper.deleteDeck(deck['id']).then((_) {
                          setState(() {});
                        });
                      },
                      icon: const Icon(Icons.delete),
                    )
                  ]));
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddDeck(),
            ),
          );
        },
        tooltip: 'Add Deck',
        child: const Icon(Icons.add),
      ),
    );
  }
}
