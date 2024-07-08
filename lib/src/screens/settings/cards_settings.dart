import 'package:flash_cards/src/composables/ads/ads_fullscreen.dart';
import 'package:flash_cards/src/composables/ads/ads_scaffold.dart';
import 'package:flash_cards/src/data/database/db_helper.dart';
import 'package:flash_cards/src/data/model/deck/deck.dart';
import 'package:flash_cards/src/data/model/card/study_card.dart';
import 'package:flash_cards/src/logic/language/string_extension.dart';
import 'package:flash_cards/src/logic/xml_handler.dart';
import 'package:flutter/material.dart';

/// Creates a page to handle the settings of a deck
class CardsSettingsPage extends StatefulWidget {
  final int deckId;

  const CardsSettingsPage({super.key, required this.deckId});

  @override
  State<CardsSettingsPage> createState() => _CardsSettingsPageState();
}

class _CardsSettingsPageState extends State<CardsSettingsPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardsController = TextEditingController();
  final AdsFullscreen _adsFullScreen = AdsFullscreen();

  @override
  void initState() {
    super.initState();
    final revC = _dbHelper.getReviewCards(widget.deckId);
    final d = _dbHelper.getDeck(widget.deckId);
    setState(() {
      _nameController.text = d.name;
      _cardsController.text = revC.toString();
    });
  }

  @override
  Widget build(BuildContext cx) {
    _adsFullScreen.loadAd();

    return AdsScaffold(
      appBar: AppBar(
        title: Text('settings'.tr(cx)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          TextField(
              controller: _nameController,
              decoration: InputDecoration(
                  labelText: 'deck_name'.tr(cx),
                  suffixIcon: InkWell(
                      onTap: () {
                        _dbHelper
                            .updateDeckName(widget.deckId, _nameController.text)
                            .then((value) => ScaffoldMessenger.of(cx)
                                .showSnackBar(SnackBar(
                                    content: Text('deck_name_update'.tr(cx)))));
                      },
                      child: const Icon(Icons.check,
                          color: Colors.grey, size: 32.0)))),
          const SizedBox(height: 16.0),
          TextField(
              keyboardType: TextInputType.number,
              controller: _cardsController,
              decoration: InputDecoration(
                  labelText: 'cards_per_review'.tr(cx),
                  suffixIcon: InkWell(
                      onTap: () {
                        _updateReviewCards().then((value) =>
                            ScaffoldMessenger.of(cx).showSnackBar(SnackBar(
                                content: Text('review_cards_update'.tr(cx)))));
                      },
                      child: const Icon(Icons.check,
                          color: Colors.grey, size: 32.0)))),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _exportDeck().then((value) {
            _adsFullScreen.showAd().then((value) {
              if (!value) {
                ScaffoldMessenger.of(cx).showSnackBar(
                    SnackBar(content: Text('no_ads_left'.tr(cx))));
              }
            });
            ScaffoldMessenger.of(cx)
                .showSnackBar(SnackBar(content: Text('deck_download'.tr(cx))));
            setState(() {});
          });
        },
        child: const Icon(Icons.file_download),
      ),
    );
  }

  /// Exports the deck to an XML file
  Future<void> _exportDeck() async {
    final Deck deck = _dbHelper.getDeck(widget.deckId);
    final List<StudyCard> cards = _dbHelper.getCards(deck.id);
    final String deckXml = XmlHandler.createXml(cards, deck.name);
    final Map<String, String> mediaMap = {}; //path;name
    for (final card in cards) {
      if (card.frontMedia.isNotEmpty) {
        mediaMap[card.frontMedia] =
            '${card.id}_front.${card.frontMedia.split('.').last}';
      }
      if (card.backMedia.isNotEmpty) {
        mediaMap[card.backMedia] =
            '${card.id}_back.${card.backMedia.split('.').last}';
      }
    }
    await XmlHandler.saveXmlToFile(deckXml, '${deck.name}.xml', mediaMap);
  }

  Future<void> _updateReviewCards() async {
    final int reviewCards = int.parse(_cardsController.text);
    await _dbHelper.setReviewCards(widget.deckId, reviewCards);
  }
}
