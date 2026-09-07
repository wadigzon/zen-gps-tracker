import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import '../../data/services/gpx_exporter.dart';
import '../../data/services/gpx_parser.dart';
import '../../data/services/kml_exporter.dart';
import '../../data/services/kml_parser.dart';
import '../../data/services/storage_service.dart';
import '../../domain/models/trip.dart';

/// View model managing recorded & imported trips history buckets and file imports.
class HistoryViewModel extends ChangeNotifier {
  final StorageService _storageService;

  List<Trip> _recordedTrips = [];
  List<Trip> get recordedTrips => List.unmodifiable(_recordedTrips);

  List<Trip> _importedTrips = [];
  List<Trip> get importedTrips => List.unmodifiable(_importedTrips);

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
      _recordedTrips = await _storageService.loadAllTrips();
      _importedTrips = await _storageService.loadAllImportedTrips();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTrip(String tripId, {bool isImported = false}) async {
    if (isImported) {
      await _storageService.deleteImportedTrip(tripId);
    } else {
      await _storageService.deleteTrip(tripId);
    }
    await loadTrips();
  }

  /// Pick & import a .kml or .gpx file from device storage into [Imported Trips] bucket
  Future<Trip?> importFileFromDevice() async {
    try {
      _statusMessage = 'Selecting file...';
      notifyListeners();

      final List<PlatformFile> files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['kml', 'gpx', 'xml'],
      );

      if (files.isEmpty) {
        _statusMessage = null;
        notifyListeners();
        return null;
      }

      final file = files.first;
      String content = '';

      final bytes = await file.readAsBytes();
      if (bytes.isNotEmpty) {
        content = utf8.decode(bytes);
      } else if (file.path != null) {
        content = await File(file.path!).readAsString();
      }

      if (content.isEmpty) {
        _statusMessage = 'File is empty or could not be read.';
        notifyListeners();
        return null;
      }

      final fileName = file.name;
      final extension = fileName.split('.').last.toLowerCase();

      Trip importedTrip;
      if (extension == 'gpx') {
        importedTrip = GpxParser.parseGpx(content, fallbackTitle: fileName);
      } else {
        // Default to KML parser
        importedTrip = KmlParser.parseKml(content, fallbackTitle: fileName);
      }

      await _storageService.saveImportedTrip(importedTrip);
      await loadTrips();

      _statusMessage = 'Successfully imported "${importedTrip.title}"!';
      notifyListeners();
      return importedTrip;
    } catch (e) {
      _statusMessage = 'Failed to import file: $e';
      notifyListeners();
      return null;
    }
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
