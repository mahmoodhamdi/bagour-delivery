import 'package:freezed_annotation/freezed_annotation.dart';

part 'restaurant.freezed.dart';
part 'restaurant.g.dart';

@freezed
class Restaurant with _$Restaurant {
  const factory Restaurant({
    @JsonKey(name: '_id') required String id,
    required String name,
    String? nameAr,
    String? slug,
    String? description,
    String? descriptionAr,
    String? logo,
    String? coverImage,
    @Default([]) List<String> images,
    String? phone,
    String? address,
    String? area,
    Location? location,
    @Default([]) List<String> categories,
    @Default([]) List<String> tags,
    @Default(2) int priceRange,
    @Default(0.0) double rating,
    @Default(0) int totalRatings,
    @Default(0) int totalOrders,
    @Default(0.0) double minimumOrder,
    @Default(0.0) double deliveryFee,
    double? freeDeliveryAbove,
    EstimatedDeliveryTime? estimatedDeliveryTime,
    @Default([]) List<WorkingHours> workingHours,
    @Default(true) bool isApproved,
    @Default(true) bool isActive,
    @Default(false) bool isPaused,
    @Default(true) bool acceptsCash,
    @Default(false) bool acceptsOnlinePayment,
    @Default(false) bool isOpen,
    @Default(false) bool isFavorite,
    double? distance,
    DateTime? createdAt,
  }) = _Restaurant;

  factory Restaurant.fromJson(Map<String, dynamic> json) =>
      _$RestaurantFromJson(json);
}

@freezed
class Location with _$Location {
  const factory Location({
    @Default('Point') String type,
    @Default([0.0, 0.0]) List<double> coordinates,
  }) = _Location;

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);
}

@freezed
class EstimatedDeliveryTime with _$EstimatedDeliveryTime {
  const factory EstimatedDeliveryTime({
    @Default(20) int min,
    @Default(40) int max,
  }) = _EstimatedDeliveryTime;

  factory EstimatedDeliveryTime.fromJson(Map<String, dynamic> json) =>
      _$EstimatedDeliveryTimeFromJson(json);
}

@freezed
class WorkingHours with _$WorkingHours {
  const factory WorkingHours({
    required int day,
    @Default(true) bool isOpen,
    @Default([]) List<WorkingShift> shifts,
  }) = _WorkingHours;

  factory WorkingHours.fromJson(Map<String, dynamic> json) =>
      _$WorkingHoursFromJson(json);
}

@freezed
class WorkingShift with _$WorkingShift {
  const factory WorkingShift({
    required String open,
    required String close,
  }) = _WorkingShift;

  factory WorkingShift.fromJson(Map<String, dynamic> json) =>
      _$WorkingShiftFromJson(json);
}

@freezed
class MenuCategory with _$MenuCategory {
  const factory MenuCategory({
    @JsonKey(name: '_id') required String id,
    required String restaurantId,
    required String name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    String? image,
    @Default(0) int sortOrder,
    @Default(true) bool isActive,
    @Default([]) List<MenuItem> items,
  }) = _MenuCategory;

  factory MenuCategory.fromJson(Map<String, dynamic> json) =>
      _$MenuCategoryFromJson(json);
}

@freezed
class MenuItem with _$MenuItem {
  const factory MenuItem({
    @JsonKey(name: '_id') required String id,
    required String restaurantId,
    required String categoryId,
    required String name,
    String? nameAr,
    String? description,
    String? descriptionAr,
    String? image,
    required double price,
    double? discountPrice,
    DateTime? discountEndsAt,
    @Default(15) int preparationTime,
    int? calories,
    String? servingSize,
    @Default([]) List<MenuAddon> addons,
    @Default([]) List<MenuVariation> variations,
    @Default([]) List<String> tags,
    @Default(true) bool isAvailable,
    @Default(false) bool isPopular,
    @Default(false) bool isNew,
    @Default(0) int sortOrder,
    @Default(0) int totalOrders,
  }) = _MenuItem;

  factory MenuItem.fromJson(Map<String, dynamic> json) =>
      _$MenuItemFromJson(json);

  const MenuItem._();

  double get currentPrice => discountPrice ?? price;
  bool get hasDiscount =>
      discountPrice != null &&
      discountPrice! < price &&
      (discountEndsAt == null || discountEndsAt!.isAfter(DateTime.now()));
  int get discountPercentage =>
      hasDiscount ? ((price - discountPrice!) / price * 100).round() : 0;
}

@freezed
class MenuAddon with _$MenuAddon {
  const factory MenuAddon({
    required String name,
    String? nameAr,
    required double price,
    @Default(true) bool isAvailable,
    @Default(5) int maxQuantity,
  }) = _MenuAddon;

  factory MenuAddon.fromJson(Map<String, dynamic> json) =>
      _$MenuAddonFromJson(json);
}

@freezed
class MenuVariation with _$MenuVariation {
  const factory MenuVariation({
    required String name,
    String? nameAr,
    @Default(false) bool isRequired,
    @Default([]) List<VariationOption> options,
  }) = _MenuVariation;

  factory MenuVariation.fromJson(Map<String, dynamic> json) =>
      _$MenuVariationFromJson(json);
}

@freezed
class VariationOption with _$VariationOption {
  const factory VariationOption({
    required String name,
    String? nameAr,
    @Default(0.0) double price,
  }) = _VariationOption;

  factory VariationOption.fromJson(Map<String, dynamic> json) =>
      _$VariationOptionFromJson(json);
}

@freezed
class RestaurantSearchParams with _$RestaurantSearchParams {
  const factory RestaurantSearchParams({
    String? search,
    String? category,
    String? area,
    int? priceRange,
    bool? isOpen,
    String? sortBy,
    String? sortOrder,
    @Default(1) int page,
    @Default(20) int limit,
    double? lat,
    double? lng,
    @Default(10) double maxDistance,
  }) = _RestaurantSearchParams;

  factory RestaurantSearchParams.fromJson(Map<String, dynamic> json) =>
      _$RestaurantSearchParamsFromJson(json);
}
