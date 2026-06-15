import 'package:hive/hive.dart';

part 'user_settings.g.dart';

@HiveType(typeId: 10)
class UserSettings extends HiveObject {
  @HiveField(0)
  final String language; // 'ar', 'en'

  @HiveField(1)
  final bool isDarkMode;

  @HiveField(2)
  final int calculationMethod; // Muslim World League, etc.

  @HiveField(3)
  final int madhab; // Shafi, Hanafi

  @HiveField(4)
  final bool notificationsEnabled;

  @HiveField(5)
  final bool fajrNotification;

  @HiveField(6)
  final bool dhuhrNotification;

  @HiveField(7)
  final bool asrNotification;

  @HiveField(8)
  final bool maghribNotification;

  @HiveField(9)
  final bool ishaNotification;

  @HiveField(10)
  final int notificationAdvanceMinutes; // minutes before prayer

  @HiveField(11)
  final bool quranAudioAutoPlay;

  @HiveField(12)
  final String quranReciter; // reciter ID

  @HiveField(13)
  final double quranFontSize;

  @HiveField(14)
  final bool showTranslation;

  @HiveField(15)
  final String translationLanguage; // 'en', 'ar', etc.

  @HiveField(16)
  final bool showTafsir;

  @HiveField(17)
  final String tafsirSource;

  @HiveField(18)
  final bool useSystemLocale;

  @HiveField(19)
  final int themeMode; // 0: system, 1: light, 2: dark

  @HiveField(20)
  final bool hapticFeedback;

  @HiveField(21)
  final bool reduceMotion;

  @HiveField(22)
  final String lastLocationLat;

  @HiveField(23)
  final String lastLocationLng;

  @HiveField(24)
  final String lastLocationCity;

  @HiveField(25)
  final bool locationPermissionGranted;

  @HiveField(26)
  final bool compassCalibrated;

  @HiveField(27)
  final DateTime? lastCompassCalibration;

  UserSettings({
    this.language = 'en',
    this.isDarkMode = false,
    this.calculationMethod = 3, // Muslim World League
    this.madhab = 0, // Shafi
    this.notificationsEnabled = true,
    this.fajrNotification = true,
    this.dhuhrNotification = true,
    this.asrNotification = true,
    this.maghribNotification = true,
    this.ishaNotification = true,
    this.notificationAdvanceMinutes = 5,
    this.quranAudioAutoPlay = false,
    this.quranReciter = 'ar.alafasy',
    this.quranFontSize = 26.0,
    this.showTranslation = true,
    this.translationLanguage = 'en',
    this.showTafsir = false,
    this.tafsirSource = 'ibn-kathir',
    this.useSystemLocale = true,
    this.themeMode = 0,
    this.hapticFeedback = true,
    this.reduceMotion = false,
    this.lastLocationLat = '',
    this.lastLocationLng = '',
    this.lastLocationCity = '',
    this.locationPermissionGranted = false,
    this.compassCalibrated = false,
    this.lastCompassCalibration,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      language: json['language'] ?? 'en',
      isDarkMode: json['isDarkMode'] ?? false,
      calculationMethod: json['calculationMethod'] ?? 3,
      madhab: json['madhab'] ?? 0,
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      fajrNotification: json['fajrNotification'] ?? true,
      dhuhrNotification: json['dhuhrNotification'] ?? true,
      asrNotification: json['asrNotification'] ?? true,
      maghribNotification: json['maghribNotification'] ?? true,
      ishaNotification: json['ishaNotification'] ?? true,
      notificationAdvanceMinutes: json['notificationAdvanceMinutes'] ?? 5,
      quranAudioAutoPlay: json['quranAudioAutoPlay'] ?? false,
      quranReciter: json['quranReciter'] ?? 'ar.alafasy',
      quranFontSize: (json['quranFontSize'] ?? 26.0).toDouble(),
      showTranslation: json['showTranslation'] ?? true,
      translationLanguage: json['translationLanguage'] ?? 'en',
      showTafsir: json['showTafsir'] ?? false,
      tafsirSource: json['tafsirSource'] ?? 'ibn-kathir',
      useSystemLocale: json['useSystemLocale'] ?? true,
      themeMode: json['themeMode'] ?? 0,
      hapticFeedback: json['hapticFeedback'] ?? true,
      reduceMotion: json['reduceMotion'] ?? false,
      lastLocationLat: json['lastLocationLat'] ?? '',
      lastLocationLng: json['lastLocationLng'] ?? '',
      lastLocationCity: json['lastLocationCity'] ?? '',
      locationPermissionGranted: json['locationPermissionGranted'] ?? false,
      compassCalibrated: json['compassCalibrated'] ?? false,
      lastCompassCalibration: json['lastCompassCalibration'] != null
          ? DateTime.parse(json['lastCompassCalibration'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'isDarkMode': isDarkMode,
      'calculationMethod': calculationMethod,
      'madhab': madhab,
      'notificationsEnabled': notificationsEnabled,
      'fajrNotification': fajrNotification,
      'dhuhrNotification': dhuhrNotification,
      'asrNotification': asrNotification,
      'maghribNotification': maghribNotification,
      'ishaNotification': ishaNotification,
      'notificationAdvanceMinutes': notificationAdvanceMinutes,
      'quranAudioAutoPlay': quranAudioAutoPlay,
      'quranReciter': quranReciter,
      'quranFontSize': quranFontSize,
      'showTranslation': showTranslation,
      'translationLanguage': translationLanguage,
      'showTafsir': showTafsir,
      'tafsirSource': tafsirSource,
      'useSystemLocale': useSystemLocale,
      'themeMode': themeMode,
      'hapticFeedback': hapticFeedback,
      'reduceMotion': reduceMotion,
      'lastLocationLat': lastLocationLat,
      'lastLocationLng': lastLocationLng,
      'lastLocationCity': lastLocationCity,
      'locationPermissionGranted': locationPermissionGranted,
      'compassCalibrated': compassCalibrated,
      'lastCompassCalibration': lastCompassCalibration?.toIso8601String(),
    };
  }

  UserSettings copyWith({
    String? language,
    bool? isDarkMode,
    int? calculationMethod,
    int? madhab,
    bool? notificationsEnabled,
    bool? fajrNotification,
    bool? dhuhrNotification,
    bool? asrNotification,
    bool? maghribNotification,
    bool? ishaNotification,
    int? notificationAdvanceMinutes,
    bool? quranAudioAutoPlay,
    String? quranReciter,
    double? quranFontSize,
    bool? showTranslation,
    String? translationLanguage,
    bool? showTafsir,
    String? tafsirSource,
    bool? useSystemLocale,
    int? themeMode,
    bool? hapticFeedback,
    bool? reduceMotion,
    String? lastLocationLat,
    String? lastLocationLng,
    String? lastLocationCity,
    bool? locationPermissionGranted,
    bool? compassCalibrated,
    DateTime? lastCompassCalibration,
  }) {
    return UserSettings(
      language: language ?? this.language,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      madhab: madhab ?? this.madhab,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      fajrNotification: fajrNotification ?? this.fajrNotification,
      dhuhrNotification: dhuhrNotification ?? this.dhuhrNotification,
      asrNotification: asrNotification ?? this.asrNotification,
      maghribNotification: maghribNotification ?? this.maghribNotification,
      ishaNotification: ishaNotification ?? this.ishaNotification,
      notificationAdvanceMinutes: notificationAdvanceMinutes ?? this.notificationAdvanceMinutes,
      quranAudioAutoPlay: quranAudioAutoPlay ?? this.quranAudioAutoPlay,
      quranReciter: quranReciter ?? this.quranReciter,
      quranFontSize: quranFontSize ?? this.quranFontSize,
      showTranslation: showTranslation ?? this.showTranslation,
      translationLanguage: translationLanguage ?? this.translationLanguage,
      showTafsir: showTafsir ?? this.showTafsir,
      tafsirSource: tafsirSource ?? this.tafsirSource,
      useSystemLocale: useSystemLocale ?? this.useSystemLocale,
      themeMode: themeMode ?? this.themeMode,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      reduceMotion: reduceMotion ?? this.reduceMotion,
      lastLocationLat: lastLocationLat ?? this.lastLocationLat,
      lastLocationLng: lastLocationLng ?? this.lastLocationLng,
      lastLocationCity: lastLocationCity ?? this.lastLocationCity,
      locationPermissionGranted: locationPermissionGranted ?? this.locationPermissionGranted,
      compassCalibrated: compassCalibrated ?? this.compassCalibrated,
      lastCompassCalibration: lastCompassCalibration ?? this.lastCompassCalibration,
    );
  }
}

@HiveType(typeId: 11)
class Bookmark extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String type; // 'quran', 'hadith', 'azkar'

  @HiveField(2)
  final int surahNumber;

  @HiveField(3)
  final int ayahNumber;

  @HiveField(4)
  final String hadithId;

  @HiveField(5)
  final String azkarId;

  @HiveField(6)
  final String note;

  @HiveField(7)
  final DateTime createdAt;

  @HiveField(8)
  final Map<String, dynamic> metadata;

  Bookmark({
    required this.id,
    required this.type,
    this.surahNumber = 0,
    this.ayahNumber = 0,
    this.hadithId = '',
    this.azkarId = '',
    this.note = '',
    required this.createdAt,
    this.metadata = const {},
  });

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      surahNumber: json['surahNumber'] ?? 0,
      ayahNumber: json['ayahNumber'] ?? 0,
      hadithId: json['hadithId'] ?? '',
      azkarId: json['azkarId'] ?? '',
      note: json['note'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      metadata: Map<String, dynamic>.from(json['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'surahNumber': surahNumber,
      'ayahNumber': ayahNumber,
      'hadithId': hadithId,
      'azkarId': azkarId,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'metadata': metadata,
    };
  }
}