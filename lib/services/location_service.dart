import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/user_settings.dart';

class LocationService {
  static const String _defaultCity = 'Fez';
  static const String _defaultCountry = 'Morocco';
  static const double _defaultLat = 34.0331;
  static const double _defaultLng = -5.0003;

  Future<Position> getCurrentLocation() async {
    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    // Get current position
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  Future<void> requestLocationPermission() async {
    await Permission.location.request();
  }

  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  Future<Position?> getLastKnownLocation() async {
    return await Geolocator.getLastKnownPosition();
  }

  Stream<Position> getPositionStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 100,
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }

  Future<Map<String, dynamic>> getLocationInfo() async {
    try {
      final position = await getCurrentLocation();
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
        'city': _defaultCity, // Would need reverse geocoding
        'country': _defaultCountry,
      };
    } catch (e) {
      // Return default location if GPS fails
      return {
        'latitude': _defaultLat,
        'longitude': _defaultLng,
        'city': _defaultCity,
        'country': _defaultCountry,
      };
    }
  }

  double calculateDistance(
    double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  double calculateBearing(
    double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.bearingBetween(lat1, lon1, lat2, lon2);
  }

  // Save location to settings
  Future<void> saveLocationToSettings(
    UserSettings settings, {
    required double latitude,
    required double longitude,
    required String city,
  }) async {
    // This will be handled by the settings provider
  }
}

final locationService = LocationService();