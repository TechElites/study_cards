class StudyCard {
  final int id;
  final int deckId;
  final String front;
  final String back;
  final String rating;
  final String lastReviewed;
  final String frontMedia;
  final String backMedia;

  StudyCard({
    this.id = -1,
    this.deckId = -1,
    required this.front,
    required this.back,
    this.rating = '',
    this.lastReviewed = '',
    this.frontMedia = '',
    this.backMedia = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'deckId': deckId,
      'front': front,
      'back': back,
      'rating': rating,
      'lastReviewed': lastReviewed,
      'frontImage': frontMedia,
      'backImage': backMedia,
    };
  }

  factory StudyCard.fromMap(Map<String, dynamic> map) {
    return StudyCard(
      id: map['id'],
      deckId: map['deckId'],
      front: map['front'],
      back: map['back'],
      rating: map['rating'],
      lastReviewed: map['lastReviewed'],
      frontMedia: map['frontImage'],
      backMedia: map['backImage'],
    );
  }
}
