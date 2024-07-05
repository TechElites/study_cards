import 'package:hive/hive.dart';

part 'study_card.g.dart';

/// HiveStudyCard class is a Hive type adapter class that 
/// can be saved in the database.
@HiveType(typeId: 1)
class HiveStudyCard extends HiveObject {
  @HiveField(0)
  late int deckId;

  @HiveField(1)
  late String front;

  @HiveField(2)
  late String back;

  @HiveField(3)
  late String rating;

  @HiveField(4)
  late String lastReviewed;

  @HiveField(5)
  late String frontMedia;

  @HiveField(6)
  late String backMedia;
}

/// StudyCard class is a model class to rapresent a card.
class StudyCard {
  final int id;
  final int deckId;
  final String front;
  final String back;
  final String rating;
  final String lastReviewed;
  final String frontMedia;
  final String backMedia;

  /// Formats the last reviewed date to a more readable format.
  get lastReviewedFormatted => lastReviewed == 'never'
      ? lastReviewed
      : lastReviewed.replaceFirst('T', ' ').substring(0, 16);

  /// Returns the minutes since the card was last reviewed.
  get minutesSinceReviewed {
    if (lastReviewed == 'never') return 0;
    final now = DateTime.now();
    final last = DateTime.parse(lastReviewed);
    return now.difference(last).inMinutes;
  }

  StudyCard({
    this.id = -1,
    this.deckId = -1,
    required this.front,
    required this.back,
    this.rating = 'none',
    this.lastReviewed = 'never',
    this.frontMedia = '',
    this.backMedia = '',
  });

  /// Converts the StudyCard object to a HiveStudyCard object.
  HiveStudyCard toHiveStudyCard() {
    return HiveStudyCard()
      ..deckId = deckId
      ..front = front
      ..back = back
      ..rating = rating
      ..lastReviewed = lastReviewed
      ..frontMedia = frontMedia
      ..backMedia = backMedia;
  }

  /// Converts the HiveStudyCard object to a StudyCard object.
  factory StudyCard.fromHiveStudyCard(HiveStudyCard hiveCard) {
    return StudyCard(
      id: hiveCard.key,
      deckId: hiveCard.deckId,
      front: hiveCard.front,
      back: hiveCard.back,
      rating: hiveCard.rating,
      lastReviewed: hiveCard.lastReviewed,
      frontMedia: hiveCard.frontMedia,
      backMedia: hiveCard.backMedia,
    );
  }
}
