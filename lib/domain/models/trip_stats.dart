import 'gps_point.dart';

/// Aggregated telemetry and statistics for a trip.
class TripStats {
  final double totalDistanceMeters;
  final Duration activeDuration;
  final Duration pausedDuration;
  final double maxSpeedMps;
  final double minAltitudeMeters;
  final double maxAltitudeMeters;
  final double elevationGainMeters;

  const TripStats({
    this.totalDistanceMeters = 0.0,
    this.activeDuration = Duration.zero,
    this.pausedDuration = Duration.zero,
    this.maxSpeedMps = 0.0,
    this.minAltitudeMeters = 0.0,
    this.maxAltitudeMeters = 0.0,
    this.elevationGainMeters = 0.0,
  });

  /// Total duration (active + paused)
  Duration get totalDuration => activeDuration + pausedDuration;

  /// Distance in kilometers
  double get distanceKm => totalDistanceMeters / 1000.0;

  /// Distance in miles
  double get distanceMiles => totalDistanceMeters * 0.000621371;

  /// Average speed in meters per second
  double get avgSpeedMps {
    final seconds = activeDuration.inSeconds;
    if (seconds <= 0) return 0.0;
    return totalDistanceMeters / seconds;
  }

  /// Average speed in km/h
  double get avgSpeedKmh => avgSpeedMps * 3.6;

  /// Average speed in mph
  double get avgSpeedMph => avgSpeedMps * 2.23694;

  /// Max speed in km/h
  double get maxSpeedKmh => maxSpeedMps * 3.6;

  /// Max speed in mph
  double get maxSpeedMph => maxSpeedMps * 2.23694;

  /// Compute stats from a sequence of [GpsPoint]s and active duration
  factory TripStats.fromPoints(List<GpsPoint> points, {
    required Duration activeDuration,
    required Duration pausedDuration,
  }) {
    if (points.isEmpty) {
      return TripStats(
        activeDuration: activeDuration,
        pausedDuration: pausedDuration,
      );
    }

    double totalDist = 0.0;
    double maxSpd = 0.0;
    double minAlt = points.first.altitude;
    double maxAlt = points.first.altitude;
    double elevGain = 0.0;

    for (int i = 0; i < points.length; i++) {
      final current = points[i];

      if (current.speed > maxSpd) {
        maxSpd = current.speed;
      }
      if (current.altitude < minAlt) {
        minAlt = current.altitude;
      }
      if (current.altitude > maxAlt) {
        maxAlt = current.altitude;
      }

      if (i > 0) {
        final prev = points[i - 1];
        final dist = prev.distanceTo(current);
        totalDist += dist;

        final altDiff = current.altitude - prev.altitude;
        if (altDiff > 0) {
          elevGain += altDiff;
        }
      }
    }

    return TripStats(
      totalDistanceMeters: totalDist,
      activeDuration: activeDuration,
      pausedDuration: pausedDuration,
      maxSpeedMps: maxSpd,
      minAltitudeMeters: minAlt,
      maxAltitudeMeters: maxAlt,
      elevationGainMeters: elevGain,
    );
  }

  Map<String, dynamic> toJson() => {
        'totalDistanceMeters': totalDistanceMeters,
        'activeDurationSeconds': activeDuration.inSeconds,
        'pausedDurationSeconds': pausedDuration.inSeconds,
        'maxSpeedMps': maxSpeedMps,
        'minAltitudeMeters': minAltitudeMeters,
        'maxAltitudeMeters': maxAltitudeMeters,
        'elevationGainMeters': elevationGainMeters,
      };

  factory TripStats.fromJson(Map<String, dynamic> json) => TripStats(
        totalDistanceMeters: (json['totalDistanceMeters'] as num?)?.toDouble() ?? 0.0,
        activeDuration: Duration(seconds: json['activeDurationSeconds'] as int? ?? 0),
        pausedDuration: Duration(seconds: json['pausedDurationSeconds'] as int? ?? 0),
        maxSpeedMps: (json['maxSpeedMps'] as num?)?.toDouble() ?? 0.0,
        minAltitudeMeters: (json['minAltitudeMeters'] as num?)?.toDouble() ?? 0.0,
        maxAltitudeMeters: (json['maxAltitudeMeters'] as num?)?.toDouble() ?? 0.0,
        elevationGainMeters: (json['elevationGainMeters'] as num?)?.toDouble() ?? 0.0,
      );
}
