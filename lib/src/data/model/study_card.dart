class StudyCard {
  final int id;
  final int deckId;
  final String question;
  final String answer;
  final String rating;
  final String lastReviewed;

  StudyCard({
    this.id = -1,
    this.deckId = -1,
    required this.question,
    required this.answer,
    this.rating = '',
    this.lastReviewed = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'deckId': deckId,
      'question': question,
      'answer': answer,
      'rating': rating,
      'lastReviewed': lastReviewed,
    };
  }

  factory StudyCard.fromMap(Map<String, dynamic> map) {
    return StudyCard(
      id: map['id'],
      deckId: map['deckId'],
      question: map['question'],
      answer: map['answer'],
      rating: map['rating'],
      lastReviewed: map['lastReviewed'],
    );
  }
}
