import 'package:dio/dio.dart';
import '../config/constants.dart';
import '../models/restaurant.dart';
import '../models/api_response.dart';
import 'api_service.dart';

class RestaurantService {
  final ApiService _api;

  RestaurantService(this._api);

  /// Get featured restaurants (high rating)
  Future<ApiResponse<List<Restaurant>>> getFeaturedRestaurants({
    int limit = 10,
  }) async {
    try {
      final response = await _api.get(
        '${AppEndpoints.restaurants}/featured',
        queryParameters: {'limit': limit},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final restaurants = (data['data']?['restaurants'] as List? ?? [])
            .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
            .toList();

        return ApiResponse<List<Restaurant>>(
          success: true,
          message: data['message'] ?? 'تم جلب المطاعم المميزة بنجاح',
          data: restaurants,
        );
      }

      return ApiResponse<List<Restaurant>>(
        success: false,
        message: 'فشل في جلب المطاعم المميزة',
        data: [],
      );
    } on DioException catch (e) {
      return ApiResponse<List<Restaurant>>(
        success: false,
        message: _api.handleError(e),
        data: [],
      );
    }
  }

  /// Get nearby restaurants
  Future<ApiResponse<List<Restaurant>>> getNearbyRestaurants({
    required double lat,
    required double lng,
    double maxDistance = 10,
    int limit = 20,
  }) async {
    try {
      final response = await _api.get(
        '${AppEndpoints.restaurants}/nearby',
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'maxDistance': maxDistance,
          'limit': limit,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final restaurants = (data['data']?['restaurants'] as List? ?? [])
            .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
            .toList();

        return ApiResponse<List<Restaurant>>(
          success: true,
          message: data['message'] ?? 'تم جلب المطاعم القريبة بنجاح',
          data: restaurants,
        );
      }

      return ApiResponse<List<Restaurant>>(
        success: false,
        message: 'فشل في جلب المطاعم القريبة',
        data: [],
      );
    } on DioException catch (e) {
      return ApiResponse<List<Restaurant>>(
        success: false,
        message: _api.handleError(e),
        data: [],
      );
    }
  }

  /// Search restaurants
  Future<ApiResponse<List<Restaurant>>> searchRestaurants(
    RestaurantSearchParams params,
  ) async {
    try {
      final queryParams = <String, dynamic>{};

      if (params.search?.isNotEmpty ?? false) queryParams['q'] = params.search;
      if (params.category?.isNotEmpty ?? false)
        queryParams['category'] = params.category;
      if (params.area?.isNotEmpty ?? false) queryParams['area'] = params.area;
      if (params.priceRange != null)
        queryParams['priceRange'] = params.priceRange;
      if (params.isOpen != null) queryParams['isOpen'] = params.isOpen;
      if (params.sortBy?.isNotEmpty ?? false)
        queryParams['sortBy'] = params.sortBy;
      if (params.sortOrder?.isNotEmpty ?? false)
        queryParams['sortOrder'] = params.sortOrder;
      queryParams['page'] = params.page;
      queryParams['limit'] = params.limit;
      if (params.lat != null) queryParams['lat'] = params.lat;
      if (params.lng != null) queryParams['lng'] = params.lng;
      if (params.lat != null && params.lng != null)
        queryParams['maxDistance'] = params.maxDistance;

      final response = await _api.get(
        AppEndpoints.restaurants,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final restaurants = (data['data'] as List? ?? [])
            .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
            .toList();

        return ApiResponse<List<Restaurant>>(
          success: true,
          message: data['message'] ?? 'تم جلب المطاعم بنجاح',
          data: restaurants,
          pagination: data['pagination'] != null
              ? PaginationInfo.fromJson(data['pagination'])
              : null,
        );
      }

      return ApiResponse<List<Restaurant>>(
        success: false,
        message: 'فشل في جلب المطاعم',
        data: [],
      );
    } on DioException catch (e) {
      return ApiResponse<List<Restaurant>>(
        success: false,
        message: _api.handleError(e),
        data: [],
      );
    }
  }

  /// Get restaurant by slug
  Future<ApiResponse<Restaurant?>> getRestaurantBySlug(String slug) async {
    try {
      final response = await _api.get('${AppEndpoints.restaurants}/$slug');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final restaurant =
            Restaurant.fromJson(data['data']?['restaurant'] ?? {});

        return ApiResponse<Restaurant?>(
          success: true,
          message: data['message'] ?? 'تم جلب بيانات المطعم بنجاح',
          data: restaurant,
        );
      }

      return ApiResponse<Restaurant?>(
        success: false,
        message: 'المطعم غير موجود',
        data: null,
      );
    } on DioException catch (e) {
      return ApiResponse<Restaurant?>(
        success: false,
        message: _api.handleError(e),
        data: null,
      );
    }
  }

  /// Get restaurant menu
  Future<ApiResponse<List<MenuCategory>>> getRestaurantMenu(
    String slug, {
    String? categoryId,
    bool? isAvailable,
    String? search,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (categoryId != null) queryParams['categoryId'] = categoryId;
      if (isAvailable != null) queryParams['isAvailable'] = isAvailable;
      if (search != null) queryParams['search'] = search;

      final response = await _api.get(
        '${AppEndpoints.restaurants}/$slug/menu',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final menu = (data['data']?['menu'] as List? ?? [])
            .map((e) => MenuCategory.fromJson(e as Map<String, dynamic>))
            .toList();

        return ApiResponse<List<MenuCategory>>(
          success: true,
          message: data['message'] ?? 'تم جلب القائمة بنجاح',
          data: menu,
        );
      }

      return ApiResponse<List<MenuCategory>>(
        success: false,
        message: 'فشل في جلب القائمة',
        data: [],
      );
    } on DioException catch (e) {
      return ApiResponse<List<MenuCategory>>(
        success: false,
        message: _api.handleError(e),
        data: [],
      );
    }
  }

  /// Get favorites
  Future<ApiResponse<List<Restaurant>>> getFavorites() async {
    try {
      final response = await _api.get(AppEndpoints.favorites);

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final favorites = (data['data']?['favorites'] as List? ?? [])
            .map((e) => Restaurant.fromJson(e as Map<String, dynamic>))
            .toList();

        return ApiResponse<List<Restaurant>>(
          success: true,
          message: data['message'] ?? 'تم جلب المفضلة بنجاح',
          data: favorites,
        );
      }

      return ApiResponse<List<Restaurant>>(
        success: false,
        message: 'فشل في جلب المفضلة',
        data: [],
      );
    } on DioException catch (e) {
      return ApiResponse<List<Restaurant>>(
        success: false,
        message: _api.handleError(e),
        data: [],
      );
    }
  }

  /// Toggle favorite
  Future<ApiResponse<bool>> toggleFavorite(String restaurantId) async {
    try {
      final response = await _api.post(
        '${AppEndpoints.favorites}/$restaurantId',
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final isFavorite = data['data']?['isFavorite'] ?? false;

        return ApiResponse<bool>(
          success: true,
          message: data['message'] ??
              (isFavorite ? 'تمت الإضافة للمفضلة' : 'تمت الإزالة من المفضلة'),
          data: isFavorite,
        );
      }

      return ApiResponse<bool>(
        success: false,
        message: 'فشل في تحديث المفضلة',
        data: false,
      );
    } on DioException catch (e) {
      return ApiResponse<bool>(
        success: false,
        message: _api.handleError(e),
        data: false,
      );
    }
  }
}
