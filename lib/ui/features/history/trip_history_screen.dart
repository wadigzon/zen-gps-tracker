import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/trip.dart';
import '../../core/glass_card.dart';
import '../../core/zen_colors.dart';
import '../../view_models/history_view_model.dart';
import '../../view_models/settings_view_model.dart';
import 'trip_detail_screen.dart';

/// Screen listing all past recorded trips with search/deletion and KML/GPX export.
class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyVM = context.watch<HistoryViewModel>();
    final settingsVM = context.watch<SettingsViewModel>();
    final isMetric = settingsVM.isMetric;

    return Scaffold(
      backgroundColor: ZenColors.background,
      appBar: AppBar(
        backgroundColor: ZenColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ZenColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Trip History & Exports',
          style: TextStyle(
            color: ZenColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: historyVM.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: ZenColors.emeraldPrimary),
            )
          : historyVM.trips.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: historyVM.trips.length,
                  itemBuilder: (context, index) {
                    final trip = historyVM.trips[index];
                    return _buildTripCard(context, historyVM, trip, isMetric);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ZenColors.surfaceLight.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.hiking_outlined,
              size: 56,
              color: ZenColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No Recorded Trips Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ZenColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start a new trip to record your outdoor journey.',
            style: TextStyle(fontSize: 13, color: ZenColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(
    BuildContext context,
    HistoryViewModel historyVM,
    Trip trip,
    bool isMetric,
  ) {
    final dateFormat = DateFormat('MMM d, yyyy • h:mm a');
    final formattedDate = dateFormat.format(trip.startTime);

    final distStr = isMetric
        ? '${trip.stats.distanceKm.toStringAsFixed(2)} km'
        : '${trip.stats.distanceMiles.toStringAsFixed(2)} mi';

    final speedStr = isMetric
        ? '${trip.stats.avgSpeedKmh.toStringAsFixed(1)} km/h'
        : '${trip.stats.avgSpeedMph.toStringAsFixed(1)} mph';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TripDetailScreen(trip: trip),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title & Date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    trip.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: ZenColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Export KML Badge Button
                PopupMenuButton<String>(
                  color: ZenColors.surface,
                  icon: const Icon(Icons.share_outlined, color: ZenColors.emeraldLight, size: 20),
                  onSelected: (val) {
                    if (val == 'kml') {
                      historyVM.exportKml(trip);
                    } else if (val == 'gpx') {
                      historyVM.exportGpx(trip);
                    } else if (val == 'delete') {
                      historyVM.deleteTrip(trip.id);
                    }
                  },
                  itemBuilder: (context) => const [
                    PopupMenuItem(
                      value: 'kml',
                      child: Row(
                        children: [
                          Icon(Icons.public, color: ZenColors.emeraldPrimary, size: 18),
                          SizedBox(width: 8),
                          Text('Export .KML (Google Earth)', style: TextStyle(color: ZenColors.textPrimary)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'gpx',
                      child: Row(
                        children: [
                          Icon(Icons.map, color: ZenColors.cyanAccent, size: 18),
                          SizedBox(width: 8),
                          Text('Export .GPX Format', style: TextStyle(color: ZenColors.textPrimary)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, color: ZenColors.roseStop, size: 18),
                          SizedBox(width: 8),
                          Text('Delete Trip', style: TextStyle(color: ZenColors.roseStop)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            Text(
              formattedDate,
              style: const TextStyle(fontSize: 11, color: ZenColors.textSecondary),
            ),
            const SizedBox(height: 12),
            const Divider(color: ZenColors.glassBorder, height: 1),
            const SizedBox(height: 12),

            // Quick Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCompactStat('DISTANCE', distStr, Icons.directions_walk),
                _buildCompactStat('DURATION', _formatDuration(trip.stats.activeDuration), Icons.timer),
                _buildCompactStat('AVG SPEED', speedStr, Icons.speed),
                _buildCompactStat('POINTS', '${trip.points.length}', Icons.pin_drop),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactStat(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 11, color: ZenColors.textSecondary),
            const SizedBox(width: 3),
            Text(
              label,
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: ZenColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: ZenColors.textPrimary,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes % 60;
    final seconds = d.inSeconds % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m ${seconds}s';
  }
}
