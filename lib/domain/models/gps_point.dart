import 'dart:math';

/// Represents a single geographic position recorded by the GPS.
class GpsPoint {
  final double latitude;
  final double longitude;
  final double altitude; // meters
  final DateTime timestamp;
  final double speed; // meters per second
  final double accuracy; // meters
  final double? heading; // degrees (0-360)

  const GpsPoint({
    required this.latitude,
    required this.longitude,
    this.altitude = 0.0,
    required this.timestamp,
    this.speed = 0.0,
    this.accuracy = 0.0,
    this.heading,
  });

  /// Calculates distance in meters to another [GpsPoint] using Haversine formula
  double distanceTo(GpsPoint other) {
    const earthRadiusMeters = 6371000.0;
    final dLat = _toRadians(other.latitude - latitude);
    final dLon = _toRadians(other.longitude - longitude);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(latitude)) *
            cos(_toRadians(other.latitude)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180.0;
  }

  /// Format as KML string: "longitude,latitude,altitude"
  String toKmlCoordinate() {
    return '$longitude,$latitude,$altitude';
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'altitude': altitude,
        'timestamp': timestamp.toIso8601String(),
        'speed': speed,
        'accuracy': accuracy,
        'heading': heading,
      };

  factory GpsPoint.fromJson(Map<String, dynamic> json) => GpsPoint(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        altitude: (json['altitude'] as num?)?.toDouble() ?? 0.0,
        timestamp: DateTime.parse(json['timestamp'] as String),
        speed: (json['speed'] as num?)?.toDouble() ?? 0.0,
        accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
        heading: (json['heading'] as num?)?.toDouble(),
      );
}
