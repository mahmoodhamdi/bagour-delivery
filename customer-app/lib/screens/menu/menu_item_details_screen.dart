import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/restaurant.dart';
import '../../models/cart.dart';
import '../../providers/cart_provider.dart';

class MenuItemDetailsScreen extends ConsumerStatefulWidget {
  final MenuItem menuItem;
  final Restaurant restaurant;

  const MenuItemDetailsScreen({
    super.key,
    required this.menuItem,
    required this.restaurant,
  });

  @override
  ConsumerState<MenuItemDetailsScreen> createState() => _MenuItemDetailsScreenState();
}

class _MenuItemDetailsScreenState extends ConsumerState<MenuItemDetailsScreen> {
  int _quantity = 1;
  final Set<String> _selectedAddons = {}; // Store addon names
  String? _selectedVariationOption;
  final TextEditingController _instructionsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-select first variation option if available
    if (widget.menuItem.variations.isNotEmpty &&
        widget.menuItem.variations.first.options.isNotEmpty) {
      _selectedVariationOption = widget.menuItem.variations.first.options.first.name;
    }
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  double _calculateTotalPrice() {
    double basePrice = widget.menuItem.currentPrice;

    // Add addons price
    for (final addonName in _selectedAddons) {
      final addon = widget.menuItem.addons.firstWhere((a) => a.name == addonName);
      basePrice += addon.price;
    }

    // Add variation price
    if (_selectedVariationOption != null && widget.menuItem.variations.isNotEmpty) {
      final variation = widget.menuItem.variations.first;
      final selectedOption = variation.options.firstWhere(
        (o) => o.name == _selectedVariationOption,
      );
      basePrice += selectedOption.price;
    }

    return basePrice * _quantity;
  }

  Future<void> _addToCart() async {
    final cartNotifier = ref.read(cartProvider.notifier);

    // Build selected addons list
    final selectedAddonsList = _selectedAddons.map((addonName) {
      final addon = widget.menuItem.addons.firstWhere((a) => a.name == addonName);
      return SelectedAddon(
        name: addon.name,
        nameAr: addon.nameAr,
        price: addon.price,
      );
    }).toList();

    // Build selected variation
    final selectedVariations = <SelectedVariation>[];
    if (_selectedVariationOption != null && widget.menuItem.variations.isNotEmpty) {
      final variation = widget.menuItem.variations.first;
      final selectedOption = variation.options.firstWhere(
        (o) => o.name == _selectedVariationOption,
      );
      selectedVariations.add(SelectedVariation(
        variationName: variation.name,
        variationNameAr: variation.nameAr,
        optionName: selectedOption.name,
        optionNameAr: selectedOption.nameAr,
        price: selectedOption.price,
      ));
    }

    await cartNotifier.addItem(
      menuItem: widget.menuItem,
      restaurant: widget.restaurant,
      addons: selectedAddonsList,
      variations: selectedVariations,
      quantity: _quantity,
      specialInstructions: _instructionsController.text.trim().isEmpty
          ? null
          : _instructionsController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تمت الإضافة إلى السلة'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalPrice = _calculateTotalPrice();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.menuItem.name),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(0),
              children: [
                // Image
                if (widget.menuItem.image != null)
                  CachedNetworkImage(
                    imageUrl: widget.menuItem.image!,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      height: 250,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported, size: 50),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.menuItem.name,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (widget.menuItem.nameAr != null)
                                  Text(
                                    widget.menuItem.nameAr!,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              if (widget.menuItem.hasDiscount)
                                Text(
                                  '${widget.menuItem.price} ج.م',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    decoration: TextDecoration.lineThrough,
                                    color: Colors.grey,
                                  ),
                                ),
                              Text(
                                '${widget.menuItem.currentPrice} ج.م',
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Description
                      if (widget.menuItem.description != null) ...[
                        Text(
                          widget.menuItem.description!,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Info Row
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (widget.menuItem.calories != null)
                            _buildInfoChip(
                              icon: Icons.local_fire_department,
                              label: '${widget.menuItem.calories} سعرة',
                            ),
                          _buildInfoChip(
                            icon: Icons.access_time,
                            label: '${widget.menuItem.preparationTime} دقيقة',
                          ),
                          if (widget.menuItem.servingSize != null)
                            _buildInfoChip(
                              icon: Icons.people,
                              label: widget.menuItem.servingSize!,
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Variations
                      if (widget.menuItem.variations.isNotEmpty) ...[
                        Text(
                          widget.menuItem.variations.first.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: widget.menuItem.variations.first.options.map((option) {
                            final isSelected = _selectedVariationOption == option.name;
                            return ChoiceChip(
                              label: Text(
                                option.price > 0
                                    ? '${option.name} (+${option.price} ج.م)'
                                    : option.name,
                              ),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedVariationOption = selected ? option.name : null;
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Addons
                      if (widget.menuItem.addons.isNotEmpty) ...[
                        const Text(
                          'الإضافات',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...widget.menuItem.addons.map((addon) {
                          final isSelected = _selectedAddons.contains(addon.name);
                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(addon.name),
                            subtitle: Text(
                              '${addon.price} ج.م',
                              style: const TextStyle(color: Colors.green),
                            ),
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedAddons.add(addon.name);
                                } else {
                                  _selectedAddons.remove(addon.name);
                                }
                              });
                            },
                          );
                        }),
                        const SizedBox(height: 24),
                      ],

                      // Special Instructions
                      const Text(
                        'ملاحظات خاصة',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _instructionsController,
                        maxLines: 3,
                        maxLength: 200,
                        decoration: const InputDecoration(
                          hintText: 'أضف أي ملاحظات خاصة بالطلب...',
                          border: OutlineInputBorder(),
                          counterText: '',
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_instructionsController.text.length}/200',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Bar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Quantity Selector
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: _quantity > 1
                              ? () => setState(() => _quantity--)
                              : null,
                          icon: const Icon(Icons.remove),
                        ),
                        Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () => setState(() => _quantity++),
                          icon: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Add to Cart Button
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _addToCart,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'إضافة للسلة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${totalPrice.toStringAsFixed(2)} ج.م',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[700]),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
