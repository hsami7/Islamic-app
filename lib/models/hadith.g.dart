// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hadith.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HadithCollectionAdapter extends TypeAdapter<HadithCollection> {
  @override
  final int typeId = 5;

  @override
  HadithCollection read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HadithCollection(
      id: fields[0] as String,
      name: fields[1] as String,
      nameArabic: fields[2] as String,
      author: fields[3] as String,
      authorArabic: fields[4] as String,
      totalHadiths: fields[5] as int,
      description: fields[6] as String,
      descriptionArabic: fields[7] as String,
      hadiths: (fields[8] as List).cast<Hadith>(),
    );
  }

  @override
  void write(BinaryWriter writer, HadithCollection obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.nameArabic)
      ..writeByte(3)
      ..write(obj.author)
      ..writeByte(4)
      ..write(obj.authorArabic)
      ..writeByte(5)
      ..write(obj.totalHadiths)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.descriptionArabic)
      ..writeByte(8)
      ..write(obj.hadiths);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HadithCollectionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class HadithAdapter extends TypeAdapter<Hadith> {
  @override
  final int typeId = 6;

  @override
  Hadith read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Hadith(
      id: fields[0] as String,
      collection: fields[1] as String,
      number: fields[2] as int,
      book: fields[3] as String,
      bookArabic: fields[4] as String,
      chapter: fields[5] as String,
      chapterArabic: fields[6] as String,
      text: fields[7] as String,
      textArabic: fields[8] as String,
      narrator: fields[9] as String,
      narratorArabic: fields[10] as String,
      grade: fields[11] as String,
      reference: fields[12] as String,
      referenceArabic: fields[13] as String,
      isBookmarked: fields[14] as bool,
      bookmarkedAt: fields[15] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Hadith obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.collection)
      ..writeByte(2)
      ..write(obj.number)
      ..writeByte(3)
      ..write(obj.book)
      ..writeByte(4)
      ..write(obj.bookArabic)
      ..writeByte(5)
      ..write(obj.chapter)
      ..writeByte(6)
      ..write(obj.chapterArabic)
      ..writeByte(7)
      ..write(obj.text)
      ..writeByte(8)
      ..write(obj.textArabic)
      ..writeByte(9)
      ..write(obj.narrator)
      ..writeByte(10)
      ..write(obj.narratorArabic)
      ..writeByte(11)
      ..write(obj.grade)
      ..writeByte(12)
      ..write(obj.reference)
      ..writeByte(13)
      ..write(obj.referenceArabic)
      ..writeByte(14)
      ..write(obj.isBookmarked)
      ..writeByte(15)
      ..write(obj.bookmarkedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HadithAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
