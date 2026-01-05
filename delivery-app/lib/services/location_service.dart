import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';
import '../config/constants.dart';

final locationServiceProvider = Provider<LocationService>((ref) {
  final apiService = ApiService();
  return LocationService(apiService);
});

class LocationService {
  final ApiService _apiService;
  StreamSubscription<Position>? _positionStreamSubscription;
  Position? _lastPosition;
  Timer? _locationUpdateTimer;

  LocationService(this._apiService);

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Check and request location permissions
  Future<bool> checkAndRequestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) {
        throw Exception('لا يوجد إذن للوصول إلى الموقع');
      }

      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('خدمات الموقع غير مفعلة');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _lastPosition = position;
      return position;
    } catch (e) {
      throw Exception('فشل الحصول على الموقع: ${e.toString()}');
    }
  }

  /// Get last known location
  Future<Position?> getLastKnownLocation() async {
    try {
      return await Geolocator.getLastKnownPosition();
    } catch (e) {
      return null;
    }
  }

  /// Start background location tracking
  Future<void> startLocationTracking({
    required Function(Position) onLocationUpdate,
    required Function(String) onError,
  }) async {
    try {
      final hasPermission = await checkAndRequestPermission();
      if (!hasPermission) {
        onError('لا يوجد إذن للوصول إلى الموقع');
        return;
      }

      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        onError('خدمات الموقع غير مفعلة');
        return;
      }

      // Configure location settings for delivery tracking
      final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: AppConstants.locationDistanceFilter.toInt(),
      );

      // Start listening to position stream
      _positionStreamSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen(
        (Position position) {
          _lastPosition = position;
          onLocationUpdate(position);
          _updateServerLocation(position);
        },
        onError: (error) {
          onError('خطأ في تتبع الموقع: ${error.toString()}');
        },
      );

      // Also set up periodic updates as backup
      _locationUpdateTimer = Timer.periodic(
        Duration(seconds: AppConstants.locationUpdateInterval),
        (_) async {
          if (_lastPosition != null) {
            await _updateServerLocation(_lastPosition!);
          }
        },
      );
    } catch (e) {
      onError('فشل بدء تتبع الموقع: ${e.toString()}');
    }
  }

  /// Stop location tracking
  void stopLocationTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
    _locationUpdateTimer?.cancel();
    _locationUpdateTimer = null;
  }

  /// Update server with current location
  Future<void> _updateServerLocation(Position position) async {
    try {
      await _apiService.post(
        ApiEndpoints.updateLocation,
        data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'heading': position.heading,
          'speed': position.speed,
        },
      );
    } catch (e) {
      // Silent fail - location updates are not critical
      // The app will retry on the next interval
    }
  }

  /// Manually update location on server
  Future<void> updateLocation(Position position) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.updateLocation,
        data: {
          'latitude': position.latitude,
          'longitude': position.longitude,
          'accuracy': position.accuracy,
          'heading': position.heading,
          'speed': position.speed,
        },
      );

      if (!response.data['success']) {
        throw Exception(response.data['message'] ?? 'فشل تحديث الموقع');
      }
    } catch (e) {
      throw Exception('فشل تحديث الموقع على الخادم: ${e.toString()}');
    }
  }

  /// Calculate distance between two positions in meters
  double calculateDistance(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
  ) {
    return Geolocator.distanceBetween(startLat, startLng, endLat, endLng);
  }

  /// Open location settings
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Get location stream
  Stream<Position> getLocationStream() {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: AppConstants.locationDistanceFilter.toInt(),
    );

    return Geolocator.getPositionStream(locationSettings: locationSettings);
  }

  /// Dispose resources
  void dispose() {
    stopLocationTracking();
  }
}
