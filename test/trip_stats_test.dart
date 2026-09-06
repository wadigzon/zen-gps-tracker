import 'package:flutter_test/flutter_test.dart';
import 'package:zen_gps_tracker/domain/models/gps_point.dart';
import 'package:zen_gps_tracker/domain/models/trip_stats.dart';

void main() {
  group('TripStats Calculation Tests', () {
    test('Haversine distance calculation is accurate', () {
      // Point 1: San Francisco (37.7749, -122.4194)
      final pt1 = GpsPoint(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
      );

      // Point 2: ~1 km North (37.7839, -122.4194)
      final pt2 = GpsPoint(
        latitude: 37.7839,
        longitude: -122.4194,
        timestamp: DateTime.now().add(const Duration(minutes: 10)),
      );

      final distanceMeters = pt1.distanceTo(pt2);
      expect(distanceMeters, closeTo(1000, 50)); // Expect approx 1000m +- 50m
    });

    test('TripStats computes distance, speed, and elevation correctly', () {
      final t0 = DateTime.utc(2026, 9, 6, 10, 0, 0);

      final points = [
        GpsPoint(latitude: 37.0, longitude: -120.0, altitude: 100, speed: 2.0, timestamp: t0),
        GpsPoint(latitude: 37.001, longitude: -120.0, altitude: 120, speed: 3.0, timestamp: t0.add(const Duration(seconds: 30))),
        GpsPoint(latitude: 37.002, longitude: -120.0, altitude: 115, speed: 2.5, timestamp: t0.add(const Duration(seconds: 60))),
      ];

      final stats = TripStats.fromPoints(
        points,
        activeDuration: const Duration(seconds: 60),
        pausedDuration: Duration.zero,
      );

      expect(stats.totalDistanceMeters, greaterThan(200));
      expect(stats.maxSpeedMps, equals(3.0));
      expect(stats.maxSpeedKmh, closeTo(10.8, 0.1));
      expect(stats.minAltitudeMeters, equals(100));
      expect(stats.maxAltitudeMeters, equals(120));
      expect(stats.elevationGainMeters, equals(20));
    });
  });
}
