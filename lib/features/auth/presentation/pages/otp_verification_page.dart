import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/ui_state_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../config/providers.dart';
import '../../../../home_page.dart';

// Provider IDs pour cette page
const _otpLoadingId = 'otp_loading';
const _otpCountdownId = 'otp_countdown';
const _otpErrorId = 'otp_error';

class OtpVerificationPage extends ConsumerStatefulWidget {
  final String phoneNumber;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
  });

  @override
  ConsumerState<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage>
    with SingleTickerProviderStateMixin {
  final int _otpLength = 4;
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  
  // UI state moved to Riverpod providers:
  // - _isLoading -> loadingProvider(_otpLoadingId)
  // - _resendTimer -> countdownProvider(_otpCountdownId)
  // - _errorMessage -> formFieldsProvider(_otpErrorId)
  Timer? _timer;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize controllers and focus nodes
    for (int i = 0; i < _otpLength; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }

    // Start timer after build is complete to avoid modifying provider during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startResendTimer();
    });

    // Animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
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
    _animationController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    ref.read(countdownProvider(_otpCountdownId).notifier).setValue(30);
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentValue = ref.read(countdownProvider(_otpCountdownId));
      if (currentValue > 0) {
        ref.read(countdownProvider(_otpCountdownId).notifier).decrement();
      } else {
        timer.cancel();
      }
    });
  }

  void _onOtpChanged(String value, int index) {
    // Clear any previous error when user types
    final errorMessage = ref.read(formFieldsProvider(_otpErrorId))['otp'];
    if (errorMessage != null) {
      ref.read(formFieldsProvider(_otpErrorId).notifier).clearError('otp');
    }
    
    if (value.length == 1 && index < _otpLength - 1) {
      _focusNodes[index + 1].requestFocus();
    }
    if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    
    // Check if all filled to auto-submit
    if (_controllers.every((c) => c.text.isNotEmpty)) {
      _verifyOtp();
    }
  }

  Future<void> _verifyOtp() async {
    final otp = _controllers.map((c) => c.text).join();
    if (otp.length != _otpLength) return;
    
    // Prevent multiple simultaneous calls
    final isLoading = ref.read(loadingProvider(_otpLoadingId)).isLoading;
    if (isLoading) return;

    ref.read(loadingProvider(_otpLoadingId).notifier).startLoading();
    ref.read(formFieldsProvider(_otpErrorId).notifier).clearAll();

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.verifyOtp(
        identifier: widget.phoneNumber,
        otp: otp,
      );

      if (mounted) {
        result.fold(
          (failure) {
            ref.read(loadingProvider(_otpLoadingId).notifier).stopLoading();
            ref.read(formFieldsProvider(_otpErrorId).notifier).setError('otp', failure.message);
            // Clear OTP fields on error
            for (var controller in _controllers) {
              controller.clear();
            }
            _focusNodes[0].requestFocus();
          },
          (authResponse) {
            ref.read(loadingProvider(_otpLoadingId).notifier).stopLoading();
            // Navigate to Home on success
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ref.read(loadingProvider(_otpLoadingId).notifier).stopLoading();
        ref.read(formFieldsProvider(_otpErrorId).notifier).setError('otp', 'Erreur de connexion. Veuillez réessayer.');
      }
    }
  }

  Future<void> _resendCode() async {
    final resendTimer = ref.read(countdownProvider(_otpCountdownId));
    final isLoading = ref.read(loadingProvider(_otpLoadingId)).isLoading;
    if (resendTimer > 0 || isLoading) return;
    
    ref.read(loadingProvider(_otpLoadingId).notifier).startLoading();

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.resendOtp(
        identifier: widget.phoneNumber,
      );
      
      if (mounted) {
        result.fold(
          (failure) {
            ref.read(loadingProvider(_otpLoadingId).notifier).stopLoading();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(failure.message),
                backgroundColor: Colors.red,
              ),
            );
          },
          (data) {
            ref.read(loadingProvider(_otpLoadingId).notifier).stopLoading();
            _startResendTimer();
            
            // Show message from server (includes fallback info)
            final message = data['message'] ?? 'Nouveau code envoyé';
            final channel = data['channel'] ?? 'sms';
            
            // Different color/icon based on channel
            final isEmailFallback = channel == 'sms_fallback_email';
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      isEmailFallback ? Icons.email : Icons.sms,
                      color: Colors.white,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(message)),
                  ],
                ),
                backgroundColor: isEmailFallback ? Colors.orange : Colors.green,
                duration: Duration(seconds: isEmailFallback ? 5 : 3),
              ),
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ref.read(loadingProvider(_otpLoadingId).notifier).stopLoading();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erreur lors de l\'envoi du code'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Watch UI state providers
    final isLoading = ref.watch(loadingProvider(_otpLoadingId)).isLoading;
    final resendTimer = ref.watch(countdownProvider(_otpCountdownId));
    final errorMessage = ref.watch(formFieldsProvider(_otpErrorId))['otp'];

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF1A1A2E) : Colors.grey[50],
      body: Stack(
        children: [
          // Background Design
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.4,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    top: -50,
                    right: -50,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    left: -30,
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),



          // Main Content
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.12),
                  
                  // Header
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.lock_clock_outlined,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Vérification',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Entrez le code envoyé au',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              widget.phoneNumber,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // OTP Card
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF252540) : Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(
                                _otpLength,
                                (index) => _buildOtpDigit(index, isDark),
                              ),
                            ),
                            
                            // Error message
                            if (errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.red.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        errorMessage,
                                        style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            
                            const SizedBox(height: 32),
                            
                            // Verify Button
                            _buildVerifyButton(isLoading),
                            
                            const SizedBox(height: 24),
                            
                            // Resend Timer
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Code non reçu ? ',
                                  style: TextStyle(
                                    color: isDark ? Colors.white60 : const Color(0xFF6B7C8E),
                                    fontSize: 14,
                                  ),
                                ),
                                if (resendTimer > 0)
                                  Text(
                                    'Renvoyer dans ${resendTimer}s',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  )
                                else
                                  TextButton(
                                    onPressed: _resendCode,
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      'Renvoyer',
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Back Button
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            child: IconButton(
              onPressed: () => context.go(AppRoutes.register),
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                padding: const EdgeInsets.all(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtpDigit(int index, bool isDark) {
    return SizedBox(
      width: 60,
      height: 64,
      child: TextFormField(
        controller: _controllers[index],
        focusNode: _focusNodes[index],
        onChanged: (value) => _onOtpChanged(value, index),
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF1A2B3C),
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(1),
          FilteringTextInputFormatter.digitsOnly,
        ],
        decoration: InputDecoration(
          filled: true,
          fillColor: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : const Color(0xFFF8FAFB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.1)
                  : const Color(0xFFE8ECF0),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.primary,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyButton(bool isLoading) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primaryDark],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : _verifyOtp,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Vérifier',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
