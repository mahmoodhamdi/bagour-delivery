import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/auth_provider.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/otp_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/orders/order_details_screen.dart';
import '../screens/menu/menu_screen.dart';
import '../screens/menu/add_menu_item_screen.dart';
import '../screens/menu/categories_screen.dart';
import '../screens/reviews/reviews_screen.dart';
import '../screens/earnings/earnings_screen.dart';

/// Route path constants
class AppRoutes {
  // Initial
  static const String splash = '/';
  static const String onboarding = '/onboarding';

  // Auth
  static const String login = '/login';
  static const String register = '/register';
  static const String otp = '/otp';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';

  // Main
  static const String dashboard = '/dashboard';

  // Orders
  static const String orders = '/orders';
  static const String orderDetails = '/orders/:id';
  static const String orderHistory = '/orders/history';

  // Menu
  static const String menu = '/menu';
  static const String addMenuItem = '/menu/add';
  static const String editMenuItem = '/menu/:id';
  static const String categories = '/menu/categories';
  static const String addCategory = '/menu/categories/add';

  // Reviews
  static const String reviews = '/reviews';
  static const String reviewDetails = '/reviews/:id';

  // Earnings
  static const String earnings = '/earnings';
  static const String earningsHistory = '/earnings/history';
  static const String payoutRequests = '/earnings/payouts';

  // Profile & Settings
  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String restaurantInfo = '/restaurant/info';
  static const String restaurantHours = '/restaurant/hours';
  static const String settings = '/settings';
  static const String notifications = '/notifications';
  static const String help = '/help';
  static const String support = '/support';
}

/// Routes that don't require authentication
const _publicRoutes = [
  AppRoutes.splash,
  AppRoutes.onboarding,
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.otp,
  AppRoutes.forgotPassword,
  AppRoutes.resetPassword,
];

/// GoRouter configuration provider with auth state redirect
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(ref, authProvider),
    redirect: (context, state) {
      final isAuthenticated = authState.maybeMap(
        authenticated: (_) => true,
        orElse: () => false,
      );

      final isInitializing = authState.maybeMap(
        initial: (_) => true,
        loading: (_) => true,
        orElse: () => false,
      );

      final currentPath = state.matchedLocation;
      final isPublicRoute = _publicRoutes.any((route) => currentPath == route);

      // Don't redirect while initializing (splash screen handles this)
      if (isInitializing && currentPath == AppRoutes.splash) {
        return null;
      }

      // If authenticated and trying to access auth routes, redirect to dashboard
      if (isAuthenticated && _isAuthRoute(currentPath)) {
        return AppRoutes.dashboard;
      }

      // If not authenticated and trying to access protected routes, redirect to login
      if (!isAuthenticated && !isPublicRoute && !isInitializing) {
        return AppRoutes.login;
      }

      return null;
    },
    routes: [
      // ==================== INITIAL & AUTH ====================
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.otp,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OtpScreen(
            identifier: extra?['email'] ?? extra?['phone'] ?? '',
            type: extra?['type'] ?? 'email_verification',
          );
        },
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.resetPassword,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          // TODO: Create ResetPasswordScreen
          return _ResetPasswordScreen(
            email: extra?['email'] ?? '',
            otp: extra?['otp'] ?? '',
          );
        },
      ),

      // ==================== DASHBOARD ====================
      GoRoute(
        path: AppRoutes.dashboard,
        builder: (context, state) => const DashboardScreen(),
      ),

      // ==================== ORDERS ====================
      GoRoute(
        path: AppRoutes.orders,
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: AppRoutes.orderDetails,
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderDetailsScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: AppRoutes.orderHistory,
        builder: (context, state) {
          // TODO: Create OrderHistoryScreen
          return const _PlaceholderScreen(title: 'سجل الطلبات');
        },
      ),

      // ==================== MENU ====================
      GoRoute(
        path: AppRoutes.menu,
        builder: (context, state) => const MenuScreen(),
      ),
      GoRoute(
        path: AppRoutes.addMenuItem,
        builder: (context, state) => const AddMenuItemScreen(),
      ),
      GoRoute(
        path: AppRoutes.categories,
        builder: (context, state) => const CategoriesScreen(),
      ),
      GoRoute(
        path: AppRoutes.addCategory,
        builder: (context, state) {
          // TODO: Create AddCategoryScreen
          return const _PlaceholderScreen(title: 'إضافة تصنيف');
        },
      ),
      GoRoute(
        path: AppRoutes.editMenuItem,
        builder: (context, state) {
          final menuItemId = state.pathParameters['id']!;
          // TODO: Create EditMenuItemScreen
          return _EditMenuItemScreen(menuItemId: menuItemId);
        },
      ),

      // ==================== REVIEWS ====================
      GoRoute(
        path: AppRoutes.reviews,
        builder: (context, state) => const ReviewsScreen(),
      ),
      GoRoute(
        path: AppRoutes.reviewDetails,
        builder: (context, state) {
          final reviewId = state.pathParameters['id']!;
          // TODO: Create ReviewDetailsScreen
          return _PlaceholderScreen(title: 'تفاصيل التقييم - $reviewId');
        },
      ),

      // ==================== EARNINGS ====================
      GoRoute(
        path: AppRoutes.earnings,
        builder: (context, state) => const EarningsScreen(),
      ),
      GoRoute(
        path: AppRoutes.earningsHistory,
        builder: (context, state) {
          // TODO: Create EarningsHistoryScreen
          return const _PlaceholderScreen(title: 'سجل الأرباح');
        },
      ),
      GoRoute(
        path: AppRoutes.payoutRequests,
        builder: (context, state) {
          // TODO: Create PayoutRequestsScreen
          return const _PlaceholderScreen(title: 'طلبات السحب');
        },
      ),

      // ==================== PROFILE & SETTINGS ====================
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) {
          // TODO: Create ProfileScreen
          return const _ProfileScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) {
          // TODO: Create EditProfileScreen
          return const _PlaceholderScreen(title: 'تعديل الملف الشخصي');
        },
      ),
      GoRoute(
        path: AppRoutes.restaurantInfo,
        builder: (context, state) {
          // TODO: Create RestaurantInfoScreen
          return const _PlaceholderScreen(title: 'معلومات المطعم');
        },
      ),
      GoRoute(
        path: AppRoutes.restaurantHours,
        builder: (context, state) {
          // TODO: Create RestaurantHoursScreen
          return const _PlaceholderScreen(title: 'ساعات العمل');
        },
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) {
          // TODO: Create SettingsScreen
          return const _SettingsScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) {
          // TODO: Create NotificationsScreen
          return const _NotificationsScreen();
        },
      ),
      GoRoute(
        path: AppRoutes.help,
        builder: (context, state) {
          // TODO: Create HelpScreen
          return const _PlaceholderScreen(title: 'المساعدة');
        },
      ),
      GoRoute(
        path: AppRoutes.support,
        builder: (context, state) {
          // TODO: Create SupportScreen
          return const _PlaceholderScreen(title: 'الدعم الفني');
        },
      ),
    ],
    errorBuilder: (context, state) => ErrorScreen(error: state.error),
  );
});

/// Check if the current path is an auth route
bool _isAuthRoute(String path) {
  return path == AppRoutes.login ||
      path == AppRoutes.register ||
      path == AppRoutes.otp ||
      path == AppRoutes.forgotPassword ||
      path == AppRoutes.resetPassword;
}

/// Custom refresh stream for GoRouter that listens to auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(this._ref, this._provider) {
    _ref.listen(_provider, (_, __) => notifyListeners());
  }

  final Ref _ref;
  final StateNotifierProvider<AuthNotifier, AuthState> _provider;
}

/// Error screen for unhandled routes
class ErrorScreen extends StatelessWidget {
  final Exception? error;

  const ErrorScreen({super.key, this.error});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('خطأ'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.dashboard),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                'الصفحة غير موجودة',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error?.toString() ?? 'حدث خطأ غير متوقع',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.dashboard),
                icon: const Icon(Icons.home),
                label: const Text('العودة للرئيسية'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Placeholder screen for routes that are not yet implemented
class _PlaceholderScreen extends StatelessWidget {
  final String title;

  const _PlaceholderScreen({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'هذه الصفحة قيد التطوير',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('العودة'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reset password screen placeholder
class _ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const _ResetPasswordScreen({
    required this.email,
    required this.otp,
  });

  @override
  State<_ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<_ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    // TODO: Implement password reset logic
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم تغيير كلمة المرور بنجاح'),
          backgroundColor: Colors.green,
        ),
      );
      context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعيين كلمة مرور جديدة'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'أدخل كلمة المرور الجديدة',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'كلمة المرور مطلوبة';
                  }
                  if (value.length < 6) {
                    return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'تأكيد كلمة المرور',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                ),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'كلمات المرور غير متطابقة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleResetPassword,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('تغيير كلمة المرور'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Edit menu item screen placeholder
class _EditMenuItemScreen extends StatelessWidget {
  final String menuItemId;

  const _EditMenuItemScreen({required this.menuItemId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تعديل الصنف'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.edit_note,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              'تعديل الصنف #$menuItemId',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'هذه الصفحة قيد التطوير',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('العودة'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Profile screen placeholder
class _ProfileScreen extends StatelessWidget {
  const _ProfileScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الملف الشخصي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => context.push(AppRoutes.editProfile),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Center(
            child: CircleAvatar(
              radius: 50,
              child: Icon(Icons.restaurant, size: 50),
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'اسم المطعم',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 32),
          _buildProfileItem(
            context,
            icon: Icons.restaurant_menu,
            title: 'معلومات المطعم',
            onTap: () => context.push(AppRoutes.restaurantInfo),
          ),
          _buildProfileItem(
            context,
            icon: Icons.access_time,
            title: 'ساعات العمل',
            onTap: () => context.push(AppRoutes.restaurantHours),
          ),
          _buildProfileItem(
            context,
            icon: Icons.star,
            title: 'التقييمات',
            onTap: () => context.push(AppRoutes.reviews),
          ),
          _buildProfileItem(
            context,
            icon: Icons.settings,
            title: 'الإعدادات',
            onTap: () => context.push(AppRoutes.settings),
          ),
          _buildProfileItem(
            context,
            icon: Icons.help_outline,
            title: 'المساعدة',
            onTap: () => context.push(AppRoutes.help),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

/// Settings screen placeholder
class _SettingsScreen extends StatelessWidget {
  const _SettingsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإعدادات'),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('الإشعارات'),
            trailing: Switch(
              value: true,
              onChanged: (value) {},
            ),
          ),
          ListTile(
            leading: const Icon(Icons.volume_up_outlined),
            title: const Text('صوت الطلبات الجديدة'),
            trailing: Switch(
              value: true,
              onChanged: (value) {},
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('اللغة'),
            subtitle: const Text('العربية'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock_outline),
            title: const Text('تغيير كلمة المرور'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('سياسة الخصوصية'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('الشروط والأحكام'),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'تسجيل الخروج',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () => context.go(AppRoutes.login),
          ),
        ],
      ),
    );
  }
}

/// Notifications screen placeholder
class _NotificationsScreen extends StatelessWidget {
  const _NotificationsScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('مسح الكل'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'لا توجد إشعارات',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extension methods for navigation
extension NavigationExtensions on BuildContext {
  /// Navigate to order details
  void goToOrderDetails(String orderId) {
    go('/orders/$orderId');
  }

  /// Navigate to edit menu item
  void goToEditMenuItem(String menuItemId) {
    go('/menu/$menuItemId');
  }

  /// Navigate to review details
  void goToReviewDetails(String reviewId) {
    go('/reviews/$reviewId');
  }

  /// Navigate to OTP screen with data
  void goToOtp({
    required String identifier,
    required String type,
  }) {
    go(
      AppRoutes.otp,
      extra: {
        'email': identifier,
        'type': type,
      },
    );
  }

  /// Navigate to reset password screen with data
  void goToResetPassword({
    required String email,
    required String otp,
  }) {
    go(
      AppRoutes.resetPassword,
      extra: {
        'email': email,
        'otp': otp,
      },
    );
  }
}
