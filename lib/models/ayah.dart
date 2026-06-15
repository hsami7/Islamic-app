import 'package:hive/hive.dart';

part 'ayah.g.dart';

@HiveType(typeId: 1)
class Ayah extends HiveObject {
  @HiveField(0)
  final int number;

  @HiveField(1)
  final int surahNumber;

  @HiveField(2)
  final int numberInSurah;

  @HiveField(3)
  final int juz;

  @HiveField(4)
  final int manzil;

  @HiveField(5)
  final int page;

  @HiveField(6)
  final int ruku;

  @HiveField(7)
  final int hizbQuarter;

  @HiveField(8)
  final String text;

  @HiveField(9)
  final String textArabic;

  @HiveField(10)
  final String translation;

  @HiveField(11)
  final String audioUrl;

  Ayah({
    required this.number,
    required this.surahNumber,
    required this.numberInSurah,
    required this.juz,
    required this.manzil,
    required this.page,
    required this.ruku,
    required this.hizbQuarter,
    required this.text,
    required this.textArabic,
    required this.translation,
    required this.audioUrl,
  });

  factory Ayah.fromJson(Map<String, dynamic> json) {
    return Ayah(
      number: json['number'] ?? 0,
      surahNumber: json['surah']?['number'] ?? 0,
      numberInSurah: json['numberInSurah'] ?? 0,
      juz: json['juz'] ?? 0,
      manzil: json['manzil'] ?? 0,
      page: json['page'] ?? 0,
      ruku: json['ruku'] ?? 0,
      hizbQuarter: json['hizbQuarter'] ?? 0,
      text: json['text'] ?? '',
      textArabic: json['textArabic'] ?? '',
      translation: json['translation'] ?? '',
      audioUrl: json['audio'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'number': number,
      'surahNumber': surahNumber,
      'numberInSurah': numberInSurah,
      'juz': juz,
      'manzil': manzil,
      'page': page,
      'ruku': ruku,
      'hizbQuarter': hizbQuarter,
      'text': text,
      'textArabic': textArabic,
      'translation': translation,
      'audioUrl': audioUrl,
    };
  }

  @override
  String toString() =>
      'Ayah(surah: $surahNumber, ayah: $numberInSurah, juz: $juz)';
}