import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final mapServiceProvider = Provider<MapService>((ref) => MapService());

/// Service for map operations using free OpenStreetMap APIs
/// - Nominatim for geocoding/reverse geocoding
/// - OSRM for routing/directions
class MapService {
  static final MapService _instance = MapService._internal();
  factory MapService() => _instance;
  MapService._internal();

  static const String _nominatimBase = 'https://nominatim.openstreetmap.org';
  static const String _osrmBase = 'https://router.project-osrm.org';

  // Default location (Bagour, Egypt)
  static const LatLng bagourCenter = LatLng(30.4500, 30.9667);

  /// Search for places using Nominatim
  Future<List<PlaceResult>> searchPlaces(String query, {LatLng? near}) async {
    try {
      // Rate limiting - Nominatim requires max 1 request per second
      await Future.delayed(const Duration(milliseconds: 100));

      final params = {
        'q': query,
        'format': 'json',
        'limit': '10',
        'countrycodes': 'eg', // Egypt only
        'addressdetails': '1',
      };

      // If near location provided, bias results to that area
      if (near != null) {
        params['viewbox'] = '${near.longitude - 0.3},${near.latitude - 0.3},${near.longitude + 0.3},${near.latitude + 0.3}';
        params['bounded'] = '1';
      }

      final response = await http.get(
        Uri.parse('$_nominatimBase/search').replace(queryParameters: params),
        headers: {
          'User-Agent': 'BagourDelivery/1.0',
          'Accept-Language': 'ar,en',
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        return data.map((item) => PlaceResult(
          placeId: item['place_id'].toString(),
          name: _extractName(item),
          address: item['display_name'] ?? '',
          location: LatLng(
            double.parse(item['lat']),
            double.parse(item['lon']),
          ),
        )).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  String _extractName(Map<String, dynamic> item) {
    final address = item['address'] as Map<String, dynamic>?;
    if (address != null) {
      return address['amenity'] ??
             address['shop'] ??
             address['road'] ??
             address['suburb'] ??
             address['city'] ??
             item['display_name']?.split(',').first ?? '';
    }
    return item['display_name']?.split(',').first ?? '';
  }

  /// Reverse geocode coordinates to address using Nominatim
  Future<String?> getAddressFromCoordinates(LatLng location) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));

      final response = await http.get(
        Uri.parse('$_nominatimBase/reverse').replace(queryParameters: {
          'lat': location.latitude.toString(),
          'lon': location.longitude.toString(),
          'format': 'json',
          'accept-language': 'ar',
          'addressdetails': '1',
        }),
        headers: {'User-Agent': 'BagourDelivery/1.0'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['display_name'];
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get structured address from coordinates
  Future<AddressDetails?> getAddressDetailsFromCoordinates(LatLng location) async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));

      final response = await http.get(
        Uri.parse('$_nominatimBase/reverse').replace(queryParameters: {
          'lat': location.latitude.toString(),
          'lon': location.longitude.toString(),
          'format': 'json',
          'accept-language': 'ar',
          'addressdetails': '1',
        }),
        headers: {'User-Agent': 'BagourDelivery/1.0'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final address = data['address'] as Map<String, dynamic>?;

        return AddressDetails(
          fullAddress: data['display_name'] ?? '',
          street: address?['road'] ?? address?['pedestrian'] ?? '',
          subLocality: address?['suburb'] ?? address?['neighbourhood'] ?? '',
          locality: address?['city'] ?? address?['town'] ?? address?['village'] ?? '',
          administrativeArea: address?['state'] ?? address?['governorate'] ?? '',
          country: address?['country'] ?? '',
        );
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Get distance and duration between two points
  Future<DistanceResult?> getDistance(LatLng origin, LatLng destination) async {
    try {
      final response = await http.get(Uri.parse(
        '$_osrmBase/route/v1/driving/${origin.longitude},${origin.latitude};${destination.longitude},${destination.latitude}?overview=false'
      ));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['routes']?.isNotEmpty == true) {
          final route = data['routes'][0];
          return DistanceResult(
            distanceMeters: (route['distance'] as num).toDouble(),
            durationSeconds: (route['duration'] as num).toDouble(),
          );
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Format distance for display in Arabic
  String formatDistance(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} كم';
    }
    return '${meters.round()} م';
  }

  /// Format duration for display in Arabic
  String formatDuration(double seconds) {
    final minutes = (seconds / 60).round();
    if (minutes >= 60) {
      final hours = minutes ~/ 60;
      final remainingMinutes = minutes % 60;
      if (remainingMinutes == 0) {
        return '$hours س';
      }
      return '$hours س $remainingMinutes د';
    }
    return '$minutes د';
  }
}

/// Place search result
class PlaceResult {
  final String placeId;
  final String name;
  final String address;
  final LatLng location;

  PlaceResult({
    required this.placeId,
    required this.name,
    required this.address,
    required this.location,
  });
}

/// Structured address details
class AddressDetails {
  final String fullAddress;
  final String street;
  final String subLocality;
  final String locality;
  final String administrativeArea;
  final String country;

  AddressDetails({
    required this.fullAddress,
    required this.street,
    required this.subLocality,
    required this.locality,
    required this.administrativeArea,
    required this.country,
  });

  String get shortAddress {
    final parts = [street, subLocality, locality]
        .where((p) => p.isNotEmpty)
        .toList();
    return parts.isNotEmpty ? parts.join(', ') : fullAddress;
  }
}

/// Distance result
class DistanceResult {
  final double distanceMeters;
  final double durationSeconds;

  DistanceResult({
    required this.distanceMeters,
    required this.durationSeconds,
  });

  String get distanceText => MapService().formatDistance(distanceMeters);
  String get durationText => MapService().formatDuration(durationSeconds);
}
