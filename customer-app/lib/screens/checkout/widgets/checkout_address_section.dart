import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/address.dart';

class CheckoutAddressSection extends StatelessWidget {
  final List<Address> addresses;
  final Address? selectedAddress;
  final bool isLoading;
  final VoidCallback onAddAddress;
  final ValueChanged<Address> onSelectAddress;
  final VoidCallback onManageAddresses;

  const CheckoutAddressSection({
    super.key,
    required this.addresses,
    this.selectedAddress,
    required this.isLoading,
    required this.onAddAddress,
    required this.onSelectAddress,
    required this.onManageAddresses,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'عنوان التوصيل',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            TextButton(
              onPressed: onManageAddresses,
              child: const Text('إدارة العناوين'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(),
            ),
          )
        else if (addresses.isEmpty)
          _buildEmptyState(context)
        else
          _buildAddressList(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.location_off_outlined,
            size: 48,
            color: AppColors.textHint,
          ),
          const SizedBox(height: 12),
          Text(
            'لا توجد عناوين محفوظة',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: onAddAddress,
            icon: const Icon(Icons.add_location_alt),
            label: const Text('إضافة عنوان'),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressList(BuildContext context) {
    return Column(
      children: [
        ...addresses.take(3).map((address) => _buildAddressCard(
              context,
              address,
              isSelected: selectedAddress?.id == address.id,
            )),
        if (addresses.length > 3)
          TextButton(
            onPressed: onManageAddresses,
            child: Text('عرض المزيد (${addresses.length - 3})'),
          ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onAddAddress,
          icon: const Icon(Icons.add),
          label: const Text('إضافة عنوان جديد'),
        ),
      ],
    );
  }

  Widget _buildAddressCard(
    BuildContext context,
    Address address, {
    bool isSelected = false,
  }) {
    return GestureDetector(
      onTap: () => onSelectAddress(address),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getLabelColor(address.label).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getLabelIcon(address.label),
                color: _getLabelColor(address.label),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address.name,
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      if (address.isDefault) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'افتراضي',
                            style:
                                Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 10,
                                    ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address.shortAddress,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (_) => onSelectAddress(address),
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Color _getLabelColor(AddressLabel label) {
    switch (label) {
      case AddressLabel.home:
        return AppColors.primary;
      case AddressLabel.work:
        return AppColors.info;
      case AddressLabel.other:
        return AppColors.secondary;
    }
  }

  IconData _getLabelIcon(AddressLabel label) {
    switch (label) {
      case AddressLabel.home:
        return Icons.home_outlined;
      case AddressLabel.work:
        return Icons.work_outline;
      case AddressLabel.other:
        return Icons.location_on_outlined;
    }
  }
}
