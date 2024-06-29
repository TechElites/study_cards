// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'study_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveStudyCardAdapter extends TypeAdapter<HiveStudyCard> {
  @override
  final int typeId = 1;

  @override
  HiveStudyCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveStudyCard()
      ..deckId = fields[0] as int
      ..front = fields[1] as String
      ..back = fields[2] as String
      ..rating = fields[3] as String
      ..lastReviewed = fields[4] as String
      ..frontMedia = fields[5] as String
      ..backMedia = fields[6] as String;
  }

  @override
  void write(BinaryWriter writer, HiveStudyCard obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.deckId)
      ..writeByte(1)
      ..write(obj.front)
      ..writeByte(2)
      ..write(obj.back)
      ..writeByte(3)
      ..write(obj.rating)
      ..writeByte(4)
      ..write(obj.lastReviewed)
      ..writeByte(5)
      ..write(obj.frontMedia)
      ..writeByte(6)
      ..write(obj.backMedia);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveStudyCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
