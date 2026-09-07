import 'package:xml/xml.dart';
import '../../domain/models/gps_point.dart';
import '../../domain/models/trip.dart';
import '../../domain/models/trip_stats.dart';

/// Service to parse Google Earth KML files into clean [Trip] domain models.
class KmlParser {
  /// Parses KML string content into a [Trip]
  static Trip parseKml(String xmlContent, {required String fallbackTitle}) {
    final document = XmlDocument.parse(xmlContent);

    // Extract Trip Title from <name> or fallback
    String title = fallbackTitle;
    final nameElements = document.findAllElements('name');
    if (nameElements.isNotEmpty) {
      final text = nameElements.first.innerText.trim();
      if (text.isNotEmpty) {
        title = text;
      }
    }

    final points = <GpsPoint>[];
    DateTime now = DateTime.now();

    // 1. Try gx:Track format (timestamped coordinates)
    final gxTracks = document.findAllElements('gx:Track');
    if (gxTracks.isNotEmpty) {
      final whens = gxTracks.first.findElements('when').map((e) => e.innerText.trim()).toList();
      final coords = gxTracks.first.findElements('gx:coord').map((e) => e.innerText.trim()).toList();

      for (int i = 0; i < coords.length; i++) {
        final parts = coords[i].split(RegExp(r'\s+'));
        if (parts.length >= 2) {
          final lng = double.parse(parts[0]);
          final lat = double.parse(parts[1]);
          final alt = parts.length >= 3 ? double.parse(parts[2]) : 0.0;
          final time = i < whens.length ? DateTime.tryParse(whens[i]) ?? now : now;

          points.add(GpsPoint(
            latitude: lat,
            longitude: lng,
            altitude: alt,
            timestamp: time,
          ));
        }
      }
    }

    // 2. Fallback to LineString <coordinates> if no gx:Track
    if (points.isEmpty) {
      final coordElements = document.findAllElements('coordinates');
      for (final elem in coordElements) {
        final rawCoords = elem.innerText.trim();
        final rawTuples = rawCoords.split(RegExp(r'\s+'));

        for (int i = 0; i < rawTuples.length; i++) {
          final tuple = rawTuples[i].split(',');
          if (tuple.length >= 2) {
            try {
              final lng = double.parse(tuple[0].trim());
              final lat = double.parse(tuple[1].trim());
              final alt = tuple.length >= 3 ? double.parse(tuple[2].trim()) : 0.0;
              final ptTime = now.add(Duration(seconds: i * 2));

              points.add(GpsPoint(
                latitude: lat,
                longitude: lng,
                altitude: alt,
                timestamp: ptTime,
              ));
            } catch (_) {
              // Ignore invalid coordinate pairs
            }
          }
        }
        if (points.isNotEmpty) break;
      }
    }

    final startTime = points.isNotEmpty ? points.first.timestamp : now;
    final endTime = points.isNotEmpty ? points.last.timestamp : now;
    final activeDuration = endTime.difference(startTime).abs();

    final stats = TripStats.fromPoints(
      points,
      activeDuration: activeDuration == Duration.zero ? const Duration(minutes: 10) : activeDuration,
      pausedDuration: Duration.zero,
    );

    return Trip(
      id: 'imported_kml_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: 'Imported from KML file',
      startTime: startTime,
      endTime: endTime,
      points: points,
      stats: stats,
      isCompleted: true,
    );
  }
}
