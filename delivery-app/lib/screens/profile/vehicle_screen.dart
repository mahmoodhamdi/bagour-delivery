import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';

class VehicleScreen extends ConsumerStatefulWidget {
  const VehicleScreen({super.key});

  @override
  ConsumerState<VehicleScreen> createState() => _VehicleScreenState();
}

class _VehicleScreenState extends ConsumerState<VehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _vehicleType;
  late TextEditingController _plateController;
  late TextEditingController _modelController;
  late TextEditingController _colorController;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _vehicleType = 'motorcycle';
    _plateController = TextEditingController();
    _modelController = TextEditingController();
    _colorController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      authState.mapOrNull(
        authenticated: (state) {
          if (state.driver != null) {
            _vehicleType = state.driver!.vehicleType;
            _plateController.text = state.driver!.vehiclePlate ?? '';
            _modelController.text = state.driver!.vehicleModel ?? '';
            _colorController.text = state.driver!.vehicleColor ?? '';
            setState(() {});
          }
        },
      );
    });
  }

  @override
  void dispose() {
    _plateController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _saveVehicleInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // TODO: Implement vehicle update via API
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;
    setState(() {
      _isLoading = false;
      _isEditing = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديث معلومات المركبة'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('معلومات المركبة'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Vehicle Type Display
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getVehicleIcon(_vehicleType),
                          size: 32,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'نوع المركبة',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            Text(
                              _getVehicleTypeName(_vehicleType),
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (_isEditing)
                DropdownButtonFormField<String>(
                  value: _vehicleType,
                  decoration: const InputDecoration(
                    labelText: 'نوع المركبة',
                    prefixIcon: Icon(Icons.two_wheeler),
                  ),
                  items: AppConstants.vehicleTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(_getVehicleTypeName(type)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _vehicleType = value);
                    }
                  },
                ),
              const SizedBox(height: 16),

              // Plate Number
              TextFormField(
                controller: _plateController,
                enabled: _isEditing,
                textDirection: TextDirection.ltr,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'رقم اللوحة',
                  prefixIcon: Icon(Icons.confirmation_number),
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
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'موديل المركبة',
                  prefixIcon: Icon(Icons.info_outline),
                ),
              ),
              const SizedBox(height: 16),

              // Vehicle Color
              TextFormField(
                controller: _colorController,
                enabled: _isEditing,
                decoration: const InputDecoration(
                  labelText: 'لون المركبة',
                  prefixIcon: Icon(Icons.color_lens_outlined),
                ),
              ),
              const SizedBox(height: 24),

              if (_isEditing) ...[
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveVehicleInfo,
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('حفظ التغييرات'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => setState(() => _isEditing = false),
                  child: const Text('إلغاء'),
                ),
              ],

              const SizedBox(height: 24),

              // Vehicle Photo Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'صورة المركبة',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: _isEditing ? () {} : null,
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          height: 150,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.grey100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.grey300,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: AppColors.grey500,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'اضغط لإضافة صورة',
                                style: Theme.of(context).textTheme.bodySmall,
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
        ),
      ),
    );
  }

  IconData _getVehicleIcon(String type) {
    switch (type) {
      case 'motorcycle':
        return Icons.two_wheeler;
      case 'bicycle':
        return Icons.pedal_bike;
      case 'car':
        return Icons.directions_car;
      default:
        return Icons.help;
    }
  }

  String _getVehicleTypeName(String type) {
    switch (type) {
      case 'motorcycle':
        return 'دراجة نارية';
      case 'bicycle':
        return 'دراجة هوائية';
      case 'car':
        return 'سيارة';
      default:
        return type;
    }
  }
}
