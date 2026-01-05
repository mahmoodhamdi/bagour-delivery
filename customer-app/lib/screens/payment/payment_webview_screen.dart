import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../config/theme.dart';
import '../../providers/payment_provider.dart';

class PaymentWebViewScreen extends ConsumerStatefulWidget {
  final String paymentUrl;
  final String orderId;
  final bool isWalletTopup;

  const PaymentWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.orderId,
    this.isWalletTopup = false,
  });

  @override
  ConsumerState<PaymentWebViewScreen> createState() =>
      _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends ConsumerState<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasProcessedPayment = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            _checkPaymentStatus(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            debugPrint('Navigating to: $url');

            // Check for Paymob response URL patterns
            if (_isPaymentResultUrl(url)) {
              _processPaymentResult(url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('WebView error: ${error.description}');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  /// Check if the URL is a payment result URL
  bool _isPaymentResultUrl(String url) {
    return url.contains('payment/success') ||
        url.contains('payment/failed') ||
        url.contains('payment/response') ||
        url.contains('/txn_response') ||
        (url.contains('success=') && url.contains('pending='));
  }

  /// Check payment status from page URL
  void _checkPaymentStatus(String url) {
    if (_hasProcessedPayment) return;

    // Parse Paymob response parameters from URL
    final uri = Uri.parse(url);
    final queryParams = uri.queryParameters;

    // Check for Paymob standard response parameters
    if (queryParams.containsKey('success') && queryParams.containsKey('pending')) {
      _processPaymentResult(url);
    }
  }

  /// Process payment result from URL
  void _processPaymentResult(String url) {
    if (_hasProcessedPayment) return;

    final uri = Uri.parse(url);
    final queryParams = uri.queryParameters;

    // Paymob returns success=true/false and pending=true/false
    final success = queryParams['success'] == 'true';
    final pending = queryParams['pending'] == 'true';

    // Payment is successful only if success=true AND pending=false
    final paymentSuccessful = success && !pending;

    _hasProcessedPayment = true;

    if (paymentSuccessful) {
      _handlePaymentSuccess();
    } else {
      _handlePaymentFailure();
    }
  }

  void _handlePaymentSuccess() {
    ref.read(paymentProvider.notifier).onPaymentCompleted(true);

    if (widget.isWalletTopup) {
      // Wallet topup success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم شحن المحفظة بنجاح!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Go back to wallet screen
      context.pop();
    } else {
      // Order payment success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم الدفع بنجاح!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Navigate to order tracking
      context.go('/order/${widget.orderId}');
    }
  }

  void _handlePaymentFailure() {
    ref.read(paymentProvider.notifier).onPaymentCompleted(false);

    if (widget.isWalletTopup) {
      // Wallet topup failure
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فشل شحن المحفظة. يرجى المحاولة مرة أخرى.'),
          backgroundColor: AppColors.error,
        ),
      );

      // Go back to wallet screen
      context.pop();
    } else {
      // Order payment failure
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('فشل الدفع. يرجى المحاولة مرة أخرى.'),
          backgroundColor: AppColors.error,
        ),
      );

      // Go back to checkout
      context.pop();
    }
  }

  Future<bool> _onWillPop() async {
    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إلغاء الدفع؟'),
        content: const Text('هل أنت متأكد أنك تريد إلغاء عملية الدفع؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('لا'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('نعم'),
          ),
        ],
      ),
    );

    return shouldPop ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('الدفع الآمن'),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldPop = await _onWillPop();
              if (shouldPop && context.mounted) {
                context.pop();
              }
            },
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (_isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
