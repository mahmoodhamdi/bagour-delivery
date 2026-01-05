import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:dio/dio.dart';
import '../../config/theme.dart';
import '../../config/constants.dart';
import '../../services/api_service.dart';
import 'orders_screen.dart';

/// Order detail state
class OrderDetailState {
  final bool isLoading;
  final String? error;
  final RestaurantOrder? order;
  final bool isUpdatingStatus;
  final List<OrderStatusHistoryItem> statusHistory;

  const OrderDetailState({
    this.isLoading = false,
    this.error,
    this.order,
    this.isUpdatingStatus = false,
    this.statusHistory = const [],
  });

  OrderDetailState copyWith({
    bool? isLoading,
    String? error,
    RestaurantOrder? order,
    bool? isUpdatingStatus,
    List<OrderStatusHistoryItem>? statusHistory,
  }) {
    return OrderDetailState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      order: order ?? this.order,
      isUpdatingStatus: isUpdatingStatus ?? this.isUpdatingStatus,
      statusHistory: statusHistory ?? this.statusHistory,
    );
  }
}

/// Order status history item
class OrderStatusHistoryItem {
  final String status;
  final DateTime timestamp;
  final String? note;

  const OrderStatusHistoryItem({
    required this.status,
    required this.timestamp,
    this.note,
  });

  factory OrderStatusHistoryItem.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistoryItem(
      status: json['status'] ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      note: json['note'],
    );
  }

  String get statusLabel =>
      AppConstants.orderStatusLabels[status] ?? status;

  Color get statusColor =>
      Color(AppConstants.orderStatusColors[status] ?? 0xFF9E9E9E);
}

/// Order detail notifier
class OrderDetailNotifier extends StateNotifier<OrderDetailState> {
  final ApiService _apiService;
  final String orderId;

  OrderDetailNotifier(this._apiService, this.orderId)
      : super(const OrderDetailState()) {
    fetchOrderDetails();
  }

  Future<void> fetchOrderDetails() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await _apiService.get('/restaurant/orders/$orderId');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final order = RestaurantOrder.fromJson(data);

        final historyData = data['statusHistory'] as List? ?? [];
        final history = historyData
            .map((h) => OrderStatusHistoryItem.fromJson(h as Map<String, dynamic>))
            .toList();

        state = state.copyWith(
          isLoading: false,
          order: order,
          statusHistory: history,
          error: null,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.data['message'] ?? 'فشل في تحميل بيانات الطلب',
        );
      }
    } on DioException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _apiService.handleError(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'حدث خطأ غير متوقع',
      );
    }
  }

  Future<bool> updateStatus(String newStatus) async {
    state = state.copyWith(isUpdatingStatus: true);

    try {
      final response = await _apiService.patch(
        '/restaurant/orders/$orderId/status',
        data: {'status': newStatus},
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        await fetchOrderDetails();
        return true;
      }

      state = state.copyWith(isUpdatingStatus: false);
      return false;
    } on DioException catch (e) {
      state = state.copyWith(
        isUpdatingStatus: false,
        error: _apiService.handleError(e),
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        isUpdatingStatus: false,
        error: 'حدث خطأ في تحديث حالة الطلب',
      );
      return false;
    }
  }

  Future<bool> acceptOrder() async {
    return updateStatus('confirmed');
  }

  Future<bool> rejectOrder(String reason) async {
    state = state.copyWith(isUpdatingStatus: true);

    try {
      final response = await _apiService.patch(
        '/restaurant/orders/$orderId/status',
        data: {
          'status': 'cancelled',
          'cancellationReason': reason,
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        await fetchOrderDetails();
        return true;
      }

      state = state.copyWith(isUpdatingStatus: false);
      return false;
    } catch (e) {
      state = state.copyWith(isUpdatingStatus: false);
      return false;
    }
  }

  Future<bool> startPreparing() async {
    return updateStatus('preparing');
  }

  Future<bool> markReady() async {
    return updateStatus('ready');
  }

  Future<void> refresh() async {
    await fetchOrderDetails();
  }
}

/// Order detail provider family
final orderDetailProvider = StateNotifierProvider.autoDispose
    .family<OrderDetailNotifier, OrderDetailState, String>((ref, orderId) {
  final apiService = ref.watch(apiServiceProvider);
  return OrderDetailNotifier(apiService, orderId);
});

/// Order Details Screen
class OrderDetailsScreen extends ConsumerWidget {
  final String orderId;

  const OrderDetailsScreen({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailState = ref.watch(orderDetailProvider(orderId));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          detailState.order != null
              ? 'طلب #${detailState.order!.orderNumber}'
              : 'تفاصيل الطلب',
        ),
        actions: [
          if (detailState.order != null)
            PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(context, ref, value),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'print',
                  child: ListTile(
                    leading: Icon(Icons.print),
                    title: Text('طباعة الإيصال'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'copy',
                  child: ListTile(
                    leading: Icon(Icons.copy),
                    title: Text('نسخ رقم الطلب'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                if (detailState.order!.customerPhone != null)
                  const PopupMenuItem(
                    value: 'call',
                    child: ListTile(
                      leading: Icon(Icons.phone),
                      title: Text('اتصل بالعميل'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
              ],
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(orderDetailProvider(orderId).notifier).refresh(),
        child: detailState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : detailState.error != null
                ? _buildErrorState(context, ref, detailState.error!)
                : detailState.order != null
                    ? _buildContent(context, ref, detailState)
                    : const Center(child: Text('الطلب غير موجود')),
      ),
      bottomNavigationBar: detailState.order != null
          ? _buildBottomActions(context, ref, detailState)
          : null,
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () =>
                  ref.read(orderDetailProvider(orderId).notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    OrderDetailState state,
  ) {
    final order = state.order!;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Status Card
          _buildStatusCard(context, order),
          const SizedBox(height: 16),

          // Status Timeline
          _buildStatusTimeline(context, order, state.statusHistory),
          const SizedBox(height: 16),

          // Customer Info
          _buildCustomerCard(context, order),
          const SizedBox(height: 16),

          // Order Items
          _buildOrderItemsCard(context, order),
          const SizedBox(height: 16),

          // Notes (if any)
          if (order.notes != null && order.notes!.isNotEmpty) ...[
            _buildNotesCard(context, order),
            const SizedBox(height: 16),
          ],

          // Delivery Address
          if (order.deliveryAddress != null) ...[
            _buildAddressCard(context, order),
            const SizedBox(height: 16),
          ],

          // Payment Summary
          _buildPaymentSummary(context, order),
          const SizedBox(height: 100), // Space for bottom actions
        ],
      ),
    );
  }

  Widget _buildStatusCard(BuildContext context, RestaurantOrder order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: order.statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getStatusIcon(order.status),
                color: order.statusColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.statusLabel,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: order.statusColor,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getStatusDescription(order.status),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(
    BuildContext context,
    RestaurantOrder order,
    List<OrderStatusHistoryItem> history,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.timeline, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'مسار الطلب',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ..._buildTimelineSteps(context, order, history),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildTimelineSteps(
    BuildContext context,
    RestaurantOrder order,
    List<OrderStatusHistoryItem> history,
  ) {
    // Define all possible statuses for restaurant
    final allStatuses = [
      'pending',
      'confirmed',
      'preparing',
      'ready',
      'picked_up',
      'on_the_way',
      'delivered',
    ];

    // If cancelled, show different flow
    if (order.status == 'cancelled') {
      return [
        _buildTimelineItem(
          context,
          status: 'pending',
          isCompleted: true,
          timestamp: _getHistoryTime(history, 'pending'),
        ),
        _buildTimelineItem(
          context,
          status: 'cancelled',
          isCompleted: true,
          isCancelled: true,
          isLast: true,
          timestamp: _getHistoryTime(history, 'cancelled'),
        ),
      ];
    }

    final currentIndex = allStatuses.indexOf(order.status);
    final steps = <Widget>[];

    for (var i = 0; i < allStatuses.length; i++) {
      final status = allStatuses[i];
      final isCompleted = i <= currentIndex;
      final isCurrent = i == currentIndex;
      final isLast = i == allStatuses.length - 1;

      steps.add(_buildTimelineItem(
        context,
        status: status,
        isCompleted: isCompleted,
        isCurrent: isCurrent,
        isLast: isLast,
        timestamp: _getHistoryTime(history, status),
      ));
    }

    return steps;
  }

  DateTime? _getHistoryTime(List<OrderStatusHistoryItem> history, String status) {
    try {
      return history.firstWhere((h) => h.status == status).timestamp;
    } catch (_) {
      return null;
    }
  }

  Widget _buildTimelineItem(
    BuildContext context, {
    required String status,
    bool isCompleted = false,
    bool isCurrent = false,
    bool isCancelled = false,
    bool isLast = false,
    DateTime? timestamp,
  }) {
    final color = isCancelled
        ? AppColors.error
        : isCompleted
            ? AppColors.success
            : AppColors.textHint;
    final label = AppConstants.orderStatusLabels[status] ?? status;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isCompleted
                    ? color.withValues(alpha: 0.2)
                    : AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: isCurrent ? 3 : 2,
                ),
              ),
              child: isCompleted
                  ? Icon(
                      isCancelled ? Icons.close : Icons.check,
                      size: 14,
                      color: color,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 32,
                color: isCompleted ? color : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight:
                            isCurrent ? FontWeight.bold : FontWeight.normal,
                        color: isCompleted
                            ? AppColors.textPrimary
                            : AppColors.textHint,
                      ),
                ),
                if (timestamp != null)
                  Text(
                    _formatDateTime(timestamp),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerCard(BuildContext context, RestaurantOrder order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'معلومات العميل',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppColors.grey200,
                  backgroundImage: order.customerAvatar != null
                      ? NetworkImage(order.customerAvatar!)
                      : null,
                  child: order.customerAvatar == null
                      ? const Icon(
                          Icons.person,
                          size: 32,
                          color: AppColors.textSecondary,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      if (order.customerPhone != null)
                        Text(
                          order.customerPhone!,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                    ],
                  ),
                ),
                if (order.customerPhone != null)
                  IconButton(
                    onPressed: () => _callCustomer(context, order.customerPhone!),
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.phone,
                        color: AppColors.success,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsCard(BuildContext context, RestaurantOrder order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.restaurant_menu, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'تفاصيل الطلب',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.grey100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${order.itemCount} عناصر',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...order.items.map((item) => _buildOrderItem(context, item)),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, OrderItemData item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.grey50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item image or placeholder
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.grey200,
                  borderRadius: BorderRadius.circular(8),
                  image: item.image != null
                      ? DecorationImage(
                          image: NetworkImage(item.image!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: item.image == null
                    ? const Icon(
                        Icons.fastfood,
                        color: AppColors.textHint,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.displayName,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        Text(
                          '${item.itemTotal.toStringAsFixed(0)} ج.م',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${item.quantity}x @ ${item.price.toStringAsFixed(0)} ج.م',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Variations
          if (item.variations.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: item.variations
                  .map((v) => Chip(
                        label: Text(
                          '${v.displayName}: ${v.displayOption}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ))
                  .toList(),
            ),
          ],

          // Addons
          if (item.addons.isNotEmpty) ...[
            const SizedBox(height: 8),
            ...item.addons.map((addon) => Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.add_circle,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          '${addon.displayName} (${addon.quantity}x)',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      Text(
                        '+${(addon.price * addon.quantity).toStringAsFixed(0)} ج.م',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                )),
          ],

          // Special Instructions
          if (item.specialInstructions != null &&
              item.specialInstructions!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.note,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.specialInstructions!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotesCard(BuildContext context, RestaurantOrder order) {
    return Card(
      color: AppColors.warningLight,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.note, color: AppColors.warning),
                const SizedBox(width: 8),
                Text(
                  'ملاحظات على الطلب',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              order.notes!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(BuildContext context, RestaurantOrder order) {
    final address = order.deliveryAddress!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.location_on, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'عنوان التوصيل',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              address.name,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              address.fullAddress,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (address.building != null || address.floor != null || address.apartment != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  if (address.building != null) ...[
                    _buildAddressDetail(context, 'مبنى', address.building!),
                    const SizedBox(width: 16),
                  ],
                  if (address.floor != null) ...[
                    _buildAddressDetail(context, 'طابق', address.floor!),
                    const SizedBox(width: 16),
                  ],
                  if (address.apartment != null)
                    _buildAddressDetail(context, 'شقة', address.apartment!),
                ],
              ),
            ],
            if (address.landmark != null && address.landmark!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.near_me,
                    size: 14,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      address.landmark!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddressDetail(BuildContext context, String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildPaymentSummary(BuildContext context, RestaurantOrder order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.receipt, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'ملخص الفاتورة',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPriceRow(context, 'المجموع الفرعي', order.subtotal),
            const SizedBox(height: 8),
            _buildPriceRow(context, 'رسوم التوصيل', order.deliveryFee),
            if (order.discount > 0) ...[
              const SizedBox(height: 8),
              _buildPriceRow(
                context,
                'الخصم',
                -order.discount,
                valueColor: AppColors.success,
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'الإجمالي',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${order.total.toStringAsFixed(0)} ج.م',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    order.paymentMethod == 'cash'
                        ? Icons.payments
                        : Icons.credit_card,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'طريقة الدفع',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                        ),
                        Text(
                          order.paymentMethodLabel,
                          style:
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: order.paymentStatus == 'paid'
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      order.paymentStatus == 'paid' ? 'مدفوع' : 'غير مدفوع',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: order.paymentStatus == 'paid'
                                ? AppColors.success
                                : AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    double value, {
    Color? valueColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        Text(
          '${value >= 0 ? '' : '-'}${value.abs().toStringAsFixed(0)} ج.م',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
        ),
      ],
    );
  }

  Widget? _buildBottomActions(
    BuildContext context,
    WidgetRef ref,
    OrderDetailState state,
  ) {
    final order = state.order!;

    // Don't show actions for completed orders
    if (order.status == 'delivered' ||
        order.status == 'cancelled' ||
        order.status == 'picked_up' ||
        order.status == 'on_the_way') {
      return null;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: state.isUpdatingStatus
            ? const Center(child: CircularProgressIndicator())
            : _buildActionButton(context, ref, order),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    WidgetRef ref,
    RestaurantOrder order,
  ) {
    if (order.canAccept) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showRejectDialog(context, ref),
              icon: const Icon(Icons.close),
              label: const Text('رفض'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: FilledButton.icon(
              onPressed: () async {
                final success = await ref
                    .read(orderDetailProvider(orderId).notifier)
                    .acceptOrder();
                if (success && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم قبول الطلب بنجاح'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('قبول الطلب'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ),
        ],
      );
    }

    if (order.canStartPreparing) {
      return FilledButton.icon(
        onPressed: () async {
          final success = await ref
              .read(orderDetailProvider(orderId).notifier)
              .startPreparing();
          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم بدء تحضير الطلب'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        icon: const Icon(Icons.restaurant),
        label: const Text('بدء التحضير'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.statusPreparing,
          minimumSize: const Size.fromHeight(52),
        ),
      );
    }

    if (order.canMarkReady) {
      return FilledButton.icon(
        onPressed: () async {
          final success = await ref
              .read(orderDetailProvider(orderId).notifier)
              .markReady();
          if (success && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تم تجهيز الطلب'),
                backgroundColor: AppColors.success,
              ),
            );
          }
        },
        icon: const Icon(Icons.check_circle),
        label: const Text('الطلب جاهز'),
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.statusReady,
          minimumSize: const Size.fromHeight(52),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  void _showRejectDialog(BuildContext context, WidgetRef ref) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('رفض الطلب'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('هل أنت متأكد من رفض هذا الطلب؟'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'سبب الرفض',
                hintText: 'اختياري',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              final success = await ref
                  .read(orderDetailProvider(orderId).notifier)
                  .rejectOrder(reasonController.text);
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم رفض الطلب'),
                    backgroundColor: AppColors.error,
                  ),
                );
                context.pop();
              }
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('رفض الطلب'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(BuildContext context, WidgetRef ref, String action) {
    final state = ref.read(orderDetailProvider(orderId));
    final order = state.order;

    if (order == null) return;

    switch (action) {
      case 'print':
        _printReceipt(context, order);
        break;
      case 'copy':
        Clipboard.setData(ClipboardData(text: order.orderNumber));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم نسخ رقم الطلب')),
        );
        break;
      case 'call':
        if (order.customerPhone != null) {
          _callCustomer(context, order.customerPhone!);
        }
        break;
    }
  }

  void _printReceipt(BuildContext context, RestaurantOrder order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('طباعة الإيصال'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'إيصال طلب #${order.orderNumber}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  const Divider(height: 24),
                  ...order.items.map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${item.quantity}x ${item.displayName}'),
                            Text('${item.itemTotal.toStringAsFixed(0)} ج.م'),
                          ],
                        ),
                      )),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('الإجمالي'),
                      Text(
                        '${order.total.toStringAsFixed(0)} ج.م',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('جاري إرسال للطابعة...')),
              );
            },
            icon: const Icon(Icons.print),
            label: const Text('طباعة'),
          ),
        ],
      ),
    );
  }

  void _callCustomer(BuildContext context, String phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('الاتصال بـ $phone'),
        action: SnackBarAction(
          label: 'اتصال',
          onPressed: () {
            // Launch phone dialer - would use url_launcher in real app
          },
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.pending_actions;
      case 'confirmed':
        return Icons.check_circle;
      case 'preparing':
        return Icons.restaurant;
      case 'ready':
        return Icons.done_all;
      case 'picked_up':
        return Icons.delivery_dining;
      case 'on_the_way':
        return Icons.directions_bike;
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'pending':
        return 'في انتظار قبول الطلب';
      case 'confirmed':
        return 'تم قبول الطلب، يرجى البدء بالتحضير';
      case 'preparing':
        return 'جاري تحضير الطلب';
      case 'ready':
        return 'الطلب جاهز للاستلام من السائق';
      case 'picked_up':
        return 'السائق استلم الطلب';
      case 'on_the_way':
        return 'الطلب في الطريق للعميل';
      case 'delivered':
        return 'تم توصيل الطلب بنجاح';
      case 'cancelled':
        return 'تم إلغاء الطلب';
      default:
        return '';
    }
  }

  String _formatDateTime(DateTime time) {
    return '${time.day}/${time.month} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
