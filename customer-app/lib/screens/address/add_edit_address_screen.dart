import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../models/address.dart';
import '../../providers/address_provider.dart';

class AddEditAddressScreen extends ConsumerStatefulWidget {
  final String? addressId;

  const AddEditAddressScreen({
    super.key,
    this.addressId,
  });

  bool get isEditing => addressId != null;

  @override
  ConsumerState<AddEditAddressScreen> createState() =>
      _AddEditAddressScreenState();
}

class _AddEditAddressScreenState extends ConsumerState<AddEditAddressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _areaController = TextEditingController();
  final _buildingController = TextEditingController();
  final _floorController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _landmarkController = TextEditingController();

  AddressLabel _selectedLabel = AddressLabel.home;
  bool _isDefault = false;
  bool _isLoading = false;

  // Default coordinates for Bagour
  double _latitude = AppConstants.defaultLatitude;
  double _longitude = AppConstants.defaultLongitude;

  Address? _existingAddress;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _loadExistingAddress();
    }
  }

  void _loadExistingAddress() {
    final addresses = ref.read(addressListProvider).addresses;
    try {
      _existingAddress = addresses.firstWhere((a) => a.id == widget.addressId);
    } catch (_) {
      _existingAddress = null;
    }

    if (_existingAddress != null) {
      _nameController.text = _existingAddress!.name;
      _addressController.text = _existingAddress!.address;
      _areaController.text = _existingAddress!.area;
      _buildingController.text = _existingAddress!.building ?? '';
      _floorController.text = _existingAddress!.floor ?? '';
      _apartmentController.text = _existingAddress!.apartment ?? '';
      _landmarkController.text = _existingAddress!.landmark ?? '';
      _selectedLabel = _existingAddress!.label;
      _isDefault = _existingAddress!.isDefault;
      _latitude = _existingAddress!.latitude;
      _longitude = _existingAddress!.longitude;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _areaController.dispose();
    _buildingController.dispose();
    _floorController.dispose();
    _apartmentController.dispose();
    _landmarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEditing ? 'تعديل العنوان' : 'إضافة عنوان'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Address Label Selection
            _buildLabelSelection(),
            const SizedBox(height: 24),

            // Address Name
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'اسم العنوان',
                hintText: 'مثال: منزلي، شغلي',
                prefixIcon: Icon(Icons.label_outline),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'اسم العنوان مطلوب';
                }
                if (value.length < 2) {
                  return 'اسم العنوان يجب أن يكون على الأقل حرفين';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Street Address
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'العنوان التفصيلي',
                hintText: 'الشارع، الحي',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
              textInputAction: TextInputAction.next,
              maxLines: 2,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'العنوان مطلوب';
                }
                if (value.length < 5) {
                  return 'العنوان يجب أن يكون على الأقل 5 أحرف';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Area
            TextFormField(
              controller: _areaController,
              decoration: const InputDecoration(
                labelText: 'المنطقة',
                hintText: 'اسم المنطقة',
                prefixIcon: Icon(Icons.map_outlined),
              ),
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'المنطقة مطلوبة';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Building Details Row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _buildingController,
                    decoration: const InputDecoration(
                      labelText: 'رقم المبنى',
                      hintText: '123',
                      prefixIcon: Icon(Icons.apartment_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _floorController,
                    decoration: const InputDecoration(
                      labelText: 'الطابق',
                      hintText: '2',
                      prefixIcon: Icon(Icons.stairs_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _apartmentController,
                    decoration: const InputDecoration(
                      labelText: 'الشقة',
                      hintText: '5',
                      prefixIcon: Icon(Icons.door_front_door_outlined),
                    ),
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Landmark
            TextFormField(
              controller: _landmarkController,
              decoration: const InputDecoration(
                labelText: 'علامة مميزة (اختياري)',
                hintText: 'مثال: بجوار مسجد...',
                prefixIcon: Icon(Icons.place_outlined),
              ),
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),

            // Map Preview (Placeholder)
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 48,
                          color: AppColors.textHint,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'سيتم تحديد الموقع تلقائياً',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: TextButton.icon(
                      onPressed: () {
                        // TODO: Open map picker
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('سيتم إضافة اختيار الموقع قريباً'),
                          ),
                        );
                      },
                      icon: const Icon(Icons.my_location),
                      label: const Text('اختر الموقع'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Set as Default
            SwitchListTile(
              value: _isDefault,
              onChanged: (value) => setState(() => _isDefault = value),
              title: const Text('تعيين كعنوان افتراضي'),
              subtitle: const Text('سيتم استخدام هذا العنوان تلقائياً'),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveAddress,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          widget.isEditing ? 'حفظ التغييرات' : 'إضافة العنوان',
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabelSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'نوع العنوان',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Row(
          children: AddressLabel.values.map((label) {
            final isSelected = _selectedLabel == label;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: label != AddressLabel.values.first ? 8 : 0,
                ),
                child: _buildLabelChip(label, isSelected),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildLabelChip(AddressLabel label, bool isSelected) {
    return InkWell(
      onTap: () => setState(() => _selectedLabel = label),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? _getLabelColor(label).withValues(alpha: 0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? _getLabelColor(label) : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              _getLabelIcon(label),
              color: isSelected ? _getLabelColor(label) : AppColors.textHint,
            ),
            const SizedBox(height: 4),
            Text(
              _getLabelName(label),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        isSelected ? _getLabelColor(label) : AppColors.textHint,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
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

  String _getLabelName(AddressLabel label) {
    switch (label) {
      case AddressLabel.home:
        return 'المنزل';
      case AddressLabel.work:
        return 'العمل';
      case AddressLabel.other:
        return 'آخر';
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final input = AddressInput(
      label: _selectedLabel,
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      area: _areaController.text.trim(),
      building: _buildingController.text.trim().isNotEmpty
          ? _buildingController.text.trim()
          : null,
      floor: _floorController.text.trim().isNotEmpty
          ? _floorController.text.trim()
          : null,
      apartment: _apartmentController.text.trim().isNotEmpty
          ? _apartmentController.text.trim()
          : null,
      landmark: _landmarkController.text.trim().isNotEmpty
          ? _landmarkController.text.trim()
          : null,
      coordinates: [_longitude, _latitude],
      isDefault: _isDefault,
    );

    Address? result;

    if (widget.isEditing) {
      result = await ref
          .read(addressListProvider.notifier)
          .updateAddress(widget.addressId!, input);
    } else {
      result = await ref.read(addressListProvider.notifier).addAddress(input);
    }

    setState(() => _isLoading = false);

    if (mounted) {
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isEditing
                  ? 'تم تحديث العنوان بنجاح'
                  : 'تمت إضافة العنوان بنجاح',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        context.pop();
      } else {
        final error = ref.read(addressListProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'حدث خطأ'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}
