import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/trip.dart';

/// Storage service managing trip persistence and KML/GPX file exports/sharing.
class StorageService {
  static const String _tripsStorageKey = 'zen_gps_trips_v1';

  /// Save trip to persistent storage
  Future<void> saveTrip(Trip trip) async {
    final trips = await loadAllTrips();

    // Replace if existing, or add to start
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
      if (rawJson == null || rawJson.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = jsonDecode(rawJson);
      return jsonList.map((j) => Trip.fromJson(j as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('Error loading trips from storage: $e');
      return [];
    }
  }

  /// Delete trip by ID
  Future<void> deleteTrip(String tripId) async {
    final trips = await loadAllTrips();
    trips.removeWhere((t) => t.id == tripId);

    final prefs = await SharedPreferences.getInstance();
    final jsonList = trips.map((t) => t.toJson()).toList();
    await prefs.setString(_tripsStorageKey, jsonEncode(jsonList));
  }

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
