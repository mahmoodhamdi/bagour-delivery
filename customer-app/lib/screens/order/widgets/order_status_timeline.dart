import 'package:flutter/material.dart';
import '../../../config/theme.dart';
import '../../../models/order.dart';

class OrderStatusTimeline extends StatelessWidget {
  final OrderStatus currentStatus;
  final List<OrderStatusHistory> statusHistory;

  const OrderStatusTimeline({
    super.key,
    required this.currentStatus,
    required this.statusHistory,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = _getStatusSteps();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'حالة الطلب',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...statuses.map((status) {
            final index = statuses.indexOf(status);
            final isLast = index == statuses.length - 1;
            return _buildTimelineStep(
              context,
              status: status,
              isLast: isLast,
            );
          }),
        ],
      ),
    );
  }

  List<_StatusStep> _getStatusSteps() {
    // If cancelled, show different flow
    if (currentStatus == OrderStatus.cancelled) {
      return [
        _StatusStep(
          status: OrderStatus.pending,
          isCompleted: true,
          time: _getStatusTime(OrderStatus.pending),
        ),
        _StatusStep(
          status: OrderStatus.cancelled,
          isCompleted: true,
          isCancelled: true,
          time: _getStatusTime(OrderStatus.cancelled),
        ),
      ];
    }

    final steps = <_StatusStep>[];
    final statusOrder = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.preparing,
      OrderStatus.ready,
      OrderStatus.pickedUp,
      OrderStatus.onTheWay,
      OrderStatus.delivered,
    ];

    final currentIndex = statusOrder.indexOf(currentStatus);

    for (var i = 0; i < statusOrder.length; i++) {
      final status = statusOrder[i];
      steps.add(_StatusStep(
        status: status,
        isCompleted: i <= currentIndex,
        isCurrent: i == currentIndex,
        time: _getStatusTime(status),
      ));
    }

    return steps;
  }

  DateTime? _getStatusTime(OrderStatus status) {
    try {
      return statusHistory
          .firstWhere((h) => h.status == status)
          .timestamp;
    } catch (_) {
      return null;
    }
  }

  Widget _buildTimelineStep(
    BuildContext context, {
    required _StatusStep status,
    required bool isLast,
  }) {
    final color = status.isCancelled
        ? AppColors.error
        : status.isCompleted
            ? AppColors.success
            : AppColors.textHint;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline indicator
        Column(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: status.isCompleted
                    ? color.withValues(alpha: 0.2)
                    : AppColors.background,
                shape: BoxShape.circle,
                border: Border.all(
                  color: color,
                  width: status.isCurrent ? 3 : 2,
                ),
              ),
              child: status.isCompleted
                  ? Icon(
                      status.isCancelled ? Icons.close : Icons.check,
                      size: 18,
                      color: color,
                    )
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: status.isCompleted ? color : AppColors.border,
              ),
          ],
        ),
        const SizedBox(width: 12),
        // Step content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getStatusLabel(status.status),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: status.isCurrent
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: status.isCompleted
                                ? AppColors.textPrimary
                                : AppColors.textHint,
                          ),
                    ),
                    if (status.time != null)
                      Text(
                        _formatTime(status.time!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                  ],
                ),
                if (status.isCurrent && !status.isCancelled) ...[
                  const SizedBox(height: 4),
                  Text(
                    _getStatusDescription(status.status),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'في انتظار التأكيد';
      case OrderStatus.confirmed:
        return 'تم التأكيد';
      case OrderStatus.preparing:
        return 'جاري التحضير';
      case OrderStatus.ready:
        return 'جاهز للاستلام';
      case OrderStatus.pickedUp:
        return 'تم الاستلام';
      case OrderStatus.onTheWay:
        return 'في الطريق إليك';
      case OrderStatus.delivered:
        return 'تم التوصيل';
      case OrderStatus.cancelled:
        return 'تم الإلغاء';
    }
  }

  String _getStatusDescription(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'المطعم يراجع طلبك...';
      case OrderStatus.confirmed:
        return 'تم قبول طلبك وسيبدأ التحضير قريباً';
      case OrderStatus.preparing:
        return 'المطعم يحضر طلبك الآن';
      case OrderStatus.ready:
        return 'طلبك جاهز وفي انتظار السائق';
      case OrderStatus.pickedUp:
        return 'السائق استلم طلبك';
      case OrderStatus.onTheWay:
        return 'السائق في طريقه إليك';
      case OrderStatus.delivered:
        return 'تم توصيل طلبك بنجاح!';
      case OrderStatus.cancelled:
        return 'تم إلغاء الطلب';
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}

class _StatusStep {
  final OrderStatus status;
  final bool isCompleted;
  final bool isCurrent;
  final bool isCancelled;
  final DateTime? time;

  _StatusStep({
    required this.status,
    this.isCompleted = false,
    this.isCurrent = false,
    this.isCancelled = false,
    this.time,
  });
}
