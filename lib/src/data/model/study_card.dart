class StudyCard {
  final int id;
  final int deckId;
  final String front;
  final String back;
  final String rating;
  final String lastReviewed;

  get lastReviewedFormatted => lastReviewed.length < 6
      ? lastReviewed
      : lastReviewed.replaceFirst('T', ' ').substring(0, 16);

  StudyCard({
    this.id = -1,
    this.deckId = -1,
    required this.front,
    required this.back,
    this.rating = '',
    this.lastReviewed = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'deckId': deckId,
      'front': front,
      'back': back,
      'rating': rating,
      'lastReviewed': lastReviewed,
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
    );
  }
}
