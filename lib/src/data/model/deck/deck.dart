import 'package:hive/hive.dart';

part 'deck.g.dart';

@HiveType(typeId: 0)
class HiveDeck extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late int cards;

  @HiveField(2)
  late int reviewCards;

  @HiveField(3)
  late String creation;
}

class Deck {
  final int id;
  final String name;
  final int cards;
  final int reviewCards;
  final DateTime creation;

  Deck({
    this.id = -1,
    required this.name,
    required this.cards,
    this.reviewCards = 10,
    required this.creation,
  });

  HiveDeck toHiveDeck() {
    return HiveDeck()
      ..name = name
      ..cards = cards
      ..reviewCards = reviewCards
      ..creation = creation.toIso8601String();
  }

  static Deck fromHiveDeck(HiveDeck hiveDeck) {
    return Deck(
      id: hiveDeck.key,
      name: hiveDeck.name,
      cards: hiveDeck.cards,
      reviewCards: hiveDeck.reviewCards,
      creation: DateTime.parse(hiveDeck.creation),
    );
  }
}
