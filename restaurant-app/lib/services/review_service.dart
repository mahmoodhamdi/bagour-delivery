import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/constants.dart';
import 'api_service.dart';

/// Review author model
class ReviewAuthor {
  final String id;
  final String name;
  final String? avatar;

  ReviewAuthor({
    required this.id,
    required this.name,
    this.avatar,
  });

  factory ReviewAuthor.fromJson(Map<String, dynamic> json) {
    return ReviewAuthor(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? 'مستخدم',
      avatar: json['avatar'],
    );
  }
}

/// Review reply model
class ReviewReply {
  final String content;
  final DateTime createdAt;

  ReviewReply({
    required this.content,
    required this.createdAt,
  });

  factory ReviewReply.fromJson(Map<String, dynamic> json) {
    return ReviewReply(
      content: json['content'] ?? '',
      createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }
}

/// Review model
class Review {
  final String id;
  final ReviewAuthor customer;
  final String? orderId;
  final String? orderNumber;
  final int rating;
  final String? comment;
  final ReviewReply? reply;
  final bool isPublic;
  final DateTime createdAt;

  Review({
    required this.id,
    required this.customer,
    this.orderId,
    this.orderNumber,
    required this.rating,
    this.comment,
    this.reply,
    this.isPublic = true,
    required this.createdAt,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? json['id'] ?? '',
      customer: ReviewAuthor.fromJson(json['customer'] ?? json['user'] ?? {}),
      orderId: json['order']?['_id'] ?? json['orderId'],
      orderNumber: json['order']?['orderNumber'] ?? json['orderNumber'],
      rating: json['rating'] ?? 0,
      comment: json['comment'],
      reply: json['reply'] != null ? ReviewReply.fromJson(json['reply']) : null,
      isPublic: json['isPublic'] ?? true,
      createdAt: DateTime.parse(
          json['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  bool get hasReply => reply != null;
}

/// Reviews list response with pagination
class ReviewsResponse {
  final List<Review> reviews;
  final int total;
  final int page;
  final int pages;

  ReviewsResponse({
    required this.reviews,
    required this.total,
    required this.page,
    required this.pages,
  });

  factory ReviewsResponse.fromJson(Map<String, dynamic> json) {
    return ReviewsResponse(
      reviews: (json['reviews'] ?? json['data'] ?? [])
          .map<Review>((r) => Review.fromJson(r))
          .toList(),
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      pages: json['pages'] ?? 1,
    );
  }
}

/// Review statistics
class ReviewStats {
  final int totalReviews;
  final double averageRating;
  final int fiveStars;
  final int fourStars;
  final int threeStars;
  final int twoStars;
  final int oneStar;
  final int repliedCount;
  final int unrepliedCount;

  ReviewStats({
    this.totalReviews = 0,
    this.averageRating = 0,
    this.fiveStars = 0,
    this.fourStars = 0,
    this.threeStars = 0,
    this.twoStars = 0,
    this.oneStar = 0,
    this.repliedCount = 0,
    this.unrepliedCount = 0,
  });

  factory ReviewStats.fromJson(Map<String, dynamic> json) {
    return ReviewStats(
      totalReviews: json['totalReviews'] ?? json['total'] ?? 0,
      averageRating: (json['averageRating'] ?? json['average'] ?? 0).toDouble(),
      fiveStars: json['fiveStars'] ?? json['ratings']?['5'] ?? 0,
      fourStars: json['fourStars'] ?? json['ratings']?['4'] ?? 0,
      threeStars: json['threeStars'] ?? json['ratings']?['3'] ?? 0,
      twoStars: json['twoStars'] ?? json['ratings']?['2'] ?? 0,
      oneStar: json['oneStar'] ?? json['ratings']?['1'] ?? 0,
      repliedCount: json['repliedCount'] ?? 0,
      unrepliedCount: json['unrepliedCount'] ?? 0,
    );
  }

  /// Get count for specific rating
  int getCountForRating(int rating) {
    switch (rating) {
      case 5:
        return fiveStars;
      case 4:
        return fourStars;
      case 3:
        return threeStars;
      case 2:
        return twoStars;
      case 1:
        return oneStar;
      default:
        return 0;
    }
  }

  /// Get percentage for specific rating
  double getPercentageForRating(int rating) {
    if (totalReviews == 0) return 0;
    return (getCountForRating(rating) / totalReviews) * 100;
  }
}

/// Review service for review operations
class ReviewService {
  final ApiService _api;

  ReviewService(this._api);

  /// Get reviews with pagination and filters
  Future<ReviewsResponse> getReviews({
    int page = 1,
    int limit = 20,
    int? rating,
    bool? hasReply,
    String? sortBy,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };
      if (rating != null) queryParams['rating'] = rating;
      if (hasReply != null) queryParams['hasReply'] = hasReply;
      if (sortBy != null) queryParams['sortBy'] = sortBy;

      final response = await _api.get(
        AppEndpoints.reviews,
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        return ReviewsResponse.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'فشل في جلب التقييمات');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get review statistics
  Future<ReviewStats> getReviewStats() async {
    try {
      final response = await _api.get('${AppEndpoints.reviews}/stats');

      if (response.data['success'] == true) {
        return ReviewStats.fromJson(response.data['data']);
      }

      throw Exception(
          response.data['message'] ?? 'فشل في جلب إحصائيات التقييمات');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Reply to a review
  Future<Review> replyToReview(String reviewId, String content) async {
    try {
      final response = await _api.post(
        '${AppEndpoints.reviews}/$reviewId/reply',
        data: {'content': content},
      );

      if (response.data['success'] == true) {
        return Review.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'فشل في إرسال الرد');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Update reply to a review
  Future<Review> updateReply(String reviewId, String content) async {
    try {
      final response = await _api.put(
        '${AppEndpoints.reviews}/$reviewId/reply',
        data: {'content': content},
      );

      if (response.data['success'] == true) {
        return Review.fromJson(response.data['data']);
      }

      throw Exception(response.data['message'] ?? 'فشل في تحديث الرد');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Delete reply to a review
  Future<void> deleteReply(String reviewId) async {
    try {
      final response = await _api.delete(
        '${AppEndpoints.reviews}/$reviewId/reply',
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'فشل في حذف الرد');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Report a review
  Future<void> reportReview(String reviewId, String reason) async {
    try {
      final response = await _api.post(
        '${AppEndpoints.reviews}/$reviewId/report',
        data: {'reason': reason},
      );

      if (response.data['success'] != true) {
        throw Exception(response.data['message'] ?? 'فشل في الإبلاغ عن التقييم');
      }
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Get unreplied reviews
  Future<ReviewsResponse> getUnrepliedReviews({
    int page = 1,
    int limit = 20,
  }) async {
    return getReviews(page: page, limit: limit, hasReply: false);
  }

  /// Handle Dio errors
  Exception _handleDioError(DioException e) {
    if (e.response != null) {
      final data = e.response?.data;
      if (data is Map && data.containsKey('message')) {
        return Exception(data['message']);
      }
    }
    return Exception('حدث خطأ ما');
  }
}

/// Review service provider
final reviewServiceProvider = Provider<ReviewService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return ReviewService(apiService);
});

/// Reviews list provider with filters
final reviewsProvider = FutureProvider.family
    .autoDispose<ReviewsResponse, Map<String, dynamic>>((ref, params) async {
  final service = ref.watch(reviewServiceProvider);
  return service.getReviews(
    page: params['page'] ?? 1,
    limit: params['limit'] ?? 20,
    rating: params['rating'],
    hasReply: params['hasReply'],
    sortBy: params['sortBy'],
  );
});

/// Review statistics provider
final reviewStatsProvider =
    FutureProvider.autoDispose<ReviewStats>((ref) async {
  final service = ref.watch(reviewServiceProvider);
  return service.getReviewStats();
});

/// Unreplied reviews provider
final unrepliedReviewsProvider =
    FutureProvider.autoDispose<ReviewsResponse>((ref) async {
  final service = ref.watch(reviewServiceProvider);
  return service.getUnrepliedReviews();
});
