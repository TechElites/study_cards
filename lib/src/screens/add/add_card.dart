import 'dart:io';

import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/study_card.dart';
import 'package:flash_cards/src/data/model/rating.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

enum Type { front, back }

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
  File? _selectedFrontImage;
  File? _selectedBackImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Card'),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          //Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                  controller: _frontController,
                  decoration: InputDecoration(
                      labelText: 'Question',
                      suffixIcon: InkWell(
                          onTap: () => _pickImage(Type.front),
                          child: const Icon(Icons.image,
                              color: Colors.grey, size: 32.0)))),
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
                  decoration: InputDecoration(
                      labelText: 'Answer',
                      suffixIcon: InkWell(
                          onTap: () => _pickImage(Type.back),
                          child: const Icon(Icons.image,
                              color: Colors.grey, size: 32.0)))),
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
                onPressed: _addCard,
                child: const Text('Add Card'),
              ),
            ],
          ),
        ));
  }

  void _addCard() {
    final StudyCard newCard = StudyCard(
      deckId: widget.deckId,
      front: _frontController.text,
      back: _backController.text,
      rating: Rating.none,
      lastReviewed: 'Never',
      frontMedia: _selectedFrontImage?.path ?? '',
      backMedia: _selectedBackImage?.path ?? '',
    );

    _dbHelper.insertCard(newCard).then((id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Card added successfully'),
          duration: Duration(seconds: 1),
        ),
      );
      setState(() {
        _frontController.clear();
        _backController.clear();
        _selectedFrontImage = null;
        _selectedBackImage = null;
      });
    });
  }

  Future<void> _pickImage(Type type) async {
    final picker = ImagePicker();
    final XFile? pickedFile = await showDialog<XFile?>(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        title: const Text('Select source'),
        children: <Widget>[
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(
                  context, await picker.pickImage(source: ImageSource.camera));
            },
            child: const Text('Camera'),
          ),
          SimpleDialogOption(
            onPressed: () async {
              Navigator.pop(
                  context, await picker.pickImage(source: ImageSource.gallery));
            },
            child: const Text('Gallery'),
          ),
        ],
      ),
    );

    if (pickedFile != null) {
      if (type == Type.front) {
        setState(() {
          _selectedFrontImage = File(pickedFile.path);
        });
      } else if (type == Type.back)
        setState(() {
          _selectedBackImage = File(pickedFile.path);
        });
    }
  }
}
