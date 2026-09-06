import 'gps_point.dart';
import 'trip_stats.dart';

/// Represents a complete recorded outdoor trip (walk, hike, ride, etc.).
class Trip {
  final String id;
  final String title;
  final String? description;
  final DateTime startTime;
  final DateTime? endTime;
  final List<GpsPoint> points;
  final TripStats stats;
  final bool isCompleted;

  const Trip({
    required this.id,
    required this.title,
    this.description,
    required this.startTime,
    this.endTime,
    required this.points,
    required this.stats,
    this.isCompleted = false,
  });

  Trip copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    List<GpsPoint>? points,
    TripStats? stats,
    bool? isCompleted,
  }) {
    return Trip(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      points: points ?? this.points,
      stats: stats ?? this.stats,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'points': points.map((p) => p.toJson()).toList(),
        'stats': stats.toJson(),
        'isCompleted': isCompleted,
      };

  factory Trip.fromJson(Map<String, dynamic> json) => Trip(
        id: json['id'] as String,
        title: json['title'] as String,
        description: json['description'] as String?,
        startTime: DateTime.parse(json['startTime'] as String),
        endTime: json['endTime'] != null ? DateTime.parse(json['endTime'] as String) : null,
        points: (json['points'] as List<dynamic>)
            .map((p) => GpsPoint.fromJson(p as Map<String, dynamic>))
            .toList(),
        stats: TripStats.fromJson(json['stats'] as Map<String, dynamic>),
        isCompleted: json['isCompleted'] as bool? ?? true,
      );
}
