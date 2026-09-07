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

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(
      _mapController.camera.center,
      (currentZoom + 1.0).clamp(1.0, 19.0),
    );
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    _mapController.move(
      _mapController.camera.center,
      (currentZoom - 1.0).clamp(1.0, 19.0),
    );
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

        // Google Maps Style Map Control Cluster (Location & Zoom + / -)
        Positioned(
          top: MediaQuery.of(context).padding.top + 70,
          right: 14,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Re-Center / Target Location Button (Google Maps Style - No Text Label)
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                elevation: 5,
                shadowColor: Colors.black45,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _centerOnCurrentPosition,
                  child: Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    child: Icon(
                      _followUser ? Icons.gps_fixed : Icons.gps_not_fixed,
                      size: 22,
                      color: _followUser ? ZenColors.emeraldPrimary : Colors.black87,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Google Maps Style Vertical Zoom Controls (+ / -)
              Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                elevation: 5,
                shadowColor: Colors.black45,
                child: Container(
                  width: 44,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Zoom In (+)
                      InkWell(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        onTap: _zoomIn,
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(
                            Icons.add,
                            size: 24,
                            color: Colors.black87,
                          ),
                        ),
                      ),

                      // Subtle Horizontal Divider
                      Container(
                        height: 1,
                        width: 26,
                        color: Colors.grey.shade300,
                      ),

                      // Zoom Out (-)
                      InkWell(
                        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
                        onTap: _zoomOut,
                        child: const SizedBox(
                          width: 44,
                          height: 44,
                          child: Icon(
                            Icons.remove,
                            size: 24,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
