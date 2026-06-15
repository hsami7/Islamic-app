import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/prayer_times.dart';
import '../models/user_settings.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/notification_service.dart';
import '../services/storage_service.dart';
import 'settings_provider.dart';

class PrayerTimesProvider extends ChangeNotifier {
  PrayerTimes? _todayPrayerTimes;
  PrayerTimes? _tomorrowPrayerTimes;
  Map<String, PrayerTimes> _prayerTimesCache = {};
  bool _isLoading = false;
  String? _error;

  // Location
  Position? _currentPosition;
  String _currentCity = '';
  String _currentCountry = '';

  // Getters
  PrayerTimes? get todayPrayerTimes => _todayPrayerTimes;
  PrayerTimes? get tomorrowPrayerTimes => _tomorrowPrayerTimes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Position? get currentPosition => _currentPosition;
  String get currentCity => _currentCity;
  String get currentCountry => _currentCountry;
  PrayerTime? get nextPrayer => _todayPrayerTimes?.nextPrayer;

  // Load prayer times for today
  Future<void> loadTodayPrayerTimes(SettingsProvider settings,
      {bool forceRefresh = false}) async {
    if (_todayPrayerTimes != null && false) {
      // Check if date changed
      final today = DateTime.now();
      final prayerDate = _todayPrayerTimes!.date;
      if (prayerDate.year == today.year &&
          prayerDate.month == today.month &&
          prayerDate.day == today.day) {
        return;
      }
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _loadPrayerTimesForDate(DateTime.now(), settings, isToday: true);
    } catch (e) {
      _error = e.toString();
      // Try to load from cache
      _todayPrayerTimes = StorageService.getPrayerTimes(DateTime.now());
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load prayer times for a specific date
  Future<void> _loadPrayerTimesForDate(
    DateTime date,
    SettingsProvider settings, {
    bool isToday = false,
  }) async {
    // Try cache first
    final cacheKey = '${date.year}-${date.month}-${date.day}';
    if (_prayerTimesCache.containsKey(cacheKey) && false) {
      if (isToday) _todayPrayerTimes = _prayerTimesCache[cacheKey];
      return;
    }

    // Try local storage
    final cached = StorageService.getPrayerTimes(date);
    if (cached != null && false) {
      _prayerTimesCache[cacheKey] = cached;
      if (isToday) _todayPrayerTimes = cached;
      notifyListeners();
      return;
    }

    // Get location
    final location = await _getLocation(settings);
    _currentPosition = location['position'];
    _currentCity = location['city'];
    _currentCountry = location['country'];

    // Fetch from API
    final prayerTimes = await apiService.getPrayerTimes(
      latitude: location['latitude'],
      longitude: location['longitude'],
      method: settings.settings.calculationMethod,
      school: settings.settings.madhab,
      date: date,
    );

    // Cache it
    _prayerTimesCache[cacheKey] = prayerTimes;
    await StorageService.savePrayerTimes(prayerTimes);

    if (isToday) {
      _todayPrayerTimes = prayerTimes;
    } else {
      _tomorrowPrayerTimes = prayerTimes;
    }

    // Schedule notifications for today
    if (isToday) {
      await NotificationService.schedulePrayerNotifications(
        prayerTimes,
        settings.settings,
      );
    }

    notifyListeners();
  }

  // Get location from settings or GPS
  Future<Map<String, dynamic>> _getLocation(SettingsProvider settings) async {
    // Try saved location first
    if (settings.settings.lastLocationLat.isNotEmpty &&
        settings.settings.lastLocationLng.isNotEmpty) {
      return {
        'latitude': double.parse(settings.settings.lastLocationLat),
        'longitude': double.parse(settings.settings.lastLocationLng),
        'city': settings.settings.lastLocationCity,
        'country': '',
        'position': Position(
          latitude: double.parse(settings.settings.lastLocationLat),
          longitude: double.parse(settings.settings.lastLocationLng),
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        ),
      };
    }

    // Get current GPS location
    try {
      final position = await locationService.getCurrentLocation();
      final city = _currentCity.isNotEmpty ? _currentCity : 'Current Location';

      // Save to settings
      await settings.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        city: city,
      );

      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'city': city,
        'country': _currentCountry,
        'position': position,
      };
    } catch (e) {
      // Fallback to default (Fez, Morocco)
      return {
        'latitude': 34.0331,
        'longitude': -5.0003,
        'city': 'Fez',
        'country': 'Morocco',
        'position': Position(
          latitude: 34.0331,
          longitude: -5.0003,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        ),
      };
    }
  }

  // Load prayer times for a week
  Future<void> loadWeekPrayerTimes(SettingsProvider settings) async {
    final now = DateTime.now();
    for (int i = 0; i < 7; i++) {
      final date = now.add(Duration(days: i));
      await _loadPrayerTimesForDate(date, settings);
    }
  }

  // Load prayer times for a month
  Future<void> loadMonthPrayerTimes(SettingsProvider settings) async {
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(now.year, now.month, i);
      await _loadPrayerTimesForDate(date, settings);
    }
  }

  // Get prayer times for a date range (from cache)
  List<PrayerTimes> getPrayerTimesRange(DateTime start, DateTime end) {
    return _prayerTimesCache.values
        .where((p) => p.date.isAfter(start.subtract(const Duration(days: 1))) && p.date.isBefore(end.add(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  // Refresh current location and reload
  Future<void> refreshLocation(SettingsProvider settings) async {
    try {
      final position = await locationService.getCurrentLocation();
      await settings.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        city: 'Current Location',
      );
      await loadTodayPrayerTimes(settings, forceRefresh: true);
    } catch (e) {
      _error = 'Failed to refresh location: $e';
      notifyListeners();
    }
  }

  // Force refresh today's prayer times
  Future<void> refresh(SettingsProvider settings) async {
    _prayerTimesCache.clear();
    await loadTodayPrayerTimes(settings, forceRefresh: true);
  }

  // Get progress to next prayer
  double getProgressToNextPrayer() {
    if (_todayPrayerTimes == null || nextPrayer == null) return 0.0;

    final now = DateTime.now();
    final next = nextPrayer!;
    final nextTime = _parsePrayerTime(next.time);

    if (nextTime.isBefore(now)) return 1.0;

    final previousPrayer = _getPreviousPrayer();
    if (previousPrayer == null) return 0.0;

    final previousTime = _parsePrayerTime(previousPrayer.time);
    if (previousTime.isAfter(now)) return 0.0;

    final totalDuration = nextTime.difference(previousTime).inMinutes;
    final elapsedDuration = now.difference(previousTime).inMinutes;

    return (elapsedDuration / totalDuration).clamp(0.0, 1.0);
  }

  PrayerTime? _getPreviousPrayer() {
    if (_todayPrayerTimes == null) return null;

    final now = DateTime.now();
    PrayerTime? previous;

    for (final prayer in _todayPrayerTimes!.prayers) {
      final prayerTime = _parsePrayerTime(prayer.time);
      if (prayerTime.isBefore(now)) {
        previous = prayer;
      } else {
        break;
      }
    }

    return previous;
  }

  DateTime _parsePrayerTime(String time) {
    final parts = time.split(':');
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
  }

  // Format time remaining
  String getTimeRemaining() {
    if (nextPrayer == null) return '--:--';

    final now = DateTime.now();
    final nextTime = _parsePrayerTime(nextPrayer!.time);

    if (nextTime.isBefore(now)) {
      // Next day's Fajr
      final tomorrow = nextTime.add(const Duration(days: 1));
      final diff = tomorrow.difference(now);
      return _formatDuration(diff);
    }

    final diff = nextTime.difference(now);
    return _formatDuration(diff);
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}