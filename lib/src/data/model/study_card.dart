class StudyCard {
  final int id;
  final int deckId;
  final String front;
  final String back;
  final String rating;
  final String lastReviewed;
  final String frontMedia;
  final String backMedia;

  get lastReviewedFormatted => lastReviewed == 'Never'
      ? lastReviewed
      : lastReviewed.replaceFirst('T', ' ').substring(0, 16);

  get minutesSinceReviewed {
    if (lastReviewed == 'Never') return 0;
    final now = DateTime.now();
    final last = DateTime.parse(lastReviewed);
    return now.difference(last).inMinutes;
  }

  StudyCard({
    this.id = -1,
    this.deckId = -1,
    required this.front,
    required this.back,
    this.rating = 'None',
    this.lastReviewed = 'Never',
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
      'frontMedia': frontMedia,
      'backMedia': backMedia,
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
      frontMedia: map['frontMedia'],
      backMedia: map['backMedia'],
    );
  }
}
