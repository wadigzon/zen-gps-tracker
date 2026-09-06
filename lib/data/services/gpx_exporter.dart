import 'package:xml/xml.dart';
import '../../domain/models/trip.dart';

/// Exporter service to generate standard GPX (GPS Exchange Format v1.1) XML files.
class GpxExporter {
  /// Builds a standard .gpx XML document string from a [Trip]
  static String generateGpx(Trip trip) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');

    builder.element('gpx', attributes: {
      'version': '1.1',
      'creator': 'Zen GPS Tracker',
      'xmlns': 'http://www.topografix.com/GPX/1/1',
      'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',
      'xsi:schemaLocation':
          'http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd',
    }, nest: () {
      // Metadata
      builder.element('metadata', nest: () {
        builder.element('name', nest: trip.title);
        builder.element('desc', nest: 'Recorded with Zen GPS Tracker');
        builder.element('time', nest: trip.startTime.toUtc().toIso8601String());
      });

      // Track
      builder.element('trk', nest: () {
        builder.element('name', nest: trip.title);
        if (trip.description != null && trip.description!.isNotEmpty) {
          builder.element('desc', nest: trip.description!);
        }

        // Track segment
        builder.element('trkseg', nest: () {
          for (final pt in trip.points) {
            builder.element('trkpt', attributes: {
              'lat': pt.latitude.toString(),
              'lon': pt.longitude.toString(),
            }, nest: () {
              builder.element('ele', nest: pt.altitude.toStringAsFixed(1));
              builder.element('time', nest: pt.timestamp.toUtc().toIso8601String());
              if (pt.speed > 0) {
                builder.element('speed', nest: pt.speed.toStringAsFixed(2));
              }
            });
          }
        });
      });
    });

    final document = builder.buildDocument();
    return document.toXmlString(pretty: true, indent: '  ');
  }
}
