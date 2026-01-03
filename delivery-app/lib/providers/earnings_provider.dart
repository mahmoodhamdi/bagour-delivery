import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/order.dart';
import '../services/api_service.dart';
import '../config/constants.dart';
import 'order_provider.dart' show apiServiceProvider;

part 'earnings_provider.freezed.dart';

/// State for earnings summary
@freezed
class EarningsState with _$EarningsState {
  const factory EarningsState({
    @Default(EarningsSummary(
      todayEarnings: 0,
      weekEarnings: 0,
      monthEarnings: 0,
      totalEarnings: 0,
      todayDeliveries: 0,
      weekDeliveries: 0,
      monthDeliveries: 0,
      totalDeliveries: 0,
      averageRating: 0,
      totalRatings: 0,
    ))
    EarningsSummary summary,
    @Default(false) bool isLoading,
    String? error,
  }) = _EarningsState;
}

/// State for withdrawal requests
@freezed
class WithdrawalRequest with _$WithdrawalRequest {
  const factory WithdrawalRequest({
    required String id,
    required double amount,
    required String status,
    required String bankName,
    required String accountNumber,
    required DateTime createdAt,
    DateTime? processedAt,
    String? notes,
  }) = _WithdrawalRequest;

  factory WithdrawalRequest.fromJson(Map<String, dynamic> json) {
    return WithdrawalRequest(
      id: json['_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      bankName: json['bankName'] as String,
      accountNumber: json['accountNumber'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }
}

/// State for withdrawal history
@freezed
class WithdrawalsState with _$WithdrawalsState {
  const factory WithdrawalsState({
    @Default([]) List<WithdrawalRequest> requests,
    @Default(false) bool isLoading,
    @Default(false) bool isSubmitting,
    String? error,
  }) = _WithdrawalsState;
}

/// Notifier for earnings
class EarningsNotifier extends StateNotifier<EarningsState> {
  final ApiService _apiService;

  EarningsNotifier(this._apiService) : super(const EarningsState());

  Future<void> fetchEarnings() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get(ApiEndpoints.earningsSummary);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final summary = EarningsSummary.fromJson(data as Map<String, dynamic>);

        state = state.copyWith(
          summary: summary,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'حدث خطأ',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message ?? 'حدث خطأ في الاتصال',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'حدث خطأ غير متوقع',
      );
    }
  }

  void updateSummary(EarningsSummary summary) {
    state = state.copyWith(summary: summary);
  }
}

/// Notifier for withdrawals
class WithdrawalsNotifier extends StateNotifier<WithdrawalsState> {
  final ApiService _apiService;

  WithdrawalsNotifier(this._apiService) : super(const WithdrawalsState());

  Future<void> fetchWithdrawals() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get(ApiEndpoints.withdrawalRequests);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data']?['requests'] as List<dynamic>? ?? [];
        final requests =
            data.map((r) => WithdrawalRequest.fromJson(r as Map<String, dynamic>)).toList();

        state = state.copyWith(
          requests: requests,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'حدث خطأ',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.message ?? 'حدث خطأ في الاتصال',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'حدث خطأ غير متوقع',
      );
    }
  }

  Future<bool> requestWithdrawal({
    required double amount,
    required String bankName,
    required String accountNumber,
    required String accountName,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final response = await _apiService.post(
        ApiEndpoints.requestWithdrawal,
        data: {
          'amount': amount,
          'bankName': bankName,
          'accountNumber': accountNumber,
          'accountName': accountName,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        state = state.copyWith(isSubmitting: false);
        await fetchWithdrawals(); // Refresh the list
        return true;
      } else {
        state = state.copyWith(
          isSubmitting: false,
          error: response.data['message'] ?? 'فشل في تقديم طلب السحب',
        );
        return false;
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.message ?? 'حدث خطأ في الاتصال',
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'حدث خطأ غير متوقع',
      );
      return false;
    }
  }
}

// Providers
final earningsProvider =
    StateNotifierProvider<EarningsNotifier, EarningsState>((ref) {
  return EarningsNotifier(ref.watch(apiServiceProvider));
});

final withdrawalsProvider =
    StateNotifierProvider<WithdrawalsNotifier, WithdrawalsState>((ref) {
  return WithdrawalsNotifier(ref.watch(apiServiceProvider));
});
