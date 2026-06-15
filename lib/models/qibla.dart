import 'package:hive/hive.dart';

part 'qibla.g.dart';

@HiveType(typeId: 9)
class QiblaDirection extends HiveObject {
  @HiveField(0)
  final double latitude;

  @HiveField(1)
  final double longitude;

  @HiveField(2)
  final double direction;

  @HiveField(3)
  final double distance;

  @HiveField(4)
  final DateTime calculatedAt;

  @HiveField(5)
  final String method;

  QiblaDirection({
    required this.latitude,
    required this.longitude,
    required this.direction,
    required this.distance,
    required this.calculatedAt,
    required this.method,
  });

  factory QiblaDirection.fromJson(Map<String, dynamic> json) {
    return QiblaDirection(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
      direction: json['direction']?.toDouble() ?? 0.0,
      distance: json['distance']?.toDouble() ?? 0.0,
      calculatedAt: json['calculatedAt'] != null
          ? DateTime.parse(json['calculatedAt'])
          : DateTime.now(),
      method: json['method'] ?? 'great_circle',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'direction': direction,
      'distance': distance,
      'calculatedAt': calculatedAt.toIso8601String(),
      'method': method,
    };
  }

  String get formattedDistance {
    if (distance < 1) {
      return '${(distance * 1000).round()} m';
    }
    return '${distance.toStringAsFixed(1)} km';
  }

  String get formattedDirection => '${direction.round()}°';

  @override
  String toString() => 'QiblaDirection(direction: $direction°, distance: $distance km)';
}