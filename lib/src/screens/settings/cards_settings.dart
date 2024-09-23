import 'package:flash_cards/src/composables/ads/ads_fullscreen.dart';
import 'package:flash_cards/src/composables/ads/ads_scaffold.dart';
import 'package:flash_cards/src/composables/floating_bar.dart';
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
  double cardsPerReview = 0;
  int maxCards = 10;
  final AdsFullscreen _adsFullScreen = AdsFullscreen();

  @override
  void initState() {
    super.initState();
    final revC = _dbHelper.getReviewCards(widget.deckId);
    final d = _dbHelper.getDeck(widget.deckId);
    _adsFullScreen.loadAd();
    setState(() {
      _nameController.text = d.name;
      maxCards = d.cards > 10 ? d.cards : 10;
      cardsPerReview = revC.toDouble();
    });
  }

  @override
  Widget build(BuildContext cx) {
    return AdsScaffold(
      appBar: AppBar(
        title: Text('settings'.tr(cx)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
              controller: _nameController,
              decoration: InputDecoration(
                  labelText: 'deck_name'.tr(cx),
                  suffixIcon: InkWell(
                      onTap: () {
                        _dbHelper
                            .updateDeckName(widget.deckId, _nameController.text)
                            .then((value) => FloatingBar.show(
                                'deck_name_update'.tr(cx), cx));
                      },
                      child: const Icon(Icons.check,
                          color: Colors.grey, size: 32.0)))),
          const SizedBox(height: 16.0),
          Text(
            'cards_per_review'.tr(cx),
            style: const TextStyle(fontSize: 13)),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: cardsPerReview,
                  min: 0,
                  max: maxCards.toDouble(),
                  divisions: maxCards - 1,
                  label: cardsPerReview.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      cardsPerReview = value;
                    });
                  },
                  onChangeEnd: (double value) {
                    _updateReviewCards(cardsPerReview.round()).then((_) =>
                        FloatingBar.show('review_cards_update'.tr(cx), cx));
                  },
                ),
              ),
              SizedBox(
                width: 50,
                child: Text(
                  cardsPerReview.round().toString(),
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _exportDeck().then((value) {
            _adsFullScreen.showAndReloadAd(() {
              FloatingBar.show('deck_download'.tr(cx), cx);
              setState(() {});
            });
          });
        },
        child: const Icon(Icons.file_download),
      ),
    );
  }

  /// Exports the deck to an XML file
  Future<bool> _exportDeck() async {
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
    return await XmlHandler.saveXmlToFile(
        deckXml, '${deck.name}.xml', mediaMap);
  }

  Future<void> _updateReviewCards(int cards) async {
    final int reviewCards = cards;
    await _dbHelper.setReviewCards(widget.deckId, reviewCards);
  }
}
