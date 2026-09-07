import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/trip.dart';

/// Storage service managing recorded & imported trips persistence and KML/GPX exports.
class StorageService {
  static const String _tripsStorageKey = 'zen_gps_trips_v1';
  static const String _importedTripsStorageKey = 'zen_imported_trips_v1';

  // --- RECORDED TRIPS BUCKET ---

  /// Save trip to recorded storage bucket
  Future<void> saveTrip(Trip trip) async {
    final trips = await loadAllTrips();
    final index = trips.indexWhere((t) => t.id == trip.id);
    if (index >= 0) {
      trips[index] = trip;
    } else {
      trips.insert(0, trip);
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonList = trips.map((t) => t.toJson()).toList();
    await prefs.setString(_tripsStorageKey, jsonEncode(jsonList));
  }

  /// Retrieve all recorded trips
  Future<List<Trip>> loadAllTrips() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_tripsStorageKey);
      if (rawJson == null || rawJson.isEmpty) return [];

      final List<dynamic> jsonList = jsonDecode(rawJson);
      return jsonList.map((j) => Trip.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error loading recorded trips: $e');
      return [];
    }
  }

  /// Delete recorded trip
  Future<void> deleteTrip(String tripId) async {
    final trips = await loadAllTrips();
    trips.removeWhere((t) => t.id == tripId);
    final prefs = await SharedPreferences.getInstance();
    final jsonList = trips.map((t) => t.toJson()).toList();
    await prefs.setString(_tripsStorageKey, jsonEncode(jsonList));
  }

  /// Clear all recorded trips
  Future<void> clearAllTrips() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tripsStorageKey);
  }

  // --- IMPORTED TRIPS BUCKET ---

  /// Save trip to dedicated [Imported Trips] storage bucket
  Future<void> saveImportedTrip(Trip trip) async {
    final trips = await loadAllImportedTrips();
    final index = trips.indexWhere((t) => t.id == trip.id);
    if (index >= 0) {
      trips[index] = trip;
    } else {
      trips.insert(0, trip);
    }

    final prefs = await SharedPreferences.getInstance();
    final jsonList = trips.map((t) => t.toJson()).toList();
    await prefs.setString(_importedTripsStorageKey, jsonEncode(jsonList));
  }

  /// Retrieve all imported trips
  Future<List<Trip>> loadAllImportedTrips() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_importedTripsStorageKey);
      if (rawJson == null || rawJson.isEmpty) return [];

      final List<dynamic> jsonList = jsonDecode(rawJson);
      return jsonList.map((j) => Trip.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error loading imported trips: $e');
      return [];
    }
  }

  /// Delete imported trip
  Future<void> deleteImportedTrip(String tripId) async {
    final trips = await loadAllImportedTrips();
    trips.removeWhere((t) => t.id == tripId);
    final prefs = await SharedPreferences.getInstance();
    final jsonList = trips.map((t) => t.toJson()).toList();
    await prefs.setString(_importedTripsStorageKey, jsonEncode(jsonList));
  }

  /// Clear all imported trips
  Future<void> clearAllImportedTrips() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_importedTripsStorageKey);
  }

  // --- FILE EXPORT & SHARING ---

  /// Save KML content to local file and return the file path
  Future<String> saveKmlFile({required String filename, required String kmlContent}) async {
    final dir = await getApplicationDocumentsDirectory();
    final sanitizeName = filename.replaceAll(RegExp(r'[^\w\s\.-]'), '_');
    final filePath = '${dir.path}/$sanitizeName.kml';
    final file = File(filePath);
    await file.writeAsString(kmlContent);
    return filePath;
  }

  /// Save GPX content to local file and return the file path
  Future<String> saveGpxFile({required String filename, required String gpxContent}) async {
    final dir = await getApplicationDocumentsDirectory();
    final sanitizeName = filename.replaceAll(RegExp(r'[^\w\s\.-]'), '_');
    final filePath = '${dir.path}/$sanitizeName.gpx';
    final file = File(filePath);
    await file.writeAsString(gpxContent);
    return filePath;
  }

  /// Share file via system share sheet
  Future<void> shareFile({
    required String filePath,
    required String mimeType,
    required String subject,
  }) async {
    final xFile = XFile(filePath, mimeType: mimeType);
    await Share.shareXFiles(
      [xFile],
      subject: subject,
      text: 'Exported track from Zen GPS Tracker.',
    );
  }
}
