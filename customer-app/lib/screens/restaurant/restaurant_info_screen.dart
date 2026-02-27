import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../config/theme.dart';
import '../../models/restaurant.dart';
import '../../providers/restaurant_provider.dart';

/// Restaurant info screen showing hours, location, contact info
class RestaurantInfoScreen extends ConsumerWidget {
  final String restaurantId;
  final Restaurant? restaurant;

  const RestaurantInfoScreen({
    super.key,
    required this.restaurantId,
    this.restaurant,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use passed restaurant or fetch from provider
    final restaurantState = ref.watch(restaurantDetailsProvider);
    final currentRestaurant = restaurant ?? restaurantState.restaurant;

    if (currentRestaurant == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('معلومات المطعم'),
        ),
        body: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with restaurant image
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                currentRestaurant.name,
                style: const TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      color: Colors.black54,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (currentRestaurant.coverImage != null)
                    CachedNetworkImage(
                      imageUrl: currentRestaurant.coverImage!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.background,
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        child: const Icon(
                          Icons.restaurant,
                          size: 64,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else
                    Container(
                      color: AppColors.primary,
                    ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            leading: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status and quick info
                _buildStatusSection(context, currentRestaurant),

                const Divider(height: 32),

                // Working hours
                _buildWorkingHoursSection(context, currentRestaurant),

                const Divider(height: 32),

                // Location
                _buildLocationSection(context, currentRestaurant),

                const Divider(height: 32),

                // Contact info
                _buildContactSection(context, currentRestaurant),

                const Divider(height: 32),

                // Additional info
                _buildAdditionalInfoSection(context, currentRestaurant),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context, Restaurant restaurant) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status badge
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: restaurant.isOpen
                      ? AppColors.success
                      : AppColors.error,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      restaurant.isOpen
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      restaurant.isOpen ? 'مفتوح الآن' : 'مغلق',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              if (restaurant.isPaused) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.warning,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pause_circle,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'مشغول',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 16),

          // Quick info cards
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  context,
                  icon: Icons.star,
                  iconColor: AppColors.rating,
                  title: 'التقييم',
                  value: restaurant.rating.toStringAsFixed(1),
                  subtitle: '${restaurant.totalRatings} تقييم',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  context,
                  icon: Icons.access_time,
                  iconColor: AppColors.info,
                  title: 'وقت التوصيل',
                  value: restaurant.estimatedDeliveryTime != null
                      ? '${restaurant.estimatedDeliveryTime!.min}-${restaurant.estimatedDeliveryTime!.max}'
                      : '-',
                  subtitle: 'دقيقة',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildInfoCard(
                  context,
                  icon: Icons.delivery_dining,
                  iconColor: AppColors.success,
                  title: 'رسوم التوصيل',
                  value: restaurant.deliveryFee == 0
                      ? 'مجاني'
                      : restaurant.deliveryFee.toStringAsFixed(0),
                  subtitle: restaurant.deliveryFee == 0 ? '' : 'ج.م',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textHint,
                  ),
            ),
        ],
      ),
    );
  }

  Widget _buildWorkingHoursSection(BuildContext context, Restaurant restaurant) {
    final daysAr = [
      'الأحد',
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
    ];

    final today = DateTime.now().weekday % 7; // Sunday = 0

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.schedule, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'ساعات العمل',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (restaurant.workingHours.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.textHint),
                  SizedBox(width: 8),
                  Text('مواعيد العمل غير متوفرة'),
                ],
              ),
            )
          else
            ...List.generate(7, (index) {
              final workingHour = restaurant.workingHours.firstWhere(
                (wh) => wh.day == index,
                orElse: () => WorkingHours(day: index, isOpen: false),
              );

              final isToday = index == today;

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: isToday
                      ? Border.all(color: AppColors.primary)
                      : null,
                ),
                child: Row(
                  children: [
                    if (isToday)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(left: 8),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    Text(
                      daysAr[index],
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight:
                                isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                    ),
                    const Spacer(),
                    if (workingHour.isOpen && workingHour.shifts.isNotEmpty)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: workingHour.shifts.map((shift) {
                          return Text(
                            '${shift.open} - ${shift.close}',
                            style:
                                Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: isToday
                                          ? AppColors.primary
                                          : AppColors.textSecondary,
                                    ),
                          );
                        }).toList(),
                      )
                    else
                      Text(
                        'مغلق',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.error,
                            ),
                      ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildLocationSection(BuildContext context, Restaurant restaurant) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'الموقع',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Address card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (restaurant.address != null) ...[
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.pin_drop_outlined,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          restaurant.address!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                if (restaurant.area != null) ...[
                  Row(
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        restaurant.area!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                // Open in maps button
                if (restaurant.location != null &&
                    restaurant.location!.coordinates.length >= 2)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _openInMaps(
                        restaurant.location!.coordinates[1],
                        restaurant.location!.coordinates[0],
                      ),
                      icon: const Icon(Icons.directions),
                      label: const Text('فتح في الخرائط'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context, Restaurant restaurant) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.contact_phone, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'التواصل',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (restaurant.phone != null)
            _buildContactRow(
              context,
              icon: Icons.phone,
              label: 'الهاتف',
              value: restaurant.phone!,
              onTap: () => _makePhoneCall(restaurant.phone!),
              onCopy: () => _copyToClipboard(context, restaurant.phone!),
            )
          else
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.textHint),
                  SizedBox(width: 8),
                  Text('معلومات التواصل غير متوفرة'),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildContactRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
    required VoidCallback onCopy,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        subtitle: Text(
          value,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: onCopy,
              color: AppColors.textSecondary,
            ),
            IconButton(
              icon: const Icon(Icons.call, size: 20),
              onPressed: onTap,
              color: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalInfoSection(
      BuildContext context, Restaurant restaurant) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'معلومات إضافية',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Info items
          _buildInfoItem(
            context,
            icon: Icons.shopping_bag_outlined,
            label: 'الحد الأدنى للطلب',
            value: restaurant.minimumOrder > 0
                ? '${restaurant.minimumOrder.toStringAsFixed(0)} ج.م'
                : 'لا يوجد حد أدنى',
          ),
          if (restaurant.freeDeliveryAbove != null)
            _buildInfoItem(
              context,
              icon: Icons.local_shipping_outlined,
              label: 'توصيل مجاني',
              value: 'للطلبات فوق ${restaurant.freeDeliveryAbove!.toStringAsFixed(0)} ج.م',
            ),
          _buildInfoItem(
            context,
            icon: Icons.payments_outlined,
            label: 'طرق الدفع',
            value: _getPaymentMethods(restaurant),
          ),
          _buildInfoItem(
            context,
            icon: Icons.category_outlined,
            label: 'الأقسام',
            value: restaurant.categories.isNotEmpty
                ? restaurant.categories.join('، ')
                : 'غير محدد',
          ),
          if (restaurant.description?.isNotEmpty == true)
            _buildInfoItem(
              context,
              icon: Icons.description_outlined,
              label: 'الوصف',
              value: restaurant.description!,
            ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getPaymentMethods(Restaurant restaurant) {
    final methods = <String>[];
    if (restaurant.acceptsCash) methods.add('الدفع عند الاستلام');
    if (restaurant.acceptsOnlinePayment) methods.add('الدفع الإلكتروني');
    return methods.isNotEmpty ? methods.join('، ') : 'غير محدد';
  }

  Future<void> _makePhoneCall(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _copyToClipboard(BuildContext context, String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الرقم'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openInMaps(double lat, double lng) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
