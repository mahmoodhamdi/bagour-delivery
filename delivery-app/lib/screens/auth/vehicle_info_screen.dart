import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../../services/api_service.dart';
import '../../providers/order_provider.dart' show apiServiceProvider;

class VehicleInfoScreen extends ConsumerStatefulWidget {
  const VehicleInfoScreen({super.key});

  @override
  ConsumerState<VehicleInfoScreen> createState() => _VehicleInfoScreenState();
}

class _VehicleInfoScreenState extends ConsumerState<VehicleInfoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _plateNumberController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _yearController = TextEditingController();

  String _selectedVehicleType = 'motorcycle';
  bool _isLoading = false;

  @override
  void dispose() {
    _plateNumberController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _submitVehicleInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.put(
        ApiEndpoints.updateVehicle,
        data: {
          'vehicleType': _selectedVehicleType,
          'vehiclePlateNumber': _plateNumberController.text.trim(),
          'vehicleModel': _modelController.text.trim(),
          'vehicleColor': _colorController.text.trim(),
          'vehicleYear': _yearController.text.trim().isNotEmpty
              ? int.tryParse(_yearController.text.trim())
              : null,
        },
      );

      if (!mounted) return;

      if (response.statusCode == 200 && response.data['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ معلومات المركبة بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
        context.go(AppRoutes.documentsUpload);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.data['message'] ?? 'حدث خطأ'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('معلومات المركبة'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.driverGradient,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.two_wheeler,
                        size: 40,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'أدخل معلومات مركبتك',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'سيتم استخدام هذه المعلومات لتحديد نوع الطلبات المناسبة لك',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.white.withValues(alpha: 0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Vehicle Type Selection
              Text(
                'نوع المركبة',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _VehicleTypeCard(
                      icon: Icons.two_wheeler,
                      label: 'دراجة نارية',
                      type: 'motorcycle',
                      isSelected: _selectedVehicleType == 'motorcycle',
                      onTap: () => setState(() => _selectedVehicleType = 'motorcycle'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _VehicleTypeCard(
                      icon: Icons.pedal_bike,
                      label: 'دراجة هوائية',
                      type: 'bicycle',
                      isSelected: _selectedVehicleType == 'bicycle',
                      onTap: () => setState(() => _selectedVehicleType = 'bicycle'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _VehicleTypeCard(
                      icon: Icons.directions_car,
                      label: 'سيارة',
                      type: 'car',
                      isSelected: _selectedVehicleType == 'car',
                      onTap: () => setState(() => _selectedVehicleType = 'car'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Plate Number
              TextFormField(
                controller: _plateNumberController,
                textDirection: TextDirection.ltr,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'رقم اللوحة',
                  prefixIcon: Icon(Icons.pin),
                  hintText: 'مثال: ا ب ج 123',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'رقم اللوحة مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Vehicle Model
              TextFormField(
                controller: _modelController,
                decoration: const InputDecoration(
                  labelText: 'موديل المركبة',
                  prefixIcon: Icon(Icons.info_outline),
                  hintText: 'مثال: Honda CG 125',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'موديل المركبة مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Vehicle Color
              TextFormField(
                controller: _colorController,
                decoration: const InputDecoration(
                  labelText: 'لون المركبة',
                  prefixIcon: Icon(Icons.color_lens_outlined),
                  hintText: 'مثال: أحمر',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'لون المركبة مطلوب';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Vehicle Year
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                textDirection: TextDirection.ltr,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: 'سنة الصنع (اختياري)',
                  prefixIcon: Icon(Icons.calendar_today),
                  hintText: 'مثال: 2020',
                  counterText: '',
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final year = int.tryParse(value);
                    if (year == null) {
                      return 'أدخل سنة صالحة';
                    }
                    if (year < 1990 || year > DateTime.now().year) {
                      return 'السنة يجب أن تكون بين 1990 و ${DateTime.now().year}';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber, color: AppColors.warning),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'تأكد من صحة المعلومات المدخلة. سيتم التحقق منها مع رخصة المركبة.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Submit Button
              ElevatedButton(
                onPressed: _isLoading ? null : _submitVehicleInfo,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('التالي'),
              ),
              const SizedBox(height: 16),

              // Skip Button
              TextButton(
                onPressed: _isLoading ? null : () => context.go(AppRoutes.documentsUpload),
                child: const Text('تخطي هذه الخطوة'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VehicleTypeCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String type;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleTypeCard({
    required this.icon,
    required this.label,
    required this.type,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.grey100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
