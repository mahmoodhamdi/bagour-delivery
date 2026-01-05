import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../services/api_service.dart';
import '../../providers/cart_provider.dart';

/// Promo code model
class PromoCode {
  final String id;
  final String code;
  final String description;
  final String descriptionAr;
  final String discountType;
  final double discountValue;
  final double? minimumOrder;
  final double? maxDiscount;
  final DateTime? validUntil;
  final bool isApplied;

  PromoCode({
    required this.id,
    required this.code,
    required this.description,
    required this.descriptionAr,
    required this.discountType,
    required this.discountValue,
    this.minimumOrder,
    this.maxDiscount,
    this.validUntil,
    this.isApplied = false,
  });

  factory PromoCode.fromJson(Map<String, dynamic> json) {
    return PromoCode(
      id: json['_id'] ?? json['id'] ?? '',
      code: json['code'] ?? '',
      description: json['description'] ?? '',
      descriptionAr: json['descriptionAr'] ?? json['description'] ?? '',
      discountType: json['discountType'] ?? 'percentage',
      discountValue: (json['discountValue'] ?? 0).toDouble(),
      minimumOrder: json['minimumOrder']?.toDouble(),
      maxDiscount: json['maxDiscount']?.toDouble(),
      validUntil: json['validUntil'] != null
          ? DateTime.tryParse(json['validUntil'])
          : null,
    );
  }

  String get discountDisplay {
    if (discountType == 'percentage') {
      return '${discountValue.toInt()}%';
    }
    return '${discountValue.toStringAsFixed(0)} ج.م';
  }

  bool get isValid {
    if (validUntil == null) return true;
    return DateTime.now().isBefore(validUntil!);
  }
}

/// Promo code state
class PromoCodeState {
  final List<PromoCode> availableCodes;
  final PromoCode? appliedCode;
  final bool isLoading;
  final bool isValidating;
  final String? error;
  final double? discountAmount;

  const PromoCodeState({
    this.availableCodes = const [],
    this.appliedCode,
    this.isLoading = false,
    this.isValidating = false,
    this.error,
    this.discountAmount,
  });

  PromoCodeState copyWith({
    List<PromoCode>? availableCodes,
    PromoCode? appliedCode,
    bool? isLoading,
    bool? isValidating,
    String? error,
    double? discountAmount,
    bool clearApplied = false,
    bool clearError = false,
  }) {
    return PromoCodeState(
      availableCodes: availableCodes ?? this.availableCodes,
      appliedCode: clearApplied ? null : (appliedCode ?? this.appliedCode),
      isLoading: isLoading ?? this.isLoading,
      isValidating: isValidating ?? this.isValidating,
      error: clearError ? null : (error ?? this.error),
      discountAmount: discountAmount ?? this.discountAmount,
    );
  }
}

/// Promo code notifier
class PromoCodeNotifier extends StateNotifier<PromoCodeState> {
  final ApiService _apiService;
  final String? restaurantId;

  PromoCodeNotifier(this._apiService, this.restaurantId)
      : super(const PromoCodeState());

  Future<void> fetchAvailableCodes() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final queryParams = <String, dynamic>{};
      if (restaurantId != null) {
        queryParams['restaurantId'] = restaurantId;
      }

      final response = await _apiService.get(
        AppEndpoints.couponsAvailable,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> codesJson = response.data['data'] ?? [];
        final codes = codesJson.map((json) => PromoCode.fromJson(json)).toList();
        state = state.copyWith(availableCodes: codes, isLoading: false);
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'فشل جلب الأكواد',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'فشل جلب الأكواد الترويجية',
      );
    }
  }

  Future<bool> validateCode(String code, double orderSubtotal) async {
    state = state.copyWith(isValidating: true, clearError: true);

    try {
      final response = await _apiService.post(
        AppEndpoints.couponValidate,
        data: {
          'code': code,
          'orderSubtotal': orderSubtotal,
          if (restaurantId != null) 'restaurantId': restaurantId,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final promoData = response.data['data'];
        final promo = PromoCode.fromJson(promoData['coupon'] ?? promoData);
        final discount = (promoData['discount'] ?? 0).toDouble();

        state = state.copyWith(
          appliedCode: promo,
          discountAmount: discount,
          isValidating: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isValidating: false,
          error: response.data['message'] ?? 'الكود غير صالح',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isValidating: false,
        error: 'فشل التحقق من الكود',
      );
      return false;
    }
  }

  void removeAppliedCode() {
    state = state.copyWith(clearApplied: true, discountAmount: 0);
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Promo code provider
final promoCodeProvider =
    StateNotifierProvider.family<PromoCodeNotifier, PromoCodeState, String?>(
  (ref, restaurantId) {
    final apiService = ref.watch(apiServiceProvider);
    return PromoCodeNotifier(apiService, restaurantId);
  },
);

class PromoCodeScreen extends ConsumerStatefulWidget {
  final String? restaurantId;

  const PromoCodeScreen({
    super.key,
    this.restaurantId,
  });

  @override
  ConsumerState<PromoCodeScreen> createState() => _PromoCodeScreenState();
}

class _PromoCodeScreenState extends ConsumerState<PromoCodeScreen> {
  final _codeController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(promoCodeProvider(widget.restaurantId).notifier)
          .fetchAvailableCodes();
    });
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final promoState = ref.watch(promoCodeProvider(widget.restaurantId));
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('كود الخصم'),
      ),
      body: Column(
        children: [
          // Enter Code Section
          _buildEnterCodeSection(context, promoState, cart.subtotal),

          // Divider with OR
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'أو اختر من الأكواد المتاحة',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ),
                const Expanded(child: Divider()),
              ],
            ),
          ),

          // Available Codes List
          Expanded(
            child: _buildAvailableCodesList(context, promoState, cart.subtotal),
          ),

          // Applied Code Banner
          if (promoState.appliedCode != null)
            _buildAppliedCodeBanner(context, promoState),
        ],
      ),
    );
  }

  Widget _buildEnterCodeSection(
    BuildContext context,
    PromoCodeState promoState,
    double orderSubtotal,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'أدخل كود الخصم',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _codeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: InputDecoration(
                      hintText: 'ادخل الكود هنا',
                      prefixIcon: const Icon(Icons.local_offer_outlined),
                      border: const OutlineInputBorder(),
                      errorText: promoState.error,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'يرجى إدخال الكود';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: promoState.isValidating
                        ? null
                        : () => _applyCode(context, orderSubtotal),
                    child: promoState.isValidating
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('تطبيق'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableCodesList(
    BuildContext context,
    PromoCodeState promoState,
    double orderSubtotal,
  ) {
    if (promoState.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (promoState.availableCodes.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(promoCodeProvider(widget.restaurantId).notifier)
          .fetchAvailableCodes(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: promoState.availableCodes.length,
        itemBuilder: (context, index) {
          final code = promoState.availableCodes[index];
          final isApplied = promoState.appliedCode?.code == code.code;
          final meetsMinimum =
              code.minimumOrder == null || orderSubtotal >= code.minimumOrder!;

          return _buildPromoCodeCard(
            context,
            code,
            isApplied: isApplied,
            meetsMinimum: meetsMinimum,
            orderSubtotal: orderSubtotal,
          );
        },
      ),
    );
  }

  Widget _buildPromoCodeCard(
    BuildContext context,
    PromoCode code, {
    required bool isApplied,
    required bool meetsMinimum,
    required double orderSubtotal,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: isApplied || !meetsMinimum || !code.isValid
            ? null
            : () => _selectCode(context, code, orderSubtotal),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: isApplied
                ? Border.all(color: AppColors.success, width: 2)
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Discount Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      code.discountDisplay,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Code
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.border,
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Text(
                            code.code,
                            style:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 1,
                                    ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          code.descriptionAr,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  // Applied/Apply Button
                  if (isApplied)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.success,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 20,
                      ),
                    )
                  else if (meetsMinimum && code.isValid)
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.textSecondary,
                    ),
                ],
              ),

              // Conditions
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (code.minimumOrder != null)
                    _buildConditionChip(
                      context,
                      icon: meetsMinimum
                          ? Icons.check_circle
                          : Icons.info_outline,
                      text: 'الحد الأدنى: ${code.minimumOrder!.toStringAsFixed(0)} ج.م',
                      isMet: meetsMinimum,
                    ),
                  if (code.maxDiscount != null)
                    _buildConditionChip(
                      context,
                      icon: Icons.savings_outlined,
                      text: 'أقصى خصم: ${code.maxDiscount!.toStringAsFixed(0)} ج.م',
                      isMet: true,
                    ),
                  if (code.validUntil != null)
                    _buildConditionChip(
                      context,
                      icon: code.isValid
                          ? Icons.access_time
                          : Icons.timer_off,
                      text: code.isValid
                          ? 'صالح حتى ${_formatDate(code.validUntil!)}'
                          : 'انتهت الصلاحية',
                      isMet: code.isValid,
                    ),
                ],
              ),

              // Warning if not applicable
              if (!meetsMinimum) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 14,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'أضف ${(code.minimumOrder! - orderSubtotal).toStringAsFixed(0)} ج.م للاستفادة من هذا العرض',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.warning,
                          ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConditionChip(
    BuildContext context, {
    required IconData icon,
    required String text,
    required bool isMet,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMet
            ? AppColors.success.withValues(alpha: 0.1)
            : AppColors.textHint.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: isMet ? AppColors.success : AppColors.textHint,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: isMet ? AppColors.success : AppColors.textHint,
                ),
          ),
        ],
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
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.local_offer_outlined,
                size: 64,
                color: AppColors.textHint,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'لا توجد أكواد متاحة',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'يمكنك إدخال كود الخصم يدوياً إذا كان لديك',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppliedCodeBanner(
    BuildContext context,
    PromoCodeState promoState,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        border: Border(
          top: BorderSide(color: AppColors.success),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.success),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تم تطبيق الكود "${promoState.appliedCode!.code}"',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
                  ),
                  Text(
                    'الخصم: ${promoState.discountAmount?.toStringAsFixed(2) ?? '0'} ج.م',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                ref
                    .read(promoCodeProvider(widget.restaurantId).notifier)
                    .removeAppliedCode();
              },
              icon: const Icon(Icons.close),
              color: AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => _confirmAndReturn(context, promoState),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
              child: const Text('تأكيد'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _applyCode(BuildContext context, double orderSubtotal) async {
    if (!_formKey.currentState!.validate()) return;

    final code = _codeController.text.trim().toUpperCase();
    ref.read(promoCodeProvider(widget.restaurantId).notifier).clearError();

    final success = await ref
        .read(promoCodeProvider(widget.restaurantId).notifier)
        .validateCode(code, orderSubtotal);

    if (success && mounted) {
      _codeController.clear();
    }
  }

  Future<void> _selectCode(
    BuildContext context,
    PromoCode code,
    double orderSubtotal,
  ) async {
    final success = await ref
        .read(promoCodeProvider(widget.restaurantId).notifier)
        .validateCode(code.code, orderSubtotal);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فشل تطبيق الكود'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _confirmAndReturn(BuildContext context, PromoCodeState promoState) {
    // Return the applied code to the checkout screen
    context.pop({
      'code': promoState.appliedCode?.code,
      'discount': promoState.discountAmount,
    });
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
