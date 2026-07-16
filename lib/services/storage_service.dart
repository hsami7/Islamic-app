import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/surah.dart';
import '../models/ayah.dart';
import '../models/prayer_times.dart';
import '../models/azkar.dart';
import '../models/qibla.dart';
import '../models/user_settings.dart';
import '../models/index.dart';

class StorageService {
  static const String _surahsBox = 'surahs';
  static const String _ayahsBox = 'ayahs';
  static const String _prayerTimesBox = 'prayer_times';
  static const String _azkarBox = 'azkar';
  static const String _qiblaBox = 'qibla';
  static const String _settingsBox = 'settings';
  static const String _bookmarksBox = 'bookmarks';
  static const String _progressBox = 'quran_progress';
  static const String _weatherBox = 'weather';
  static const String _metaBox = 'app_meta'; // plain string flags (e.g. reciter id)

  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(SurahAdapter());
    Hive.registerAdapter(AyahAdapter());
    Hive.registerAdapter(PrayerTimesAdapter());
    Hive.registerAdapter(AzkarCategoryAdapter());
    Hive.registerAdapter(AzkarAdapter());
    Hive.registerAdapter(QiblaDirectionAdapter());
    Hive.registerAdapter(UserSettingsAdapter());
    Hive.registerAdapter(BookmarkAdapter());

    // Open boxes
    await Hive.openBox<Surah>(_surahsBox);
    await Hive.openBox<Ayah>(_ayahsBox);
    await Hive.openBox<PrayerTimes>(_prayerTimesBox);
    await Hive.openBox<Azkar>(_azkarBox);
    await Hive.openBox<QiblaDirection>(_qiblaBox);
    await Hive.openBox<UserSettings>(_settingsBox);
    await Hive.openBox<Bookmark>(_bookmarksBox);
    await Hive.openBox(_progressBox); // plain map: surahNumber -> lastAyah
    await Hive.openBox(_weatherBox); // plain map: date -> weather json
    await Hive.openBox(_metaBox); // plain string flags

    _initialized = true;
  }

  // Settings
  static Box<UserSettings> get _settingsBoxInstance =>
      Hive.box<UserSettings>(_settingsBox);

  static UserSettings getSettings() {
    if (!_initialized) return UserSettings();
    return _settingsBoxInstance.get('user_settings') ??
        UserSettings();
  }

  static Future<void> saveSettings(UserSettings settings) async {
    await _settingsBoxInstance.put('user_settings', settings);
  }

  // Surahs
  static Box<Surah> get _surahsBoxInstance {
    if (!_initialized) throw StateError('StorageService not initialized. Call StorageService.initialize() first.');
    return Hive.box<Surah>(_surahsBox);
  }

  static Future<void> saveSurahs(List<Surah> surahs) async {
    await _surahsBoxInstance.clear();
    for (final surah in surahs) {
      await _surahsBoxInstance.put(surah.number, surah);
    }
  }

  static List<Surah> getSurahs() {
    if (!_initialized) return [];
    return _surahsBoxInstance.values.toList()..sort((a, b) => a.number.compareTo(b.number));
  }

  static Surah? getSurah(int number) {
    if (!_initialized) return null;
    return _surahsBoxInstance.get(number);
  }

  // Ayahs
  static Box<Ayah> get _ayahsBoxInstance {
    if (!_initialized) throw StateError('StorageService not initialized. Call StorageService.initialize() first.');
    return Hive.box<Ayah>(_ayahsBox);
  }

  static Future<void> saveAyahs(List<Ayah> ayahs) async {
    await _ayahsBoxInstance.clear();
    for (final ayah in ayahs) {
      await _ayahsBoxInstance.put(ayah.number, ayah);
    }
  }

  static List<Ayah> getSurahAyahs(int surahNumber) {
    if (!_initialized) return [];
    return _ayahsBoxInstance.values
        .where((a) => a.surahNumber == surahNumber)
        .toList()
      ..sort((a, b) => a.numberInSurah.compareTo(b.numberInSurah));
  }

  static Ayah? getAyah(int number) {
    if (!_initialized) return null;
    return _ayahsBoxInstance.get(number);
  }

  // Prayer Times
  static Box<PrayerTimes> get _prayerTimesBoxInstance {
    if (!_initialized) throw StateError('StorageService not initialized. Call StorageService.initialize() first.');
    return Hive.box<PrayerTimes>(_prayerTimesBox);
  }

  static Future<void> savePrayerTimes(PrayerTimes prayerTimes) async {
    final key = '${prayerTimes.date.year}-${prayerTimes.date.month.toString().padLeft(2, '0')}-${prayerTimes.date.day.toString().padLeft(2, '0')}';
    await _prayerTimesBoxInstance.put(key, prayerTimes);
  }

  static PrayerTimes? getPrayerTimes(DateTime date) {
    if (!_initialized) return null;
    final key = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    return _prayerTimesBoxInstance.get(key);
  }

  static List<PrayerTimes> getPrayerTimesRange(DateTime start, DateTime end) {
    return _prayerTimesBoxInstance.values
        .where((p) => p.date.isAfter(start) && p.date.isBefore(end))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Azkar
  static Box<Azkar> get _azkarBoxInstance => Hive.box<Azkar>(_azkarBox);

  static Future<void> saveAzkar(List<Azkar> azkar) async {
    await _azkarBoxInstance.clear();
    for (final azkarItem in azkar) {
      await _azkarBoxInstance.put(azkarItem.id, azkarItem);
    }
  }

  static List<Azkar> getAzkarByCategory(String categoryId) {
    return _azkarBoxInstance.values
        .where((a) => a.categoryId == categoryId)
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
  }

  static Azkar? getAzkar(String id) {
    return _azkarBoxInstance.get(id);
  }

  static Future<void> toggleAzkarFavorite(String id) async {
    final azkar = _azkarBoxInstance.get(id);
    if (azkar != null) {
      await _azkarBoxInstance.put(
        id,
        azkar.copyWith(isFavorite: !azkar.isFavorite),
      );
    }
  }

  static Future<void> incrementAzkarCompletion(String id) async {
    final azkar = _azkarBoxInstance.get(id);
    if (azkar != null) {
      final newCompletions = Map<String, int>.from(azkar.completions);
      final today = DateTime.now();
      final key = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
      newCompletions[key] = (newCompletions[key] ?? 0) + 1;

      await _azkarBoxInstance.put(
        id,
        azkar.copyWith(completions: newCompletions),
      );
    }
  }

  static List<Azkar> getFavoriteAzkar() {
    return _azkarBoxInstance.values.where((a) => a.isFavorite).toList();
  }

  // Qibla
  static Box<QiblaDirection> get _qiblaBoxInstance =>
      Hive.box<QiblaDirection>(_qiblaBox);

  static Future<void> saveQiblaDirection(QiblaDirection direction) async {
    final key = '${direction.latitude},${direction.longitude}';
    await _qiblaBoxInstance.put(key, direction);
  }

  static QiblaDirection? getQiblaDirection(double lat, double lng) {
    final key = '$lat,$lng';
    return _qiblaBoxInstance.get(key);
  }

  // Bookmarks
  static Box<Bookmark> get _bookmarksBoxInstance =>
      Hive.box<Bookmark>(_bookmarksBox);

  static Future<void> addBookmark(Bookmark bookmark) async {
    await _bookmarksBoxInstance.put(bookmark.id, bookmark);
  }

  static Future<void> removeBookmark(String id) async {
    await _bookmarksBoxInstance.delete(id);
  }

  static List<Bookmark> getBookmarks() {
    return _bookmarksBoxInstance.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  static List<Bookmark> getBookmarksByType(String type) {
    return _bookmarksBoxInstance.values
        .where((b) => b.type == type)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // Reading progress (plain Hive box — no codegen needed)
  static Box get _progressBoxInstance => Hive.box(_progressBox);
  static Box get _weatherBoxInstance => Hive.box(_weatherBox);

  /// Record the last ayah the user read in [surahNumber].
  /// Only moves forward (never regresses) so "continue" always resumes
  /// at the furthest point reached.
  static Future<void> saveReadingProgress(int surahNumber, int ayahNumber) async {
    final current = _progressBoxInstance.get(surahNumber, defaultValue: 0) as int? ?? 0;
    if (ayahNumber > current) {
      await _progressBoxInstance.put(surahNumber, ayahNumber);
    }
  }

  static int getReadingProgress(int surahNumber) {
    if (!_initialized) return 0;
    return _progressBoxInstance.get(surahNumber, defaultValue: 0) as int? ?? 0;
  }

  /// The furthest surah the user has reached (largest key with progress).
  static int getLastReadSurah() {
    if (!_initialized) return 0;
    final keys = _progressBoxInstance.keys.whereType<int>();
    if (keys.isEmpty) return 0;
    return keys.reduce((a, b) => a > b ? a : b);
  }

  // Weather (plain Hive box — no codegen needed)
  static Future<void> saveWeather(Map<String, dynamic> weather) async {
    final key = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
    await _weatherBoxInstance.put(key, weather);
  }

  static Map<String, dynamic>? getWeather() {
    if (!_initialized) return null;
    final key = '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
    final data = _weatherBoxInstance.get(key);
    return data is Map ? Map<String, dynamic>.from(data) : null;
  }

  // Selected Quran reciter id (plain string in app_meta box)
  static const String _reciterKey = 'selected_reciter_id';

  static String getSelectedReciterId() {
    if (!_initialized) return 'yasser_al_dosari';
    final box = Hive.box(_metaBox);
    return box.get(_reciterKey, defaultValue: 'yasser_al_dosari') as String;
  }

  static Future<void> saveSelectedReciterId(String id) async {
    if (!_initialized) return;
    final box = Hive.box(_metaBox);
    await box.put(_reciterKey, id);
  }

  // Clear all data
  static Future<void> clearAll() async {
    await _surahsBoxInstance.clear();
    await _ayahsBoxInstance.clear();
    await _prayerTimesBoxInstance.clear();
    await _azkarBoxInstance.clear();
    await _qiblaBoxInstance.clear();
    await _bookmarksBoxInstance.clear();
    await _progressBoxInstance.clear();
    await _weatherBoxInstance.clear();
  }

  static Future<void> close() async {
    await Hive.close();
  }
}