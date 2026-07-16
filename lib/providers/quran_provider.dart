import 'package:flutter/material.dart';
import '../models/surah.dart';
import '../models/ayah.dart';
import '../models/user_settings.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class QuranProvider extends ChangeNotifier {
  List<Surah> _surahs = [];
  bool _isLoadingSurahs = false;
  String? _surahsError;

  Map<int, List<Ayah>> _surahAyahsCache = {};
  Map<int, bool> _loadingAyahs = {};
  Map<int, String?> _ayahsErrors = {};

  // Juz -> set of surah numbers, built from cached ayahs
  Map<int, Set<int>> _juzSurahsCache = {};

  List<Bookmark> _quranBookmarks = [];

  // Getters
  List<Surah> get surahs => _surahs;
  bool get isLoadingSurahs => _isLoadingSurahs;
  String? get surahsError => _surahsError;
  List<Bookmark> get quranBookmarks => _quranBookmarks;

  // Load all surahs
  Future<void> loadSurahs({bool forceRefresh = false}) async {
    if (_surahs.isNotEmpty && !forceRefresh) return;

    _isLoadingSurahs = true;
    _surahsError = null;
    notifyListeners();

    try {
      // Try local first
      final localSurahs = StorageService.getSurahs();
      if (localSurahs.isNotEmpty && !forceRefresh) {
        _surahs = localSurahs;
      } else {
        // Fetch from API
        _surahs = await apiService.getAllSurahs();
        await StorageService.saveSurahs(_surahs);
      }
      _surahsError = null;
    } catch (e) {
      _surahsError = e.toString();
      // Fallback to local
      _surahs = StorageService.getSurahs();
    } finally {
      _isLoadingSurahs = false;
      notifyListeners();
    }
  }

  // Load ayahs for a surah
  Future<List<Ayah>> loadSurahAyahs(int surahNumber,
      {bool forceRefresh = false}) async {
    if (_surahAyahsCache.containsKey(surahNumber) && !forceRefresh) {
      return _surahAyahsCache[surahNumber]!;
    }

    _loadingAyahs[surahNumber] = true;
    _ayahsErrors[surahNumber] = null;
    notifyListeners();

    try {
      // Try local first
      final localAyahs = StorageService.getSurahAyahs(surahNumber);
      // Stale-cache guard: older builds cached ayahs without Arabic text.
      // If any cached ayah is missing its Arabic, treat the cache as stale.
      final cacheStale = localAyahs.any((a) => a.textArabic.trim().isEmpty);
      List<Ayah> ayahs;
      if (localAyahs.isNotEmpty && !forceRefresh && !cacheStale) {
        ayahs = localAyahs;
      } else {
        // Fetch from API
        ayahs = await apiService.getSurahAyahs(surahNumber);
        await StorageService.saveAyahs(ayahs);
      }

      _surahAyahsCache[surahNumber] = ayahs;
      _ayahsErrors[surahNumber] = null;
      _rebuildJuzCache();
      return ayahs;
    } catch (e) {
      _ayahsErrors[surahNumber] = e.toString();
      return _surahAyahsCache[surahNumber] ?? [];
    } finally {
      _loadingAyahs[surahNumber] = false;
      notifyListeners();
    }
  }

  bool isLoadingAyahs(int surahNumber) => _loadingAyahs[surahNumber] ?? false;
  String? getAyahsError(int surahNumber) => _ayahsErrors[surahNumber];

  // Search surahs
  List<Surah> searchSurahs(String query) {
    if (query.isEmpty) return _surahs;

    final lowerQuery = query.toLowerCase();
    return _surahs.where((surah) {
      return surah.name.toLowerCase().contains(lowerQuery) ||
          surah.englishName.toLowerCase().contains(lowerQuery) ||
          surah.englishNameTranslation.toLowerCase().contains(lowerQuery) ||
          surah.number.toString().contains(query);
    }).toList();
  }

  // Get juz surahs
  List<Surah> getSurahsByJuz(int juz) {
    if (juz < 1 || juz > 30) return [];
    final surahNumbers = _juzSurahsCache[juz] ?? {};
    return _surahs.where((s) => surahNumbers.contains(s.number)).toList();
  }

  // Rebuild the juz -> surah mapping from all cached ayahs
  void _rebuildJuzCache() {
    _juzSurahsCache.clear();
    for (final entry in _surahAyahsCache.entries) {
      final surahNumber = entry.key;
      for (final ayah in entry.value) {
        if (ayah.juz >= 1 && ayah.juz <= 30) {
          _juzSurahsCache.putIfAbsent(ayah.juz, () => <int>{}).add(surahNumber);
        }
      }
    }
  }

  // Bookmarks
  Future<void> loadQuranBookmarks() async {
    _quranBookmarks = StorageService.getBookmarksByType('quran');
    notifyListeners();
  }

  Future<void> addQuranBookmark({
    required int surahNumber,
    required int ayahNumber,
    String note = '',
  }) async {
    final bookmark = Bookmark(
      id: 'quran_${surahNumber}_$ayahNumber',
      type: 'quran',
      surahNumber: surahNumber,
      ayahNumber: ayahNumber,
      note: note,
      createdAt: DateTime.now(),
      metadata: {'surahName': _surahs.firstWhere((s) => s.number == surahNumber, orElse: () => Surah(number: 0, name: '', englishName: '', englishNameTranslation: '', numberOfAyahs: 0, revelationType: '')).name},
    );

    await StorageService.addBookmark(bookmark);
    _quranBookmarks.insert(0, bookmark);
    notifyListeners();
  }

  Future<void> removeQuranBookmark(int surahNumber, int ayahNumber) async {
    final id = 'quran_${surahNumber}_$ayahNumber';
    await StorageService.removeBookmark(id);
    _quranBookmarks.removeWhere((b) => b.id == id);
    notifyListeners();
  }

  bool isBookmarked(int surahNumber, int ayahNumber) {
    final id = 'quran_${surahNumber}_$ayahNumber';
    return _quranBookmarks.any((b) => b.id == id);
  }

  // Clear cache
  void clearAyahsCache() {
    _surahAyahsCache.clear();
    _juzSurahsCache.clear();
    notifyListeners();
  }

  void clearSurahsCache() {
    _surahs.clear();
    _surahAyahsCache.clear();
    _juzSurahsCache.clear();
    notifyListeners();
  }
}