import 'dart:io';

import 'package:flash_cards/src/composables/ads/ads_scaffold.dart';
import 'package:flash_cards/src/composables/media_picker.dart';
import 'package:flash_cards/src/composables/rating_buttons.dart';
import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'package:flash_cards/src/logic/language/string_extension.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Creates a page to handle the creation of new cards
class CardDetailsPage extends StatefulWidget {
  final StudyCard card;

  const CardDetailsPage({super.key, required this.card});

  @override
  State<CardDetailsPage> createState() => _CardsPageState();
}

class _CardsPageState extends State<CardDetailsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();
  String _ratingController = 'None';
  File? _selectedFrontImage;
  File? _selectedBackImage;

  @override
  void initState() {
    super.initState();
    _frontController.text = widget.card.front;
    _backController.text = widget.card.back;
    _ratingController = widget.card.rating;
    _selectedFrontImage =
        widget.card.frontMedia != '' ? File(widget.card.frontMedia) : null;
    _selectedBackImage =
        widget.card.backMedia != '' ? File(widget.card.backMedia) : null;
  }

  @override
  Widget build(BuildContext cx) {
    return AdsScaffold(
      appBar: AppBar(title: Text('modify_card'.tr(cx)), centerTitle: true),
      body: Column(children: [
        Column(children: [
          const SizedBox(height: 16.0),
          RatingButtons.build(cx, selected: _ratingController, (rating) {
            setState(() {
              _ratingController = rating;
            });
          }),
          Text(
              '${'last_reviewed'.tr(cx)}: ${widget.card.lastReviewedFormatted == 'never' ? 'never'.tr(cx) : widget.card.lastReviewedFormatted}'),
        ]),
        Expanded(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _frontController,
                decoration: InputDecoration(
                    labelText: 'Front',
                    suffixIcon: kIsWeb || _selectedFrontImage != null
                        ? null
                        : InkWell(
                            onTap: () {
                              MediaPicker.pickImage(context).then((value) {
                                setState(() {
                                  _selectedFrontImage = File(value);
                                });
                              });
                            },
                            child: const Icon(Icons.add_photo_alternate_rounded,
                                color: Colors.grey, size: 32.0))),
                maxLines: null,
              ),
              if (_selectedFrontImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      Image.file(
                        File(_selectedFrontImage!.path),
                        height: 300.0, // Altezza massima
                        width: 300.0, // Larghezza massima
                        fit: BoxFit
                            .contain, // Ridimensiona mantenendo le proporzioni
                        alignment: Alignment.center,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedFrontImage = null;
                                });
                              },
                              icon: const Icon(
                                Icons.image_not_supported_rounded,
                                color: Colors.red,
                              )),
                          const SizedBox(width: 16.0),
                          IconButton(
                              onPressed: () {
                                MediaPicker.pickImage(context).then((value) {
                                  setState(() {
                                    _selectedFrontImage = File(value);
                                  });
                                });
                              },
                              icon: Icon(
                                Icons.edit_square,
                                color: Theme.of(cx).colorScheme.primary,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _backController,
                decoration: InputDecoration(
                    labelText: 'Back',
                    suffixIcon: kIsWeb || _selectedBackImage != null
                        ? null
                        : InkWell(
                            onTap: () {
                              MediaPicker.pickImage(context).then((value) {
                                setState(() {
                                  _selectedBackImage = File(value);
                                });
                              });
                            },
                            child: const Icon(Icons.add_photo_alternate_rounded,
                                color: Colors.grey, size: 32.0))),
                maxLines: null,
              ),
              if (_selectedBackImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      Image.file(
                        File(_selectedBackImage!.path),
                        height: 300.0, // Altezza massima
                        width: 300.0, // Larghezza massima
                        fit: BoxFit
                            .contain, // Ridimensiona mantenendo le proporzioni
                        alignment: Alignment.center,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  _selectedBackImage = null;
                                });
                              },
                              icon: const Icon(
                                Icons.image_not_supported_rounded,
                                color: Colors.red,
                              )),
                          const SizedBox(width: 16.0),
                          IconButton(
                              onPressed: () {
                                MediaPicker.pickImage(context).then((value) {
                                  setState(() {
                                    _selectedBackImage = File(value);
                                  });
                                });
                              },
                              icon: Icon(
                                Icons.edit_square,
                                color: Theme.of(cx).colorScheme.primary,
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ))
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _modifyCard().then((id) {
            if (!cx.mounted) return;
            Navigator.pop(cx, true);
          });
        },
        child: const Icon(Icons.check),
      ),
    );
  }

  /// Modifies the card in the database
  Future<void> _modifyCard() {
    final StudyCard modifiedCard = StudyCard(
        id: widget.card.id,
        deckId: widget.card.deckId,
        front: _frontController.text,
        back: _backController.text,
        rating: _ratingController,
        lastReviewed: DateTime.now().toIso8601String(),
        frontMedia: _selectedFrontImage?.path ?? '',
        backMedia: _selectedBackImage?.path ?? '');

    return _dbHelper.updateCard(modifiedCard);
  }
}
