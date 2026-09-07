import 'package:flutter_test/flutter_test.dart';
import 'package:zen_gps_tracker/data/services/gpx_parser.dart';
import 'package:zen_gps_tracker/data/services/kml_parser.dart';

void main() {
  group('KML & GPX Parser Tests', () {
    test('KmlParser successfully parses KML XML with coordinates', () {
      const kmlXml = '''<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2">
  <Document>
    <name>Imported Mountain Hike</name>
    <Placemark>
      <LineString>
        <coordinates>
          -119.5936,37.7459,1200 -119.5930,37.7465,1220 -119.5920,37.7470,1240
        </coordinates>
      </LineString>
    </Placemark>
  </Document>
</kml>''';

      final trip = KmlParser.parseKml(kmlXml, fallbackTitle: 'Fallback Hike');

      expect(trip.title, equals('Imported Mountain Hike'));
      expect(trip.points.length, equals(3));
      expect(trip.points.first.latitude, equals(37.7459));
      expect(trip.points.first.longitude, equals(-119.5936));
      expect(trip.points.first.altitude, equals(1200.0));
      expect(trip.stats.totalDistanceMeters, greaterThan(0));
    });

    test('GpxParser successfully parses GPX XML with trkpt elements', () {
      const gpxXml = '''<?xml version="1.0" encoding="UTF-8"?>
<gpx version="1.1" creator="Test">
  <trk>
    <name>Imported Bike Route</name>
    <trkseg>
      <trkpt lat="37.7749" lon="-122.4194">
        <ele>15.0</ele>
        <time>2026-09-06T10:00:00Z</time>
      </trkpt>
      <trkpt lat="37.7755" lon="-122.4180">
        <ele>20.0</ele>
        <time>2026-09-06T10:05:00Z</time>
      </trkpt>
    </trkseg>
  </trk>
</gpx>''';

      final trip = GpxParser.parseGpx(gpxXml, fallbackTitle: 'Fallback Route');

      expect(trip.title, equals('Imported Bike Route'));
      expect(trip.points.length, equals(2));
      expect(trip.points.first.latitude, equals(37.7749));
      expect(trip.points.first.longitude, equals(-122.4194));
      expect(trip.points.first.altitude, equals(15.0));
    });
  });
}
