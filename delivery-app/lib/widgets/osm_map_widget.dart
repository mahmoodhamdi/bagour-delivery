import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

/// OpenStreetMap widget using flutter_map
/// Replaces Google Maps with FREE OpenStreetMap tiles
class OSMMapWidget extends StatefulWidget {
  final LatLng initialCenter;
  final double initialZoom;
  final List<OSMMarker> markers;
  final List<LatLng>? polylinePoints;
  final Color polylineColor;
  final double polylineWidth;
  final bool showUserLocation;
  final bool showMyLocationButton;
  final Function(LatLng)? onTap;
  final Function(MapCamera)? onPositionChanged;
  final MapController? controller;
  final bool interactive;

  const OSMMapWidget({
    super.key,
    required this.initialCenter,
    this.initialZoom = 15,
    this.markers = const [],
    this.polylinePoints,
    this.polylineColor = Colors.blue,
    this.polylineWidth = 4,
    this.showUserLocation = true,
    this.showMyLocationButton = true,
    this.onTap,
    this.onPositionChanged,
    this.controller,
    this.interactive = true,
  });

  @override
  State<OSMMapWidget> createState() => _OSMMapWidgetState();
}

class _OSMMapWidgetState extends State<OSMMapWidget> {
  late MapController _mapController;
  LatLng? _userLocation;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _mapController = widget.controller ?? MapController();
    if (widget.showUserLocation) {
      _getUserLocation();
    }
  }

  Future<void> _getUserLocation() async {
    if (_isLoadingLocation) return;

    setState(() => _isLoadingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
        });
      }
    } catch (e) {
      // Location not available
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  void _goToUserLocation() async {
    await _getUserLocation();
    if (_userLocation != null) {
      _mapController.move(_userLocation!, 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: widget.initialCenter,
            initialZoom: widget.initialZoom,
            onTap: widget.onTap != null
                ? (tapPosition, point) => widget.onTap!(point)
                : null,
            onPositionChanged: (camera, hasGesture) {
              widget.onPositionChanged?.call(camera);
            },
            interactionOptions: InteractionOptions(
              flags: widget.interactive
                  ? InteractiveFlag.all
                  : InteractiveFlag.none,
            ),
          ),
          children: [
            // OpenStreetMap tiles
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.bagour.delivery',
              maxZoom: 19,
            ),

            // Route polyline
            if (widget.polylinePoints != null &&
                widget.polylinePoints!.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.polylinePoints!,
                    color: widget.polylineColor,
                    strokeWidth: widget.polylineWidth,
                  ),
                ],
              ),

            // Markers layer
            MarkerLayer(
              markers: [
                // User location marker
                if (_userLocation != null && widget.showUserLocation)
                  Marker(
                    point: _userLocation!,
                    width: 40,
                    height: 40,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 2),
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.blue,
                        size: 20,
                      ),
                    ),
                  ),

                // Custom markers
                ...widget.markers.map((m) => Marker(
                      point: m.position,
                      width: m.width,
                      height: m.height,
                      child: GestureDetector(
                        onTap: m.onTap,
                        child: m.child ??
                            Icon(
                              m.icon ?? Icons.location_on,
                              color: m.color ?? Colors.red,
                              size: 36,
                            ),
                      ),
                    )),
              ],
            ),
          ],
        ),

        // My location button
        if (widget.showMyLocationButton)
          Positioned(
            right: 16,
            bottom: 100,
            child: FloatingActionButton(
              mini: true,
              heroTag: 'osm_location_btn',
              backgroundColor: Colors.white,
              onPressed: _goToUserLocation,
              child: _isLoadingLocation
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),
      ],
    );
  }
}

/// Custom marker for OSM map
class OSMMarker {
  final String id;
  final LatLng position;
  final String? title;
  final IconData? icon;
  final Color? color;
  final Widget? child;
  final double width;
  final double height;
  final VoidCallback? onTap;

  OSMMarker({
    required this.id,
    required this.position,
    this.title,
    this.icon,
    this.color,
    this.child,
    this.width = 40,
    this.height = 40,
    this.onTap,
  });
}
