import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart.dart';
import '../models/restaurant.dart';

const String _cartStorageKey = 'bagour_cart';

/// Cart state notifier for managing cart operations
class CartNotifier extends StateNotifier<Cart> {
  CartNotifier() : super(const Cart()) {
    _loadCart();
  }

  /// Load cart from local storage
  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString(_cartStorageKey);
      if (cartJson != null) {
        final cartMap = json.decode(cartJson) as Map<String, dynamic>;
        state = Cart.fromJson(cartMap);
      }
    } catch (e) {
      // If loading fails, start with empty cart
      state = const Cart();
    }
  }

  /// Save cart to local storage
  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_cartStorageKey, json.encode(state.toJson()));
    } catch (e) {
      // Ignore save errors
    }
  }

  /// Add item to cart
  Future<bool> addItem({
    required MenuItem menuItem,
    required Restaurant restaurant,
    List<SelectedAddon>? addons,
    List<SelectedVariation>? variations,
    int quantity = 1,
    String? specialInstructions,
  }) async {
    // Check if cart has items from different restaurant
    if (state.isFromDifferentRestaurant(restaurant.id)) {
      return false; // Caller should handle this (show confirmation dialog)
    }

    // Create cart item
    final cartItem = CartItem.fromMenuItem(
      menuItem: menuItem,
      restaurantId: restaurant.id,
      restaurantName: restaurant.name,
      restaurantNameAr: restaurant.nameAr,
      addons: addons,
      variations: variations,
      quantity: quantity,
      specialInstructions: specialInstructions,
    );

    // Update restaurant info if this is first item
    if (state.isEmpty) {
      state = state.copyWith(
        restaurantId: restaurant.id,
        restaurantName: restaurant.name,
        restaurantNameAr: restaurant.nameAr,
        minimumOrder: restaurant.minimumOrder,
        deliveryFee: restaurant.deliveryFee,
        freeDeliveryAbove: restaurant.freeDeliveryAbove,
      );
    }

    // Add item to cart
    state = state.copyWith(
      items: [...state.items, cartItem],
    );

    await _saveCart();
    return true;
  }

  /// Add item with confirmation to clear existing cart
  Future<void> addItemWithClear({
    required MenuItem menuItem,
    required Restaurant restaurant,
    List<SelectedAddon>? addons,
    List<SelectedVariation>? variations,
    int quantity = 1,
    String? specialInstructions,
  }) async {
    // Clear cart first
    await clearCart();

    // Add the new item
    await addItem(
      menuItem: menuItem,
      restaurant: restaurant,
      addons: addons,
      variations: variations,
      quantity: quantity,
      specialInstructions: specialInstructions,
    );
  }

  /// Remove item from cart
  Future<void> removeItem(String itemId) async {
    state = state.copyWith(
      items: state.items.where((item) => item.id != itemId).toList(),
    );

    // Clear restaurant info if cart is now empty
    if (state.isEmpty) {
      state = const Cart();
    }

    await _saveCart();
  }

  /// Update item quantity
  Future<void> updateQuantity(String itemId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(itemId);
      return;
    }

    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(quantity: quantity);
        }
        return item;
      }).toList(),
    );

    await _saveCart();
  }

  /// Increment item quantity
  Future<void> incrementQuantity(String itemId) async {
    final item = state.items.firstWhere(
      (item) => item.id == itemId,
      orElse: () => throw Exception('Item not found'),
    );
    await updateQuantity(itemId, item.quantity + 1);
  }

  /// Decrement item quantity
  Future<void> decrementQuantity(String itemId) async {
    final item = state.items.firstWhere(
      (item) => item.id == itemId,
      orElse: () => throw Exception('Item not found'),
    );
    await updateQuantity(itemId, item.quantity - 1);
  }

  /// Update special instructions for an item
  Future<void> updateSpecialInstructions(
    String itemId,
    String? instructions,
  ) async {
    state = state.copyWith(
      items: state.items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(specialInstructions: instructions);
        }
        return item;
      }).toList(),
    );

    await _saveCart();
  }

  /// Clear all items from cart
  Future<void> clearCart() async {
    state = const Cart();
    await _saveCart();
  }

  /// Update delivery fee (e.g., when applying coupon)
  void updateDeliveryFee(double fee) {
    state = state.copyWith(deliveryFee: fee);
  }

  /// Check if a specific menu item is in cart
  bool hasItem(String menuItemId) {
    return state.items.any((item) => item.menuItemId == menuItemId);
  }

  /// Get total quantity of a specific menu item in cart
  int getItemQuantity(String menuItemId) {
    return state.items
        .where((item) => item.menuItemId == menuItemId)
        .fold(0, (sum, item) => sum + item.quantity);
  }

  /// Get cart items by menu item ID
  List<CartItem> getItemsByMenuItemId(String menuItemId) {
    return state.items
        .where((item) => item.menuItemId == menuItemId)
        .toList();
  }
}

/// Cart provider
final cartProvider = StateNotifierProvider<CartNotifier, Cart>((ref) {
  return CartNotifier();
});

/// Provider to check if cart is empty
final isCartEmptyProvider = Provider<bool>((ref) {
  return ref.watch(cartProvider).isEmpty;
});

/// Provider for cart item count
final cartItemCountProvider = Provider<int>((ref) {
  return ref.watch(cartProvider).totalItems;
});

/// Provider for cart subtotal
final cartSubtotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).subtotal;
});

/// Provider for cart total (including delivery)
final cartTotalProvider = Provider<double>((ref) {
  return ref.watch(cartProvider).total;
});

/// Provider to check if minimum order is met
final meetsMinimumOrderProvider = Provider<bool>((ref) {
  return ref.watch(cartProvider).meetsMinimumOrder;
});

/// Provider for current restaurant in cart
final cartRestaurantIdProvider = Provider<String?>((ref) {
  return ref.watch(cartProvider).restaurantId;
});

/// Provider to check if adding from different restaurant
final isDifferentRestaurantProvider =
    Provider.family<bool, String>((ref, restaurantId) {
  return ref.watch(cartProvider).isFromDifferentRestaurant(restaurantId);
});
