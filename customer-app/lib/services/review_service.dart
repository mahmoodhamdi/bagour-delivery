import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';

final reviewServiceProvider = Provider<ReviewService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ReviewService(apiService);
});

class ReviewService {
  final ApiService _apiService;

  ReviewService(this._apiService);

  /// Submit a review for an order
  Future<void> submitOrderReview({
    required String orderId,
    required double restaurantRating,
    required double foodRating,
    double? driverRating,
    String? comment,
    List<String>? images,
  }) async {
    try {
      final response = await _apiService.post(
        '/orders/$orderId/rate',
        data: {
          // Backend expects 'restaurant', 'food', 'driver' (not restaurantRating)
          'restaurant': restaurantRating.toInt(),
          'food': foodRating.toInt(),
          if (driverRating != null) 'driver': driverRating.toInt(),
          if (comment != null && comment.isNotEmpty) 'comment': comment,
          if (images != null && images.isNotEmpty) 'images': images,
        },
      );

      if (!response.data['success']) {
        throw Exception(response.data['message'] ?? 'فشل إرسال التقييم');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'حدث خطأ أثناء إرسال التقييم',
        );
      } else {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }
    }
  }

  /// Get my reviews
  Future<List<Review>> getMyReviews({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/customer/reviews',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.data['success']) {
        final List<dynamic> reviewsData = response.data['data']['reviews'];
        return reviewsData.map((json) => Review.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'فشل جلب التقييمات');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'حدث خطأ أثناء جلب التقييمات',
        );
      } else {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }
    }
  }

  /// Get restaurant reviews
  Future<List<Review>> getRestaurantReviews({
    required String restaurantId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _apiService.get(
        '/restaurants/$restaurantId/reviews',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.data['success']) {
        final List<dynamic> reviewsData = response.data['data']['reviews'];
        return reviewsData.map((json) => Review.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'فشل جلب التقييمات');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'حدث خطأ أثناء جلب التقييمات',
        );
      } else {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }
    }
  }
}

/// Review model
class Review {
  final String id;
  final String orderId;
  final double restaurantRating;
  final double foodRating;
  final double? driverRating;
  final String? comment;
  final List<String> images;
  final String? restaurantReply;
  final DateTime? repliedAt;
  final DateTime createdAt;
  final RestaurantInfo? restaurant;
  final CustomerInfo? customer;

  Review({
    required this.id,
    required this.orderId,
    required this.restaurantRating,
    required this.foodRating,
    this.driverRating,
    this.comment,
    this.images = const [],
    this.restaurantReply,
    this.repliedAt,
    required this.createdAt,
    this.restaurant,
    this.customer,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] as String,
      orderId: json['orderId'] as String,
      restaurantRating: (json['restaurantRating'] as num).toDouble(),
      foodRating: (json['foodRating'] as num).toDouble(),
      driverRating: json['driverRating'] != null
          ? (json['driverRating'] as num).toDouble()
          : null,
      comment: json['comment'] as String?,
      images: (json['images'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      restaurantReply: json['restaurantReply'] as String?,
      repliedAt: json['repliedAt'] != null
          ? DateTime.parse(json['repliedAt'] as String)
          : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      restaurant: json['restaurant'] != null
          ? RestaurantInfo.fromJson(json['restaurant'] as Map<String, dynamic>)
          : null,
      customer: json['customer'] != null
          ? CustomerInfo.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'orderId': orderId,
      'restaurantRating': restaurantRating,
      'foodRating': foodRating,
      if (driverRating != null) 'driverRating': driverRating,
      if (comment != null) 'comment': comment,
      'images': images,
      if (restaurantReply != null) 'restaurantReply': restaurantReply,
      if (repliedAt != null) 'repliedAt': repliedAt!.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class RestaurantInfo {
  final String id;
  final String name;
  final String? logo;

  RestaurantInfo({
    required this.id,
    required this.name,
    this.logo,
  });

  factory RestaurantInfo.fromJson(Map<String, dynamic> json) {
    return RestaurantInfo(
      id: json['_id'] as String? ?? json['id'] as String,
      name: json['name'] as String,
      logo: json['logo'] as String?,
    );
  }
}

class CustomerInfo {
  final String name;
  final String? avatar;

  CustomerInfo({
    required this.name,
    this.avatar,
  });

  factory CustomerInfo.fromJson(Map<String, dynamic> json) {
    return CustomerInfo(
      name: json['name'] as String,
      avatar: json['avatar'] as String?,
    );
  }
}
