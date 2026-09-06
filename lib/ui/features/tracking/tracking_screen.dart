import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/zen_colors.dart';
import '../../view_models/history_view_model.dart';
import '../../view_models/settings_view_model.dart';
import '../../view_models/tracking_view_model.dart';
import '../history/trip_history_screen.dart';
import 'controls_panel.dart';
import 'map_widget.dart';
import 'save_trip_dialog.dart';
import 'stats_overlay.dart';

/// Main interactive screen for recording GPS position in real-time.
class TrackingScreen extends StatelessWidget {
  const TrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final trackingVM = context.watch<TrackingViewModel>();
    final settingsVM = context.watch<SettingsViewModel>();
    final historyVM = context.watch<HistoryViewModel>();

    return Scaffold(
      backgroundColor: ZenColors.background,
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            // 1. Interactive Map View Background
            MapWidget(
              points: trackingVM.points,
              currentPosition: trackingVM.currentPosition,
              mapTileType: settingsVM.mapTileType,
              isTracking: trackingVM.isRecording,
            ),

            // 2. Top Header Bar
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  // App Title Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: ZenColors.glassBackground,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: ZenColors.glassBorder),
                      boxShadow: const [
                        BoxShadow(color: Colors.black26, blurRadius: 8)
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_on, color: ZenColors.emeraldPrimary, size: 20),
                        SizedBox(width: 6),
                        Text(
                          'ZEN GPS',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                            color: ZenColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),

                  // Unit System Toggle Button (km vs mi)
                  InkWell(
                    onTap: settingsVM.toggleUnits,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: ZenColors.glassBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ZenColors.glassBorder),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.swap_horiz_rounded, size: 16, color: ZenColors.cyanAccent),
                          const SizedBox(width: 4),
                          Text(
                            settingsVM.isMetric ? 'KM' : 'MI',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: ZenColors.cyanAccent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Map Layer Selector (Street, Topo, Satellite)
                  PopupMenuButton<MapTileType>(
                    initialValue: settingsVM.mapTileType,
                    onSelected: settingsVM.setMapTileType,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    color: ZenColors.surface,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: ZenColors.glassBackground,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ZenColors.glassBorder),
                      ),
                      child: const Icon(Icons.layers_outlined, color: ZenColors.textPrimary, size: 20),
                    ),
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: MapTileType.openStreetMap,
                        child: Row(
                          children: [
                            Icon(Icons.map_outlined, color: ZenColors.emeraldLight, size: 18),
                            SizedBox(width: 8),
                            Text('Street Map', style: TextStyle(color: ZenColors.textPrimary)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: MapTileType.openTopoMap,
                        child: Row(
                          children: [
                            Icon(Icons.terrain, color: ZenColors.goldAccent, size: 18),
                            SizedBox(width: 8),
                            Text('Topo Terrain', style: TextStyle(color: ZenColors.textPrimary)),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: MapTileType.esriSatellite,
                        child: Row(
                          children: [
                            Icon(Icons.satellite_alt_outlined, color: ZenColors.cyanAccent, size: 18),
                            SizedBox(width: 8),
                            Text('Satellite View', style: TextStyle(color: ZenColors.textPrimary)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 8),

                  // Saved Trips History Button
                  IconButton.filledTonal(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TripHistoryScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.history_rounded, size: 20),
                    style: IconButton.styleFrom(
                      backgroundColor: ZenColors.glassBackground,
                      foregroundColor: ZenColors.textPrimary,
                      side: const BorderSide(color: ZenColors.glassBorder),
                    ),
                  ),
                ],
              ),
            ),

            // Error Banner
            if (trackingVM.errorMessage != null)
              Positioned(
                top: MediaQuery.of(context).padding.top + 60,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: ZenColors.roseStop.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          trackingVM.errorMessage!,
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // 3. Floating Stats & Control Dashboards at Bottom
            Positioned(
              left: 16,
              right: 16,
              bottom: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Live Telemetry Stats Dashboard
                  StatsOverlay(
                    stats: trackingVM.liveStats,
                    state: trackingVM.state,
                    isMetric: settingsVM.isMetric,
                  ),
                  const SizedBox(height: 12),

                  // Control Action Panel (Start / Pause / Resume / Stop)
                  ControlsPanel(
                    state: trackingVM.state,
                    isSimulating: settingsVM.useSimulationMode,
                    onStart: () {
                      trackingVM.startRecording(
                        simulate: settingsVM.useSimulationMode,
                      );
                    },
                    onPause: trackingVM.pauseRecording,
                    onResume: () {
                      trackingVM.resumeRecording(
                        simulate: settingsVM.useSimulationMode,
                      );
                    },
                    onStop: trackingVM.stopRecording,
                    onDiscard: trackingVM.reset,
                    onToggleSimulation: (val) {
                      settingsVM.setSimulationMode(val);
                      if (!val) {
                        trackingVM.fetchCurrentLocation(forceReal: true);
                      }
                    },
                    onSave: () {
                      final now = DateTime.now();
                      final defaultTitle = 'Zen Hike ${now.month}/${now.day}/${now.year}';
                      showDialog(
                        context: context,
                        builder: (context) => SaveTripDialog(
                          defaultTitle: defaultTitle,
                          onSave: (title, desc) async {
                            final savedTrip = await trackingVM.saveTrip(
                              title: title,
                              description: desc,
                            );
                            if (savedTrip != null) {
                              await historyVM.loadTrips();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Trip "${savedTrip.title}" saved!'),
                                    backgroundColor: ZenColors.emeraldPrimary,
                                    action: SnackBarAction(
                                      label: 'EXPORT KML',
                                      textColor: Colors.white,
                                      onPressed: () => historyVM.exportKml(savedTrip),
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
