import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/card.dart';
import 'package:flash_cards/src/data/model/deck.dart';
import 'package:flash_cards/src/logic/xml_handler.dart';
import 'package:flash_cards/src/screens/add/add_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class CardsPage extends StatefulWidget {
  final Deck deck;

  const CardsPage({super.key, required this.deck});

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
      body: FutureBuilder<List<StudyCard>>(
        future: _dbHelper.getCards(widget.deck.id),
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
                        title: Text(card.question),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rating: ${card.rating}'),
                            Text('Last Reviewed: ${card.lastReviewed}'),
                          ],
                        ),
                      ),
                    )),
                    IconButton(
                      onPressed: () {
                        _dbHelper.deleteDeck(card.id).then((_) {
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
      floatingActionButton: SpeedDial(
        icon: Icons.menu,
        activeIcon: Icons.close,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.download),
            label: 'Download',
            onTap: () async {
              final List<StudyCard> cards = await _dbHelper.getCards(widget.deck.id);
              final String deckXml = XmlHandler.createXml(cards, widget.deck.name);
              await XmlHandler.saveXmlToFile(deckXml, '${widget.deck.name}.xml');
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.add),
            label: 'Add',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCard(deckId: widget.deck.id),
                ),
              );
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.rate_review),
            label: 'Review',
            onTap: () {
              
            },
          )
        ],
      )
    );
  }
}
