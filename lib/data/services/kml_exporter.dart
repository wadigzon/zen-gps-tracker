import 'package:xml/xml.dart';
import '../../domain/models/trip.dart';

/// Exporter service to generate standard Google Earth KML XML formatted files.
class KmlExporter {
  /// Builds a standard Google Earth .kml XML document string from a [Trip]
  static String generateKml(Trip trip) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');

    builder.element('kml', attributes: {
      'xmlns': 'http://www.opengis.net/kml/2.2',
      'xmlns:gx': 'http://www.google.com/kml/ext/2.2',
      'xmlns:kml': 'http://www.opengis.net/kml/2.2',
      'xmlns:atom': 'http://www.w3.org/2005/Atom',
    }, nest: () {
      builder.element('Document', nest: () {
        // Document metadata
        builder.element('name', nest: trip.title);
        builder.element('description', nest: () {
          final desc = '''
Recorded with Zen GPS Tracker
----------------------------------
Distance: ${trip.stats.distanceKm.toStringAsFixed(2)} km (${trip.stats.distanceMiles.toStringAsFixed(2)} mi)
Active Duration: ${_formatDuration(trip.stats.activeDuration)}
Avg Speed: ${trip.stats.avgSpeedKmh.toStringAsFixed(1)} km/h (${trip.stats.avgSpeedMph.toStringAsFixed(1)} mph)
Max Speed: ${trip.stats.maxSpeedKmh.toStringAsFixed(1)} km/h (${trip.stats.maxSpeedMph.toStringAsFixed(1)} mph)
Elevation Gain: ${trip.stats.elevationGainMeters.toStringAsFixed(0)} m
Min/Max Altitude: ${trip.stats.minAltitudeMeters.toStringAsFixed(0)}m / ${trip.stats.maxAltitudeMeters.toStringAsFixed(0)}m
Start Time: ${trip.startTime.toUtc().toIso8601String()}
Points Recorded: ${trip.points.length}
''';
          builder.text(desc.trim());
        });

        // Track Line Style (KML color format is AABBGGRR)
        builder.element('Style', attributes: {'id': 'zenTrackStyle'}, nest: () {
          builder.element('LineStyle', nest: () {
            builder.element('color', nest: 'ff81b910'); // Emerald Green in KML AABBGGRR
            builder.element('width', nest: '5');
          });
          builder.element('PolyStyle', nest: () {
            builder.element('color', nest: '4d81b910');
          });
        });

        // Start Placemark Style
        builder.element('Style', attributes: {'id': 'startPinStyle'}, nest: () {
          builder.element('IconStyle', nest: () {
            builder.element('scale', nest: '1.2');
            builder.element('Icon', nest: () {
              builder.element('href', nest: 'http://maps.google.com/mapfiles/kml/paddle/grn-circle.png');
            });
          });
        });

        // Finish Placemark Style
        builder.element('Style', attributes: {'id': 'finishPinStyle'}, nest: () {
          builder.element('IconStyle', nest: () {
            builder.element('scale', nest: '1.2');
            builder.element('Icon', nest: () {
              builder.element('href', nest: 'http://maps.google.com/mapfiles/kml/paddle/red-square.png');
            });
          });
        });

        if (trip.points.isNotEmpty) {
          final firstPoint = trip.points.first;
          final lastPoint = trip.points.last;

          // Start Waypoint Placemark
          builder.element('Placemark', nest: () {
            builder.element('name', nest: 'Start: ${trip.title}');
            builder.element('styleUrl', nest: '#startPinStyle');
            builder.element('Point', nest: () {
              builder.element('coordinates', nest: firstPoint.toKmlCoordinate());
            });
          });

          // Finish Waypoint Placemark
          builder.element('Placemark', nest: () {
            builder.element('name', nest: 'Finish: ${trip.title}');
            builder.element('styleUrl', nest: '#finishPinStyle');
            builder.element('Point', nest: () {
              builder.element('coordinates', nest: lastPoint.toKmlCoordinate());
            });
          });

          // Route Path LineString Placemark
          builder.element('Placemark', nest: () {
            builder.element('name', nest: 'Track Path - ${trip.title}');
            builder.element('styleUrl', nest: '#zenTrackStyle');
            builder.element('LineString', nest: () {
              builder.element('extrude', nest: '1');
              builder.element('tessellate', nest: '1');
              builder.element('altitudeMode', nest: 'clampToGround');
              
              final coordsString = trip.points
                  .map((p) => p.toKmlCoordinate())
                  .join(' ');
              builder.element('coordinates', nest: coordsString);
            });
          });

          // Animated Google Earth gx:Track Placemark
          builder.element('Placemark', nest: () {
            builder.element('name', nest: 'Playback Track');
            builder.element('styleUrl', nest: '#zenTrackStyle');
            builder.element('gx:Track', nest: () {
              builder.element('altitudeMode', nest: 'clampToGround');
              for (final pt in trip.points) {
                builder.element('when', nest: pt.timestamp.toUtc().toIso8601String());
              }
              for (final pt in trip.points) {
                // gx:coord expects "longitude latitude altitude" space-separated
                builder.element('gx:coord', nest: '${pt.longitude} ${pt.latitude} ${pt.altitude}');
              }
            });
          });
        }
      });
    });

    final document = builder.buildDocument();
    return document.toXmlString(pretty: true, indent: '  ');
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = (duration.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
