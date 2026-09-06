import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/trip.dart';
import '../../core/glass_card.dart';
import '../../core/zen_colors.dart';
import '../../view_models/history_view_model.dart';
import '../../view_models/settings_view_model.dart';
import '../tracking/map_widget.dart';

/// Detailed view of a recorded trip featuring map track preview and export capabilities.
class TripDetailScreen extends StatelessWidget {
  final Trip trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    final historyVM = context.watch<HistoryViewModel>();
    final settingsVM = context.watch<SettingsViewModel>();
    final isMetric = settingsVM.isMetric;

    final dateFormat = DateFormat('EEEE, MMMM d, yyyy • h:mm a');
    final formattedDate = dateFormat.format(trip.startTime);

    final distVal = isMetric ? trip.stats.distanceKm : trip.stats.distanceMiles;
    final distUnit = isMetric ? 'km' : 'mi';

    final avgSpeed = isMetric ? trip.stats.avgSpeedKmh : trip.stats.avgSpeedMph;
    final maxSpeed = isMetric ? trip.stats.maxSpeedKmh : trip.stats.maxSpeedMph;
    final speedUnit = isMetric ? 'km/h' : 'mph';

    final elevGain = isMetric
        ? trip.stats.elevationGainMeters
        : (trip.stats.elevationGainMeters * 3.28084);
    final minAlt = isMetric
        ? trip.stats.minAltitudeMeters
        : (trip.stats.minAltitudeMeters * 3.28084);
    final maxAlt = isMetric
        ? trip.stats.maxAltitudeMeters
        : (trip.stats.maxAltitudeMeters * 3.28084);
    final altUnit = isMetric ? 'm' : 'ft';

    return Scaffold(
      backgroundColor: ZenColors.background,
      appBar: AppBar(
        backgroundColor: ZenColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ZenColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          trip.title,
          style: const TextStyle(
            color: ZenColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.public, color: ZenColors.emeraldPrimary),
            tooltip: 'Export .KML (Google Earth)',
            onPressed: () => historyVM.exportKml(trip),
          ),
          IconButton(
            icon: const Icon(Icons.share_rounded, color: ZenColors.cyanAccent),
            tooltip: 'Export .GPX',
            onPressed: () => historyVM.exportGpx(trip),
          ),
        ],
      ),
      body: Column(
        children: [
          // Interactive Route Map
          Expanded(
            flex: 4,
            child: MapWidget(
              points: trip.points,
              mapTileType: settingsVM.mapTileType,
            ),
          ),

          // Trip Details & Stats Panel
          Expanded(
            flex: 5,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formattedDate,
                    style: const TextStyle(fontSize: 12, color: ZenColors.textSecondary),
                  ),
                  if (trip.description != null && trip.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      trip.description!,
                      style: const TextStyle(fontSize: 14, color: ZenColors.textPrimary),
                    ),
                  ],
                  const SizedBox(height: 16),

                  // Distance & Duration Header Card
                  GlassCard(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBigStat(
                          label: 'TOTAL DISTANCE',
                          value: distVal.toStringAsFixed(2),
                          unit: distUnit,
                          color: ZenColors.emeraldLight,
                        ),
                        Container(width: 1, height: 40, color: ZenColors.glassBorder),
                        _buildBigStat(
                          label: 'ACTIVE DURATION',
                          value: _formatDuration(trip.stats.activeDuration),
                          unit: '',
                          color: ZenColors.textPrimary,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Detailed Telemetry Metrics Grid
                  GlassCard(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildGridStat('AVG SPEED', '${avgSpeed.toStringAsFixed(1)} $speedUnit', Icons.speed),
                            _buildGridStat('MAX SPEED', '${maxSpeed.toStringAsFixed(1)} $speedUnit', Icons.directions_run),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: ZenColors.glassBorder, height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildGridStat('ELEVATION GAIN', '${elevGain.toStringAsFixed(0)} $altUnit', Icons.terrain),
                            _buildGridStat('ALT RANGE', '${minAlt.toStringAsFixed(0)} - ${maxAlt.toStringAsFixed(0)} $altUnit', Icons.height),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Export Action Bar
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => historyVM.exportKml(trip),
                          icon: const Icon(Icons.public_rounded, size: 20),
                          label: const Text('EXPORT KML (Google Earth)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ZenColors.emeraldPrimary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => historyVM.exportGpx(trip),
                          icon: const Icon(Icons.download_rounded, size: 20),
                          label: const Text('EXPORT GPX'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ZenColors.cyanAccent,
                            side: const BorderSide(color: ZenColors.cyanAccent),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBigStat({
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: ZenColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(fontSize: 12, color: ZenColors.textSecondary),
              ),
            ]
          ],
        ),
      ],
    );
  }

  Widget _buildGridStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: ZenColors.textSecondary),
              const SizedBox(width: 4),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: ZenColors.textSecondary,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: ZenColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }
}
