class Deck {
  final int id;
  final String name;
  final int cards;
  final DateTime creation;

  Deck({
    this.id = -1,
    required this.name,
    required this.cards,
    required this.creation,
  });

  factory Deck.fromMap(Map<String, dynamic> map) {
    return Deck(
      id: map['id'] as int,
      name: map['name'] as String,
      cards: map['cards'] as int,
      creation: DateTime.parse(map['creation'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'cards': cards,
      'creation': creation.toIso8601String(),
    };
  }
}
