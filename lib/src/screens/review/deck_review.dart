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
            child: !_reveal
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _index < widget.cards.length
                            ? widget.cards[_index].front
                            : 'No more cards',
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 16),
                      const Text('Tap to reveal answer'),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.cards[_index].front,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.cards[_index].back,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(height: 16),
                      ButtonBar(
                        alignment: MainAxisAlignment.center,
                        children: _createRatingButtons()),
                    ],
                  ),
          ),
        ));
  }

  List<Widget> _createRatingButtons() {
    return [
      for (var rating in Rating.colors.entries.where((e) => e.key != Rating.none))
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
            backgroundColor: MaterialStateProperty.all(rating.value),
          ),
          child: Text(rating.key),
        )
    ];
  }
}
