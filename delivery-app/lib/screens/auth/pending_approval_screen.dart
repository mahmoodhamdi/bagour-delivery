import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../providers/auth_provider.dart';
import '../../utils/url_launcher_helper.dart';

class PendingApprovalScreen extends ConsumerStatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  ConsumerState<PendingApprovalScreen> createState() =>
      _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends ConsumerState<PendingApprovalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkApprovalStatus() async {
    setState(() => _isRefreshing = true);

    try {
      await ref.read(authProvider.notifier).refreshUser();

      if (!mounted) return;

      final authState = ref.read(authProvider);
      authState.mapOrNull(
        authenticated: (state) {
          if (state.driver?.status == 'approved') {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('تهانينا! تم قبول طلبك'),
                backgroundColor: AppColors.success,
              ),
            );
            context.go(AppRoutes.home);
          } else if (state.driver?.status == 'rejected') {
            _showRejectionDialog();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('طلبك لا يزال قيد المراجعة'),
                backgroundColor: AppColors.warning,
              ),
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  void _showRejectionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: AppColors.error),
            ),
            const SizedBox(width: 12),
            const Text('تم رفض الطلب'),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'للأسف، تم رفض طلبك. قد يكون السبب:',
            ),
            SizedBox(height: 12),
            Text('- المستندات غير واضحة أو غير صالحة'),
            Text('- معلومات غير صحيحة'),
            Text('- عدم استيفاء الشروط'),
            SizedBox(height: 16),
            Text(
              'يمكنك التواصل مع الدعم للمزيد من التفاصيل.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.go(AppRoutes.documentsUpload);
            },
            child: const Text('إعادة رفع المستندات'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              UrlLauncherHelper.launchSupportWhatsApp();
            },
            child: const Text('تواصل مع الدعم'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Animated Icon
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _pulseAnimation.value,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      gradient: AppColors.driverGradient,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.hourglass_bottom,
                      size: 80,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Title
              Text(
                'طلبك قيد المراجعة',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Description
              Text(
                'شكراً لتقديم طلبك! فريقنا يقوم بمراجعة مستنداتك ومعلوماتك. عادةً ما تستغرق عملية المراجعة 24-48 ساعة.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Status Steps
              _buildStatusStep(
                icon: Icons.upload_file,
                title: 'رفع المستندات',
                subtitle: 'تم بنجاح',
                isCompleted: true,
              ),
              _buildStatusStep(
                icon: Icons.verified_user,
                title: 'مراجعة المستندات',
                subtitle: 'جاري المراجعة',
                isCompleted: false,
                isActive: true,
              ),
              _buildStatusStep(
                icon: Icons.check_circle,
                title: 'الموافقة النهائية',
                subtitle: 'في انتظار المراجعة',
                isCompleted: false,
              ),
              const SizedBox(height: 32),

              // Info Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.notifications_active, color: AppColors.info),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'سنرسل لك إشعاراً فور اتخاذ قرار بشأن طلبك',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.textSecondary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Refresh Button
              OutlinedButton.icon(
                onPressed: _isRefreshing ? null : _checkApprovalStatus,
                icon: _isRefreshing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(_isRefreshing ? 'جاري التحقق...' : 'تحقق من الحالة'),
              ),
              const SizedBox(height: 16),

              // Contact Support
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'هل لديك استفسار؟',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  TextButton(
                    onPressed: () => UrlLauncherHelper.launchSupportWhatsApp(),
                    child: const Text('تواصل معنا'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Logout
              TextButton.icon(
                onPressed: () async {
                  await ref.read(authProvider.notifier).logout();
                  if (mounted) {
                    context.go(AppRoutes.login);
                  }
                },
                icon: const Icon(Icons.logout, color: AppColors.textSecondary),
                label: const Text(
                  'تسجيل الخروج',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusStep({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isCompleted,
    bool isActive = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isCompleted
                  ? AppColors.success.withValues(alpha: 0.1)
                  : isActive
                      ? AppColors.warning.withValues(alpha: 0.1)
                      : AppColors.grey100,
              shape: BoxShape.circle,
              border: isActive
                  ? Border.all(color: AppColors.warning, width: 2)
                  : null,
            ),
            child: Icon(
              isCompleted ? Icons.check : icon,
              color: isCompleted
                  ? AppColors.success
                  : isActive
                      ? AppColors.warning
                      : AppColors.grey400,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isCompleted || isActive
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                ),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: isCompleted
                            ? AppColors.success
                            : isActive
                                ? AppColors.warning
                                : AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          if (isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 12,
                    height: 12,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.warning),
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'جاري',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.warning,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
