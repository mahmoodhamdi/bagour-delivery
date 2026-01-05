import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/order.dart';
import '../../models/cart.dart';
import '../../models/restaurant.dart';
import '../../providers/cart_provider.dart';
import '../../services/api_service.dart';

/// Reorder item model for tracking selection and quantity changes
class ReorderItem {
  final OrderItem originalItem;
  bool isSelected;
  int quantity;

  ReorderItem({
    required this.originalItem,
    this.isSelected = true,
    int? quantity,
  }) : quantity = quantity ?? originalItem.quantity;

  double get total => (originalItem.price + originalItem.addonsTotal + originalItem.variationsTotal) * quantity;
}

/// Reorder state provider
final reorderItemsProvider = StateProvider<List<ReorderItem>>((ref) => []);
final isLoadingRestaurantProvider = StateProvider<bool>((ref) => false);

class ReorderScreen extends ConsumerStatefulWidget {
  final Order order;

  const ReorderScreen({
    super.key,
    required this.order,
  });

  @override
  ConsumerState<ReorderScreen> createState() => _ReorderScreenState();
}

class _ReorderScreenState extends ConsumerState<ReorderScreen> {
  Restaurant? _restaurant;

  @override
  void initState() {
    super.initState();
    // Initialize reorder items from order
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(reorderItemsProvider.notifier).state = widget.order.items
          .map((item) => ReorderItem(originalItem: item))
          .toList();
      _fetchRestaurant();
    });
  }

  Future<void> _fetchRestaurant() async {
    ref.read(isLoadingRestaurantProvider.notifier).state = true;
    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get(
        '/restaurants/${widget.order.restaurant.id}',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        setState(() {
          _restaurant = Restaurant.fromJson(response.data['data']);
        });
      }
    } catch (e) {
      // Restaurant fetch failed - continue with limited info
    } finally {
      ref.read(isLoadingRestaurantProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final reorderItems = ref.watch(reorderItemsProvider);
    final isLoading = ref.watch(isLoadingRestaurantProvider);
    final cart = ref.watch(cartProvider);

    final selectedItems = reorderItems.where((item) => item.isSelected).toList();
    final subtotal = selectedItems.fold<double>(0, (sum, item) => sum + item.total);

    return Scaffold(
      appBar: AppBar(
        title: const Text('إعادة الطلب'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Restaurant Header
                _buildRestaurantHeader(context),

                // Items List
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: reorderItems.length,
                    itemBuilder: (context, index) {
                      final item = reorderItems[index];
                      return _buildReorderItemCard(context, item, index);
                    },
                  ),
                ),

                // Bottom Summary & Button
                _buildBottomSection(context, selectedItems, subtotal, cart),
              ],
            ),
    );
  }

  Widget _buildRestaurantHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: widget.order.restaurant.logo != null
                ? CachedNetworkImage(
                    imageUrl: widget.order.restaurant.logo!,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => _buildPlaceholder(),
                    errorWidget: (context, url, error) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.order.restaurant.displayName,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.receipt_long,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'طلب #${widget.order.orderNumber}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.access_time,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(widget.order.createdAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: 56,
      height: 56,
      color: AppColors.background,
      child: const Icon(
        Icons.restaurant,
        color: AppColors.textHint,
      ),
    );
  }

  Widget _buildReorderItemCard(BuildContext context, ReorderItem item, int index) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selection Checkbox
            Checkbox(
              value: item.isSelected,
              onChanged: (value) {
                final items = ref.read(reorderItemsProvider);
                items[index].isSelected = value ?? false;
                ref.read(reorderItemsProvider.notifier).state = [...items];
              },
              activeColor: AppColors.primary,
            ),

            // Item Image
            if (item.originalItem.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: item.originalItem.image!,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 60,
                    height: 60,
                    color: AppColors.background,
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 60,
                    height: 60,
                    color: AppColors.background,
                    child: const Icon(Icons.fastfood, color: AppColors.textHint),
                  ),
                ),
              ),
            if (item.originalItem.image != null) const SizedBox(width: 12),

            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.originalItem.displayName,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: item.isSelected
                              ? AppColors.textPrimary
                              : AppColors.textHint,
                        ),
                  ),
                  if (item.originalItem.variations.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      children: item.originalItem.variations.map((v) {
                        return Text(
                          '${v.nameAr ?? v.name}: ${v.optionAr ?? v.option}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        );
                      }).toList(),
                    ),
                  ],
                  if (item.originalItem.addons.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 4,
                      runSpacing: 2,
                      children: item.originalItem.addons.map((a) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '+ ${a.nameAr ?? a.name}',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Quantity Controls
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildQuantityButton(
                              icon: Icons.remove,
                              onPressed: item.isSelected && item.quantity > 1
                                  ? () {
                                      final items = ref.read(reorderItemsProvider);
                                      items[index].quantity--;
                                      ref.read(reorderItemsProvider.notifier).state =
                                          [...items];
                                    }
                                  : null,
                            ),
                            Container(
                              width: 36,
                              alignment: Alignment.center,
                              child: Text(
                                '${item.quantity}',
                                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                            _buildQuantityButton(
                              icon: Icons.add,
                              onPressed: item.isSelected
                                  ? () {
                                      final items = ref.read(reorderItemsProvider);
                                      items[index].quantity++;
                                      ref.read(reorderItemsProvider.notifier).state =
                                          [...items];
                                    }
                                  : null,
                            ),
                          ],
                        ),
                      ),

                      // Price
                      Text(
                        '${item.total.toStringAsFixed(2)} ج.م',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: item.isSelected
                                  ? AppColors.primary
                                  : AppColors.textHint,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 18,
            color: onPressed != null ? AppColors.primary : AppColors.textHint,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomSection(
    BuildContext context,
    List<ReorderItem> selectedItems,
    double subtotal,
    Cart cart,
  ) {
    final hasSelection = selectedItems.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'العناصر المحددة',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${selectedItems.length} عنصر',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'المجموع الفرعي',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${subtotal.toStringAsFixed(2)} ج.م',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Select All / Deselect All
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      final items = ref.read(reorderItemsProvider);
                      for (var item in items) {
                        item.isSelected = true;
                      }
                      ref.read(reorderItemsProvider.notifier).state = [...items];
                    },
                    child: const Text('تحديد الكل'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      final items = ref.read(reorderItemsProvider);
                      for (var item in items) {
                        item.isSelected = false;
                      }
                      ref.read(reorderItemsProvider.notifier).state = [...items];
                    },
                    child: const Text('إلغاء التحديد'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Add to Cart Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: hasSelection ? () => _addToCart(context, selectedItems, cart) : null,
                icon: const Icon(Icons.shopping_cart_outlined),
                label: Text(
                  cart.isEmpty
                      ? 'إضافة إلى السلة'
                      : cart.isFromDifferentRestaurant(widget.order.restaurant.id)
                          ? 'استبدال السلة'
                          : 'إضافة إلى السلة',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            // Different Restaurant Warning
            if (cart.isNotEmpty &&
                cart.isFromDifferentRestaurant(widget.order.restaurant.id)) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 14,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      'سيتم استبدال العناصر الحالية في السلة',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _addToCart(
    BuildContext context,
    List<ReorderItem> selectedItems,
    Cart cart,
  ) async {
    if (_restaurant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى الانتظار حتى يتم تحميل بيانات المطعم'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    // Check if cart has items from different restaurant
    if (cart.isFromDifferentRestaurant(widget.order.restaurant.id)) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('استبدال السلة؟'),
          content: Text(
            'لديك عناصر من "${cart.displayRestaurantName}" في السلة. '
            'هل تريد استبدالها بعناصر من "${widget.order.restaurant.displayName}"؟',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('استبدال'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;

      // Clear cart
      await ref.read(cartProvider.notifier).clearCart();
    }

    // Add items to cart
    final cartNotifier = ref.read(cartProvider.notifier);
    int addedCount = 0;

    for (final item in selectedItems) {
      // Create a pseudo MenuItem for the cart
      final menuItem = MenuItem(
        id: item.originalItem.menuItemId,
        restaurantId: widget.order.restaurant.id,
        categoryId: '',
        name: item.originalItem.name,
        nameAr: item.originalItem.nameAr,
        price: item.originalItem.price,
        image: item.originalItem.image,
      );

      // Convert order addons to cart addons
      final cartAddons = item.originalItem.addons.map((a) {
        return SelectedAddon(
          name: a.name,
          nameAr: a.nameAr,
          price: a.price,
          quantity: a.quantity,
        );
      }).toList();

      // Convert order variations to cart variations
      final cartVariations = item.originalItem.variations.map((v) {
        return SelectedVariation(
          variationName: v.name,
          variationNameAr: v.nameAr,
          optionName: v.option,
          optionNameAr: v.optionAr,
          price: v.price,
        );
      }).toList();

      final success = await cartNotifier.addItem(
        menuItem: menuItem,
        restaurant: _restaurant!,
        addons: cartAddons,
        variations: cartVariations,
        quantity: item.quantity,
        specialInstructions: item.originalItem.specialInstructions,
      );

      if (success) addedCount++;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تمت إضافة $addedCount عنصر إلى السلة'),
          backgroundColor: AppColors.success,
          action: SnackBarAction(
            label: 'عرض السلة',
            textColor: Colors.white,
            onPressed: () => context.push(AppRoutes.cart),
          ),
        ),
      );

      // Navigate to cart
      context.push(AppRoutes.cart);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
