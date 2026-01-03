import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/constants.dart';
import '../services/api_service.dart' hide apiServiceProvider;
import 'auth_provider.dart' show apiServiceProvider;

/// Payment state
class PaymentState {
  final bool isLoading;
  final String? paymentUrl;
  final String? orderId;
  final String? paymentStatus;
  final String? error;

  const PaymentState({
    this.isLoading = false,
    this.paymentUrl,
    this.orderId,
    this.paymentStatus,
    this.error,
  });

  PaymentState copyWith({
    bool? isLoading,
    String? paymentUrl,
    String? orderId,
    String? paymentStatus,
    String? error,
  }) {
    return PaymentState(
      isLoading: isLoading ?? this.isLoading,
      paymentUrl: paymentUrl ?? this.paymentUrl,
      orderId: orderId ?? this.orderId,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      error: error,
    );
  }

  bool get isPending => paymentStatus == 'pending';
  bool get isPaid => paymentStatus == 'paid';
  bool get isFailed => paymentStatus == 'failed';
}

/// Coupon validation result
class CouponValidationResult {
  final bool isValid;
  final double? discount;
  final String? code;
  final String? type;
  final double? value;
  final String? message;

  const CouponValidationResult({
    required this.isValid,
    this.discount,
    this.code,
    this.type,
    this.value,
    this.message,
  });

  factory CouponValidationResult.fromJson(Map<String, dynamic> json) {
    final coupon = json['coupon'] as Map<String, dynamic>?;
    return CouponValidationResult(
      isValid: json['isValid'] as bool,
      discount: (json['discount'] as num?)?.toDouble(),
      code: coupon?['code'] as String?,
      type: coupon?['type'] as String?,
      value: (coupon?['value'] as num?)?.toDouble(),
      message: json['message'] as String?,
    );
  }
}

/// Coupon state
class CouponState {
  final bool isValidating;
  final CouponValidationResult? result;
  final String? error;

  const CouponState({
    this.isValidating = false,
    this.result,
    this.error,
  });

  CouponState copyWith({
    bool? isValidating,
    CouponValidationResult? result,
    String? error,
  }) {
    return CouponState(
      isValidating: isValidating ?? this.isValidating,
      result: result ?? this.result,
      error: error,
    );
  }

  bool get hasValidCoupon => result?.isValid == true;
  double get discount => result?.discount ?? 0;
}

/// Payment notifier
class PaymentNotifier extends StateNotifier<PaymentState> {
  final ApiService _apiService;

  PaymentNotifier(this._apiService) : super(const PaymentState());

  /// Initiate card payment
  Future<bool> initiateCardPayment(String orderId) async {
    state = state.copyWith(isLoading: true, error: null, orderId: orderId);

    try {
      final response = await _apiService.post(
        AppEndpoints.paymentInitiate,
        data: {'orderId': orderId},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        state = state.copyWith(
          isLoading: false,
          paymentUrl: data['iframeUrl'] as String?,
          paymentStatus: 'pending',
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'فشل في بدء عملية الدفع',
        );
        return false;
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _apiService.handleError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'حدث خطأ غير متوقع',
      );
      return false;
    }
  }

  /// Initiate wallet payment
  Future<bool> initiateWalletPayment(String orderId, String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null, orderId: orderId);

    try {
      final response = await _apiService.post(
        AppEndpoints.paymentWallet,
        data: {
          'orderId': orderId,
          'phoneNumber': phoneNumber,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        state = state.copyWith(
          isLoading: false,
          paymentUrl: data['redirectUrl'] as String?,
          paymentStatus: 'pending',
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'فشل في بدء عملية الدفع',
        );
        return false;
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _apiService.handleError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'حدث خطأ غير متوقع',
      );
      return false;
    }
  }

  /// Check payment status
  Future<String?> checkPaymentStatus(String orderId) async {
    try {
      final response = await _apiService.get(
        '${AppEndpoints.paymentStatus}/$orderId',
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final status = response.data['data']['paymentStatus'] as String?;
        state = state.copyWith(paymentStatus: status);
        return status;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Handle payment completed (called from webview)
  void onPaymentCompleted(bool success) {
    state = state.copyWith(
      paymentStatus: success ? 'paid' : 'failed',
    );
  }

  /// Reset payment state
  void reset() {
    state = const PaymentState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Coupon notifier
class CouponNotifier extends StateNotifier<CouponState> {
  final ApiService _apiService;

  CouponNotifier(this._apiService) : super(const CouponState());

  /// Validate coupon code
  Future<bool> validateCoupon(String code, double subtotal, {String? restaurantId}) async {
    state = state.copyWith(isValidating: true, error: null);

    try {
      final response = await _apiService.post(
        AppEndpoints.couponValidate,
        data: {
          'code': code,
          'subtotal': subtotal,
          if (restaurantId != null) 'restaurantId': restaurantId,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final result = CouponValidationResult.fromJson(response.data['data']);
        state = state.copyWith(
          isValidating: false,
          result: result,
          error: result.isValid ? null : result.message,
        );
        return result.isValid;
      } else {
        state = state.copyWith(
          isValidating: false,
          error: response.data['message'] ?? 'فشل التحقق من الكود',
        );
        return false;
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isValidating: false,
        error: _apiService.handleError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isValidating: false,
        error: 'حدث خطأ غير متوقع',
      );
      return false;
    }
  }

  /// Clear coupon
  void clearCoupon() {
    state = const CouponState();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Payment provider
final paymentProvider =
    StateNotifierProvider<PaymentNotifier, PaymentState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return PaymentNotifier(apiService);
});

/// Coupon provider
final couponProvider =
    StateNotifierProvider<CouponNotifier, CouponState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return CouponNotifier(apiService);
});
