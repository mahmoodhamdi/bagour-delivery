import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../models/address.dart';
import '../../providers/address_provider.dart';
import 'widgets/address_card.dart';

class AddressesScreen extends ConsumerWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final addressState = ref.watch(addressListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('عناويني'),
        actions: [
          if (addressState.addresses.length < 10)
            IconButton(
              onPressed: () => context.push(AppRoutes.addAddress),
              icon: const Icon(Icons.add),
              tooltip: 'إضافة عنوان',
            ),
        ],
      ),
      body: _buildBody(context, ref, addressState),
      floatingActionButton: addressState.addresses.length < 10
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.addAddress),
              icon: const Icon(Icons.add_location_alt),
              label: const Text('إضافة عنوان'),
            )
          : null,
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AddressListState state,
  ) {
    if (state.isLoading && state.addresses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.addresses.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              state.error!,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () =>
                  ref.read(addressListProvider.notifier).fetchAddresses(),
              child: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      );
    }

    if (state.addresses.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(addressListProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: state.addresses.length,
        itemBuilder: (context, index) {
          final address = state.addresses[index];
          return AddressCard(
            address: address,
            onTap: () => _showAddressOptions(context, ref, address),
            onSetDefault: () => _setDefault(context, ref, address),
            onEdit: () => context.push('/addresses/${address.id}'),
            onDelete: () => _confirmDelete(context, ref, address),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.location_off_outlined,
                size: 64,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد عناوين',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'أضف عنواناً لتتمكن من طلب الطعام',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push(AppRoutes.addAddress),
              icon: const Icon(Icons.add_location_alt),
              label: const Text('إضافة عنوان'),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddressOptions(
    BuildContext context,
    WidgetRef ref,
    Address address,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('تعديل العنوان'),
              onTap: () {
                Navigator.pop(context);
                context.push('/addresses/${address.id}');
              },
            ),
            if (!address.isDefault)
              ListTile(
                leading: const Icon(Icons.star_outline),
                title: const Text('تعيين كعنوان افتراضي'),
                onTap: () {
                  Navigator.pop(context);
                  _setDefault(context, ref, address);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.error),
              title: const Text(
                'حذف العنوان',
                style: TextStyle(color: AppColors.error),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, ref, address);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setDefault(
    BuildContext context,
    WidgetRef ref,
    Address address,
  ) async {
    final success = await ref
        .read(addressListProvider.notifier)
        .setDefaultAddress(address.id!);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'تم تعيين العنوان كافتراضي' : 'فشل تعيين العنوان',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
        ),
      );
    }
  }

  void _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Address address,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف العنوان'),
        content: Text('هل أنت متأكد من حذف "${address.name}"؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(addressListProvider.notifier)
                  .deleteAddress(address.id!);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success ? 'تم حذف العنوان' : 'فشل حذف العنوان',
                    ),
                    backgroundColor:
                        success ? AppColors.success : AppColors.error,
                  ),
                );
              }
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
}
