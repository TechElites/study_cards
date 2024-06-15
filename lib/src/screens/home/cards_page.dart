import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/screens/add/add_card.dart';
import 'package:flutter/material.dart';

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
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _dbHelper.getCards(widget.deckId),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final card = snapshot.data![index];
              return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(children: [
                    Expanded(
                        child: Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text(card['question']),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rating: ${card['rating']}'),
                            Text('Last Reviewed: ${card['lastReviewed']}'),
                          ],
                        ),
                      ),
                    )),
                    IconButton(
                      onPressed: () {
                        _dbHelper.deleteDeck(card['id']).then((_) {
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
              builder: (context) => AddCard(deckId: widget.deckId),
            ),
          );
        },
        tooltip: 'Add Card',
        child: const Icon(Icons.add),
      ),
    );
  }
}
