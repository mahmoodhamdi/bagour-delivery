import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../services/location_service.dart';
import '../../services/map_service.dart';
import '../../widgets/common/loading_indicator.dart';

class NavigationScreen extends ConsumerStatefulWidget {
  final String orderId;

  const NavigationScreen({super.key, required this.orderId});

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  final MapController _mapController = MapController();
  final MapService _mapService = MapService();
  Timer? _locationUpdateTimer;
  LatLng? _currentLocation;
  LatLng? _destination;
  List<LatLng>? _routePoints;
  double? _distanceRemaining;
  String? _eta;
  bool _isNavigating = false;
  bool _isLoadingRoute = false;

  @override
  void initState() {
    super.initState();
    _loadOrder();
    _startLocationUpdates();
  }

  Future<void> _loadOrder() async {
    await ref.read(currentOrderProvider.notifier).fetchCurrentOrder();
    _updateDestination();
  }

  void _updateDestination() {
    final order = ref.read(currentOrderProvider).order;
    if (order != null) {
      setState(() {
        if (order.status == OrderStatus.ready) {
          _destination = LatLng(order.restaurant.latitude, order.restaurant.longitude);
        } else {
          _destination = LatLng(order.deliveryAddress.latitude, order.deliveryAddress.longitude);
        }
      });
      _loadRoute();
    }
  }

  Future<void> _loadRoute() async {
    if (_currentLocation == null || _destination == null) return;

    setState(() => _isLoadingRoute = true);

    try {
      final route = await _mapService.getRoute(_currentLocation!, _destination!);
      if (route != null && mounted) {
        setState(() {
          _routePoints = route.polylinePoints;
          _distanceRemaining = route.distanceMeters / 1000; // Convert to km
          _eta = route.durationText;
          _isLoadingRoute = false;
        });

        // Fit map to show entire route
        if (_routePoints != null && _routePoints!.isNotEmpty) {
          final bounds = LatLngBounds.fromPoints(_routePoints!);
          _mapController.fitCamera(
            CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(50)),
          );
        }
      } else {
        setState(() => _isLoadingRoute = false);
      }
    } catch (e) {
      setState(() => _isLoadingRoute = false);
    }
  }

  void _startLocationUpdates() {
    _locationUpdateTimer = Timer.periodic(
      Duration(seconds: AppConstants.locationUpdateInterval),
      (_) => _updateLocation(),
    );
    _updateLocation();
  }

  Future<void> _updateLocation() async {
    try {
      final locationService = LocationService(ref.read(apiServiceProvider));
      final position = await locationService.getCurrentLocation();

      if (!mounted || position == null) return;

      final newLocation = LatLng(position.latitude, position.longitude);

      setState(() => _currentLocation = newLocation);

      // Recalculate route and ETA
      if (_destination != null) {
        final distance = _mapService.getDistance(_currentLocation!, _destination!);
        distance.then((result) {
          if (result != null && mounted) {
            setState(() {
              _distanceRemaining = result.distanceMeters / 1000;
              _eta = result.durationText;
            });
          }
        });
      }
    } catch (e) {
      // Handle location error silently
    }
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _launchExternalNavigation(double lat, double lng) async {
    setState(() => _isNavigating = true);

    // Try OpenStreetMap-based navigation first (OsmAnd or similar)
    final osmUrl = Uri.parse('geo:$lat,$lng?q=$lat,$lng');
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );

    try {
      // Try to open with geo URI (works with OsmAnd and other OSM apps)
      if (await canLaunchUrl(osmUrl)) {
        await launchUrl(osmUrl, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(googleMapsUrl)) {
        // Fallback to Google Maps web
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('فشل فتح تطبيق الملاحة'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }

    if (mounted) {
      setState(() => _isNavigating = false);
    }
  }

  Future<void> _launchCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderState = ref.watch(currentOrderProvider);

    return Scaffold(
      body: orderState.order == null
          ? const LoadingIndicator(message: 'جاري تحميل بيانات الطلب...')
          : _buildNavigationContent(orderState.order!),
    );
  }

  Widget _buildNavigationContent(DriverOrder order) {
    final bool isPickup = order.status == OrderStatus.ready;
    final String destinationName = isPickup
        ? order.restaurant.displayName
        : order.deliveryAddress.name;
    final String destinationAddress = isPickup
        ? order.restaurant.address
        : order.deliveryAddress.fullAddress;
    final String phone = isPickup
        ? order.restaurant.phone
        : order.customer.phone;
    final double destLat = isPickup
        ? order.restaurant.latitude
        : order.deliveryAddress.latitude;
    final double destLng = isPickup
        ? order.restaurant.longitude
        : order.deliveryAddress.longitude;

    return Stack(
      children: [
        // OpenStreetMap (FREE)
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: _currentLocation ?? _destination ?? MapService.bagourCenter,
            initialZoom: 15,
          ),
          children: [
            // Map tiles
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.bagour.delivery',
              maxZoom: 19,
            ),

            // Route polyline
            if (_routePoints != null && _routePoints!.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints!,
                    color: AppColors.primary,
                    strokeWidth: 5,
                  ),
                ],
              ),

            // Markers
            MarkerLayer(
              markers: [
                // Current location marker
                if (_currentLocation != null)
                  Marker(
                    point: _currentLocation!,
                    width: 50,
                    height: 50,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.blue, width: 3),
                      ),
                      child: const Icon(Icons.delivery_dining, color: Colors.blue, size: 28),
                    ),
                  ),

                // Destination marker
                if (_destination != null)
                  Marker(
                    point: _destination!,
                    width: 50,
                    height: 50,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isPickup ? AppColors.primary : AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPickup ? Icons.restaurant : Icons.location_on,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),

        // Loading indicator for route
        if (_isLoadingRoute)
          Positioned(
            top: MediaQuery.of(context).padding.top + 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 8),
                    Text('جاري تحميل المسار...'),
                  ],
                ),
              ),
            ),
          ),

        // Top Bar
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        isPickup ? 'الذهاب للمطعم' : 'التوصيل للعميل',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        order.orderNumber,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _launchCall(phone),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.phone, color: AppColors.success),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ETA Card
        if (_distanceRemaining != null && _eta != null)
          Positioned(
            top: MediaQuery.of(context).padding.top + 80,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _ETAItem(
                      icon: Icons.access_time,
                      label: 'الوقت المتوقع',
                      value: _eta!,
                    ),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppColors.grey200,
                    ),
                    _ETAItem(
                      icon: Icons.straighten,
                      label: 'المسافة',
                      value: '${_distanceRemaining!.toStringAsFixed(1)} كم',
                    ),
                  ],
                ),
              ),
            ),
          ),

        // My Location Button
        Positioned(
          right: 16,
          bottom: 280,
          child: FloatingActionButton(
            mini: true,
            heroTag: 'myLocation',
            backgroundColor: Colors.white,
            onPressed: () {
              if (_currentLocation != null) {
                _mapController.move(_currentLocation!, 16);
              }
            },
            child: const Icon(Icons.my_location, color: Colors.blue),
          ),
        ),

        // Reload Route Button
        Positioned(
          right: 16,
          bottom: 230,
          child: FloatingActionButton(
            mini: true,
            heroTag: 'refreshRoute',
            backgroundColor: Colors.white,
            onPressed: _loadRoute,
            child: _isLoadingRoute
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.refresh, color: Colors.blue),
          ),
        ),

        // Bottom Card
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 16,
              right: 16,
              top: 16,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Destination Info
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isPickup
                            ? AppColors.primary.withOpacity(0.1)
                            : AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isPickup ? Icons.restaurant : Icons.location_on,
                        color: isPickup ? AppColors.primary : AppColors.secondary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            destinationName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            destinationAddress,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _launchCall(phone),
                        icon: const Icon(Icons.phone),
                        label: const Text('اتصال'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _isNavigating
                            ? null
                            : () => _launchExternalNavigation(destLat, destLng),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                        ),
                        icon: _isNavigating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.navigation),
                        label: const Text('فتح الملاحة'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Back to Order Button
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => context.go(AppRoutes.activeOrder),
                    child: const Text('العودة لتفاصيل الطلب'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ETAItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ETAItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(height: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}
