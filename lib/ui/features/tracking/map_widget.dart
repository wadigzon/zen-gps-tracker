import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../../domain/models/gps_point.dart';
import '../../core/zen_colors.dart';
import '../../view_models/settings_view_model.dart';

/// Interactive map widget visualizing GPS track polyline and current user marker.
class MapWidget extends StatefulWidget {
  final List<GpsPoint> points;
  final GpsPoint? currentPosition;
  final MapTileType mapTileType;
  final bool isTracking;

  const MapWidget({
    super.key,
    required this.points,
    this.currentPosition,
    this.mapTileType = MapTileType.openStreetMap,
    this.isTracking = false,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final MapController _mapController = MapController();
  bool _followUser = true;

  @override
  void didUpdateWidget(covariant MapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_followUser && widget.currentPosition != null) {
      _mapController.move(
        LatLng(
          widget.currentPosition!.latitude,
          widget.currentPosition!.longitude,
        ),
        _mapController.camera.zoom,
      );
    }
  }

  void _centerOnCurrentPosition() {
    if (widget.currentPosition != null) {
      setState(() => _followUser = true);
      _mapController.move(
        LatLng(
          widget.currentPosition!.latitude,
          widget.currentPosition!.longitude,
        ),
        16.5,
      );
    } else if (widget.points.isNotEmpty) {
      final lastPt = widget.points.last;
      _mapController.move(LatLng(lastPt.latitude, lastPt.longitude), 16.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Default initial location: Yosemite Valley or current position
    final initialCenter = widget.currentPosition != null
        ? LatLng(widget.currentPosition!.latitude, widget.currentPosition!.longitude)
        : widget.points.isNotEmpty
            ? LatLng(widget.points.last.latitude, widget.points.last.longitude)
            : const LatLng(37.7459, -119.5936);

    final polylineCoords = widget.points
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();

    // Map Tile URL template
    String tileUrl;
    switch (widget.mapTileType) {
      case MapTileType.openTopoMap:
        tileUrl = 'https://tile.opentopomap.org/{z}/{x}/{y}.png';
        break;
      case MapTileType.esriSatellite:
        tileUrl = 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';
        break;
      case MapTileType.openStreetMap:
      default:
        tileUrl = 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
        break;
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: initialCenter,
            initialZoom: 15.5,
            onPositionChanged: (pos, hasGesture) {
              if (hasGesture && _followUser) {
                setState(() => _followUser = false);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: tileUrl,
              userAgentPackageName: 'com.zengps.zen_gps_tracker',
              maxZoom: 19,
            ),
            if (polylineCoords.length >= 2) ...[
              // Outer glow polyline
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: polylineCoords,
                    strokeWidth: 8.0,
                    color: ZenColors.trackPolylineGlow,
                  ),
                  // Inner solid polyline
                  Polyline(
                    points: polylineCoords,
                    strokeWidth: 4.5,
                    color: widget.mapTileType == MapTileType.esriSatellite
                        ? ZenColors.cyanAccent
                        : ZenColors.trackPolyline,
                  ),
                ],
              ),
            ],
            MarkerLayer(
              markers: [
                // Start pin marker
                if (widget.points.isNotEmpty)
                  Marker(
                    point: LatLng(
                      widget.points.first.latitude,
                      widget.points.first.longitude,
                    ),
                    width: 32,
                    height: 32,
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 6)
                        ],
                      ),
                      child: const Icon(
                        Icons.play_circle_fill,
                        color: ZenColors.emeraldPrimary,
                        size: 28,
                      ),
                    ),
                  ),

                // Current user location pulsing marker
                if (widget.currentPosition != null)
                  Marker(
                    point: LatLng(
                      widget.currentPosition!.latitude,
                      widget.currentPosition!.longitude,
                    ),
                    width: 44,
                    height: 44,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulse glow
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ZenColors.emeraldPrimary.withValues(alpha: 0.25),
                          ),
                        ),
                        // Inner marker
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: ZenColors.emeraldPrimary,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: const [
                              BoxShadow(color: Colors.black38, blurRadius: 6)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),

        // Prominent Re-center button (shows whenever user drags map off-center)
        Positioned(
          top: MediaQuery.of(context).padding.top + 70,
          right: 16,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 250),
            opacity: !_followUser ? 1.0 : 0.85,
            child: ElevatedButton.icon(
              onPressed: _centerOnCurrentPosition,
              icon: Icon(
                _followUser ? Icons.my_location : Icons.location_searching,
                size: 18,
                color: _followUser ? ZenColors.emeraldPrimary : ZenColors.cyanAccent,
              ),
              label: Text(
                _followUser ? 'CENTERED' : 'RE-CENTER MAP',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                  color: _followUser ? ZenColors.textPrimary : ZenColors.cyanAccent,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ZenColors.glassBackground,
                elevation: 6,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: _followUser ? ZenColors.glassBorder : ZenColors.cyanAccent.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
