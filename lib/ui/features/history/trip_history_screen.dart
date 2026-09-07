import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../domain/models/trip.dart';
import '../../core/glass_card.dart';
import '../../core/zen_colors.dart';
import '../../view_models/history_view_model.dart';
import '../../view_models/settings_view_model.dart';
import 'trip_detail_screen.dart';

/// Screen listing recorded & imported trips with TabBar navigation & file import.
class TripHistoryScreen extends StatelessWidget {
  const TripHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final historyVM = context.watch<HistoryViewModel>();
    final settingsVM = context.watch<SettingsViewModel>();
    final isMetric = settingsVM.isMetric;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: ZenColors.background,
        appBar: AppBar(
          backgroundColor: ZenColors.surface,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: ZenColors.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Trips & Exports',
            style: TextStyle(
              color: ZenColors.textPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            // Import File Button
            TextButton.icon(
              onPressed: () async {
                final imported = await historyVM.importFileFromDevice();
                if (imported != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Imported "${imported.title}"!'),
                      backgroundColor: ZenColors.emeraldPrimary,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.file_upload_outlined, color: ZenColors.cyanAccent, size: 18),
              label: const Text(
                'IMPORT',
                style: TextStyle(color: ZenColors.cyanAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
          bottom: TabBar(
            indicatorColor: ZenColors.emeraldPrimary,
            labelColor: ZenColors.emeraldLight,
            unselectedLabelColor: ZenColors.textSecondary,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            tabs: [
              Tab(text: 'RECORDED (${historyVM.recordedTrips.length})'),
              Tab(text: 'IMPORTED (${historyVM.importedTrips.length})'),
            ],
          ),
        ),
        body: historyVM.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: ZenColors.emeraldPrimary),
              )
            : TabBarView(
                children: [
                  // Tab 1: Recorded Trips
                  _buildTripList(
                    context: context,
                    historyVM: historyVM,
                    trips: historyVM.recordedTrips,
                    isMetric: isMetric,
                    isImportedBucket: false,
                  ),

                  // Tab 2: Imported Trips
                  _buildTripList(
                    context: context,
                    historyVM: historyVM,
                    trips: historyVM.importedTrips,
                    isMetric: isMetric,
                    isImportedBucket: true,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildTripList({
    required BuildContext context,
    required HistoryViewModel historyVM,
    required List<Trip> trips,
    required bool isMetric,
    required bool isImportedBucket,
  }) {
    if (trips.isEmpty) {
      return _buildEmptyState(isImportedBucket, historyVM);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: trips.length,
      itemBuilder: (context, index) {
        final trip = trips[index];
        return _buildTripCard(context, historyVM, trip, isMetric, isImportedBucket);
      },
    );
  }

  Widget _buildEmptyState(bool isImportedBucket, HistoryViewModel historyVM) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: ZenColors.surfaceLight.withValues(alpha: 0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isImportedBucket ? Icons.file_download_outlined : Icons.hiking_outlined,
              size: 56,
              color: ZenColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isImportedBucket ? 'No Imported Trips Yet' : 'No Recorded Trips Yet',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ZenColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isImportedBucket
                ? 'Import standard .kml or .gpx files from your device.'
                : 'Start a new trip to record your outdoor journey.',
            style: const TextStyle(fontSize: 13, color: ZenColors.textSecondary),
          ),
          if (isImportedBucket) ...[
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: historyVM.importFileFromDevice,
              icon: const Icon(Icons.file_upload_outlined, size: 18),
              label: const Text('IMPORT .KML OR .GPX FILE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ZenColors.cyanAccent,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTripCard(
    BuildContext context,
    HistoryViewModel historyVM,
    Trip trip,
    bool isMetric,
    bool isImportedBucket,
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
                  child: Row(
                    children: [
                      if (isImportedBucket) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          margin: const EdgeInsets.only(right: 6),
                          decoration: BoxDecoration(
                            color: ZenColors.cyanAccent.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'IMPORTED',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: ZenColors.cyanAccent,
                            ),
                          ),
                        ),
                      ],
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
                    ],
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
                      historyVM.deleteTrip(trip.id, isImported: isImportedBucket);
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
