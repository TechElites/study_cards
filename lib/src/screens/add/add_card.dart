import 'dart:io';
import 'package:flash_cards/src/composables/ads/ads_scaffold.dart';
import 'package:flash_cards/src/composables/floating_bar.dart';
import 'package:flash_cards/src/logic/language/string_extension.dart';
import 'package:flash_cards/src/composables/media_picker.dart';
import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'package:flash_cards/src/logic/platform_helper.dart';
import 'package:flutter/material.dart';
import 'package:markdown_editor_plus/widgets/markdown_auto_preview.dart';

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
                  style: TextStyle(fontSize: 18.0),
                  decoration: InputDecoration(
                      labelText: 'question'.tr(cx),
                      suffixIcon: PlatformHelper.isWeb
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
              Opacity(
                  opacity: 0.5,
                  child: Text('tap_below_edit'.tr(cx),
                      style: TextStyle(
                        fontSize: 10.0,
                      ))),
              MarkdownAutoPreview(
                  controller: _backController,
                  hintText: 'answer'.tr(cx),
                  maxLines: null,
                  style: TextStyle(fontSize: 18.0),
                  toolbarBackground: Theme.of(cx).colorScheme.surface,
                  expandableBackground: Theme.of(cx).colorScheme.secondary,
                  decoration: InputDecoration(
                      labelText: 'answer'.tr(cx),
                      suffixIcon: PlatformHelper.isWeb
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
                                  size: 32.0)))),
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
          onPressed: () {
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
          child: const Icon(Icons.add),
        ));
  }

  /// Adds a new card to the database
  Future<void> _addCard() {
    final StudyCard newCard = StudyCard(
      deckId: widget.deckId,
      front: _frontController.text,
      back: _backController.text,
      frontMedia: _selectedFrontImage?.path ?? '',
      backMedia: _selectedBackImage?.path ?? '',
    );

    return _dbHelper.insertCard(newCard);
  }
}
