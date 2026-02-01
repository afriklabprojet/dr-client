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
  
  Timer? _timer;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    for (int i = 0; i < _otpLength; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
    
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
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    
    _animationController.forward();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startResendCountdown();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _startResendCountdown() {
    _timer?.cancel();
    ref.read(countdownProvider(_otpCountdownId).notifier).setValue(60);
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final current = ref.read(countdownProvider(_otpCountdownId));
      if (current > 0) {
        ref.read(countdownProvider(_otpCountdownId).notifier).decrement();
      } else {
        timer.cancel();
      }
    });
  }

  String get _otpCode => _controllers.map((c) => c.text).join();

  bool get _isOtpComplete => _otpCode.length == _otpLength;

  void _onOtpChanged(int index, String value) {
    ref.read(formFieldsProvider(_otpErrorId).notifier).clearAll();
    
    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_isOtpComplete) {
          _verifyOtp();
        }
      }
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  Future<void> _verifyOtp() async {
    if (!_isOtpComplete) {
      ref.read(formFieldsProvider(_otpErrorId).notifier).setError('otp', 'Veuillez entrer le code complet');
      return;
    }

    ref.read(loadingProvider(_otpLoadingId).notifier).startLoading();
    ref.read(formFieldsProvider(_otpErrorId).notifier).clearAll();

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.verifyOtp(
        identifier: widget.phoneNumber,
        otp: _otpCode,
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          ref.read(formFieldsProvider(_otpErrorId).notifier).setError('otp', failure.message);
        },
        (success) {
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomePage()),
              (route) => false,
            );
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ref.read(formFieldsProvider(_otpErrorId).notifier).setError('otp', 'Une erreur est survenue. Veuillez reessayer.');
      }
    } finally {
      if (mounted) {
        ref.read(loadingProvider(_otpLoadingId).notifier).stopLoading();
      }
    }
  }

  Future<void> _resendOtp() async {
    final countdown = ref.read(countdownProvider(_otpCountdownId));
    if (countdown > 0) return;

    ref.read(loadingProvider(_otpLoadingId).notifier).startLoading();
    ref.read(formFieldsProvider(_otpErrorId).notifier).clearAll();

    try {
      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.resendOtp(
        identifier: widget.phoneNumber,
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          ref.read(formFieldsProvider(_otpErrorId).notifier).setError('otp', failure.message);
        },
        (success) {
          for (var controller in _controllers) {
            controller.clear();
          }
          _focusNodes[0].requestFocus();
          _startResendCountdown();
          
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Code renvoye avec succes'),
              backgroundColor: AppColors.primary,
            ),
          );
        },
      );
    } catch (e) {
      if (mounted) {
        ref.read(formFieldsProvider(_otpErrorId).notifier).setError('otp', 'Impossible de renvoyer le code. Reessayez.');
      }
    } finally {
      if (mounted) {
        ref.read(loadingProvider(_otpLoadingId).notifier).stopLoading();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final loadingState = ref.watch(loadingProvider(_otpLoadingId));
    final countdown = ref.watch(countdownProvider(_otpCountdownId));
    final errorMap = ref.watch(formFieldsProvider(_otpErrorId));
    final errorMessage = errorMap['otp'];
    final isLoading = loadingState.isLoading;
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => context.go(AppRoutes.register),
        ),
      ),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  
                  const Text(
                    'Verification OTP',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  Text(
                    'Entrez le code a 4 chiffres envoye au',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  
                  const SizedBox(height: 4),
                  
                  Text(
                    widget.phoneNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(
                      _otpLength,
                      (index) => _buildOtpField(index),
                    ),
                  ),
                  
                  if (errorMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              errorMessage,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 32),
                  
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _verifyOtp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Verifier',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Center(
                    child: countdown > 0
                        ? Text(
                            'Renvoyer le code dans ${countdown}s',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          )
                        : TextButton(
                            onPressed: isLoading ? null : _resendOtp,
                            child: const Text(
                              'Renvoyer le code',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                  ),
                  
                  const Spacer(),
                  
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Text(
                        'Vous n avez pas recu le code ?\nVerifiez votre numero ou reessayez.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 60,
      height: 70,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) => _onKeyEvent(index, event),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 2,
              ),
            ),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
          ],
          onChanged: (value) => _onOtpChanged(index, value),
        ),
      ),
    );
  }
}
