import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/rating.dart';
import 'package:flash_cards/src/data/model/study_card.dart';
import 'package:flutter/material.dart';

class ReviewPage extends StatefulWidget {
  final List<StudyCard> cards;

  const ReviewPage({super.key, required this.cards});

  @override
  State<ReviewPage> createState() => _CardsReviewState();
}

class _CardsReviewState extends State<ReviewPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  var _index = 0;
  var _reveal = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Review'),
          centerTitle: true,
        ),
        body: GestureDetector(
          onTap: () {
            setState(() {
              _reveal = true;
            });
          },
          child: Center(
            child: _index < widget.cards.length
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 100),
                          Text(
                            widget.cards[_index].front,
                            style: const TextStyle(fontSize: 24),
                          ),
                          const SizedBox(height: 30),
                          if (_reveal)
                            Text(
                              widget.cards[_index].back,
                              style: const TextStyle(fontSize: 24),
                            )
                          else
                            const Text('Tap to reveal answer'),
                        ],
                      ),
                      if (_reveal)
                        Padding(
                          padding: const EdgeInsets.only(
                              bottom: 20.0), // Add some space at the bottom
                          child: ButtonBar(
                            alignment: MainAxisAlignment.center,
                            children: _createRatingButtons(),
                          ),
                        ),
                    ],
                  )
                : const Text('No more cards'),
          ),
        ));
  }

  List<Widget> _createRatingButtons() {
    return [
      for (var rating
          in Rating.colors.entries.where((e) => e.key != Rating.none))
        ElevatedButton(
          onPressed: () {
            _dbHelper.updateCardRating(widget.cards[_index].id, rating.key);
            setState(() {
              _index++;
              if (_index >= widget.cards.length) {
                Navigator.pop(context);
              }
              _reveal = false;
            });
          },
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.all(Colors.black),
            backgroundColor: MaterialStateProperty.all(rating.value),
          ),
          child: Text(rating.key),
        )
    ];
  }
}
