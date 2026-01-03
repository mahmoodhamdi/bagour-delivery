import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/cart_provider.dart';
import 'widgets/cart_item_card.dart';
import 'widgets/cart_summary.dart';
import 'widgets/empty_cart.dart';

class CartScreen extends ConsumerStatefulWidget {
  const CartScreen({super.key});

  @override
  ConsumerState<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends ConsumerState<CartScreen> {
  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('سلة التسوق'),
        actions: [
          if (cart.isNotEmpty)
            IconButton(
              onPressed: () => _showClearCartDialog(context),
              icon: const Icon(Icons.delete_outline),
              tooltip: 'إفراغ السلة',
            ),
        ],
      ),
      body: cart.isEmpty
          ? const EmptyCart()
          : Column(
              children: [
                // Restaurant Header
                if (cart.displayRestaurantName != null)
                  _buildRestaurantHeader(context, cart.displayRestaurantName!),
                // Cart Items List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 8, bottom: 16),
                    itemCount: cart.items.length,
                    itemBuilder: (context, index) {
                      final item = cart.items[index];
                      return CartItemCard(
                        item: item,
                        onIncrement: () => ref
                            .read(cartProvider.notifier)
                            .incrementQuantity(item.id),
                        onDecrement: () => ref
                            .read(cartProvider.notifier)
                            .decrementQuantity(item.id),
                        onRemove: () => _showRemoveItemDialog(context, item.id),
                        onEditInstructions: () =>
                            _showInstructionsDialog(context, item.id,
                                item.specialInstructions),
                      );
                    },
                  ),
                ),
                // Cart Summary
                CartSummary(
                  cart: cart,
                  onCheckout: () => _onCheckout(context),
                ),
              ],
            ),
    );
  }

  Widget _buildRestaurantHeader(BuildContext context, String restaurantName) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.restaurant,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الطلب من',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                Text(
                  restaurantName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onCheckout(BuildContext context) {
    final cart = ref.read(cartProvider);
    if (!cart.meetsMinimumOrder) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'الحد الأدنى للطلب ${cart.minimumOrder?.toStringAsFixed(0)} ج.م',
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }
    context.push(AppRoutes.checkout);
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إفراغ السلة'),
        content: const Text('هل أنت متأكد من إفراغ سلة التسوق؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(cartProvider.notifier).clearCart();
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('إفراغ'),
          ),
        ],
      ),
    );
  }

  void _showRemoveItemDialog(BuildContext context, String itemId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف المنتج'),
        content: const Text('هل أنت متأكد من حذف هذا المنتج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(cartProvider.notifier).removeItem(itemId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showInstructionsDialog(
    BuildContext context,
    String itemId,
    String? currentInstructions,
  ) {
    final controller = TextEditingController(text: currentInstructions);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ملاحظات خاصة'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'مثال: بدون بصل، زيادة صوص...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(cartProvider.notifier).updateSpecialInstructions(
                    itemId,
                    controller.text.isEmpty ? null : controller.text,
                  );
              Navigator.pop(context);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}
