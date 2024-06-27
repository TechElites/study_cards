import 'dart:io';

import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/rating.dart';
import 'package:flash_cards/src/data/model/study_card.dart';
import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _frontController.text = widget.card.front;
    _backController.text = widget.card.back;
    _ratingController = widget.card.rating;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modify Card'), centerTitle: true),
      body: Column(children: [
        Column(children: [
          const SizedBox(height: 16.0),
          ButtonBar(
            alignment: MainAxisAlignment.center,
            children: _createRatingButtons(),
          ),
          Text('Last reviewed: ${widget.card.lastReviewedFormatted}'),
        ]),
        Expanded(
            child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _frontController,
                decoration: const InputDecoration(
                  labelText: 'Front',
                ),
                maxLines: null,
              ),
              if(widget.card.frontMedia != '')
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Image.file(
                    File(widget.card.frontMedia),
                    height: 200.0,
                    width: 200.0,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
              const SizedBox(height: 16.0),
              TextField(
                controller: _backController,
                decoration: const InputDecoration(
                  labelText: 'Back',
                ),
                maxLines: null,
              ),
              if(widget.card.backMedia != '')
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Image.file(
                    File(widget.card.backMedia),
                    height: 200.0,
                    width: 200.0,
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
            ],
          ),
        ))
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: _modifyCard,
        child: const Icon(Icons.check),
      ),
    );
  }

  void _modifyCard() {
    final StudyCard modifiedCard = StudyCard(
        id: widget.card.id,
        deckId: widget.card.deckId,
        front: _frontController.text,
        back: _backController.text,
        rating: _ratingController,
        lastReviewed: DateTime.now().toIso8601String());
    _dbHelper.updateCard(modifiedCard).then((id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Card modified successfully'),
          duration: Duration(seconds: 1),
        ),
      );
      Navigator.pop(context);
    });
  }

  List<Widget> _createRatingButtons() {
    return [
      for (var rating
          in Rating.colors.entries.where((e) => e.key != Rating.none))
        ElevatedButton(
          onPressed: () {
            setState(() {
              _ratingController = rating.key;
            });
          },
          style: ButtonStyle(
            foregroundColor: rating.key == _ratingController
                ? WidgetStateProperty.all(Colors.white)
                : WidgetStateProperty.all(Colors.black),
            backgroundColor: WidgetStateProperty.all(rating.value),
            elevation: rating.key == _ratingController
                ? WidgetStateProperty.all(5)
                : WidgetStateProperty.all(0),
          ),
          child: Text(rating.key),
        )
    ];
  }
}
