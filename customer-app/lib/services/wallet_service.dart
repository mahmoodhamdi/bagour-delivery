import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_service.dart';

final walletServiceProvider = Provider<WalletService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return WalletService(apiService);
});

class WalletService {
  final ApiService _apiService;

  WalletService(this._apiService);

  /// Get wallet balance
  Future<WalletBalance> getBalance() async {
    try {
      final response = await _apiService.get('/customer/wallet/balance');

      if (response.data['success']) {
        return WalletBalance.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'فشل جلب رصيد المحفظة');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'حدث خطأ أثناء جلب رصيد المحفظة',
        );
      } else {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }
    }
  }

  /// Get wallet transactions
  Future<WalletTransactionsResponse> getTransactions({
    int page = 1,
    int limit = 20,
    String? type,
  }) async {
    try {
      final response = await _apiService.get(
        '/customer/wallet/transactions',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (type != null) 'type': type,
        },
      );

      if (response.data['success']) {
        return WalletTransactionsResponse.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'فشل جلب المعاملات');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'حدث خطأ أثناء جلب المعاملات',
        );
      } else {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }
    }
  }

  /// Initiate wallet top-up
  Future<WalletTopUpResponse> initiateTopUp({
    required double amount,
    required String paymentMethod, // 'card' or 'mobile_wallet'
    String? phoneNumber, // Required for mobile_wallet
  }) async {
    try {
      final response = await _apiService.post(
        '/customer/wallet/topup',
        data: {
          'amount': amount,
          'paymentMethod': paymentMethod,
          if (phoneNumber != null) 'phoneNumber': phoneNumber,
        },
      );

      if (response.data['success']) {
        return WalletTopUpResponse.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'فشل بدء عملية الشحن');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
          e.response?.data['message'] ?? 'حدث خطأ أثناء بدء عملية الشحن',
        );
      } else {
        throw Exception('لا يوجد اتصال بالإنترنت');
      }
    }
  }
}

/// Wallet Balance Model
class WalletBalance {
  final double balance;
  final double totalTopups;
  final double totalSpent;

  WalletBalance({
    required this.balance,
    required this.totalTopups,
    required this.totalSpent,
  });

  factory WalletBalance.fromJson(Map<String, dynamic> json) {
    return WalletBalance(
      balance: (json['balance'] as num).toDouble(),
      totalTopups: (json['totalTopups'] as num).toDouble(),
      totalSpent: (json['totalSpent'] as num).toDouble(),
    );
  }
}

/// Wallet Transaction Model
class WalletTransaction {
  final String id;
  final String type;
  final double amount;
  final String status;
  final String? description;
  final String? orderId;
  final DateTime createdAt;

  WalletTransaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.status,
    this.description,
    this.orderId,
    required this.createdAt,
  });

  factory WalletTransaction.fromJson(Map<String, dynamic> json) {
    return WalletTransaction(
      id: json['_id'] as String,
      type: json['type'] as String,
      amount: (json['amount'] as num).toDouble(),
      status: json['status'] as String,
      description: json['description'] as String?,
      orderId: json['orderId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  String get typeLabel {
    switch (type) {
      case 'wallet_topup':
        return 'شحن المحفظة';
      case 'order_payment':
        return 'دفع طلب';
      case 'refund':
        return 'استرجاع';
      default:
        return type;
    }
  }

  bool get isCredit => type == 'wallet_topup' || type == 'refund';
}

/// Wallet Transactions Response
class WalletTransactionsResponse {
  final List<WalletTransaction> transactions;
  final int total;
  final int page;
  final int limit;
  final int pages;

  WalletTransactionsResponse({
    required this.transactions,
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory WalletTransactionsResponse.fromJson(Map<String, dynamic> json) {
    // Backend sendPaginated puts transactions in 'data' field, not 'transactions'
    final List<dynamic> transactionsData =
        (json['data'] ?? json['transactions'] ?? []) as List<dynamic>;
    final pagination = json['pagination'] as Map<String, dynamic>? ?? {
      'total': 0,
      'page': 1,
      'limit': 20,
      'pages': 1,
    };

    return WalletTransactionsResponse(
      transactions: transactionsData
          .map((t) => WalletTransaction.fromJson(t as Map<String, dynamic>))
          .toList(),
      total: pagination['total'] as int? ?? 0,
      page: pagination['page'] as int? ?? 1,
      limit: pagination['limit'] as int? ?? 20,
      pages: pagination['pages'] as int? ?? 1,
    );
  }
}

/// Wallet Top-Up Response
class WalletTopUpResponse {
  final String transactionId;
  final String paymentUrl;
  final double amount;

  WalletTopUpResponse({
    required this.transactionId,
    required this.paymentUrl,
    required this.amount,
  });

  factory WalletTopUpResponse.fromJson(Map<String, dynamic> json) {
    return WalletTopUpResponse(
      transactionId: json['transactionId'] as String,
      // Backend returns 'redirectUrl', map it to paymentUrl
      paymentUrl: (json['redirectUrl'] ?? json['paymentUrl']) as String,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
