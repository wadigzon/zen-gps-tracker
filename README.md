# Zen GPS Tracker 🧭

A serene, high-performance cross-platform mobile application for **Apple iOS** and **Android** (also compatible with Web & Windows) built with **Flutter**. 

Zen GPS Tracker allows you to record your position in real-time as you embark on outdoor trips, walks, or hikes. You can pause and resume recording, view live distance, speed, and altitude metrics, and export completed trips into standard Google Earth compatible `.kml` files as well as `.gpx` format.

---

## ✨ Key Features

- **Real-Time GPS Tracking**: Precise position streaming with dynamic distance calculation (Haversine formula), current & average speed, min/max altitude, and elevation gain.
- **Recording Controls**: Start, Pause, Resume, Stop, and Save actions with an intuitive glassmorphic dashboard interface.
- **Built-in Demo GPS Simulator**: Toggle Demo mode on to simulate realistic walking/hiking routes without needing to move outdoors — perfect for quick testing on PC or simulator!
- **Google Earth `.kml` Export**: Generates standard Keyhole Markup Language (`.kml`) XML files featuring custom track line styling, `<Placemark>` start/finish markers, and animated Google Earth playback support (`<gx:Track>`).
- **Standard `.gpx` Export**: Exports standard GPS Exchange Format XML for broad compatibility with mapping and fitness apps.
- **3 Free Map Layers**:
  1. **Street Map** (OpenStreetMap)
  2. **Topo Terrain** (OpenTopoMap with contour lines)
  3. **Satellite View** (Esri World Imagery)
- **Dynamic Units Toggle**: Switch between **Metric (`km`, `km/h`, `m`)** and **Imperial (`miles`, `mph`, `ft`)** on the fly.
- **Trip History & Storage**: Local persistence using `SharedPreferences` with interactive map replay previews and one-tap KML/GPX file sharing via the system share sheet.

---

## 🛠️ Technology Stack & Architecture

- **Framework**: Flutter 3.47+ / Dart 3.13+
- **Map Visualization**: `flutter_map` & `latlong2`
- **Location Streaming**: `geolocator`
- **State Management**: `provider` (MVVM Architecture)
- **File Export & Sharing**: `xml`, `path_provider`, `share_plus`
- **Local Persistence**: `shared_preferences`

```text
lib/
├── data/
│   ├── services/
│   │   ├── location_service.dart      # Real GPS stream & Demo simulator
│   │   ├── kml_exporter.dart          # Google Earth KML XML generator
│   │   ├── gpx_exporter.dart          # GPX XML format generator
│   │   └── storage_service.dart       # Trip persistence & file sharing
├── domain/
│   ├── models/
│   │   ├── gps_point.dart             # Position model & Haversine distance
│   │   ├── trip.dart                  # Complete trip data model
│   │   └── trip_stats.dart            # Telemetry stats aggregator
├── ui/
│   ├── core/
│   │   ├── zen_colors.dart            # Zen color palette constants
│   │   └── glass_card.dart            # Glassmorphism card container
│   ├── view_models/
│   │   ├── tracking_view_model.dart   # Live tracking state & timer
│   │   ├── history_view_model.dart    # Saved trips & export triggers
│   │   └── settings_view_model.dart   # Unit & map layer preferences
│   └── features/
│       ├── tracking/
│       │   ├── tracking_screen.dart   # Main recording screen
│       │   ├── map_widget.dart        # Map polyline view
│       │   ├── stats_overlay.dart     # Live telemetry dashboard
│       │   ├── controls_panel.dart    # Start/Pause/Stop control bar
│       │   └── save_trip_dialog.dart  # Trip title & description modal
│       └── history/
│           ├── trip_history_screen.dart # List of saved trips & exports
│           └── trip_detail_screen.dart  # Trip detail & route map preview
```

---

## 🚀 How to Run Locally

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your system.

### Running in Chrome / Web (Instant Preview)
```bash
flutter run -d chrome
```

### Running on Android Device / Emulator
1. Connect your Android phone via USB (with **USB Debugging** enabled) or launch an Android Virtual Device.
2. Run:
```bash
flutter run -d android
```

### Running on iOS Device / Simulator (macOS)
```bash
flutter run -d ios
```

---

## 🧪 Running Unit Tests

To run the automated unit test suite for KML/GPX generation, Haversine distance math, and app components:

```bash
flutter test
```

---

## 📄 License & Sharing

This project is open-source and free to share, modify, or distribute.
