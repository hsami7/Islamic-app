import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:async';
import '../models/qibla.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';
import '../services/storage_service.dart';
import 'settings_provider.dart';

class QiblaProvider extends ChangeNotifier {
  QiblaDirection? _qiblaDirection;
  double _deviceHeading = 0.0;
  double _qiblaAngle = 0.0;
  bool _isLoading = false;
  String? _error;
  bool _isCalibrating = false;
  StreamSubscription<dynamic>? _compassSubscription;

  // Getters
  QiblaDirection? get qiblaDirection => _qiblaDirection;
  double get deviceHeading => _deviceHeading;
  double get qiblaAngle => _qiblaAngle;
  double get relativeAngle => (_qiblaAngle - _deviceHeading) % 360;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isCalibrating => _isCalibrating;
  bool get hasQiblaData => _qiblaDirection != null;

  // Initialize compass and load qibla direction
  Future<void> initialize(SettingsProvider settings) async {
    await loadQiblaDirection(settings);
    _startCompassStream();
  }

  // Load qibla direction for current location
  Future<void> loadQiblaDirection(SettingsProvider settings) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Try cache first
      if (settings.settings.lastLocationLat.isNotEmpty &&
          settings.settings.lastLocationLng.isNotEmpty) {
        final lat = double.parse(settings.settings.lastLocationLat);
        final lng = double.parse(settings.settings.lastLocationLng);

        final cached = StorageService.getQiblaDirection(lat, lng);
        if (cached != null) {
          _qiblaDirection = cached;
          _qiblaAngle = cached.direction;
          _isLoading = false;
          notifyListeners();
          return;
        }
      }

      // Get current location
      final location = await _getLocation(settings);

      // Fetch from API
      final direction = await apiService.getQiblaDirection(
        latitude: location['latitude'],
        longitude: location['longitude'],
      );

      _qiblaDirection = direction;
      _qiblaAngle = direction.direction;

      // Cache it
      await StorageService.saveQiblaDirection(direction);

      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> _getLocation(SettingsProvider settings) async {
    if (settings.settings.lastLocationLat.isNotEmpty &&
        settings.settings.lastLocationLng.isNotEmpty) {
      return {
        'latitude': double.parse(settings.settings.lastLocationLat),
        'longitude': double.parse(settings.settings.lastLocationLng),
      };
    }

    try {
      final position = await locationService.getCurrentLocation();
      await settings.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        city: 'Current Location',
      );
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      // Default to Kaaba
      return {'latitude': 21.4225, 'longitude': 39.8262};
    }
  }

  // Start compass stream
  void _startCompassStream() {
    FlutterCompass.events?.listen((event) {
      if (event.heading != null) {
        _deviceHeading = event.heading!;
        notifyListeners();
      }
    });
  }

  // Recalibrate compass
  Future<void> calibrateCompass(SettingsProvider settings) async {
    _isCalibrating = true;
    notifyListeners();

    // Show calibration instructions
    await Future.delayed(const Duration(seconds: 3));

    _isCalibrating = false;
    await settings.setCompassCalibrated(true);
    notifyListeners();
  }

  // Get direction to Kaaba from current heading
  String getDirectionInstruction() {
    if (!hasQiblaData) return 'Calculating...';

    final relative = relativeAngle;
    final normalized = relative < 0 ? relative + 360 : relative;

    if (normalized < 5 || normalized > 355) {
      return 'You are facing the Qibla! 🕋';
    } else if (normalized < 180) {
      return 'Turn left ${normalized.round()}°';
    } else {
      return 'Turn right ${(360 - normalized).round()}°';
    }
  }

  // Get arrow rotation for UI
  double getArrowRotation() {
    // Rotate arrow to point to Qibla relative to device heading
    return (_qiblaAngle - _deviceHeading) * (3.14159 / 180);
  }

  // Get distance to Kaaba
  String getDistanceToKaaba() {
    if (_qiblaDirection == null) return '--';
    return _qiblaDirection!.formattedDistance;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

}

// StreamSubscription removed - compass events are fire-and-forget