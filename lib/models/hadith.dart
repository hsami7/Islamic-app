import 'package:hive/hive.dart';

part 'hadith.g.dart';

@HiveType(typeId: 5)
class HadithCollection extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String nameArabic;

  @HiveField(3)
  final String author;

  @HiveField(4)
  final String authorArabic;

  @HiveField(5)
  final int totalHadiths;

  @HiveField(6)
  final String description;

  @HiveField(7)
  final String descriptionArabic;

  @HiveField(8)
  final List<Hadith> hadiths;

  HadithCollection({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.author,
    required this.authorArabic,
    required this.totalHadiths,
    required this.description,
    required this.descriptionArabic,
    required this.hadiths,
  });

  factory HadithCollection.fromJson(Map<String, dynamic> json) {
    return HadithCollection(
      id: json['collection'] ?? '',
      name: json['collectionName'] ?? '',
      nameArabic: json['collectionNameAr'] ?? '',
      author: json['author'] ?? '',
      authorArabic: json['authorAr'] ?? '',
      totalHadiths: json['totalHadiths'] ?? 0,
      description: json['description'] ?? '',
      descriptionArabic: json['descriptionAr'] ?? '',
      hadiths: (json['hadiths'] as List?)
              ?.map((h) => Hadith.fromJson(h))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameArabic': nameArabic,
      'author': author,
      'authorArabic': authorArabic,
      'totalHadiths': totalHadiths,
      'description': description,
      'descriptionArabic': descriptionArabic,
      'hadiths': hadiths.map((h) => h.toJson()).toList(),
    };
  }
}

@HiveType(typeId: 6)
class Hadith extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String collection;

  @HiveField(2)
  final int number;

  @HiveField(3)
  final String book;

  @HiveField(4)
  final String bookArabic;

  @HiveField(5)
  final String chapter;

  @HiveField(6)
  final String chapterArabic;

  @HiveField(7)
  final String text;

  @HiveField(8)
  final String textArabic;

  @HiveField(9)
  final String narrator;

  @HiveField(10)
  final String narratorArabic;

  @HiveField(11)
  final String grade;

  @HiveField(12)
  final String reference;

  @HiveField(13)
  final String referenceArabic;

  @HiveField(14)
  final bool isBookmarked;

  @HiveField(15)
  final DateTime? bookmarkedAt;

  Hadith({
    required this.id,
    required this.collection,
    required this.number,
    required this.book,
    required this.bookArabic,
    required this.chapter,
    required this.chapterArabic,
    required this.text,
    required this.textArabic,
    required this.narrator,
    required this.narratorArabic,
    required this.grade,
    required this.reference,
    required this.referenceArabic,
    this.isBookmarked = false,
    this.bookmarkedAt,
  });

  factory Hadith.fromJson(Map<String, dynamic> json) {
    return Hadith(
      id: json['hadith_id'] ?? '${json['collection']}_${json['number']}',
      collection: json['collection'] ?? '',
      number: json['number'] ?? 0,
      book: json['book'] ?? '',
      bookArabic: json['bookAr'] ?? '',
      chapter: json['chapter'] ?? '',
      chapterArabic: json['chapterAr'] ?? '',
      text: json['text'] ?? '',
      textArabic: json['textAr'] ?? '',
      narrator: json['narrator'] ?? '',
      narratorArabic: json['narratorAr'] ?? '',
      grade: json['grade'] ?? '',
      reference: json['reference'] ?? '',
      referenceArabic: json['referenceAr'] ?? '',
      isBookmarked: json['isBookmarked'] ?? false,
      bookmarkedAt: json['bookmarkedAt'] != null ? DateTime.parse(json['bookmarkedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'collection': collection,
      'number': number,
      'book': book,
      'bookAr': bookArabic,
      'chapter': chapter,
      'chapterAr': chapterArabic,
      'text': text,
      'textAr': textArabic,
      'narrator': narrator,
      'narratorAr': narratorArabic,
      'grade': grade,
      'reference': reference,
      'referenceAr': referenceArabic,
      'isBookmarked': isBookmarked,
      'bookmarkedAt': bookmarkedAt?.toIso8601String(),
    };
  }

  Hadith copyWith({
    bool? isBookmarked,
    DateTime? bookmarkedAt,
  }) {
    return Hadith(
      id: id,
      collection: collection,
      number: number,
      book: book,
      bookArabic: bookArabic,
      chapter: chapter,
      chapterArabic: chapterArabic,
      text: text,
      textArabic: textArabic,
      narrator: narrator,
      narratorArabic: narratorArabic,
      grade: grade,
      reference: reference,
      referenceArabic: referenceArabic,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      bookmarkedAt: bookmarkedAt ?? this.bookmarkedAt,
    );
  }

  @override
  String toString() => 'Hadith(collection: $collection, number: $number)';
}