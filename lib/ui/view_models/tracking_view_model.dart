import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../data/services/location_service.dart';
import '../../data/services/storage_service.dart';
import '../../domain/models/gps_point.dart';
import '../../domain/models/trip.dart';
import '../../domain/models/trip_stats.dart';

enum TrackingState { idle, recording, paused, stopped }

/// View model managing active GPS location tracking, pause/resume, timer & stats.
class TrackingViewModel extends ChangeNotifier {
  final LocationService _locationService;
  final StorageService _storageService;

  TrackingState _state = TrackingState.idle;
  TrackingState get state => _state;

  bool get isIdle => _state == TrackingState.idle;
  bool get isRecording => _state == TrackingState.recording;
  bool get isPaused => _state == TrackingState.paused;
  bool get isStopped => _state == TrackingState.stopped;

  GpsPoint? _currentPosition;
  GpsPoint? get currentPosition => _currentPosition;

  final List<GpsPoint> _points = [];
  List<GpsPoint> get points => List.unmodifiable(_points);

  DateTime? _startTime;
  DateTime? get startTime => _startTime;

  DateTime? _endTime;
  DateTime? get endTime => _endTime;

  Duration _activeDuration = Duration.zero;
  Duration get activeDuration => _activeDuration;

  Duration _pausedDuration = Duration.zero;
  Duration get pausedDuration => _pausedDuration;

  Timer? _timer;
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  TripStats _liveStats = const TripStats();
  TripStats get liveStats => _liveStats;

  TrackingViewModel({
    required LocationService locationService,
    required StorageService storageService,
  })  : _locationService = locationService,
        _storageService = storageService {
    fetchCurrentLocation();
  }

  /// Request location permission & fetch current position
  Future<void> fetchCurrentLocation({bool forceReal = false}) async {
    final pos = await _locationService.getCurrentPosition(forceReal: forceReal);
    if (pos != null) {
      _currentPosition = pos;
      notifyListeners();
    }
  }

  /// Start recording trip
  Future<void> startRecording({bool simulate = false}) async {
    _errorMessage = null;

    if (!simulate) {
      final permission = await _locationService.checkAndRequestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        _errorMessage = 'Location permission is required to record GPS trips.';
        notifyListeners();
        return;
      }

      final enabled = await _locationService.isLocationServiceEnabled();
      if (!enabled) {
        _errorMessage = 'Please enable device GPS / Location services.';
        notifyListeners();
        return;
      }
    }

    _state = TrackingState.recording;
    _points.clear();
    _startTime = DateTime.now();
    _endTime = null;
    _activeDuration = Duration.zero;
    _pausedDuration = Duration.zero;
    _liveStats = const TripStats();

    _startTimer();
    _startLocationStream(simulate: simulate);
    notifyListeners();
  }

  /// Pause current trip
  void pauseRecording() {
    if (_state != TrackingState.recording) return;
    _state = TrackingState.paused;
    _timer?.cancel();
    notifyListeners();
  }

  /// Resume current trip
  void resumeRecording({bool simulate = false}) {
    if (_state != TrackingState.paused) return;
    _state = TrackingState.recording;
    _startTimer();
    notifyListeners();
  }

  /// Stop current trip recording
  void stopRecording() {
    if (_state == TrackingState.idle || _state == TrackingState.stopped) return;
    _state = TrackingState.stopped;
    _endTime = DateTime.now();
    _timer?.cancel();
    _locationService.stopLocationStream();
    _recalculateStats();
    notifyListeners();
  }

  /// Reset to idle state
  void reset() {
    _state = TrackingState.idle;
    _points.clear();
    _activeDuration = Duration.zero;
    _pausedDuration = Duration.zero;
    _liveStats = const TripStats();
    _startTime = null;
    _endTime = null;
    _locationService.stopLocationStream();
    fetchCurrentLocation();
    notifyListeners();
  }

  /// Save current recorded trip to storage
  Future<Trip?> saveTrip({required String title, String? description}) async {
    if (_points.isEmpty || _startTime == null) return null;

    final trip = Trip(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.trim().isEmpty ? 'Zen Hike ${_formatDate(_startTime!)}' : title,
      description: description,
      startTime: _startTime!,
      endTime: _endTime ?? DateTime.now(),
      points: List.from(_points),
      stats: _liveStats,
      isCompleted: true,
    );

    await _storageService.saveTrip(trip);
    reset();
    return trip;
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_state == TrackingState.recording) {
        _activeDuration += const Duration(seconds: 1);
        _recalculateStats();
      } else if (_state == TrackingState.paused) {
        _pausedDuration += const Duration(seconds: 1);
      }
      notifyListeners();
    });
  }

  void _startLocationStream({required bool simulate}) {
    _locationService.startLocationStream(
      simulate: simulate,
      onPointReceived: (point) {
        _currentPosition = point;
        if (_state == TrackingState.recording) {
          _points.add(point);
          _recalculateStats();
        }
        notifyListeners();
      },
      onError: (err) {
        _errorMessage = 'GPS Error: $err';
        notifyListeners();
      },
    );
  }

  void _recalculateStats() {
    _liveStats = TripStats.fromPoints(
      _points,
      activeDuration: _activeDuration,
      pausedDuration: _pausedDuration,
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.month}/${dt.day}/${dt.year}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    _locationService.stopLocationStream();
    super.dispose();
  }
}
