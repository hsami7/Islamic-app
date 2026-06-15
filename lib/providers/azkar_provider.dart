import 'package:flutter/material.dart';
import '../models/azkar.dart';
import '../services/storage_service.dart';

class AzkarProvider extends ChangeNotifier {
  List<AzkarCategory> _categories = [];
  Map<String, List<Azkar>> _categoryAzkar = {};
  bool _isLoading = false;
  String? _error;

  // Getters
  List<AzkarCategory> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Azkar> get favoriteAzkar => StorageService.getFavoriteAzkar();

  // Initialize with default azkar data
  Future<void> initialize() async {
    if (_categories.isNotEmpty) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try to load from storage first
      await _loadFromStorage();

      // If empty, load defaults
      if (_categories.isEmpty) {
        await _loadDefaultAzkar();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadFromStorage() async {
    // This would load from Hive if we had stored them
    // For now, we'll use defaults
  }

  Future<void> _loadDefaultAzkar() async {
    _categories = _getDefaultCategories();
    await StorageService.saveAzkar(_categories.expand((c) => c.azkar).toList());
  }

  List<AzkarCategory> _getDefaultCategories() {
    return [
      AzkarCategory(
        id: 'morning',
        name: 'Morning Azkar',
        nameArabic: 'أذكار الصباح',
        description: 'Remembrances to recite after Fajr until sunrise',
        descriptionArabic: 'أذكار تُقرأ بعد الفجر حتى طلوع الشمس',
        icon: 'assets/icons/morning.svg',
        order: 0,
        azkar: _getMorningAzkar(),
      ),
      AzkarCategory(
        id: 'evening',
        name: 'Evening Azkar',
        nameArabic: 'أذكار المساء',
        description: 'Remembrances to recite after Asr until Maghrib',
        descriptionArabic: 'أذكار تُقرأ بعد العصر حتى غروب الشمس',
        icon: 'assets/icons/evening.svg',
        order: 1,
        azkar: _getEveningAzkar(),
      ),
      AzkarCategory(
        id: 'after_prayer',
        name: 'After Prayer',
        nameArabic: 'أذكار بعد الصلاة',
        description: 'Remembrances to recite after each obligatory prayer',
        descriptionArabic: 'أذكار تُقرأ بعد كل صلاة فريضة',
        icon: 'assets/icons/prayer.svg',
        order: 2,
        azkar: _getAfterPrayerAzkar(),
      ),
      AzkarCategory(
        id: 'sleep',
        name: 'Before Sleep',
        nameArabic: 'أذكار النوم',
        description: 'Remembrances to recite before going to sleep',
        descriptionArabic: 'أذكار تُقرأ قبل النوم',
        icon: 'assets/icons/sleep.svg',
        order: 3,
        azkar: _getSleepAzkar(),
      ),
      AzkarCategory(
        id: 'daily',
        name: 'Daily Azkar',
        nameArabic: 'أذكار يومية',
        description: 'General remembrances for throughout the day',
        descriptionArabic: 'أذكار عامة طوال اليوم',
        icon: 'assets/icons/daily.svg',
        order: 4,
        azkar: _getDailyAzkar(),
      ),
      AzkarCategory(
        id: 'protection',
        name: 'Protection',
        nameArabic: 'أذكار الحماية',
        description: 'Remembrances for protection and seeking refuge',
        descriptionArabic: 'أذكار للحماية والاستعاذة',
        icon: 'assets/icons/protection.svg',
        order: 5,
        azkar: _getProtectionAzkar(),
      ),
    ];
  }

  List<Azkar> _getMorningAzkar() {
    return [
      Azkar(
        id: 'morning_1',
        categoryId: 'morning',
        text: 'O Allah, by You we enter the morning...',
        textArabic: 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ...',
        translation: 'We have entered the morning and the whole kingdom belongs to Allah...',
        count: 1,
        reference: 'Sahih Muslim 2723',
        referenceArabic: 'صحيح مسلم 2723',
        audioUrl: '',
        order: 0,
      ),
      Azkar(
        id: 'morning_2',
        categoryId: 'morning',
        text: 'O Allah, I ask You for knowledge that is beneficial...',
        textArabic: 'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا...',
        translation: 'O Allah, I ask You for beneficial knowledge...',
        count: 1,
        reference: 'Sunan Ibn Majah 3843',
        referenceArabic: 'سنن ابن ماجه 3843',
        audioUrl: '',
        order: 1,
      ),
      Azkar(
        id: 'morning_3',
        categoryId: 'morning',
        text: 'There is no deity but Allah alone...',
        textArabic: 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ...',
        translation: 'There is no deity but Allah alone, He has no partner...',
        count: 10,
        reference: 'Sahih al-Bukhari 6306',
        referenceArabic: 'صحيح البخاري 6306',
        audioUrl: '',
        order: 2,
      ),
      Azkar(
        id: 'morning_4',
        categoryId: 'morning',
        text: 'Glory be to Allah and praise be to Him...',
        textArabic: 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ...',
        translation: 'Glory be to Allah and praise be to Him...',
        count: 100,
        reference: 'Sahih Muslim 2691',
        referenceArabic: 'صحيح مسلم 2691',
        audioUrl: '',
        order: 3,
      ),
    ];
  }

  List<Azkar> _getEveningAzkar() {
    return [
      Azkar(
        id: 'evening_1',
        categoryId: 'evening',
        text: 'O Allah, by You we enter the evening...',
        textArabic: 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ...',
        translation: 'We have entered the evening and the whole kingdom belongs to Allah...',
        count: 1,
        reference: 'Sahih Muslim 2723',
        referenceArabic: 'صحيح مسلم 2723',
        audioUrl: '',
        order: 0,
      ),
      Azkar(
        id: 'evening_2',
        categoryId: 'evening',
        text: 'I seek refuge in Allah\'s perfect words...',
        textArabic: 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ...',
        translation: 'I seek refuge in Allah\'s perfect words from the evil of what He has created...',
        count: 3,
        reference: 'Sahih Muslim 2708',
        referenceArabic: 'صحيح مسلم 2708',
        audioUrl: '',
        order: 1,
      ),
      Azkar(
        id: 'evening_3',
        categoryId: 'evening',
        text: 'There is no deity but Allah alone...',
        textArabic: 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ...',
        translation: 'There is no deity but Allah alone, He has no partner...',
        count: 10,
        reference: 'Sahih al-Bukhari 6306',
        referenceArabic: 'صحيح البخاري 6306',
        audioUrl: '',
        order: 2,
      ),
    ];
  }

  List<Azkar> _getAfterPrayerAzkar() {
    return [
      Azkar(
        id: 'after_prayer_1',
        categoryId: 'after_prayer',
        text: 'I seek forgiveness from Allah (3 times)...',
        textArabic: 'أَسْتَغْفِرُ اللَّهَ (3 مرات)...',
        translation: 'I seek forgiveness from Allah (3 times)...',
        count: 3,
        reference: 'Sahih Muslim 591',
        referenceArabic: 'صحيح مسلم 591',
        audioUrl: '',
        order: 0,
      ),
      Azkar(
        id: 'after_prayer_2',
        categoryId: 'after_prayer',
        text: 'O Allah, You are Peace...',
        textArabic: 'اللَّهُمَّ أَنتَ السَّلَامُ وَمِنكَ السَّلَامُ...',
        translation: 'O Allah, You are Peace and from You comes peace...',
        count: 1,
        reference: 'Sahih Muslim 591',
        referenceArabic: 'صحيح مسلم 591',
        audioUrl: '',
        order: 1,
      ),
      Azkar(
        id: 'after_prayer_3',
        categoryId: 'after_prayer',
        text: 'There is no deity but Allah alone... (33 times SubhanAllah, 33 times Alhamdulillah, 34 times Allahu Akbar)',
        textArabic: 'سُبْحَانَ اللَّهِ (33) الْحَمْدُ لِلَّهِ (33) اللَّهُ أَكْبَرُ (34)...',
        translation: 'SubhanAllah (33 times), Alhamdulillah (33 times), Allahu Akbar (34 times)...',
        count: 100,
        reference: 'Sahih Muslim 596',
        referenceArabic: 'صحيح مسلم 596',
        audioUrl: '',
        order: 2,
      ),
      Azkar(
        id: 'after_prayer_4',
        categoryId: 'after_prayer',
        text: 'Ayat al-Kursi',
        textArabic: 'آيَةُ الْكُرْسِيِّ...',
        translation: 'Allah - there is no deity except Him, the Ever-Living, the Sustainer...',
        count: 1,
        reference: 'Quran 2:255',
        referenceArabic: 'القرآن 2:255',
        audioUrl: '',
        order: 3,
      ),
    ];
  }

  List<Azkar> _getSleepAzkar() {
    return [
      Azkar(
        id: 'sleep_1',
        categoryId: 'sleep',
        text: 'In Your name, O Allah, I die and I live...',
        textArabic: 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا...',
        translation: 'In Your name, O Allah, I die and I live...',
        count: 1,
        reference: 'Sahih al-Bukhari 6324',
        referenceArabic: 'صحيح البخاري 6324',
        audioUrl: '',
        order: 0,
      ),
      Azkar(
        id: 'sleep_2',
        categoryId: 'sleep',
        text: 'Recite Surah Al-Ikhlas, Al-Falaq, An-Nas (3 times each) and blow over hands...',
        textArabic: 'قُلْ هُوَ اللَّهُ أَحَدٌ، قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ، قُلْ أَعُوذُ بِرَبِّ النَّاسِ (3 مرات)...',
        translation: 'Recite Qul Huwa Allahu Ahad, Qul A\'udhu bi Rabbil-Falaq, Qul A\'udhu bi Rabbil-Nas (3 times each)...',
        count: 3,
        reference: 'Sahih al-Bukhari 5017',
        referenceArabic: 'صحيح البخاري 5017',
        audioUrl: '',
        order: 1,
      ),
      Azkar(
        id: 'sleep_3',
        categoryId: 'sleep',
        text: 'Ayat al-Kursi',
        textArabic: 'آيَةُ الْكُرْسِيِّ...',
        translation: 'Allah - there is no deity except Him, the Ever-Living, the Sustainer...',
        count: 1,
        reference: 'Quran 2:255',
        referenceArabic: 'القرآن 2:255',
        audioUrl: '',
        order: 2,
      ),
    ];
  }

  List<Azkar> _getDailyAzkar() {
    return [
      Azkar(
        id: 'daily_1',
        categoryId: 'daily',
        text: 'Glory be to Allah (33), Praise be to Allah (33), Allah is Greatest (34)',
        textArabic: 'سُبْحَانَ اللَّهِ (33) الْحَمْدُ لِلَّهِ (33) اللَّهُ أَكْبَرُ (34)',
        translation: 'SubhanAllah (33 times), Alhamdulillah (33 times), Allahu Akbar (34 times)',
        count: 100,
        reference: 'Sahih Muslim 2726',
        referenceArabic: 'صحيح مسلم 2726',
        audioUrl: '',
        order: 0,
      ),
      Azkar(
        id: 'daily_2',
        categoryId: 'daily',
        text: 'There is no deity but Allah alone...',
        textArabic: 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ...',
        translation: 'There is no deity but Allah alone, He has no partner...',
        count: 100,
        reference: 'Sahih al-Bukhari 6403',
        referenceArabic: 'صحيح البخاري 6403',
        audioUrl: '',
        order: 1,
      ),
      Azkar(
        id: 'daily_3',
        categoryId: 'daily',
        text: 'O Allah, send prayers upon Muhammad...',
        textArabic: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ...',
        translation: 'O Allah, send prayers upon Muhammad and upon the family of Muhammad...',
        count: 10,
        reference: 'Sahih Muslim 408',
        referenceArabic: 'صحيح مسلم 408',
        audioUrl: '',
        order: 2,
      ),
    ];
  }

  List<Azkar> _getProtectionAzkar() {
    return [
      Azkar(
        id: 'protection_1',
        categoryId: 'protection',
        text: 'I seek refuge in Allah from Satan the accursed...',
        textArabic: 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ...',
        translation: 'I seek refuge in Allah from Satan the accursed...',
        count: 1,
        reference: 'Quran 16:98',
        referenceArabic: 'القرآن 16:98',
        audioUrl: '',
        order: 0,
      ),
      Azkar(
        id: 'protection_2',
        categoryId: 'protection',
        text: 'In the name of Allah, with whose name nothing can harm...',
        textArabic: 'بِسْمِ اللَّهِ الَّذِي لَا يَضُرُّ مَعَ اسْمِهِ شَيْءٌ فِي الْأَرْضِ وَلَا فِي السَّمَاءِ وَهُوَ السَّمِيعُ الْعَلِيمُ...',
        translation: 'In the name of Allah, with whose name nothing in the earth or heaven can cause harm...',
        count: 3,
        reference: 'Sunan al-Tirmidhi 3388',
        referenceArabic: 'سنن الترمذي 3388',
        audioUrl: '',
        order: 1,
      ),
      Azkar(
        id: 'protection_3',
        categoryId: 'protection',
        text: 'Surah Al-Falaq and An-Nas (Mu\'awwidhatayn)',
        textArabic: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ... قُلْ أَعُوذُ بِرَبِّ النَّاسِ...',
        translation: 'Say: I seek refuge in the Lord of the daybreak... Say: I seek refuge in the Lord of mankind...',
        count: 1,
        reference: 'Quran 113-114',
        referenceArabic: 'القرآن 113-114',
        audioUrl: '',
        order: 2,
      ),
    ];
  }

  // Get azkar for a category
  List<Azkar> getAzkarForCategory(String categoryId) {
    if (_categoryAzkar.containsKey(categoryId)) {
      return _categoryAzkar[categoryId]!;
    }
    final category = _categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => _categories.first,
    );
    _categoryAzkar[categoryId] = category.azkar;
    return category.azkar;
  }

  // Toggle favorite
  Future<void> toggleFavorite(String azkarId) async {
    await StorageService.toggleAzkarFavorite(azkarId);

    // Update in memory
    for (final category in _categories) {
      final index = category.azkar.indexWhere((a) => a.id == azkarId);
      if (index != -1) {
        final azkar = category.azkar[index];
        category.azkar[index] = azkar.copyWith(isFavorite: !azkar.isFavorite);
      }
    }

    notifyListeners();
  }

  // Increment completion
  Future<void> incrementCompletion(String azkarId) async {
    await StorageService.incrementAzkarCompletion(azkarId);

    // Update in memory
    for (final category in _categories) {
      final index = category.azkar.indexWhere((a) => a.id == azkarId);
      if (index != -1) {
        final azkar = category.azkar[index];
        final newCompletions = Map<String, int>.from(azkar.completions);
        final today = DateTime.now();
        final key = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';
        newCompletions[key] = (newCompletions[key] ?? 0) + 1;
        category.azkar[index] = azkar.copyWith(completions: newCompletions);
      }
    }

    notifyListeners();
  }

  // Reset daily completions
  Future<void> resetDailyCompletions() async {
    final today = DateTime.now();
    final key = '${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}';

    for (final category in _categories) {
      for (int i = 0; i < category.azkar.length; i++) {
        final azkar = category.azkar[i];
        if (azkar.completions.containsKey(key)) {
          final newCompletions = Map<String, int>.from(azkar.completions);
          newCompletions.remove(key);
          category.azkar[i] = azkar.copyWith(completions: newCompletions);
        }
      }
    }
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}