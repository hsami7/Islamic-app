import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_settings.dart';
import '../services/storage_service.dart';

/// Weather conditions surfaced on the Home screen.
enum WeatherCondition {
  clear,
  clouds,
  rain,
  snow,
  thunderstorm,
  fog,
  unknown;

  /// Friendly Arabic + English labels.
  String get labelAr {
    switch (this) {
      case WeatherCondition.clear:
        return 'صافٍ';
      case WeatherCondition.clouds:
        return 'غائم';
      case WeatherCondition.rain:
        return 'ممطر';
      case WeatherCondition.snow:
        return 'ثلج';
      case WeatherCondition.thunderstorm:
        return 'عاصفة رعدية';
      case WeatherCondition.fog:
        return 'ضباب';
      case WeatherCondition.unknown:
        return '';
    }
  }

  String get labelEn {
    switch (this) {
      case WeatherCondition.clear:
        return 'Clear';
      case WeatherCondition.clouds:
        return 'Cloudy';
      case WeatherCondition.rain:
        return 'Rain';
      case WeatherCondition.snow:
        return 'Snow';
      case WeatherCondition.thunderstorm:
        return 'Thunderstorm';
      case WeatherCondition.fog:
        return 'Fog';
      case WeatherCondition.unknown:
        return '';
    }
  }

  /// Emoji used as a lightweight graphic on the home card.
  String get emoji {
    switch (this) {
      case WeatherCondition.clear:
        return '☀️';
      case WeatherCondition.clouds:
        return '☁️';
      case WeatherCondition.rain:
        return '🌧️';
      case WeatherCondition.snow:
        return '❄️';
      case WeatherCondition.thunderstorm:
        return '⛈️';
      case WeatherCondition.fog:
        return '🌫️';
      case WeatherCondition.unknown:
        return '🌤️';
    }
  }
}

class WeatherInfo {
  final WeatherCondition condition;
  final double temperatureC;
  final String description;

  WeatherInfo({
    required this.condition,
    required this.temperatureC,
    required this.description,
  });

  factory WeatherInfo.fromJson(Map<String, dynamic> json) {
    final weather = (json['weather'] as List?)?.first as Map<String, dynamic>?;
    final main = json['main'] as Map<String, dynamic>?;
    final code = (weather?['id'] as int?) ?? 0;
    return WeatherInfo(
      condition: _mapCondition(code),
      temperatureC: (main?['temp'] as num?)?.toDouble() ?? 0.0,
      description: weather?['description'] as String? ?? '',
    );
  }

  static WeatherCondition _mapCondition(int code) {
    if (code >= 200 && code < 300) return WeatherCondition.thunderstorm;
    if (code >= 300 && code < 400) return WeatherCondition.rain;
    if (code >= 500 && code < 600) return WeatherCondition.rain;
    if (code >= 600 && code < 700) return WeatherCondition.snow;
    if (code >= 700 && code < 800) return WeatherCondition.fog;
    if (code == 800) return WeatherCondition.clear;
    if (code > 800) return WeatherCondition.clouds;
    return WeatherCondition.unknown;
  }

  Map<String, dynamic> toJson() => {
        'condition': condition.name,
        'temp': temperatureC,
        'desc': description,
      };

  factory WeatherInfo.fromStored(Map<String, dynamic> json) => WeatherInfo(
        condition: WeatherCondition.values.firstWhere(
          (c) => c.name == json['condition'],
          orElse: () => WeatherCondition.unknown,
        ),
        temperatureC: (json['temp'] as num?)?.toDouble() ?? 0.0,
        description: json['desc'] as String? ?? '',
      );
}

class WeatherService {
  /// Open-Meteo requires no API key. Falls back to a time-based guess if
  /// offline.
  static Future<WeatherInfo> getCurrentWeather(UserSettings settings) async {
    // Try cache (today) first.
    final cached = StorageService.getWeather();
    if (cached != null) {
      return WeatherInfo.fromStored(cached);
    }

    final lat = settings.lastLocationLat.isNotEmpty
        ? double.tryParse(settings.lastLocationLat)
        : null;
    final lng = settings.lastLocationLng.isNotEmpty
        ? double.tryParse(settings.lastLocationLng)
        : null;

    if (lat == null || lng == null) {
      final guess = _timeBasedGuess();
      await StorageService.saveWeather(guess.toJson());
      return guess;
    }

    try {
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$lat&longitude=$lng'
        '&current=temperature_2m,weather_code',
      );
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      if (resp.statusCode == 200) {
        final json = jsonDecode(resp.body) as Map<String, dynamic>;
        final current = json['current'] as Map<String, dynamic>?;
        if (current != null) {
          final code = (current['weather_code'] as int?) ?? 0;
          final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 0.0;
          final info = WeatherInfo(
            condition: _openMeteoCode(code),
            temperatureC: temp,
            description: '',
          );
          await StorageService.saveWeather(info.toJson());
          return info;
        }
      }
    } catch (_) {
      // Network failed — fall through to guess.
    }

    final guess = _timeBasedGuess();
    await StorageService.saveWeather(guess.toJson());
    return guess;
  }

  static WeatherCondition _openMeteoCode(int code) {
    // WMO weather interpretation codes.
    if (code == 0) return WeatherCondition.clear;
    if (code <= 2) return WeatherCondition.clouds;
    if (code == 3) return WeatherCondition.clouds;
    if (code >= 45 && code <= 48) return WeatherCondition.fog;
    if (code >= 51 && code <= 67) return WeatherCondition.rain;
    if (code >= 71 && code <= 77) return WeatherCondition.snow;
    if (code >= 80 && code <= 82) return WeatherCondition.rain;
    if (code >= 85 && code <= 86) return WeatherCondition.snow;
    if (code >= 95) return WeatherCondition.thunderstorm;
    return WeatherCondition.unknown;
  }

  /// No network / no location → derive a plausible condition from local time.
  static WeatherInfo _timeBasedGuess() {
    final hour = DateTime.now().hour;
    WeatherCondition condition;
    if (hour >= 6 && hour < 9) {
      condition = WeatherCondition.clouds; // dawn haze
    } else if (hour >= 9 && hour < 17) {
      condition = WeatherCondition.clear; // daytime
    } else if (hour >= 17 && hour < 20) {
      condition = WeatherCondition.clear; // sunset
    } else {
      condition = WeatherCondition.clear; // night (clear skies default)
    }
    return WeatherInfo(
      condition: condition,
      temperatureC: 0,
      description: '',
    );
  }
}
