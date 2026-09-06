import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SpeedUnitSystem { metric, imperial }

enum MapTileType { openStreetMap, openTopoMap, esriSatellite }

/// View model to handle app settings like units, map layers, and simulation mode.
class SettingsViewModel extends ChangeNotifier {
  static const String _unitKey = 'zen_setting_units';
  static const String _mapTileKey = 'zen_setting_map_tile';

  SpeedUnitSystem _unitSystem = SpeedUnitSystem.metric;
  MapTileType _mapTileType = MapTileType.openStreetMap;
  bool _useSimulationMode = false;

  SpeedUnitSystem get unitSystem => _unitSystem;
  MapTileType get mapTileType => _mapTileType;
  bool get useSimulationMode => _useSimulationMode;

  bool get isMetric => _unitSystem == SpeedUnitSystem.metric;

  SettingsViewModel() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final unitString = prefs.getString(_unitKey);
    if (unitString != null) {
      _unitSystem = unitString == 'imperial'
          ? SpeedUnitSystem.imperial
          : SpeedUnitSystem.metric;
    }

    final tileString = prefs.getString(_mapTileKey);
    if (tileString != null) {
      if (tileString == 'topo') {
        _mapTileType = MapTileType.openTopoMap;
      } else if (tileString == 'satellite') {
        _mapTileType = MapTileType.esriSatellite;
      } else {
        _mapTileType = MapTileType.openStreetMap;
      }
    }

    notifyListeners();
  }

  Future<void> setUnitSystem(SpeedUnitSystem unit) async {
    _unitSystem = unit;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _unitKey,
      unit == SpeedUnitSystem.imperial ? 'imperial' : 'metric',
    );
  }

  Future<void> setMapTileType(MapTileType tile) async {
    _mapTileType = tile;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    String tileStr = 'osm';
    if (tile == MapTileType.openTopoMap) tileStr = 'topo';
    if (tile == MapTileType.esriSatellite) tileStr = 'satellite';
    await prefs.setString(_mapTileKey, tileStr);
  }

  void setSimulationMode(bool value) {
    _useSimulationMode = value;
    notifyListeners();
  }

  void toggleUnits() {
    setUnitSystem(isMetric ? SpeedUnitSystem.imperial : SpeedUnitSystem.metric);
  }
}
