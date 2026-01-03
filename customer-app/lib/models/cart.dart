import 'package:freezed_annotation/freezed_annotation.dart';
import 'restaurant.dart';

part 'cart.freezed.dart';
part 'cart.g.dart';

/// Selected addon in cart
@freezed
class SelectedAddon with _$SelectedAddon {
  const factory SelectedAddon({
    required String name,
    String? nameAr,
    required double price,
    @Default(1) int quantity,
  }) = _SelectedAddon;

  factory SelectedAddon.fromJson(Map<String, dynamic> json) =>
      _$SelectedAddonFromJson(json);

  const SelectedAddon._();

  double get total => price * quantity;
}

/// Selected variation option in cart
@freezed
class SelectedVariation with _$SelectedVariation {
  const factory SelectedVariation({
    required String variationName,
    String? variationNameAr,
    required String optionName,
    String? optionNameAr,
    @Default(0.0) double price,
  }) = _SelectedVariation;

  factory SelectedVariation.fromJson(Map<String, dynamic> json) =>
      _$SelectedVariationFromJson(json);
}

/// Individual cart item
@freezed
class CartItem with _$CartItem {
  const factory CartItem({
    required String id, // Unique ID for this cart item
    required String menuItemId,
    required String restaurantId,
    required String restaurantName,
    String? restaurantNameAr,
    required String name,
    String? nameAr,
    String? image,
    required double basePrice,
    @Default(1) int quantity,
    @Default([]) List<SelectedAddon> addons,
    @Default([]) List<SelectedVariation> variations,
    String? specialInstructions,
  }) = _CartItem;

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      _$CartItemFromJson(json);

  const CartItem._();

  /// Calculate addons total
  double get addonsTotal =>
      addons.fold(0.0, (sum, addon) => sum + addon.total);

  /// Calculate variations total
  double get variationsTotal =>
      variations.fold(0.0, (sum, variation) => sum + variation.price);

  /// Calculate single item total (without quantity)
  double get unitPrice => basePrice + addonsTotal + variationsTotal;

  /// Calculate total for this cart item (with quantity)
  double get total => unitPrice * quantity;

  /// Display name (Arabic preferred)
  String get displayName => nameAr ?? name;

  /// Restaurant display name (Arabic preferred)
  String get displayRestaurantName => restaurantNameAr ?? restaurantName;

  /// Create from MenuItem with selections
  static CartItem fromMenuItem({
    required MenuItem menuItem,
    required String restaurantId,
    required String restaurantName,
    String? restaurantNameAr,
    List<SelectedAddon>? addons,
    List<SelectedVariation>? variations,
    int quantity = 1,
    String? specialInstructions,
  }) {
    return CartItem(
      id: '${menuItem.id}_${DateTime.now().millisecondsSinceEpoch}',
      menuItemId: menuItem.id,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      restaurantNameAr: restaurantNameAr,
      name: menuItem.name,
      nameAr: menuItem.nameAr,
      image: menuItem.image,
      basePrice: menuItem.currentPrice,
      quantity: quantity,
      addons: addons ?? [],
      variations: variations ?? [],
      specialInstructions: specialInstructions,
    );
  }
}

/// Cart state containing all items
@freezed
class Cart with _$Cart {
  const factory Cart({
    @Default([]) List<CartItem> items,
    String? restaurantId,
    String? restaurantName,
    String? restaurantNameAr,
    double? minimumOrder,
    double? deliveryFee,
    double? freeDeliveryAbove,
  }) = _Cart;

  factory Cart.fromJson(Map<String, dynamic> json) => _$CartFromJson(json);

  const Cart._();

  /// Check if cart is empty
  bool get isEmpty => items.isEmpty;

  /// Check if cart is not empty
  bool get isNotEmpty => items.isNotEmpty;

  /// Get total number of items (counting quantities)
  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  /// Get number of unique items
  int get uniqueItems => items.length;

  /// Calculate subtotal (before fees)
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.total);

  /// Calculate actual delivery fee (considering free delivery threshold)
  double get actualDeliveryFee {
    if (freeDeliveryAbove != null && subtotal >= freeDeliveryAbove!) {
      return 0.0;
    }
    return deliveryFee ?? 0.0;
  }

  /// Check if eligible for free delivery
  bool get hasFreeDelivery =>
      freeDeliveryAbove != null && subtotal >= freeDeliveryAbove!;

  /// Amount needed for free delivery
  double get amountForFreeDelivery {
    if (freeDeliveryAbove == null) return 0.0;
    final remaining = freeDeliveryAbove! - subtotal;
    return remaining > 0 ? remaining : 0.0;
  }

  /// Check if minimum order is met
  bool get meetsMinimumOrder {
    if (minimumOrder == null || minimumOrder == 0) return true;
    return subtotal >= minimumOrder!;
  }

  /// Amount needed to meet minimum order
  double get amountForMinimumOrder {
    if (minimumOrder == null) return 0.0;
    final remaining = minimumOrder! - subtotal;
    return remaining > 0 ? remaining : 0.0;
  }

  /// Calculate total (subtotal + delivery fee)
  double get total => subtotal + actualDeliveryFee;

  /// Restaurant display name
  String? get displayRestaurantName => restaurantNameAr ?? restaurantName;

  /// Check if cart has items from a specific restaurant
  bool hasItemsFromRestaurant(String restaurantId) {
    return items.any((item) => item.restaurantId == restaurantId);
  }

  /// Check if adding from different restaurant
  bool isFromDifferentRestaurant(String newRestaurantId) {
    if (isEmpty) return false;
    return restaurantId != null && restaurantId != newRestaurantId;
  }
}
