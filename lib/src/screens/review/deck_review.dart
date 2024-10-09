import 'dart:io';
import 'dart:ui';

import 'package:flash_cards/src/composables/ads/ads_scaffold.dart';
import 'package:flash_cards/src/composables/rating_buttons.dart';
import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'package:flash_cards/src/logic/language/string_extension.dart';
import 'package:flutter/material.dart';

const _animDuration = Duration(milliseconds: 300);
const _fasterAnimDuration = Duration(milliseconds: 150);

/// Creates a page to review the cards
class ReviewPage extends StatefulWidget {
  final List<StudyCard> cards;

  const ReviewPage({super.key, required this.cards});

  @override
  State<ReviewPage> createState() => _CardsReviewState();
}

class _CardsReviewState extends State<ReviewPage>
    with TickerProviderStateMixin {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  var _index = 0;
  var _reveal = false;
  var _ready = true;
  late AnimationController _revealController;
  late AnimationController _nextCardController;
  late AnimationController _ratingController;
  late Animation<Offset> _revealAnimation;
  late Animation<Offset> _nextCardAnimation;
  late Animation<Offset> _ratingAnimation;
  var _fastForward = false;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      duration: _animDuration,
      vsync: this,
    );
    _nextCardController = AnimationController(
      duration: _animDuration,
      vsync: this,
    );
    _ratingController = AnimationController(
      duration: _animDuration,
      vsync: this,
    );

    _revealAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(1.5, 0),
    ).animate(
        CurvedAnimation(parent: _revealController, curve: Curves.easeInOut));
    _nextCardAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0, 1.5),
    ).animate(
        CurvedAnimation(parent: _nextCardController, curve: Curves.easeInOut));
    _ratingAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _ratingController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _revealController.dispose();
    _nextCardController.dispose();
    _ratingController.dispose();
    super.dispose();
  }

  void _toggleReveal() {
    if (!_reveal) {
      setState(() {
        _reveal = true;
        _revealController.forward();
        _ratingController.forward();
      });
    }
  }

  void _nextCard() {
    _nextCardController.forward().then((_) {
      _ratingController.reverse().then((_) {
        setState(() {
          _index++;
          _reveal = false;
          _ready = false;
        });
        if (_index >= widget.cards.length) {
          Navigator.pop(context);
        }
        _nextCardController.reverse().then((_) => _revealController
            .reverse()
            .then((_) => setState(() => _ready = true)));
      });
    });
  }

  @override
  Widget build(BuildContext cx) {
    return AdsScaffold(
      appBar: AppBar(
        title: Text('review'.tr(cx)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                if (_fastForward) {
                  _fastForward = false;
                  _revealController.duration = _animDuration;
                  _nextCardController.duration = _animDuration;
                  _ratingController.duration = _animDuration;
                } else {
                  _fastForward = true;
                  _revealController.duration = _fasterAnimDuration;
                  _nextCardController.duration = _fasterAnimDuration;
                  _ratingController.duration = _fasterAnimDuration;
                }
              });
            },
            icon: _fastForward
                ? const Icon(Icons.fast_forward_rounded)
                : const Icon(Icons.play_arrow_rounded),
          )
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleReveal,
        child: _index < widget.cards.length
            ? Column(
                children: [
                  Expanded(
                      child: Stack(
                    children: [
                      SlideTransition(
                        position: _nextCardAnimation,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.all(16.0),
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(cx).scaffoldBackgroundColor,
                                  border: Border.all(
                                    color: Colors.blue,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(16.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                child: SingleChildScrollView(
                                  child: ImageFiltered(
                                    imageFilter: _ready
                                        ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
                                        : ImageFilter.blur(
                                            sigmaX: 5, sigmaY: 5),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          widget.cards[_index].front,
                                          style: const TextStyle(fontSize: 24),
                                          textAlign: TextAlign.center,
                                        ),
                                        if (widget.cards[_index].frontMedia !=
                                            '')
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16.0),
                                            child: Image.file(
                                              File(widget
                                                  .cards[_index].frontMedia),
                                              height: 200.0,
                                              width: 200.0,
                                              fit: BoxFit.cover,
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                        const Divider(
                                          color: Colors.blue,
                                          height: 20,
                                          thickness: 1,
                                          indent: 20,
                                          endIndent: 20,
                                        ),
                                        Text(
                                          widget.cards[_index].back,
                                          style: const TextStyle(fontSize: 24),
                                          textAlign: TextAlign.center,
                                        ),
                                        if (widget.cards[_index].backMedia !=
                                            '')
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16.0),
                                            child: Image.file(
                                              File(widget
                                                  .cards[_index].backMedia),
                                              height: 200.0,
                                              width: 200.0,
                                              fit: BoxFit.cover,
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SlideTransition(
                        position: _revealAnimation,
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                margin: const EdgeInsets.all(16.0),
                                padding: const EdgeInsets.all(16.0),
                                decoration: BoxDecoration(
                                  color: Theme.of(cx).scaffoldBackgroundColor,
                                  border: Border.all(
                                    color: Colors.blue,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(16.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black,
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: SingleChildScrollView(
                                      child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                        Text(
                                          widget.cards[_index].front,
                                          style: const TextStyle(fontSize: 24),
                                          textAlign: TextAlign.center,
                                        ),
                                        if (widget.cards[_index].frontMedia !=
                                            '')
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16.0),
                                            child: Image.file(
                                              File(widget
                                                  .cards[_index].frontMedia),
                                              height: 200.0,
                                              width: 200.0,
                                              fit: BoxFit.cover,
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                      ])),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )),
                  Container(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _reveal
                        ? SlideTransition(
                            position: _ratingAnimation,
                            child: RatingButtons.build(cx, (rating) {
                              _dbHelper.updateCardRating(
                                  widget.cards[_index].id, rating);
                              _nextCard();
                            }))
                        : Text(
                            _ready ? 'tap_reveal_answer'.tr(cx) : "",
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ],
              )
            : Center(child: Text('no_cards_review'.tr(cx))),
      ),
    );
  }
}
