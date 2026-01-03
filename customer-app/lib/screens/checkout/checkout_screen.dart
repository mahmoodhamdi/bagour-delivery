import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/address.dart';
import '../../providers/cart_provider.dart';
import '../../providers/address_provider.dart';
import 'widgets/checkout_address_section.dart';
import 'widgets/checkout_payment_section.dart';
import 'widgets/checkout_items_section.dart';
import 'widgets/checkout_summary.dart';
import 'widgets/checkout_notes_section.dart';

/// Payment method enum
enum PaymentMethod {
  cash,
  card,
  wallet,
}

/// Checkout state provider
final checkoutNotesProvider = StateProvider<String>((ref) => '');
final selectedPaymentMethodProvider =
    StateProvider<PaymentMethod>((ref) => PaymentMethod.cash);
final isPlacingOrderProvider = StateProvider<bool>((ref) => false);

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch addresses if not already loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(addressListProvider.notifier).fetchAddresses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final cart = ref.watch(cartProvider);
    final addressState = ref.watch(addressListProvider);
    final selectedAddress = ref.watch(selectedAddressProvider);
    final selectedPayment = ref.watch(selectedPaymentMethodProvider);
    final isPlacing = ref.watch(isPlacingOrderProvider);

    // If cart is empty, go back
    if (cart.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(AppRoutes.cart);
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('إتمام الطلب'),
      ),
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Delivery Address Section
                      CheckoutAddressSection(
                        addresses: addressState.addresses,
                        selectedAddress: selectedAddress,
                        isLoading: addressState.isLoading,
                        onAddAddress: () => context.push(AppRoutes.addAddress),
                        onSelectAddress: (address) {
                          ref.read(selectedAddressProvider.notifier).state =
                              address;
                        },
                        onManageAddresses: () =>
                            context.push(AppRoutes.addresses),
                      ),
                      const SizedBox(height: 24),

                      // Payment Method Section
                      CheckoutPaymentSection(
                        selectedMethod: selectedPayment,
                        onSelectMethod: (method) {
                          ref.read(selectedPaymentMethodProvider.notifier)
                              .state = method;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Order Items Section
                      CheckoutItemsSection(cart: cart),
                      const SizedBox(height: 24),

                      // Notes Section
                      const CheckoutNotesSection(),
                      const SizedBox(height: 24),

                      // Summary
                      CheckoutSummary(cart: cart),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Place Order Button
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildPlaceOrderButton(
              context,
              cart,
              selectedAddress,
              selectedPayment,
              isPlacing,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceOrderButton(
    BuildContext context,
    cart,
    Address? selectedAddress,
    PaymentMethod selectedPayment,
    bool isPlacing,
  ) {
    final canPlaceOrder = selectedAddress != null && cart.meetsMinimumOrder;

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
            // Error messages
            if (selectedAddress == null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'يرجى اختيار عنوان التوصيل',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                          ),
                    ),
                  ],
                ),
              ),
            if (!cart.meetsMinimumOrder)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: AppColors.warning,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'الحد الأدنى للطلب ${cart.minimumOrder?.toStringAsFixed(0)} ج.م',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                          ),
                    ),
                  ],
                ),
              ),

            // Place Order Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canPlaceOrder && !isPlacing
                    ? () => _placeOrder(context, selectedAddress!)
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: isPlacing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.check_circle_outline),
                            const SizedBox(width: 8),
                            const Text('تأكيد الطلب'),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '${cart.total.toStringAsFixed(2)} ج.م',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelMedium
                                    ?.copyWith(
                                      color: AppColors.textOnPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _placeOrder(BuildContext context, Address address) async {
    ref.read(isPlacingOrderProvider.notifier).state = true;

    try {
      final cart = ref.read(cartProvider);
      final notes = ref.read(checkoutNotesProvider);
      final paymentMethod = ref.read(selectedPaymentMethodProvider);

      // TODO: Implement order placement API call
      // For now, simulate order placement
      await Future.delayed(const Duration(seconds: 2));

      // Clear cart after successful order
      await ref.read(cartProvider.notifier).clearCart();

      if (mounted) {
        // Show success and navigate to order tracking
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تأكيد طلبك بنجاح!'),
            backgroundColor: AppColors.success,
          ),
        );

        // Navigate to order tracking (using placeholder ID)
        context.go('/order/placeholder_id');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تأكيد الطلب: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        ref.read(isPlacingOrderProvider.notifier).state = false;
      }
    }
  }
}
