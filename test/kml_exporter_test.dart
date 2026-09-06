import 'package:flutter_test/flutter_test.dart';
import 'package:zen_gps_tracker/data/services/kml_exporter.dart';
import 'package:zen_gps_tracker/data/services/gpx_exporter.dart';
import 'package:zen_gps_tracker/domain/models/gps_point.dart';
import 'package:zen_gps_tracker/domain/models/trip.dart';
import 'package:zen_gps_tracker/domain/models/trip_stats.dart';

void main() {
  group('KML & GPX Exporter Tests', () {
    final now = DateTime.utc(2026, 9, 6, 12, 0, 0);

    final points = [
      GpsPoint(
        latitude: 37.7749,
        longitude: -122.4194,
        altitude: 15.0,
        timestamp: now,
        speed: 1.5,
      ),
      GpsPoint(
        latitude: 37.7755,
        longitude: -122.4180,
        altitude: 22.0,
        timestamp: now.add(const Duration(minutes: 5)),
        speed: 1.8,
      ),
    ];

    final trip = Trip(
      id: 'test_trip_100',
      title: 'San Francisco Coastal Walk',
      description: 'Testing Google Earth KML output',
      startTime: now,
      endTime: now.add(const Duration(minutes: 5)),
      points: points,
      stats: TripStats.fromPoints(
        points,
        activeDuration: const Duration(minutes: 5),
        pausedDuration: Duration.zero,
      ),
      isCompleted: true,
    );

    test('generateKml creates valid KML XML string containing key tags', () {
      final kml = KmlExporter.generateKml(trip);

      expect(kml, contains('<?xml version="1.0" encoding="UTF-8"?>'));
      expect(kml, contains('<kml xmlns="http://www.opengis.net/kml/2.2"'));
      expect(kml, contains('<Document>'));
      expect(kml, contains('<name>San Francisco Coastal Walk</name>'));
      expect(kml, contains('<styleUrl>#zenTrackStyle</styleUrl>'));
      expect(kml, contains('<LineString>'));
      expect(kml, contains('-122.4194,37.7749,15.0'));
      expect(kml, contains('<gx:Track>'));
    });

    test('generateGpx creates valid GPX XML string containing key tags', () {
      final gpx = GpxExporter.generateGpx(trip);

      expect(gpx, contains('<?xml version="1.0" encoding="UTF-8"?>'));
      expect(gpx, contains('<gpx version="1.1" creator="Zen GPS Tracker"'));
      expect(gpx, contains('<name>San Francisco Coastal Walk</name>'));
      expect(gpx, contains('<trkpt lat="37.7749" lon="-122.4194">'));
      expect(gpx, contains('<ele>15.0</ele>'));
    });
  });
}
