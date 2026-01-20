import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../config/constants.dart';

/// Analytics data models
class AnalyticsSummary {
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final double totalRevenue;
  final double averageOrderValue;
  final double averageRating;
  final int totalReviews;
  final int newCustomers;

  const AnalyticsSummary({
    this.totalOrders = 0,
    this.completedOrders = 0,
    this.cancelledOrders = 0,
    this.totalRevenue = 0,
    this.averageOrderValue = 0,
    this.averageRating = 0,
    this.totalReviews = 0,
    this.newCustomers = 0,
  });

  factory AnalyticsSummary.fromJson(Map<String, dynamic> json) {
    return AnalyticsSummary(
      totalOrders: json['totalOrders'] as int? ?? 0,
      completedOrders: json['completedOrders'] as int? ?? 0,
      cancelledOrders: json['cancelledOrders'] as int? ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      averageOrderValue: (json['averageOrderValue'] as num?)?.toDouble() ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      newCustomers: json['newCustomers'] as int? ?? 0,
    );
  }

  double get completionRate {
    if (totalOrders == 0) return 0;
    return (completedOrders / totalOrders) * 100;
  }

  double get cancellationRate {
    if (totalOrders == 0) return 0;
    return (cancelledOrders / totalOrders) * 100;
  }
}

class ChartDataPoint {
  final String label;
  final double value;

  const ChartDataPoint({required this.label, required this.value});

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      label: json['label'] as String? ?? json['_id'] as String? ?? '',
      value: (json['value'] as num? ?? json['count'] as num? ?? 0).toDouble(),
    );
  }
}

class TopItem {
  final String id;
  final String name;
  final String nameAr;
  final int orderCount;
  final double revenue;

  const TopItem({
    required this.id,
    required this.name,
    required this.nameAr,
    required this.orderCount,
    required this.revenue,
  });

  factory TopItem.fromJson(Map<String, dynamic> json) {
    return TopItem(
      id: json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      nameAr: json['nameAr'] as String? ?? '',
      orderCount: json['orderCount'] as int? ?? 0,
      revenue: (json['revenue'] as num?)?.toDouble() ?? 0,
    );
  }
}

class AnalyticsCharts {
  final List<ChartDataPoint> ordersByDay;
  final List<ChartDataPoint> ordersByHour;
  final List<ChartDataPoint> ordersByStatus;
  final List<TopItem> topItems;

  const AnalyticsCharts({
    this.ordersByDay = const [],
    this.ordersByHour = const [],
    this.ordersByStatus = const [],
    this.topItems = const [],
  });

  factory AnalyticsCharts.fromJson(Map<String, dynamic> json) {
    return AnalyticsCharts(
      ordersByDay: (json['ordersByDay'] as List<dynamic>?)
              ?.map((e) => ChartDataPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      ordersByHour: (json['ordersByHour'] as List<dynamic>?)
              ?.map((e) => ChartDataPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      ordersByStatus: (json['ordersByStatus'] as List<dynamic>?)
              ?.map((e) => ChartDataPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      topItems: (json['topItems'] as List<dynamic>?)
              ?.map((e) => TopItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class ComparisonData {
  final double ordersChange;
  final double revenueChange;
  final double ratingChange;

  const ComparisonData({
    this.ordersChange = 0,
    this.revenueChange = 0,
    this.ratingChange = 0,
  });

  factory ComparisonData.fromJson(Map<String, dynamic> json) {
    return ComparisonData(
      ordersChange: (json['ordersChange'] as num?)?.toDouble() ?? 0,
      revenueChange: (json['revenueChange'] as num?)?.toDouble() ?? 0,
      ratingChange: (json['ratingChange'] as num?)?.toDouble() ?? 0,
    );
  }
}

class RestaurantAnalytics {
  final AnalyticsSummary summary;
  final AnalyticsCharts charts;
  final ComparisonData comparison;

  const RestaurantAnalytics({
    this.summary = const AnalyticsSummary(),
    this.charts = const AnalyticsCharts(),
    this.comparison = const ComparisonData(),
  });

  factory RestaurantAnalytics.fromJson(Map<String, dynamic> json) {
    return RestaurantAnalytics(
      summary: AnalyticsSummary.fromJson(
          json['summary'] as Map<String, dynamic>? ?? {}),
      charts: AnalyticsCharts.fromJson(
          json['charts'] as Map<String, dynamic>? ?? {}),
      comparison: ComparisonData.fromJson(
          json['comparison'] as Map<String, dynamic>? ?? {}),
    );
  }
}

/// Analytics state
class AnalyticsState {
  final RestaurantAnalytics? analytics;
  final bool isLoading;
  final String? error;
  final String period;
  final DateTime? startDate;
  final DateTime? endDate;

  const AnalyticsState({
    this.analytics,
    this.isLoading = false,
    this.error,
    this.period = 'week',
    this.startDate,
    this.endDate,
  });

  AnalyticsState copyWith({
    RestaurantAnalytics? analytics,
    bool? isLoading,
    String? error,
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return AnalyticsState(
      analytics: analytics ?? this.analytics,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

/// Analytics notifier
class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  final ApiService _apiService;

  AnalyticsNotifier(this._apiService) : super(const AnalyticsState());

  Future<void> fetchAnalytics({
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (state.isLoading) return;

    state = state.copyWith(
      isLoading: true,
      error: null,
      period: period ?? state.period,
      startDate: startDate ?? state.startDate,
      endDate: endDate ?? state.endDate,
    );

    try {
      final queryParams = <String, dynamic>{
        'period': state.period,
      };

      if (state.startDate != null) {
        queryParams['startDate'] = state.startDate!.toIso8601String();
      }
      if (state.endDate != null) {
        queryParams['endDate'] = state.endDate!.toIso8601String();
      }

      final response = await _apiService.get(
        AppEndpoints.analytics,
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final analytics =
            RestaurantAnalytics.fromJson(data as Map<String, dynamic>);

        state = state.copyWith(
          analytics: analytics,
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

  void setPeriod(String period) {
    fetchAnalytics(period: period);
  }

  void setDateRange(DateTime start, DateTime end) {
    fetchAnalytics(period: 'custom', startDate: start, endDate: end);
  }

  void refresh() {
    state = AnalyticsState(period: state.period);
    fetchAnalytics();
  }
}

// Provider
final analyticsProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  final apiService = ApiService();
  return AnalyticsNotifier(apiService);
});
