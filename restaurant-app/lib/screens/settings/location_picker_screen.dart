import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../services/map_service.dart';

/// Location picker screen for restaurant owners to set/update restaurant location
/// Uses FREE OpenStreetMap instead of Google Maps
class LocationPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const LocationPickerScreen({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<LocationPickerScreen> createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  final MapController _mapController = MapController();
  final MapService _mapService = MapService();
  LatLng? _selectedLocation;
  String _address = 'جاري تحديد الموقع...';
  bool _isLoading = true;
  bool _isGettingAddress = false;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      LatLng initialLocation;

      if (widget.initialLat != null && widget.initialLng != null) {
        initialLocation = LatLng(widget.initialLat!, widget.initialLng!);
      } else {
        try {
          final permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied) {
            await Geolocator.requestPermission();
          }

          final serviceEnabled = await Geolocator.isLocationServiceEnabled();
          if (serviceEnabled) {
            final position = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.high,
            ).timeout(
              const Duration(seconds: 5),
              onTimeout: () => throw Exception('Timeout'),
            );
            initialLocation = LatLng(position.latitude, position.longitude);
          } else {
            initialLocation = MapService.bagourCenter;
          }
        } catch (e) {
          initialLocation = MapService.bagourCenter;
        }
      }

      setState(() {
        _selectedLocation = initialLocation;
        _isLoading = false;
      });

      _getAddressFromLatLng(initialLocation);
    } catch (e) {
      setState(() {
        _selectedLocation = MapService.bagourCenter;
        _isLoading = false;
        _address = 'فشل تحديد الموقع';
      });
    }
  }

  Future<void> _getAddressFromLatLng(LatLng location) async {
    setState(() => _isGettingAddress = true);

    try {
      final addressDetails = await _mapService.getAddressDetailsFromCoordinates(location);

      if (addressDetails != null && mounted) {
        setState(() {
          _address = addressDetails.shortAddress.isNotEmpty
              ? addressDetails.shortAddress
              : addressDetails.fullAddress;
          _isGettingAddress = false;
        });
      } else if (mounted) {
        setState(() {
          _address = 'العنوان غير متاح';
          _isGettingAddress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _address = 'فشل الحصول على العنوان';
          _isGettingAddress = false;
        });
      }
    }
  }

  void _onMapPositionChanged(MapCamera camera, bool hasGesture) {
    setState(() => _selectedLocation = camera.center);
  }

  void _onMapMoveEnd() {
    if (_selectedLocation != null) {
      _getAddressFromLatLng(_selectedLocation!);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isLoading = true);

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          throw Exception('لا يوجد إذن للوصول إلى الموقع');
        }
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('خدمات الموقع غير مفعلة');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final location = LatLng(position.latitude, position.longitude);

      setState(() {
        _selectedLocation = location;
        _isLoading = false;
      });

      _mapController.move(location, 16);
      _getAddressFromLatLng(location);
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تحديد الموقع: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _confirmLocation() {
    if (_selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى تحديد موقع أولاً'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.pop({
      'latitude': _selectedLocation!.latitude,
      'longitude': _selectedLocation!.longitude,
      'address': _address,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تحديد موقع المطعم'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // OpenStreetMap (FREE)
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLocation ?? MapService.bagourCenter,
                    initialZoom: 16,
                    onPositionChanged: _onMapPositionChanged,
                    onMapEvent: (event) {
                      if (event is MapEventMoveEnd) {
                        _onMapMoveEnd();
                      }
                    },
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.bagour.restaurant',
                      maxZoom: 19,
                    ),
                  ],
                ),

                // Center marker
                Center(
                  child: Transform.translate(
                    offset: const Offset(0, -20),
                    child: const Icon(
                      Icons.restaurant,
                      size: 50,
                      color: Colors.orange,
                    ),
                  ),
                ),

                // Address card at top
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.restaurant, color: Colors.orange, size: 20),
                              const SizedBox(width: 8),
                              const Text(
                                'موقع المطعم',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              if (_isGettingAddress)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _address,
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_selectedLocation != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'الإحداثيات: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                // My Location button
                Positioned(
                  bottom: 120,
                  left: 16,
                  child: FloatingActionButton(
                    mini: true,
                    heroTag: 'myLocation',
                    onPressed: _getCurrentLocation,
                    backgroundColor: Colors.white,
                    child: const Icon(Icons.my_location, color: Colors.blue),
                  ),
                ),

                // Confirm button
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _confirmLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'تأكيد الموقع',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
