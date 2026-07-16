import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/surah.dart';
import '../models/ayah.dart';
import '../models/prayer_times.dart';
import '../models/azkar.dart';
import '../models/qibla.dart';

class ApiService {
  static const String baseUrl = 'https://api.alquran.cloud/v1';
  static const String aladhanBaseUrl = 'https://api.aladhan.com/v1';

  final http.Client _client = http.Client();

  // Quran API
  Future<List<Surah>> getAllSurahs({String edition = 'ar'}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/surah'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> surahsJson = data['data'] ?? [];
      return surahsJson.map((json) => Surah.fromJson(json)).toList();
    }
    throw Exception('Failed to load surahs: ${response.statusCode}');
  }

  Future<Surah> getSurah(int number, {String edition = 'ar'}) async {
    final response = await _client.get(
      Uri.parse('$baseUrl/surah/$number/$edition'),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return Surah.fromJson(data['data']);
    }
    throw Exception('Failed to load surah: ${response.statusCode}');
  }

  Future<List<Ayah>> getSurahAyahs(int surahNumber,
      {String edition = 'ar', String translationEdition = 'en.sahih'}) async {
    // Get Arabic text
    final arabicResponse = await _client.get(
      Uri.parse('$baseUrl/surah/$surahNumber/ar'),
      headers: {'Accept': 'application/json'},
    );

    // Get translation
    final translationResponse = await _client.get(
      Uri.parse('$baseUrl/surah/$surahNumber/$translationEdition'),
      headers: {'Accept': 'application/json'},
    );

    if (arabicResponse.statusCode == 200 && translationResponse.statusCode == 200) {
      final arabicData = json.decode(arabicResponse.body);
      final translationData = json.decode(translationResponse.body);

      final arabicAyahs = arabicData['data']['ayahs'] as List<dynamic>;
      final translationAyahs = translationData['data']['ayahs'] as List<dynamic>;

      return arabicAyahs.asMap().entries.map((entry) {
        final index = entry.key;
        final arabicAyah = entry.value;
        final translationAyah = index < translationAyahs.length ? translationAyahs[index] : {};

        return Ayah(
          number: arabicAyah['number'] ?? 0,
          surahNumber: surahNumber,
          numberInSurah: arabicAyah['numberInSurah'] ?? 0,
          juz: arabicAyah['juz'] ?? 0,
          manzil: arabicAyah['manzil'] ?? 0,
          page: arabicAyah['page'] ?? 0,
          ruku: arabicAyah['ruku'] ?? 0,
          hizbQuarter: arabicAyah['hizbQuarter'] ?? 0,
          text: translationAyah['text'] ?? '',
          textArabic: arabicAyah['text'] ?? '',
          translation: translationAyah['text'] ?? '',
          audioUrl: 'https://verses.quran.com/${arabicAyah['number']}.mp3',
        );
      }).toList();
    }

    throw Exception('Failed to load ayahs');
  }

  Future<String> getAyahAudio(int ayahNumber, String reciter) async {
    return 'https://verses.quran.com/$ayahNumber.mp3';
  }

  // Prayer Times API (Aladhan)
  Future<PrayerTimes> getPrayerTimes({
    required double latitude,
    required double longitude,
    int method = 3, // Muslim World League
    int school = 0, // Shafi
    DateTime? date,
  }) async {
    final targetDate = date ?? DateTime.now();
    final dateString = '${targetDate.day}-${targetDate.month}-${targetDate.year}';

    final response = await _client.get(
      Uri.parse('$aladhanBaseUrl/timings/$dateString').replace(queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'method': method.toString(),
        'school': school.toString(),
        'timezone': 'auto',
      }),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PrayerTimes.fromJson(data['data'],
          lat: latitude, lng: longitude, tz: data['data']['meta']['timezone'] ?? '');
    }
    throw Exception('Failed to load prayer times: ${response.statusCode}');
  }

  Future<PrayerTimes> getPrayerTimesByCity({
    required String city,
    required String country,
    int method = 3,
    int school = 0,
    DateTime? date,
  }) async {
    final targetDate = date ?? DateTime.now();
    final dateString = '${targetDate.day}-${targetDate.month}-${targetDate.year}';

    final response = await _client.get(
      Uri.parse('$aladhanBaseUrl/timingsByCity/$dateString').replace(queryParameters: {
        'city': city,
        'country': country,
        'method': method.toString(),
        'school': school.toString(),
        'timezone': 'auto',
      }),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return PrayerTimes.fromJson(data['data'],
          lat: data['data']['meta']['latitude']?.toDouble() ?? 0,
          lng: data['data']['meta']['longitude']?.toDouble() ?? 0,
          tz: data['data']['meta']['timezone'] ?? '');
    }
    throw Exception('Failed to load prayer times by city: ${response.statusCode}');
  }

  Future<QiblaDirection> getQiblaDirection({
    required double latitude,
    required double longitude,
  }) async {
    final response = await _client.get(
      Uri.parse('$aladhanBaseUrl/qibla').replace(queryParameters: {
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      }),
      headers: {'Accept': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return QiblaDirection.fromJson(data['data']);
    }
    throw Exception('Failed to load qibla direction: ${response.statusCode}');
  }

  // Azkar - using local JSON for now, can be moved to API
  Future<List<AzkarCategory>> getAzkarCategories() async {
    // This will be loaded from local assets
    return [];
  }

  void dispose() {
    _client.close();
  }
}

final apiService = ApiService();