import 'package:freezed_annotation/freezed_annotation.dart';

part 'review.freezed.dart';
part 'review.g.dart';

/// Review model for order ratings and reviews
@freezed
class Review with _$Review {
  const factory Review({
    required String id,
    required String orderId,
    required String customerId,
    required String restaurantId,
    String? driverId,
    required double restaurantRating,
    required double foodRating,
    double? driverRating,
    String? comment,
    @Default([]) List<String> images,
    String? restaurantReply,
    DateTime? repliedAt,
    @Default(true) bool isVisible,
    @Default(false) bool isReported,
    String? reportReason,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _Review;

  factory Review.fromJson(Map<String, dynamic> json) => _$ReviewFromJson(json);
}

/// Request model for submitting a review/rating
@freezed
class RateOrderRequest with _$RateOrderRequest {
  const factory RateOrderRequest({
    double? restaurant,
    double? driver,
    double? food,
    @Default('') String comment,
  }) = _RateOrderRequest;

  factory RateOrderRequest.fromJson(Map<String, dynamic> json) =>
      _$RateOrderRequestFromJson(json);
}

extension RateOrderRequestExtension on RateOrderRequest {
  Map<String, dynamic> toRequestJson() => {
        if (restaurant != null) 'restaurant': restaurant,
        if (driver != null) 'driver': driver,
        if (food != null) 'food': food,
        if (comment.isNotEmpty) 'comment': comment,
      };
}

/// Customer's reviews list item (simplified)
@freezed
class CustomerReview with _$CustomerReview {
  const factory CustomerReview({
    required String id,
    required String orderId,
    required String orderNumber,
    required String restaurantId,
    required String restaurantName,
    String? restaurantLogo,
    required double restaurantRating,
    required double foodRating,
    double? driverRating,
    String? comment,
    String? restaurantReply,
    DateTime? repliedAt,
    required DateTime createdAt,
  }) = _CustomerReview;

  factory CustomerReview.fromJson(Map<String, dynamic> json) =>
      _$CustomerReviewFromJson(json);
}
