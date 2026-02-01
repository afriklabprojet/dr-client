import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/providers/ui_state_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/services/firebase_otp_service.dart';
import '../../../../config/providers.dart';
import '../../../../home_page.dart';
import '../../providers/firebase_otp_provider.dart';

const _otpCountdownId = 'otp_countdown';

class OtpVerificationPage extends ConsumerStatefulWidget {
  final String phoneNumber;
  final bool sendOtpOnInit;

  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
    this.sendOtpOnInit = true,
  });

  @override
  ConsumerState<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage>
    with SingleTickerProviderStateMixin {
  final int _otpLength = 6;
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
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));
    _animationController.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startResendCountdown();
      if (widget.sendOtpOnInit) _sendFirebaseOtp();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    for (var c in _controllers) c.dispose();
    for (var n in _focusNodes) n.dispose();
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
    if (value.isNotEmpty) {
      if (index < _otpLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
        if (_isOtpComplete) _verifyOtp();
      }
    }
  }

  void _onKeyEvent(int index, KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _controllers[index - 1].clear();
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  Future<void> _sendFirebaseOtp() async {
    final notifier = ref.read(firebaseOtpProvider.notifier);
    await notifier.sendOtp(widget.phoneNumber);
  }

  Future<void> _verifyOtp() async {
    if (!_isOtpComplete) {
      _showError('Veuillez entrer le code complet a 6 chiffres');
      return;
    }
    final notifier = ref.read(firebaseOtpProvider.notifier);
    final result = await notifier.verifyOtp(_otpCode);
    if (!mounted) return;
    if (result.success) {
      await _linkToBackend(result.firebaseUid!);
    }
  }

  Future<void> _linkToBackend(String firebaseUid) async {
    try {
      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.verifyFirebaseOtp(
        phone: widget.phoneNumber,
        firebaseUid: firebaseUid,
      );
      if (!mounted) return;
      result.fold(
        (failure) => _showError(failure.message),
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
      if (mounted) _showError('Erreur de liaison au compte. Veuillez reessayer.');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red.shade700),
    );
  }

  Future<void> _resendOtp() async {
    final countdown = ref.read(countdownProvider(_otpCountdownId));
    if (countdown > 0) return;
    for (var c in _controllers) c.clear();
    _focusNodes[0].requestFocus();
    final notifier = ref.read(firebaseOtpProvider.notifier);
    await notifier.resendOtp();
    _startResendCountdown();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nouveau code envoye par SMS'), backgroundColor: AppColors.primary),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(firebaseOtpProvider);
    final countdown = ref.watch(countdownProvider(_otpCountdownId));
    final isLoading = otpState.isLoading;
    final errorMessage = otpState.errorMessage;
    final state = otpState.state;

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
                  const Text('Verification OTP', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 12),
                  _buildStatusMessage(state),
                  const SizedBox(height: 4),
                  Text(widget.phoneNumber, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(_otpLength, (i) => _buildOtpField(i)),
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
                          Expanded(child: Text(errorMessage, style: TextStyle(color: Colors.red.shade700, fontSize: 14))),
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
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: isLoading
                          ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Verifier', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: countdown > 0
                        ? Text('Renvoyer le code dans ${countdown}s', style: TextStyle(fontSize: 14, color: Colors.grey[600]))
                        : TextButton(
                            onPressed: isLoading ? null : _resendOtp,
                            child: const Text('Renvoyer le code', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary)),
                          ),
                  ),
                  const Spacer(),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 24),
                      child: Column(
                        children: [
                          Icon(Icons.security, color: Colors.grey[400], size: 20),
                          const SizedBox(height: 8),
                          Text('Verification securisee par Firebase', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                        ],
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

  Widget _buildStatusMessage(FirebaseOtpState state) {
    String message;
    Color color = Colors.grey[600]!;
    switch (state) {
      case FirebaseOtpState.initial:
        message = 'Envoi du code en cours...';
        break;
      case FirebaseOtpState.codeSent:
        message = 'Entrez le code a 6 chiffres envoye au';
        break;
      case FirebaseOtpState.verifying:
        message = 'Verification en cours...';
        color = AppColors.primary;
        break;
      case FirebaseOtpState.verified:
        message = 'Verification reussie !';
        color = AppColors.success;
        break;
      case FirebaseOtpState.error:
        message = 'Entrez le code a 6 chiffres envoye au';
        break;
      case FirebaseOtpState.timeout:
        message = 'Le code a expire. Demandez un nouveau code.';
        color = AppColors.warning;
        break;
    }
    return Text(message, style: TextStyle(fontSize: 16, color: color));
  }

  Widget _buildOtpField(int index) {
    return SizedBox(
      width: 48,
      height: 56,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) => _onKeyEvent(index, event),
        child: TextField(
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.primary, width: 2)),
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (value) => _onOtpChanged(index, value),
        ),
      ),
    );
  }
}
