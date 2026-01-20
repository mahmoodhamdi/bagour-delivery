import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../config/constants.dart';

/// Balance information
class RestaurantBalance {
  final double totalEarnings;
  final double withdrawn;
  final double pending;
  final double available;

  const RestaurantBalance({
    this.totalEarnings = 0,
    this.withdrawn = 0,
    this.pending = 0,
    this.available = 0,
  });

  factory RestaurantBalance.fromJson(Map<String, dynamic> json) {
    return RestaurantBalance(
      totalEarnings: (json['totalEarnings'] as num?)?.toDouble() ?? 0,
      withdrawn: (json['withdrawn'] as num?)?.toDouble() ?? 0,
      pending: (json['pending'] as num?)?.toDouble() ?? 0,
      available: (json['available'] as num?)?.toDouble() ?? 0,
    );
  }
}

/// Payout request model
class Payout {
  final String id;
  final double amount;
  final String method;
  final String status;
  final String reference;
  final DateTime createdAt;
  final DateTime? processedAt;
  final String? adminNotes;
  final Map<String, dynamic> accountDetails;

  const Payout({
    required this.id,
    required this.amount,
    required this.method,
    required this.status,
    required this.reference,
    required this.createdAt,
    this.processedAt,
    this.adminNotes,
    required this.accountDetails,
  });

  factory Payout.fromJson(Map<String, dynamic> json) {
    return Payout(
      id: json['_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      method: json['method'] as String,
      status: json['status'] as String,
      reference: json['reference'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      processedAt: json['processedAt'] != null
          ? DateTime.parse(json['processedAt'] as String)
          : null,
      adminNotes: json['adminNotes'] as String?,
      accountDetails: json['accountDetails'] as Map<String, dynamic>? ?? {},
    );
  }

  String get methodLabel {
    switch (method) {
      case 'bank_transfer':
        return 'تحويل بنكي';
      case 'vodafone_cash':
        return 'فودافون كاش';
      case 'instapay':
        return 'انستا باي';
      default:
        return method;
    }
  }

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'قيد الانتظار';
      case 'processing':
        return 'جاري المعالجة';
      case 'completed':
        return 'مكتمل';
      case 'rejected':
        return 'مرفوض';
      default:
        return status;
    }
  }
}

/// State for balance
class BalanceState {
  final RestaurantBalance? balance;
  final bool isLoading;
  final String? error;

  const BalanceState({
    this.balance,
    this.isLoading = false,
    this.error,
  });

  BalanceState copyWith({
    RestaurantBalance? balance,
    bool? isLoading,
    String? error,
  }) {
    return BalanceState(
      balance: balance ?? this.balance,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// State for payouts list
class PayoutsState {
  final List<Payout> payouts;
  final bool isLoading;
  final bool hasMore;
  final int currentPage;
  final String? error;

  const PayoutsState({
    this.payouts = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.currentPage = 1,
    this.error,
  });

  PayoutsState copyWith({
    List<Payout>? payouts,
    bool? isLoading,
    bool? hasMore,
    int? currentPage,
    String? error,
  }) {
    return PayoutsState(
      payouts: payouts ?? this.payouts,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      error: error,
    );
  }
}

/// State for creating payout
class CreatePayoutState {
  final bool isCreating;
  final String? error;
  final Payout? createdPayout;

  const CreatePayoutState({
    this.isCreating = false,
    this.error,
    this.createdPayout,
  });

  CreatePayoutState copyWith({
    bool? isCreating,
    String? error,
    Payout? createdPayout,
  }) {
    return CreatePayoutState(
      isCreating: isCreating ?? this.isCreating,
      error: error,
      createdPayout: createdPayout ?? this.createdPayout,
    );
  }
}

/// Balance notifier
class BalanceNotifier extends StateNotifier<BalanceState> {
  final ApiService _apiService;

  BalanceNotifier(this._apiService) : super(const BalanceState());

  Future<void> fetchBalance() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get(AppEndpoints.balance);

      if (response.statusCode == 200 && response.data['success'] == true) {
        final balanceData = response.data['data'];
        final balance = RestaurantBalance.fromJson(balanceData as Map<String, dynamic>);

        state = state.copyWith(
          balance: balance,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'حدث خطأ',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'حدث خطأ في الاتصال',
      );
    }
  }

  void refresh() {
    state = const BalanceState();
    fetchBalance();
  }
}

/// Payouts list notifier
class PayoutsNotifier extends StateNotifier<PayoutsState> {
  final ApiService _apiService;

  PayoutsNotifier(this._apiService) : super(const PayoutsState());

  Future<void> fetchPayouts({bool refresh = false}) async {
    if (state.isLoading) return;

    final page = refresh ? 1 : state.currentPage;

    state = state.copyWith(
      isLoading: true,
      error: null,
      currentPage: page,
    );

    try {
      final response = await _apiService.get(
        AppEndpoints.payouts,
        queryParameters: {'page': page, 'limit': 20},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final payoutsData = data['payouts'] as List<dynamic>? ?? [];
        final payouts = payoutsData
            .map((p) => Payout.fromJson(p as Map<String, dynamic>))
            .toList();

        final pagination = data['pagination'];
        final hasMore = pagination != null
            ? (pagination['page'] as int) < (pagination['pages'] as int)
            : false;

        state = state.copyWith(
          payouts: refresh ? payouts : [...state.payouts, ...payouts],
          isLoading: false,
          hasMore: hasMore,
          currentPage: page,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'حدث خطأ',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'حدث خطأ في الاتصال',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMore) return;
    state = state.copyWith(currentPage: state.currentPage + 1);
    await fetchPayouts();
  }

  void refresh() {
    state = const PayoutsState();
    fetchPayouts(refresh: true);
  }
}

/// Create payout notifier
class CreatePayoutNotifier extends StateNotifier<CreatePayoutState> {
  final ApiService _apiService;

  CreatePayoutNotifier(this._apiService) : super(const CreatePayoutState());

  Future<bool> createPayout({
    required double amount,
    required String method,
    required Map<String, dynamic> accountDetails,
    String? notes,
  }) async {
    if (state.isCreating) return false;

    state = state.copyWith(isCreating: true, error: null);

    try {
      final response = await _apiService.post(
        AppEndpoints.payouts,
        data: {
          'amount': amount,
          'method': method,
          'accountDetails': accountDetails,
          if (notes != null) 'notes': notes,
        },
      );

      if (response.statusCode == 201 && response.data['success'] == true) {
        final payoutData = response.data['data'];
        final payout = Payout.fromJson(payoutData as Map<String, dynamic>);

        state = state.copyWith(
          isCreating: false,
          createdPayout: payout,
        );
        return true;
      } else {
        state = state.copyWith(
          isCreating: false,
          error: response.data['message'] ?? 'حدث خطأ في إنشاء طلب السحب',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        error: 'حدث خطأ في الاتصال',
      );
      return false;
    }
  }

  void reset() {
    state = const CreatePayoutState();
  }
}

// Providers
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final balanceProvider = StateNotifierProvider<BalanceNotifier, BalanceState>((ref) {
  return BalanceNotifier(ref.watch(apiServiceProvider));
});

final payoutsProvider = StateNotifierProvider<PayoutsNotifier, PayoutsState>((ref) {
  return PayoutsNotifier(ref.watch(apiServiceProvider));
});

final createPayoutProvider =
    StateNotifierProvider<CreatePayoutNotifier, CreatePayoutState>((ref) {
  return CreatePayoutNotifier(ref.watch(apiServiceProvider));
});
