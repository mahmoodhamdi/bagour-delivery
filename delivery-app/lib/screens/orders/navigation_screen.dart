import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/common/loading_indicator.dart';

class NavigationScreen extends ConsumerStatefulWidget {
  final String orderId;

  const NavigationScreen({super.key, required this.orderId});

  @override
  ConsumerState<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends ConsumerState<NavigationScreen> {
  Timer? _locationUpdateTimer;
  double? _currentLat;
  double? _currentLng;
  double? _distanceRemaining;
  String? _eta;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _loadOrder();
    _startLocationUpdates();
  }

  Future<void> _loadOrder() async {
    await ref.read(currentOrderProvider.notifier).fetchCurrentOrder();
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
      final locationService = LocationService();
      final position = await locationService.getCurrentLocation();

      if (!mounted) return;

      setState(() {
        _currentLat = position.latitude;
        _currentLng = position.longitude;
      });

      // Calculate distance to destination
      final order = ref.read(currentOrderProvider).order;
      if (order != null) {
        double destLat, destLng;

        if (order.status == OrderStatus.ready) {
          destLat = order.restaurant.latitude;
          destLng = order.restaurant.longitude;
        } else {
          destLat = order.deliveryAddress.latitude;
          destLng = order.deliveryAddress.longitude;
        }

        final distance = _calculateDistance(
          _currentLat!,
          _currentLng!,
          destLat,
          destLng,
        );

        setState(() {
          _distanceRemaining = distance;
          _eta = _calculateETA(distance);
        });
      }
    } catch (e) {
      // Handle location error silently
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    // Simplified distance calculation (Haversine formula approximation)
    const double earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat1)) *
            _cos(_toRadians(lat2)) *
            _sin(dLon / 2) *
            _sin(dLon / 2);

    final c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degree) => degree * 3.14159265359 / 180;
  double _sin(double x) => _taylorSin(x);
  double _cos(double x) => _taylorCos(x);
  double _sqrt(double x) => x > 0 ? _newtonSqrt(x) : 0;
  double _atan2(double y, double x) {
    if (x > 0) return _taylorAtan(y / x);
    if (x < 0 && y >= 0) return _taylorAtan(y / x) + 3.14159265359;
    if (x < 0 && y < 0) return _taylorAtan(y / x) - 3.14159265359;
    if (x == 0 && y > 0) return 3.14159265359 / 2;
    if (x == 0 && y < 0) return -3.14159265359 / 2;
    return 0;
  }

  double _taylorSin(double x) {
    double result = x;
    double term = x;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  double _taylorCos(double x) {
    double result = 1;
    double term = 1;
    for (int i = 1; i <= 10; i++) {
      term *= -x * x / ((2 * i - 1) * (2 * i));
      result += term;
    }
    return result;
  }

  double _taylorAtan(double x) {
    if (x.abs() > 1) {
      return (x > 0 ? 1 : -1) * (3.14159265359 / 2 - _taylorAtan(1 / x));
    }
    double result = x;
    double term = x;
    for (int i = 1; i <= 20; i++) {
      term *= -x * x;
      result += term / (2 * i + 1);
    }
    return result;
  }

  double _newtonSqrt(double x) {
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  String _calculateETA(double distanceKm) {
    // Assume average speed of 25 km/h for delivery
    const averageSpeed = 25.0;
    final timeHours = distanceKm / averageSpeed;
    final timeMinutes = (timeHours * 60).round();

    if (timeMinutes < 1) {
      return 'أقل من دقيقة';
    } else if (timeMinutes == 1) {
      return 'دقيقة واحدة';
    } else if (timeMinutes <= 10) {
      return '$timeMinutes دقائق';
    } else {
      return '$timeMinutes دقيقة';
    }
  }

  @override
  void dispose() {
    _locationUpdateTimer?.cancel();
    super.dispose();
  }

  Future<void> _launchExternalNavigation(double lat, double lng) async {
    setState(() => _isNavigating = true);

    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
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
        // Map Placeholder (in real app, use Google Maps or similar)
        Container(
          width: double.infinity,
          height: double.infinity,
          color: AppColors.grey200,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.map,
                  size: 80,
                  color: AppColors.grey400,
                ),
                const SizedBox(height: 16),
                Text(
                  'الخريطة',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _isNavigating
                      ? null
                      : () => _launchExternalNavigation(destLat, destLng),
                  icon: const Icon(Icons.navigation),
                  label: const Text('فتح في خرائط جوجل'),
                ),
              ],
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
                  color: Colors.black.withValues(alpha: 0.1),
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
                      color: AppColors.success.withValues(alpha: 0.1),
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
                  color: Colors.black.withValues(alpha: 0.1),
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
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : AppColors.secondary.withValues(alpha: 0.1),
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
                        label: const Text('ابدأ الملاحة'),
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
