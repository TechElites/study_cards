// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveDeckAdapter extends TypeAdapter<HiveDeck> {
  @override
  final int typeId = 0;

  @override
  HiveDeck read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveDeck()
      ..name = fields[0] as String
      ..cards = fields[1] as int
      ..reviewCards = fields[2] as int
      ..creation = fields[3] as String
      ..shared = fields[4] as String;
  }

  @override
  void write(BinaryWriter writer, HiveDeck obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.cards)
      ..writeByte(2)
      ..write(obj.reviewCards)
      ..writeByte(3)
      ..write(obj.creation)
      ..writeByte(4)
      ..write(obj.shared);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveDeckAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
