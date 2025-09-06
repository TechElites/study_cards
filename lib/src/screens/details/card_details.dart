import 'dart:convert';
import 'dart:io';

import 'package:flash_cards/src/composables/ads/ads_scaffold.dart';
import 'package:flash_cards/src/composables/media_picker.dart';
import 'package:flash_cards/src/composables/rating_buttons.dart';
import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'package:flash_cards/src/logic/language/string_extension.dart';
import 'package:flash_cards/src/logic/media/image_converter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';

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
  bool _hasExistingFrontImage = false;
  bool _hasExistingBackImage = false;

  @override
  void initState() {
    super.initState();
    _frontController.text = widget.card.front;
    _backController.text = widget.card.back;
    _ratingController = widget.card.rating;
    _hasExistingFrontImage = widget.card.frontMedia.isNotEmpty;
    _hasExistingBackImage = widget.card.backMedia.isNotEmpty;
    
    // Add listeners to update UI when text changes
    _frontController.addListener(() => setState(() {}));
    _backController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
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
              if (_selectedFrontImage != null || _hasExistingFrontImage)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      _selectedFrontImage != null 
                        ? Image.file(
                            _selectedFrontImage!,
                            height: 300.0, // Altezza massima
                            width: 300.0, // Larghezza massima
                            fit: BoxFit
                                .contain, // Ridimensiona mantenendo le proporzioni
                            alignment: Alignment.center,
                          )
                        : Image.memory(
                            base64Decode(widget.card.frontMedia),
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
                                  _hasExistingFrontImage = false;
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
              Theme(
                data: Theme.of(cx).copyWith(
                  textTheme: Theme.of(cx).textTheme.copyWith(
                    bodyLarge: TextStyle(
                      fontSize: 18, 
                      color: Theme.of(cx).colorScheme.onSurface
                    ),
                    bodyMedium: TextStyle(
                      fontSize: 16, 
                      color: Theme.of(cx).colorScheme.onSurface
                    ),
                    bodySmall: TextStyle(
                      fontSize: 14, 
                      color: Theme.of(cx).colorScheme.onSurface
                    ),
                  ),
                ),
                child: MarkdownAutoPreview(
                  controller: _backController,
                  maxLines: null,
                  hintText: 'answer'.tr(cx),
                  toolbarBackground: Theme.of(cx).colorScheme.surface,
                  expandableBackground: Theme.of(cx).colorScheme.secondary,
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
                ),
              ),
              if (_selectedBackImage != null || _hasExistingBackImage)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Column(
                    children: [
                      _selectedBackImage != null 
                        ? Image.file(
                            _selectedBackImage!,
                            height: 300.0, // Altezza massima
                            width: 300.0, // Larghezza massima
                            fit: BoxFit
                                .contain, // Ridimensiona mantenendo le proporzioni
                            alignment: Alignment.center,
                          )
                        : Image.memory(
                            base64Decode(widget.card.backMedia),
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
                                  _hasExistingBackImage = false;
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
        onPressed: _isCardEmpty() ? null : () {
          _modifyCard().then((id) {
            if (!cx.mounted) return;
            Navigator.pop(cx, true);
          });
        },
        backgroundColor: _isCardEmpty() ? Colors.grey : null,
        child: const Icon(Icons.check),
      ),
    );
  }

  /// Checks if the card is completely empty (no text and no images)
  bool _isCardEmpty() {
    final frontText = _frontController.text.trim();
    final backText = _backController.text.trim();
    
    return frontText.isEmpty && 
           backText.isEmpty && 
           _selectedFrontImage == null && 
           _selectedBackImage == null &&
           !_hasExistingFrontImage &&
           !_hasExistingBackImage;
  }

  /// Modifies the card in the database
  Future<void> _modifyCard() async {
    String frontMedia = '';
    String backMedia = '';
    
    // Convert front image to Base64 if new image is selected
    if (_selectedFrontImage != null) {
      try {
        frontMedia = await ImageConverter.fileToBase64(_selectedFrontImage!);
      } catch (e) {
        throw Exception('Error converting front image to Base64: $e');
      }
    } else if (_hasExistingFrontImage) {
      // Keep existing Base64 if no new image is selected
      frontMedia = widget.card.frontMedia;
    }
    
    // Convert back image to Base64 if new image is selected
    if (_selectedBackImage != null) {
      try {
        backMedia = await ImageConverter.fileToBase64(_selectedBackImage!);
      } catch (e) {
        throw Exception('Error converting back image to Base64: $e');
      }
    } else if (_hasExistingBackImage) {
      // Keep existing Base64 if no new image is selected
      backMedia = widget.card.backMedia;
    }

    final StudyCard modifiedCard = StudyCard(
        id: widget.card.id,
        deckId: widget.card.deckId,
        front: _frontController.text,
        back: _backController.text,
        rating: _ratingController,
        lastReviewed: DateTime.now().toIso8601String(),
        frontMedia: frontMedia,
        backMedia: backMedia);

    return _dbHelper.updateCard(modifiedCard);
  }
}
