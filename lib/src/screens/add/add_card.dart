import 'dart:io';
import 'package:flash_cards/src/logic/language/string_extension.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
    return Scaffold(
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
                              onTap: () => _pickImage(cx, ImageSide.front),
                              child: const Icon(
                                  Icons.add_photo_alternate_rounded,
                                  color: Colors.grey,
                                  size: 32.0)))),
              if (_selectedFrontImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Image.file(
                    _selectedFrontImage!,
                    height: 200.0,
                    width: 200.0,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              const SizedBox(height: 16.0),
              TextField(
                  controller: _backController,
                  maxLines: null,
                  decoration: InputDecoration(
                      labelText: 'answer'.tr(cx),
                      suffixIcon: kIsWeb
                          ? null
                          : InkWell(
                              onTap: () => _pickImage(cx, ImageSide.back),
                              child: const Icon(
                                  Icons.add_photo_alternate_rounded,
                                  color: Colors.grey,
                                  size: 32.0)))),
              if (_selectedBackImage != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Image.file(
                    _selectedBackImage!,
                    height: 200.0,
                    width: 200.0,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _addCard().then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('card_add_success'.tr(cx)),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                    setState(() {
                      _frontController.clear();
                      _backController.clear();
                      _selectedFrontImage = null;
                      _selectedBackImage = null;
                      focus.requestFocus();
                    });
                  });
                },
                child: Text('add_card'.tr(cx)),
              ),
            ],
          ),
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

  /// Opens a dialog to select an image from the gallery or camera
  Future<void> _pickImage(BuildContext cx, ImageSide type) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        title: Text('select_source'.tr(cx)),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () {
              picker
                  .pickImage(source: ImageSource.camera)
                  .then((value) => Navigator.pop(context, value));
            },
            child: Text('camera'.tr(cx)),
          ),
          SimpleDialogOption(
            onPressed: () {
              picker
                  .pickImage(source: ImageSource.gallery)
                  .then((value) => Navigator.pop(context, value));
            },
            child: Text('gallery'.tr(cx)),
          ),
        ],
      ),
    );

    if (pickedFile != null) {
      setState(() {
        if (type == ImageSide.front) {
          _selectedFrontImage = File(pickedFile.path);
        } else if (type == ImageSide.back) {
          _selectedBackImage = File(pickedFile.path);
        }
      });
    }
  }
}
