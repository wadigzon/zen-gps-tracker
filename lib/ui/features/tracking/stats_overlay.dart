import 'package:flutter/material.dart';
import '../../../domain/models/trip_stats.dart';
import '../../core/glass_card.dart';
import '../../core/zen_colors.dart';
import '../../view_models/tracking_view_model.dart';

/// Floating telemetry dashboard overlay displaying live duration, distance, speed, and altitude.
class StatsOverlay extends StatelessWidget {
  final TripStats stats;
  final TrackingState state;
  final bool isMetric;

  const StatsOverlay({
    super.key,
    required this.stats,
    required this.state,
    required this.isMetric,
  });

  String _formatDuration(Duration d) {
    final hours = d.inHours.toString().padLeft(2, '0');
    final minutes = (d.inMinutes % 60).toString().padLeft(2, '0');
    final seconds = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final distanceVal = isMetric
        ? stats.distanceKm.toStringAsFixed(2)
        : stats.distanceMiles.toStringAsFixed(2);
    final distanceUnit = isMetric ? 'km' : 'mi';

    final speedVal = isMetric
        ? stats.avgSpeedKmh.toStringAsFixed(1)
        : stats.avgSpeedMph.toStringAsFixed(1);
    final speedUnit = isMetric ? 'km/h' : 'mph';

    final elevationVal = isMetric
        ? stats.elevationGainMeters.toStringAsFixed(0)
        : (stats.elevationGainMeters * 3.28084).toStringAsFixed(0);
    final elevationUnit = isMetric ? 'm' : 'ft';

    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // State Badge & Primary Duration Counter
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStateBadge(state),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 18, color: ZenColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    _formatDuration(stats.activeDuration),
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: ZenColors.textPrimary,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(color: ZenColors.glassBorder, height: 1),
          const SizedBox(height: 16),

          // Secondary Telemetry Metrics (Distance, Avg Speed, Elevation)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatMetric(
                label: 'DISTANCE',
                value: distanceVal,
                unit: distanceUnit,
                icon: Icons.directions_walk,
                color: ZenColors.emeraldLight,
              ),
              Container(width: 1, height: 32, color: ZenColors.glassBorder),
              _buildStatMetric(
                label: 'AVG SPEED',
                value: speedVal,
                unit: speedUnit,
                icon: Icons.speed,
                color: ZenColors.cyanAccent,
              ),
              Container(width: 1, height: 32, color: ZenColors.glassBorder),
              _buildStatMetric(
                label: 'ELEV GAIN',
                value: elevationVal,
                unit: elevationUnit,
                icon: Icons.terrain,
                color: ZenColors.goldAccent,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStateBadge(TrackingState state) {
    Color bg;
    Color textCol;
    String label;
    IconData icon;

    switch (state) {
      case TrackingState.recording:
        bg = ZenColors.emeraldPrimary.withOpacity(0.2);
        textCol = ZenColors.emeraldLight;
        label = 'RECORDING';
        icon = Icons.fiber_manual_record;
        break;
      case TrackingState.paused:
        bg = ZenColors.amberPause.withOpacity(0.2);
        textCol = ZenColors.amberPause;
        label = 'PAUSED';
        icon = Icons.pause;
        break;
      case TrackingState.stopped:
        bg = ZenColors.roseStop.withOpacity(0.2);
        textCol = ZenColors.roseStop;
        label = 'STOPPED';
        icon = Icons.stop;
        break;
      case TrackingState.idle:
        bg = ZenColors.surfaceLight.withOpacity(0.4);
        textCol = ZenColors.textSecondary;
        label = 'READY';
        icon = Icons.radio_button_unchecked;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: textCol.withOpacity(0.4), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textCol),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: textCol,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatMetric({
    required String label,
    required String value,
    required String unit,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                color: ZenColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: ZenColors.textPrimary,
              ),
            ),
            const SizedBox(width: 3),
            Text(
              unit,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: ZenColors.textSecondary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
