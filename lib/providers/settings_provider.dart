import 'package:flutter/material.dart';
import '../models/user_settings.dart';
import '../services/storage_service.dart';

class SettingsProvider extends ChangeNotifier {
  UserSettings _settings = UserSettings();

  UserSettings get settings => _settings;

  bool get isDarkMode => _settings.themeMode == 2 ||
      (_settings.themeMode == 0 &&
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark);

  String get language => _settings.language;

  Locale get locale => Locale(_settings.language);

  Future<void> initialize() async {
    _settings = StorageService.getSettings();
    notifyListeners();
  }

  Future<void> setLanguage(String language) async {
    _settings = _settings.copyWith(language: language);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setThemeMode(int themeMode) async {
    _settings = _settings.copyWith(themeMode: themeMode);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    final newMode = isDarkMode ? 1 : 2;
    await setThemeMode(newMode);
  }

  Future<void> setCalculationMethod(int method) async {
    _settings = _settings.copyWith(calculationMethod: method);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setMadhab(int madhab) async {
    _settings = _settings.copyWith(madhab: madhab);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _settings = _settings.copyWith(notificationsEnabled: enabled);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setPrayerNotification(String prayer, bool enabled) async {
    switch (prayer) {
      case 'fajr':
        _settings = _settings.copyWith(fajrNotification: enabled);
        break;
      case 'dhuhr':
        _settings = _settings.copyWith(dhuhrNotification: enabled);
        break;
      case 'asr':
        _settings = _settings.copyWith(asrNotification: enabled);
        break;
      case 'maghrib':
        _settings = _settings.copyWith(maghribNotification: enabled);
        break;
      case 'isha':
        _settings = _settings.copyWith(ishaNotification: enabled);
        break;
    }
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setNotificationAdvanceMinutes(int minutes) async {
    _settings = _settings.copyWith(notificationAdvanceMinutes: minutes);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setQuranAudioAutoPlay(bool autoPlay) async {
    _settings = _settings.copyWith(quranAudioAutoPlay: autoPlay);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setQuranReciter(String reciter) async {
    _settings = _settings.copyWith(quranReciter: reciter);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setQuranFontSize(double size) async {
    _settings = _settings.copyWith(quranFontSize: size.clamp(18.0, 40.0));
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setShowTranslation(bool show) async {
    _settings = _settings.copyWith(showTranslation: show);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setTranslationLanguage(String language) async {
    _settings = _settings.copyWith(translationLanguage: language);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setShowTafsir(bool show) async {
    _settings = _settings.copyWith(showTafsir: show);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setTafsirSource(String source) async {
    _settings = _settings.copyWith(tafsirSource: source);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setHapticFeedback(bool enabled) async {
    _settings = _settings.copyWith(hapticFeedback: enabled);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setReduceMotion(bool enabled) async {
    _settings = _settings.copyWith(reduceMotion: enabled);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> updateLocation({
    required double latitude,
    required double longitude,
    required String city,
  }) async {
    _settings = _settings.copyWith(
      lastLocationLat: latitude.toString(),
      lastLocationLng: longitude.toString(),
      lastLocationCity: city,
    );
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setLocationPermissionGranted(bool granted) async {
    _settings = _settings.copyWith(locationPermissionGranted: granted);
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  Future<void> setCompassCalibrated(bool calibrated) async {
    _settings = _settings.copyWith(
      compassCalibrated: calibrated,
      lastCompassCalibration: calibrated ? DateTime.now() : null,
    );
    await StorageService.saveSettings(_settings);
    notifyListeners();
  }

  // Prayer times calculation settings
  static const List<CalculationMethod> calculationMethods = [
    CalculationMethod(0, 'Shia Ithna-Ashari', 'Jafari'),
    CalculationMethod(1, 'University of Islamic Sciences, Karachi', 'Karachi'),
    CalculationMethod(2, 'Islamic Society of North America', 'ISNA'),
    CalculationMethod(3, 'Muslim World League', 'MWL'),
    CalculationMethod(4, 'Umm al-Qura, Makkah', 'Makkah'),
    CalculationMethod(5, 'Egyptian General Authority of Survey', 'Egypt'),
    CalculationMethod(6, 'Institute of Geophysics, University of Tehran', 'Tehran'),
    CalculationMethod(7, 'Gulf Region', 'Gulf'),
    CalculationMethod(8, 'Kuwait', 'Kuwait'),
    CalculationMethod(9, 'Qatar', 'Qatar'),
    CalculationMethod(10, 'Majlis Ugama Islam Singapura', 'Singapore'),
    CalculationMethod(11, 'Union Organization islamic de France', 'France'),
    CalculationMethod(12, 'Diyanet İşleri Başkanlığı', 'Turkey'),
    CalculationMethod(13, 'Spiritual Administration of Muslims of Russia', 'Russia'),
    CalculationMethod(14, 'Moonsighting Committee Worldwide', 'Moonsighting'),
    CalculationMethod(15, 'Dubai', 'Dubai'),
    CalculationMethod(16, 'Jabatan Kemajuan Islam Malaysia', 'JAKIM'),
    CalculationMethod(17, 'Tunisia', 'Tunisia'),
    CalculationMethod(18, 'Algeria', 'Algeria'),
    CalculationMethod(19, 'Indonesia', 'Indonesia'),
    CalculationMethod(20, 'Morocco', 'Morocco'),
    CalculationMethod(21, 'Comunidad Islámica de México', 'Mexico'),
    CalculationMethod(22, 'Majlis Ugama Islam Brunei', 'Brunei'),
    CalculationMethod(23, 'Department of Islamic Development Malaysia', 'Malaysia'),
  ];

  static const List<Madhab> madhabs = [
    Madhab(0, 'Shafi', 'Shafi'),
    Madhab(1, 'Hanafi', 'Hanafi'),
  ];

  static const List<String> availableReciters = [
    'ar.alafasy',
    'ar.abdurrahmaansudais',
    'ar.abdullahbasfar',
    'ar.husary',
    'ar.husarymujawwad',
    'ar.minshawi',
    'ar.minshawimujawwad',
    'ar.moayeq',
    'ar.samir',
    'ar.shuraim',
    'ar.sudais',
  ];

  static const List<String> availableTranslations = [
    'en.sahih',
    'en.pickthall',
    'en.yusufali',
    'en.shakir',
    'ar.ar',
    'fr.hamidullah',
    'tr.diyanet',
    'ur.junagarhi',
    'id.indonesian',
  ];

  static const List<String> availableTafsirs = [
    'ibn-kathir',
    'jalalayn',
    'maarif',
    'tafsir-ibn-kathir-ar',
    'tafsir-al-jalalayn-ar',
  ];
}

class CalculationMethod {
  final int id;
  final String name;
  final String shortName;

  const CalculationMethod(this.id, this.name, this.shortName);
}

class Madhab {
  final int id;
  final String name;
  final String shortName;

  const Madhab(this.id, this.name, this.shortName);
}