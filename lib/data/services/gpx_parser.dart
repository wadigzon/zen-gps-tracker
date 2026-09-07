import 'package:xml/xml.dart';
import '../../domain/models/gps_point.dart';
import '../../domain/models/trip.dart';
import '../../domain/models/trip_stats.dart';

/// Service to parse GPX files into clean [Trip] domain models.
class GpxParser {
  /// Parses GPX string content into a [Trip]
  static Trip parseGpx(String xmlContent, {required String fallbackTitle}) {
    final document = XmlDocument.parse(xmlContent);

    // Extract Title
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

    final trkptElements = document.findAllElements('trkpt');
    int idx = 0;
    for (final elem in trkptElements) {
      final latAttr = elem.getAttribute('lat');
      final lonAttr = elem.getAttribute('lon');

      if (latAttr != null && lonAttr != null) {
        final lat = double.parse(latAttr);
        final lon = double.parse(lonAttr);

        double alt = 0.0;
        final eleElems = elem.findElements('ele');
        if (eleElems.isNotEmpty) {
          alt = double.tryParse(eleElems.first.innerText.trim()) ?? 0.0;
        }

        DateTime time = now.add(Duration(seconds: idx * 2));
        final timeElems = elem.findElements('time');
        if (timeElems.isNotEmpty) {
          time = DateTime.tryParse(timeElems.first.innerText.trim()) ?? time;
        }

        double speed = 0.0;
        final speedElems = elem.findElements('speed');
        if (speedElems.isNotEmpty) {
          speed = double.tryParse(speedElems.first.innerText.trim()) ?? 0.0;
        }

        points.add(GpsPoint(
          latitude: lat,
          longitude: lon,
          altitude: alt,
          timestamp: time,
          speed: speed,
        ));
        idx++;
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
      id: 'imported_gpx_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      description: 'Imported from GPX file',
      startTime: startTime,
      endTime: endTime,
      points: points,
      stats: stats,
      isCompleted: true,
    );
  }
}
