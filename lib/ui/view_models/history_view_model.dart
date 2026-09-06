import 'package:flutter/foundation.dart';
import '../../data/services/gpx_exporter.dart';
import '../../data/services/kml_exporter.dart';
import '../../data/services/storage_service.dart';
import '../../domain/models/trip.dart';

/// View model managing recorded trips history list, deletion, and KML/GPX export.
class HistoryViewModel extends ChangeNotifier {
  final StorageService _storageService;

  List<Trip> _trips = [];
  List<Trip> get trips => List.unmodifiable(_trips);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _statusMessage;
  String? get statusMessage => _statusMessage;

  HistoryViewModel({required StorageService storageService})
      : _storageService = storageService {
    loadTrips();
  }

  Future<void> loadTrips() async {
    _isLoading = true;
    notifyListeners();

    try {
      _trips = await _storageService.loadAllTrips();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTrip(String tripId) async {
    await _storageService.deleteTrip(tripId);
    await loadTrips();
  }

  /// Export trip to .kml file and open share modal
  Future<void> exportKml(Trip trip) async {
    try {
      _statusMessage = 'Generating KML export...';
      notifyListeners();

      final kmlContent = KmlExporter.generateKml(trip);
      final filename = '${trip.title.replaceAll(' ', '_')}_${trip.id}';
      final filePath = await _storageService.saveKmlFile(
        filename: filename,
        kmlContent: kmlContent,
      );

      await _storageService.shareFile(
        filePath: filePath,
        mimeType: 'application/vnd.google-earth.kml+xml',
        subject: '${trip.title} (KML Google Earth Track)',
      );

      _statusMessage = 'KML exported successfully!';
    } catch (e) {
      _statusMessage = 'Failed to export KML: $e';
    } finally {
      notifyListeners();
    }
  }

  /// Export trip to .gpx file and open share modal
  Future<void> exportGpx(Trip trip) async {
    try {
      _statusMessage = 'Generating GPX export...';
      notifyListeners();

      final gpxContent = GpxExporter.generateGpx(trip);
      final filename = '${trip.title.replaceAll(' ', '_')}_${trip.id}';
      final filePath = await _storageService.saveGpxFile(
        filename: filename,
        gpxContent: gpxContent,
      );

      await _storageService.shareFile(
        filePath: filePath,
        mimeType: 'application/gpx+xml',
        subject: '${trip.title} (GPX Track)',
      );

      _statusMessage = 'GPX exported successfully!';
    } catch (e) {
      _statusMessage = 'Failed to export GPX: $e';
    } finally {
      notifyListeners();
    }
  }
}
