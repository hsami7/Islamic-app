import 'package:flutter/material.dart';
import '../models/hadith.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class HadithProvider extends ChangeNotifier {
  List<HadithCollection> _collections = [];
  Map<String, List<Hadith>> _collectionHadiths = {};
  Map<String, bool> _loadingCollections = {};
  Map<String, bool> _loadingHadiths = {};
  String? _error;
  String _selectedCollection = 'bukhari';

  // Getters
  List<HadithCollection> get collections => _collections;
  String get selectedCollection => _selectedCollection;
  List<Hadith> get currentHadiths => _collectionHadiths[_selectedCollection] ?? [];
  bool get isLoadingCollections => _loadingCollections['all'] ?? false;
  bool isLoadingHadiths(String collection) => _loadingHadiths[collection] ?? false;
  String? get error => _error;
  List<Hadith> get bookmarkedHadiths => StorageService.getBookmarkedHadiths();

  // Load all collections
  Future<void> loadCollections({bool forceRefresh = false}) async {
    if (_collections.isNotEmpty && !forceRefresh) return;

    _loadingCollections['all'] = true;
    _error = null;
    notifyListeners();

    try {
      _collections = await apiService.getHadithCollections();
      _loadingCollections['all'] = false;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _loadingCollections['all'] = false;
    }
    notifyListeners();
  }

  // Load hadiths for a collection
  Future<void> loadHadiths(String collectionId,
      {int page = 1, int limit = 50, bool forceRefresh = false}) async {
    final cacheKey = '${collectionId}_$page';

    if (_collectionHadiths.containsKey(cacheKey) && !forceRefresh) {
      _selectedCollection = collectionId;
      notifyListeners();
      return;
    }

    _loadingHadiths[cacheKey] = true;
    _error = null;
    notifyListeners();

    try {
      final collection = await apiService.getHadithCollection(
        collectionId,
        page: page,
        limit: limit,
      );

      _collectionHadiths[cacheKey] = collection.hadiths;
      _selectedCollection = collectionId;

      // Cache individual hadiths
      for (final hadith in collection.hadiths) {
        await StorageService.saveHadith(hadith);
      }

      _error = null;
    } catch (e) {
      _error = e.toString();
      // Try local storage
      final localHadiths = StorageService.getHadithsByCollection(collectionId);
      if (localHadiths.isNotEmpty) {
        _collectionHadiths[cacheKey] = localHadiths;
      }
    } finally {
      _loadingHadiths[cacheKey] = false;
      notifyListeners();
    }
  }

  // Load more hadiths (pagination)
  Future<void> loadMoreHadiths(String collectionId, int page) async {
    await loadHadiths(collectionId, page: page);
  }

  // Search hadiths
  Future<List<Hadith>> searchHadiths(String query,
      {String? collectionId, int page = 1, int limit = 20}) async {
    _error = null;
    notifyListeners();

    try {
      final results = await apiService.searchHadith(
        query: query,
        collectionId: collectionId,
        page: page,
        limit: limit,
      );
      _error = null;
      return results;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  // Toggle bookmark
  Future<void> toggleBookmark(String hadithId) async {
    await StorageService.toggleHadithBookmark(hadithId);

    // Update in memory cache
    for (final entry in _collectionHadiths.entries) {
      final hadiths = entry.value;
      final index = hadiths.indexWhere((h) => h.id == hadithId);
      if (index != -1) {
        final hadith = hadiths[index];
        hadiths[index] = hadith.copyWith(
          isBookmarked: !hadith.isBookmarked,
          bookmarkedAt: !hadith.isBookmarked ? DateTime.now() : null,
        );
      }
    }

    notifyListeners();
  }

  // Get hadith by ID
  Hadith? getHadith(String id) {
    for (final hadiths in _collectionHadiths.values) {
      final hadith = hadiths.firstWhere(
        (h) => h.id == id,
        orElse: () => Hadith(
          id: '',
          collection: '',
          number: 0,
          book: '',
          bookArabic: '',
          chapter: '',
          chapterArabic: '',
          text: '',
          textArabic: '',
          narrator: '',
          narratorArabic: '',
          grade: '',
          reference: '',
          referenceArabic: '',
        ),
      );
      if (hadith.id.isNotEmpty) return hadith;
    }
    return StorageService.getHadith(id);
  }

  // Select collection
  void selectCollection(String collectionId) {
    if (_selectedCollection != collectionId) {
      _selectedCollection = collectionId;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearCache() {
    _collections.clear();
    _collectionHadiths.clear();
    notifyListeners();
  }
}