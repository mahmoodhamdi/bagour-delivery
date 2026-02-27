import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import '../../services/map_service.dart';

class MapPickerScreen extends StatefulWidget {
  final double? initialLat;
  final double? initialLng;

  const MapPickerScreen({
    super.key,
    this.initialLat,
    this.initialLng,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
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
        // Use provided coordinates
        initialLocation = LatLng(widget.initialLat!, widget.initialLng!);
      } else {
        // Try to get current location
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
          // Fallback to Bagour center
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
    setState(() {
      _isGettingAddress = true;
    });

    try {
      final addressDetails = await _mapService.getAddressDetailsFromCoordinates(location);

      if (addressDetails != null) {
        setState(() {
          _address = addressDetails.shortAddress.isNotEmpty
              ? addressDetails.shortAddress
              : addressDetails.fullAddress;
          _isGettingAddress = false;
        });
      } else {
        setState(() {
          _address = 'العنوان غير متاح';
          _isGettingAddress = false;
        });
      }
    } catch (e) {
      setState(() {
        _address = 'فشل الحصول على العنوان';
        _isGettingAddress = false;
      });
    }
  }

  void _onMapPositionChanged(MapPosition position, bool hasGesture) {
    if (position.center != null) {
      setState(() {
        _selectedLocation = position.center;
      });
    }
  }

  void _onMapMoveEnd() {
    if (_selectedLocation != null) {
      _getAddressFromLatLng(_selectedLocation!);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() {
        _isLoading = true;
      });

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
      setState(() {
        _isLoading = false;
      });

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
        title: const Text('اختر الموقع على الخريطة'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
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
                      userAgentPackageName: 'com.bagour.customer',
                      maxZoom: 19,
                    ),
                  ],
                ),

                // Center marker
                Center(
                  child: Transform.translate(
                    offset: const Offset(0, -20),
                    child: const Icon(
                      Icons.location_pin,
                      size: 50,
                      color: Colors.red,
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
                              const Icon(
                                Icons.location_on,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'الموقع المحدد',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Spacer(),
                              if (_isGettingAddress)
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _address,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_selectedLocation != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'الإحداثيات: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
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
                    onPressed: _getCurrentLocation,
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.my_location,
                      color: Colors.blue,
                    ),
                  ),
                ),

                // Confirm button at bottom
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _confirmLocation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'تأكيد الموقع',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
