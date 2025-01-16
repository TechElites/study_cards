import 'dart:io';
import 'dart:ui';

import 'package:flash_cards/src/composables/ads/ads_scaffold.dart';
import 'package:flash_cards/src/composables/floating_bar.dart';
import 'package:flash_cards/src/composables/rating_buttons.dart';
import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'package:flash_cards/src/logic/language/string_extension.dart';
import 'package:flutter/material.dart';
import 'package:flash_cards/src/screens/details/card_details.dart';
import 'package:markdown_editor_plus/widgets/markdown_parse.dart';

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
    _index++;
    if (_index >= widget.cards.length) {
      Navigator.pop(context);
    } else {
      _nextCardController.forward().then((_) {
        _ratingController.reverse().then((_) {
          setState(() {
            _reveal = false;
            _ready = false;
          });
          _nextCardController.reverse().then((_) => _revealController
              .reverse()
              .then((_) => setState(() => _ready = true)));
        });
      });
    }
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
                                  color: Theme.of(cx).colorScheme.surface,
                                  border: Border.all(
                                    color: Theme.of(cx).colorScheme.secondary,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(16.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      offset: Offset(-0.5, 0.5),
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
                                      children: [
                                        Text(
                                          widget.cards[_index].front,
                                          style: const TextStyle(fontSize: 24),
                                        ),
                                        if (widget.cards[_index].frontMedia !=
                                            '')
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16.0),
                                            child: Image.file(
                                              File(widget
                                                  .cards[_index].frontMedia),
                                              height: 300.0, // Altezza massima
                                              width: 300.0, // Larghezza massima
                                              fit: BoxFit
                                                  .contain, // Ridimensiona mantenendo le proporzioni
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                        Divider(
                                          color: Theme.of(cx)
                                              .colorScheme
                                              .secondary,
                                          height: 20,
                                          thickness: 1,
                                          indent: 20,
                                          endIndent: 20,
                                        ),
                                        MarkdownParse(
                                          data: widget.cards[_index].back,
                                          shrinkWrap: true,
                                        ),
                                        if (widget.cards[_index].backMedia !=
                                            '')
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 16.0),
                                            child: Image.file(
                                              File(widget
                                                  .cards[_index].backMedia),
                                              height: 300.0, // Altezza massima
                                              width: 300.0, // Larghezza massima
                                              fit: BoxFit
                                                  .contain, // Ridimensiona mantenendo le proporzioni
                                              alignment: Alignment.center,
                                            ),
                                          ),
                                        SizedBox(height: 16),
                                        IconButton(
                                          icon: Icon(Icons.edit_note),
                                          iconSize: 32,
                                          onPressed: () {
                                            Navigator.push(
                                              cx,
                                              MaterialPageRoute(
                                                builder: (cx) =>
                                                    CardDetailsPage(
                                                        card: widget
                                                            .cards[_index]),
                                              ),
                                            ).then((value) {
                                              if (value != null) {
                                                if (!cx.mounted) return;
                                                FloatingBar.show(
                                                    'card_modify_success'
                                                        .tr(cx),
                                                    cx);
                                              }
                                            });
                                          },
                                        )
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
                                    color: Theme.of(cx).colorScheme.secondary,
                                    width: 2.0,
                                  ),
                                  borderRadius: BorderRadius.circular(16.0),
                                  boxShadow: const [
                                    BoxShadow(
                                      offset: Offset(-0.5, 0.5),
                                      color: Colors.black,
                                      blurRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: SingleChildScrollView(
                                      child: Column(children: [
                                    Text(
                                      widget.cards[_index].front,
                                      style: const TextStyle(fontSize: 24),
                                    ),
                                    if (widget.cards[_index].frontMedia != '')
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 16.0),
                                        child: Image.file(
                                          File(widget.cards[_index].frontMedia),
                                          height: 300.0, // Altezza massima
                                          width: 300.0, // Larghezza massima
                                          fit: BoxFit
                                              .contain, // Ridimensiona mantenendo le proporzioni
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
                              _dbHelper.updateCardsRating(
                                  [widget.cards[_index].id], rating);
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
