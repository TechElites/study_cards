import 'dart:io';

import 'package:flash_cards/src/composables/rating_buttons.dart';
import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'package:flutter/material.dart';

/// Creates a page to review the cards
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
        behavior: HitTestBehavior.opaque,
        onTap: () {
          setState(() {
            _reveal = true;
          });
        },
        child: _index < widget.cards.length
            ? Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              widget.cards[_index].front,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 24),
                            ),
                            if (widget.cards[_index].frontMedia != '')
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: Image.file(
                                  File(widget.cards[_index].frontMedia),
                                  height: 200.0,
                                  width: 200.0,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                ),
                              ),
                            const SizedBox(height: 16),
                            if (_reveal)
                              Text(
                                widget.cards[_index].back,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 24),
                              ),
                            if (widget.cards[_index].backMedia != '' && _reveal)
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: Image.file(
                                  File(widget.cards[_index].backMedia),
                                  height: 200.0,
                                  width: 200.0,
                                  fit: BoxFit.cover,
                                  alignment: Alignment.center,
                                ),
                              )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _reveal
                        ? ButtonBar(
                            alignment: MainAxisAlignment.center,
                            children: RatingButtons.build((rating) {
                              _dbHelper.updateCardRating(
                                  widget.cards[_index].id, rating);
                              setState(() {
                                _index++;
                                if (_index >= widget.cards.length) {
                                  Navigator.pop(context);
                                }
                                _reveal = false;
                              });
                            }))
                        : const Text(
                            'Tap to reveal answer',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              )
            : const Center(child: Text('No more cards to review')),
      ),
    );
  }
}
