import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/theme.dart';
import '../../config/routes.dart';
import '../../config/constants.dart';
import '../../models/models.dart';
import '../../providers/auth_provider.dart';

class OtpScreen extends ConsumerStatefulWidget {
  final String identifier;
  final String type;

  const OtpScreen({
    super.key,
    required this.identifier,
    required this.type,
  });

  @override
  ConsumerState<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends ConsumerState<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    AppConstants.otpLength,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(
    AppConstants.otpLength,
    (_) => FocusNode(),
  );

  bool _isLoading = false;
  bool _isResending = false;
  int _resendTimer = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startResendTimer();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    _timer?.cancel();
    super.dispose();
  }

  void _startResendTimer() {
    _resendTimer = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _otp => _controllers.map((c) => c.text).join();

  bool get _isOtpComplete => _otp.length == AppConstants.otpLength;

  Future<void> _verifyOtp() async {
    if (!_isOtpComplete) return;

    setState(() => _isLoading = true);

    // Use email verification
    await ref.read(authProvider.notifier).verifyEmail(
          VerifyEmailRequest(
            email: widget.identifier,
            otp: _otp,
          ),
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    final authState = ref.read(authProvider);
    authState.mapOrNull(
      authenticated: (_) => context.go(AppRoutes.home),
      error: (error) => _showError(error.message),
    );
  }

  Future<void> _resendOtp() async {
    if (_resendTimer > 0 || _isResending) return;

    setState(() => _isResending = true);

    final success = await ref.read(authProvider.notifier).resendOtp(
          widget.identifier,
        );

    if (!mounted) return;
    setState(() => _isResending = false);

    if (success) {
      _startResendTimer();
      _showSuccess('تم إرسال رمز التحقق');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
    ref.read(authProvider.notifier).clearError();
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _onOtpChanged(String value, int index) {
    if (value.length == 1 && index < AppConstants.otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (_isOtpComplete) {
      _verifyOtp();
    }
  }

  void _onKeyPressed(KeyEvent event, int index) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = widget.type.contains('phone');

    return Scaffold(
      appBar: AppBar(
        title: const Text('التحقق'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),

              // Icon
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isPhone ? Icons.phone_android : Icons.email_outlined,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Title
              Text(
                'أدخل رمز التحقق',
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'تم إرسال رمز التحقق إلى\n${widget.identifier}',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // OTP fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  AppConstants.otpLength,
                  (index) => SizedBox(
                    width: 50,
                    child: KeyboardListener(
                      focusNode: FocusNode(),
                      onKeyEvent: (event) => _onKeyPressed(event, index),
                      child: TextFormField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: Theme.of(context).textTheme.headlineMedium,
                        decoration: InputDecoration(
                          counterText: '',
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) => _onOtpChanged(value, index),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Verify button
              ElevatedButton(
                onPressed: _isLoading || !_isOtpComplete ? null : _verifyOtp,
                child: _isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('تحقق'),
              ),
              const SizedBox(height: 24),

              // Resend button
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'لم تستلم الرمز؟',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: _resendTimer > 0 ? null : _resendOtp,
                    child: _isResending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _resendTimer > 0
                                ? 'إعادة الإرسال ($_resendTimer)'
                                : 'إعادة الإرسال',
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
