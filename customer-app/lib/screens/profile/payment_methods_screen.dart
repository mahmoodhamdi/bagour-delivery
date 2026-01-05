import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';

class PaymentMethodsScreen extends ConsumerStatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  ConsumerState<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends ConsumerState<PaymentMethodsScreen> {
  bool _isLoading = true;
  List<PaymentMethod> _paymentMethods = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiService = ref.read(apiServiceProvider);
      final response = await apiService.get('/customer/payment-methods');

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        setState(() {
          _paymentMethods = data
              .map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>))
              .toList();
          _isLoading = false;
        });
      } else {
        throw Exception(response.data['message'] ?? 'فشل تحميل طرق الدفع');
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
        // Show empty list if no payment methods endpoint
        _paymentMethods = [];
      });
    }
  }

  Future<void> _deletePaymentMethod(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('حذف طريقة الدفع'),
        content: const Text('هل انت متاكد من حذف طريقة الدفع هذه؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('الغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.delete('/customer/payment-methods/$id');

      setState(() {
        _paymentMethods.removeWhere((m) => m.id == id);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف طريقة الدفع'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل حذف طريقة الدفع: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Future<void> _setAsDefault(String id) async {
    try {
      final apiService = ref.read(apiServiceProvider);
      await apiService.put('/customer/payment-methods/$id/default');

      setState(() {
        for (final method in _paymentMethods) {
          method.isDefault = method.id == id;
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم تعيين طريقة الدفع الافتراضية'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل تعيين طريقة الدفع: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showAddCardDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddPaymentMethodSheet(
        onAdded: (method) {
          setState(() {
            _paymentMethods.add(method);
          });
        },
      ),
    );
  }

  IconData _getCardIcon(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return Icons.credit_card;
      case 'mastercard':
        return Icons.credit_card;
      case 'mada':
        return Icons.credit_card;
      case 'meeza':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }

  Color _getCardColor(String brand) {
    switch (brand.toLowerCase()) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'mada':
        return const Color(0xFF2E7D32);
      case 'meeza':
        return const Color(0xFF003087);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('طرق الدفع'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPaymentMethods,
        child: _buildBody(),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddCardDialog,
        icon: const Icon(Icons.add),
        label: const Text('اضافة بطاقة'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Info Card
        Card(
          color: AppColors.info.withValues(alpha: 0.1),
          elevation: 0,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.security, color: AppColors.info),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'بياناتك محمية',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.info,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'نستخدم اعلى معايير الامان لحماية بيانات بطاقاتك',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Saved Cards Section
        if (_paymentMethods.isNotEmpty) ...[
          const Text(
            'البطاقات المحفوظة',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ..._paymentMethods.map((method) => _buildPaymentMethodCard(method)),
        ],

        // Empty State
        if (_paymentMethods.isEmpty && _error == null) ...[
          const SizedBox(height: 48),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.credit_card_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'لا توجد بطاقات محفوظة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'اضف بطاقة للدفع السريع عند الطلب',
                  style: TextStyle(color: Colors.grey[500]),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _showAddCardDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('اضافة بطاقة'),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        // Other Payment Methods
        const Text(
          'طرق دفع اخرى',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Cash on Delivery
        Card(
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.money, color: AppColors.success),
            ),
            title: const Text('الدفع عند الاستلام'),
            subtitle: Text(
              'ادفع نقدا عند استلام طلبك',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'متاح',
                style: TextStyle(
                  color: AppColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Wallet
        Card(
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.account_balance_wallet, color: AppColors.primary),
            ),
            title: const Text('محفظة التطبيق'),
            subtitle: Text(
              'استخدم رصيد محفظتك للدفع',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'متاح',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Mobile Wallet
        Card(
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.phone_android, color: AppColors.info),
            ),
            title: const Text('المحفظة الالكترونية'),
            subtitle: Text(
              'فودافون كاش، اورنج كاش، اتصالات كاش',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'متاح',
                style: TextStyle(
                  color: AppColors.info,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 100), // Space for FAB
      ],
    );
  }

  Widget _buildPaymentMethodCard(PaymentMethod method) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _getCardColor(method.brand),
              _getCardColor(method.brand).withValues(alpha: 0.8),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Card Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        method.brand.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (method.isDefault)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'الافتراضية',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '**** **** **** ${method.last4}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'صالحة حتى',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 10,
                            ),
                          ),
                          Text(
                            method.expiryDate,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (!method.isDefault)
                            TextButton(
                              onPressed: () => _setAsDefault(method.id),
                              child: Text(
                                'تعيين كافتراضية',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.9),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          IconButton(
                            icon: Icon(
                              Icons.delete_outline,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                            onPressed: () => _deletePaymentMethod(method.id),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Card Decoration
            Positioned(
              right: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
            ),
            Positioned(
              right: 40,
              bottom: -30,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AddPaymentMethodSheet extends ConsumerStatefulWidget {
  final Function(PaymentMethod) onAdded;

  const AddPaymentMethodSheet({
    super.key,
    required this.onAdded,
  });

  @override
  ConsumerState<AddPaymentMethodSheet> createState() => _AddPaymentMethodSheetState();
}

class _AddPaymentMethodSheetState extends ConsumerState<AddPaymentMethodSheet> {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLoading = false;
  bool _saveCard = true;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  String _formatCardNumber(String value) {
    value = value.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      buffer.write(value[i]);
      if ((i + 1) % 4 == 0 && i + 1 != value.length) {
        buffer.write(' ');
      }
    }
    return buffer.toString();
  }

  String _formatExpiry(String value) {
    value = value.replaceAll('/', '');
    if (value.length >= 2) {
      return '${value.substring(0, 2)}/${value.substring(2)}';
    }
    return value;
  }

  String? _validateCardNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى ادخال رقم البطاقة';
    }
    final cleaned = value.replaceAll(' ', '');
    if (cleaned.length < 13 || cleaned.length > 19) {
      return 'رقم البطاقة غير صحيح';
    }
    return null;
  }

  String? _validateExpiry(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى ادخال تاريخ الانتهاء';
    }
    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
      return 'الصيغة: MM/YY';
    }
    final parts = value.split('/');
    final month = int.tryParse(parts[0]) ?? 0;
    if (month < 1 || month > 12) {
      return 'الشهر غير صحيح';
    }
    return null;
  }

  String? _validateCvv(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى ادخال CVV';
    }
    if (value.length < 3 || value.length > 4) {
      return 'CVV غير صحيح';
    }
    return null;
  }

  String _detectCardBrand(String cardNumber) {
    final cleaned = cardNumber.replaceAll(' ', '');
    if (cleaned.startsWith('4')) return 'visa';
    if (cleaned.startsWith('5') || cleaned.startsWith('2')) return 'mastercard';
    if (cleaned.startsWith('5078') || cleaned.startsWith('6')) return 'meeza';
    return 'card';
  }

  Future<void> _addCard() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // In production, this would tokenize the card with payment provider
      final cardNumber = _cardNumberController.text.replaceAll(' ', '');
      final last4 = cardNumber.substring(cardNumber.length - 4);
      final brand = _detectCardBrand(cardNumber);

      // For demo, create a mock payment method
      final method = PaymentMethod(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        brand: brand,
        last4: last4,
        expiryDate: _expiryController.text,
        isDefault: false,
      );

      widget.onAdded(method);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم اضافة البطاقة بنجاح'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل اضافة البطاقة: ${e.toString()}'),
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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'اضافة بطاقة جديدة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Card Number
              TextFormField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                maxLength: 19,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  TextInputFormatter.withFunction((oldValue, newValue) {
                    final formatted = _formatCardNumber(newValue.text);
                    return TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }),
                ],
                decoration: const InputDecoration(
                  labelText: 'رقم البطاقة',
                  hintText: '0000 0000 0000 0000',
                  prefixIcon: Icon(Icons.credit_card),
                  counterText: '',
                ),
                validator: _validateCardNumber,
              ),

              const SizedBox(height: 16),

              // Expiry and CVV
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiryController,
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        TextInputFormatter.withFunction((oldValue, newValue) {
                          final formatted = _formatExpiry(newValue.text);
                          return TextEditingValue(
                            text: formatted,
                            selection: TextSelection.collapsed(offset: formatted.length),
                          );
                        }),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'تاريخ الانتهاء',
                        hintText: 'MM/YY',
                        prefixIcon: Icon(Icons.calendar_today),
                        counterText: '',
                      ),
                      validator: _validateExpiry,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvController,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      decoration: const InputDecoration(
                        labelText: 'CVV',
                        hintText: '***',
                        prefixIcon: Icon(Icons.lock),
                        counterText: '',
                      ),
                      validator: _validateCvv,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Cardholder Name
              TextFormField(
                controller: _nameController,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'اسم حامل البطاقة',
                  hintText: 'كما هو مكتوب على البطاقة',
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'يرجى ادخال اسم حامل البطاقة';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Save Card Checkbox
              CheckboxListTile(
                value: _saveCard,
                onChanged: (value) {
                  setState(() => _saveCard = value ?? true);
                },
                title: const Text('حفظ البطاقة للمشتريات المستقبلية'),
                contentPadding: EdgeInsets.zero,
                controlAffinity: ListTileControlAffinity.leading,
              ),

              const SizedBox(height: 24),

              // Add Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _addCard,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('اضافة البطاقة'),
                ),
              ),

              const SizedBox(height: 16),

              // Security Notice
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    'معاملة امنة ومشفرة',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PaymentMethod {
  final String id;
  final String brand;
  final String last4;
  final String expiryDate;
  bool isDefault;

  PaymentMethod({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expiryDate,
    this.isDefault = false,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['_id'] as String? ?? json['id'] as String,
      brand: json['brand'] as String? ?? 'card',
      last4: json['last4'] as String? ?? '****',
      expiryDate: json['expiryDate'] as String? ?? 'XX/XX',
      isDefault: json['isDefault'] as bool? ?? false,
    );
  }
}
