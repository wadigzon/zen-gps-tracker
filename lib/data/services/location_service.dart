import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/models/gps_point.dart';

/// Location service responsible for real device GPS streaming & simulation mode.
class LocationService {
  StreamSubscription<Position>? _positionSubscription;
  Timer? _simulationTimer;
  bool _isSimulating = false;

  bool get isSimulating => _isSimulating;

  /// Check if location services are enabled on device
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check and request location permission
  Future<LocationPermission> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission;
  }

  /// Get current one-time position (requests permission if needed)
  Future<GpsPoint?> getCurrentPosition({bool forceReal = false}) async {
    if (_isSimulating && !forceReal) {
      return _getSimulatedInitialPoint();
    }

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );

      return GpsPoint(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        timestamp: position.timestamp,
        speed: position.speed,
        accuracy: position.accuracy,
        heading: position.heading,
      );
    } catch (e) {
      // Fall back gracefully if GPS signal or browser permission denied
      return null;
    }
  }

  /// Starts location stream with high frequency 1-second continuous GPS polling
  void startLocationStream({
    required void Function(GpsPoint point) onPointReceived,
    required void Function(Object error) onError,
    bool simulate = false,
  }) {
    stopLocationStream();
    _isSimulating = simulate;

    if (simulate) {
      _startSimulatedStream(onPointReceived);
    } else {
      late LocationSettings locationSettings;

      if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
        locationSettings = AndroidSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 1, // Report every 1 meter movement
          intervalDuration: const Duration(seconds: 1), // Poll every 1 second
          forceLocationManager: true, // Force raw hardware GPS provider
          foregroundNotificationConfig: const ForegroundNotificationConfig(
            notificationTitle: "Zen GPS Tracker Active",
            notificationText: "Recording trip in background...",
            notificationIcon: AndroidResource(name: 'ic_launcher', defType: 'mipmap'),
            enableWakeLock: true,
          ),
        );
      } else if (!kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.iOS ||
              defaultTargetPlatform == TargetPlatform.macOS)) {
        locationSettings = AppleSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          activityType: ActivityType.fitness,
          distanceFilter: 1,
          pauseLocationUpdatesAutomatically: false,
        );
      } else {
        locationSettings = const LocationSettings(
          accuracy: LocationAccuracy.bestForNavigation,
          distanceFilter: 1,
        );
      }

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (position) {
          final point = GpsPoint(
            latitude: position.latitude,
            longitude: position.longitude,
            altitude: position.altitude,
            timestamp: position.timestamp,
            speed: position.speed,
            accuracy: position.accuracy,
            heading: position.heading,
          );
          onPointReceived(point);
        },
        onError: onError,
      );
    }
  }

  /// Stops current location stream
  void stopLocationStream() {
    _positionSubscription?.cancel();
    _positionSubscription = null;
    _simulationTimer?.cancel();
    _simulationTimer = null;
  }

  // --- SIMULATION ROUTE GENERATOR ---

  // Default scenic route starting point: Yosemite Emerald Trail (Latitude 37.7459, Longitude -119.5936)
  double _simLat = 37.7459;
  double _simLng = -119.5936;
  double _simAlt = 1220.0;
  double _simHeading = 45.0; // degrees
  int _simStep = 0;

  GpsPoint _getSimulatedInitialPoint() {
    return GpsPoint(
      latitude: _simLat,
      longitude: _simLng,
      altitude: _simAlt,
      timestamp: DateTime.now(),
      speed: 1.4, // ~5 km/h walking speed
      accuracy: 3.5,
      heading: _simHeading,
    );
  }

  void _startSimulatedStream(void Function(GpsPoint point) onPointReceived) {
    // Send initial point
    onPointReceived(_getSimulatedInitialPoint());

    _simulationTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _simStep++;

      // Curve route slightly every 10 steps to simulate natural hiking paths
      final angleDelta = (sin(_simStep * 0.3) * 0.15);
      final headingRad = (_simHeading * pi / 180.0) + angleDelta;
      _simHeading = (headingRad * 180.0 / pi) % 360.0;

      // Move forward ~ 2.5 - 3.5 meters every 2 seconds (~ 4.5 - 6.0 km/h)
      final stepDistanceDeg = 0.000028 + (Random().nextDouble() * 0.000008);
      _simLat += stepDistanceDeg * cos(headingRad);
      _simLng += stepDistanceDeg * sin(headingRad) / cos(_simLat * pi / 180.0);

      // Gentle elevation changes
      _simAlt += (sin(_simStep * 0.2) * 1.8) + (Random().nextDouble() * 0.5 - 0.2);

      final currentSpeed = 1.3 + (Random().nextDouble() * 0.4); // ~ 4.7 - 6.1 km/h

      final point = GpsPoint(
        latitude: _simLat,
        longitude: _simLng,
        altitude: _simAlt,
        timestamp: DateTime.now(),
        speed: currentSpeed,
        accuracy: 2.5 + (Random().nextDouble() * 1.5),
        heading: _simHeading,
      );

      onPointReceived(point);
    });
  }
}
