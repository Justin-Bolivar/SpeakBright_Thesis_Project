// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_transition.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CardTransitionAdapter extends TypeAdapter<CardTransition> {
  @override
  final int typeId = 1;

  @override
  CardTransition read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CardTransition(
      fromCard: fields[0] as String,
      toCard: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CardTransition obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.fromCard)
      ..writeByte(1)
      ..write(obj.toCard);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardTransitionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
