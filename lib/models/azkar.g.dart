// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'azkar.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AzkarCategoryAdapter extends TypeAdapter<AzkarCategory> {
  @override
  final int typeId = 7;

  @override
  AzkarCategory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AzkarCategory(
      id: fields[0] as String,
      name: fields[1] as String,
      nameArabic: fields[2] as String,
      description: fields[3] as String,
      descriptionArabic: fields[4] as String,
      icon: fields[5] as String,
      order: fields[6] as int,
      azkar: (fields[7] as List).cast<Azkar>(),
    );
  }

  @override
  void write(BinaryWriter writer, AzkarCategory obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.nameArabic)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.descriptionArabic)
      ..writeByte(5)
      ..write(obj.icon)
      ..writeByte(6)
      ..write(obj.order)
      ..writeByte(7)
      ..write(obj.azkar);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AzkarCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AzkarAdapter extends TypeAdapter<Azkar> {
  @override
  final int typeId = 8;

  @override
  Azkar read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Azkar(
      id: fields[0] as String,
      categoryId: fields[1] as String,
      text: fields[2] as String,
      textArabic: fields[3] as String,
      translation: fields[4] as String,
      count: fields[5] as int,
      reference: fields[6] as String,
      referenceArabic: fields[7] as String,
      audioUrl: fields[8] as String,
      order: fields[9] as int,
      isFavorite: fields[10] as bool,
      completions: (fields[11] as Map?)?.cast<String, int>(),
    );
  }

  @override
  void write(BinaryWriter writer, Azkar obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.categoryId)
      ..writeByte(2)
      ..write(obj.text)
      ..writeByte(3)
      ..write(obj.textArabic)
      ..writeByte(4)
      ..write(obj.translation)
      ..writeByte(5)
      ..write(obj.count)
      ..writeByte(6)
      ..write(obj.reference)
      ..writeByte(7)
      ..write(obj.referenceArabic)
      ..writeByte(8)
      ..write(obj.audioUrl)
      ..writeByte(9)
      ..write(obj.order)
      ..writeByte(10)
      ..write(obj.isFavorite)
      ..writeByte(11)
      ..write(obj.completions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AzkarAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
