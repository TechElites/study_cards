import 'dart:io';
import 'package:flash_cards/src/composables/ads/ads_scaffold.dart';
import 'package:flash_cards/src/composables/floating_bar.dart';
import 'package:flash_cards/src/logic/language/string_extension.dart';
import 'package:flash_cards/src/composables/media_picker.dart';
import 'package:flash_cards/src/logic/media/image_converter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'package:flutter/material.dart';
import 'package:markdown_editor_plus/markdown_editor_plus.dart';

/// Which side of the card the image is on
enum ImageSide { front, back }

/// Creates a page to handle the creation of new cards
class AddCard extends StatefulWidget {
  final int deckId;

  const AddCard({super.key, required this.deckId});

  @override
  State<AddCard> createState() => _AddCardState();
}

class _AddCardState extends State<AddCard> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();
  FocusNode focus = FocusNode();
  File? _selectedFrontImage;
  File? _selectedBackImage;

  @override
  void initState() {
    super.initState();
    // Add listeners to update UI when text changes
    _frontController.addListener(() => setState(() {}));
    _backController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext cx) {
    return AdsScaffold(
        appBar: AppBar(
          title: Text('add_card'.tr(cx)),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          //Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                  controller: _frontController,
                  focusNode: focus,
                  maxLines: null,
                  decoration: InputDecoration(
                      labelText: 'question'.tr(cx),
                      suffixIcon: kIsWeb
                          ? null
                          : InkWell(
                              onTap: () {
                                MediaPicker.pickImage(context).then((value) {
                                  setState(() {
                                    _selectedFrontImage = File(value);
                                  });
                                });
                              },
                              child: const Icon(
                                  Icons.add_photo_alternate_rounded,
                                  color: Colors.grey,
                                  size: 32.0)))),
              if (_selectedFrontImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Image.file(
                    _selectedFrontImage!,
                    height: 300.0,
                    width: 300.0,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
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
                  style: TextStyle(
                    fontSize: 18,
                    color: Theme.of(cx).colorScheme.onSurface,
                  ),
                  toolbarBackground: Theme.of(cx).colorScheme.surface,
                  expandableBackground: Theme.of(cx).colorScheme.secondary,
                  decoration: InputDecoration(
                    labelText: 'answer'.tr(cx),
                    suffixIcon: kIsWeb
                        ? null
                        : InkWell(
                            onTap: () {
                              MediaPicker.pickImage(context).then((value) {
                                setState(() {
                                  _selectedBackImage = File(value);
                                });
                              });
                            },
                            child: const Icon(
                                Icons.add_photo_alternate_rounded,
                                color: Colors.grey,
                                size: 32.0))
                  ),
                ),
              ),
              if (_selectedBackImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Image.file(
                    _selectedBackImage!,
                    height: 300.0,
                    width: 300.0,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _isCardEmpty() ? null : () {
            _addCard().then((_) {
              setState(() {
                _frontController.clear();
                _backController.clear();
                _selectedFrontImage = null;
                _selectedBackImage = null;
                focus.requestFocus();
              });
              if (!cx.mounted) return;
              FloatingBar.show('card_add_success'.tr(cx), cx);
            });
          },
          backgroundColor: _isCardEmpty() ? Colors.grey : null,
          child: const Icon(Icons.add),
        ));
  }

  /// Checks if the card is completely empty (no text and no images)
  bool _isCardEmpty() {
    final frontText = _frontController.text.trim();
    final backText = _backController.text.trim();
    
    return frontText.isEmpty && 
           backText.isEmpty && 
           _selectedFrontImage == null && 
           _selectedBackImage == null;
  }

  /// Adds a new card to the database
  Future<void> _addCard() async {
    String frontMedia = '';
    String backMedia = '';
    
    // Convert front image to Base64 if exists
    if (_selectedFrontImage != null) {
      try {
        frontMedia = await ImageConverter.fileToBase64(_selectedFrontImage!);
      } catch (e) {
        throw Exception('Error converting front image to Base64: $e');
      }
    }
    
    // Convert back image to Base64 if exists
    if (_selectedBackImage != null) {
      try {
        backMedia = await ImageConverter.fileToBase64(_selectedBackImage!);
      } catch (e) {
        throw Exception('Error converting back image to Base64: $e');
      }
    }

    final StudyCard newCard = StudyCard(
      deckId: widget.deckId,
      front: _frontController.text,
      back: _backController.text,
      frontMedia: frontMedia,
      backMedia: backMedia,
    );

    return _dbHelper.insertCard(newCard);
  }
}
