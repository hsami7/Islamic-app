import 'package:hive/hive.dart';

part 'azkar.g.dart';

@HiveType(typeId: 7)
class AzkarCategory extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String nameArabic;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String descriptionArabic;

  @HiveField(5)
  final String icon;

  @HiveField(6)
  final int order;

  @HiveField(7)
  final List<Azkar> azkar;

  AzkarCategory({
    required this.id,
    required this.name,
    required this.nameArabic,
    required this.description,
    required this.descriptionArabic,
    required this.icon,
    required this.order,
    required this.azkar,
  });

  factory AzkarCategory.fromJson(Map<String, dynamic> json) {
    return AzkarCategory(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameArabic: json['nameAr'] ?? '',
      description: json['description'] ?? '',
      descriptionArabic: json['descriptionAr'] ?? '',
      icon: json['icon'] ?? '',
      order: json['order'] ?? 0,
      azkar: (json['azkar'] as List?)
              ?.map((a) => Azkar.fromJson(a))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameAr': nameArabic,
      'description': description,
      'descriptionAr': descriptionArabic,
      'icon': icon,
      'order': order,
      'azkar': azkar.map((a) => a.toJson()).toList(),
    };
  }
}

@HiveType(typeId: 8)
class Azkar extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String categoryId;

  @HiveField(2)
  final String text;

  @HiveField(3)
  final String textArabic;

  @HiveField(4)
  final String translation;

  @HiveField(5)
  final int count;

  @HiveField(6)
  final String reference;

  @HiveField(7)
  final String referenceArabic;

  @HiveField(8)
  final String audioUrl;

  @HiveField(9)
  final int order;

  @HiveField(10)
  final bool isFavorite;

  @HiveField(11)
  final Map<String, int> completions; // date -> count

  Azkar({
    required this.id,
    required this.categoryId,
    required this.text,
    required this.textArabic,
    required this.translation,
    required this.count,
    required this.reference,
    required this.referenceArabic,
    required this.audioUrl,
    required this.order,
    this.isFavorite = false,
    Map<String, int>? completions,
  }) : completions = completions ?? {};

  factory Azkar.fromJson(Map<String, dynamic> json) {
    return Azkar(
      id: json['id'] ?? '',
      categoryId: json['categoryId'] ?? '',
      text: json['text'] ?? '',
      textArabic: json['textAr'] ?? '',
      translation: json['translation'] ?? '',
      count: json['count'] ?? 0,
      reference: json['reference'] ?? '',
      referenceArabic: json['referenceAr'] ?? '',
      audioUrl: json['audioUrl'] ?? '',
      order: json['order'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
      completions: Map<String, int>.from(json['completions'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'text': text,
      'textAr': textArabic,
      'translation': translation,
      'count': count,
      'reference': reference,
      'referenceAr': referenceArabic,
      'audioUrl': audioUrl,
      'order': order,
      'isFavorite': isFavorite,
      'completions': completions,
    };
  }

  Azkar copyWith({
    bool? isFavorite,
    Map<String, int>? completions,
  }) {
    return Azkar(
      id: id,
      categoryId: categoryId,
      text: text,
      textArabic: textArabic,
      translation: translation,
      count: count,
      reference: reference,
      referenceArabic: referenceArabic,
      audioUrl: audioUrl,
      order: order,
      isFavorite: isFavorite ?? this.isFavorite,
      completions: completions ?? this.completions,
    );
  }

  int get todayCount {
    final today = DateTime.now();
    final key = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    return completions[key] ?? 0;
  }

  void incrementToday() {
    final today = DateTime.now();
    final key = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
    completions[key] = (completions[key] ?? 0) + 1;
  }

  bool get isCompletedToday => todayCount >= count;

  double get progress => count > 0 ? todayCount / count : 0.0;

  @override
  String toString() => 'Azkar(id: $id, count: $count, completed: $todayCount)';
}