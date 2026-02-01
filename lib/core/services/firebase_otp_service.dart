import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// États possibles de la vérification OTP Firebase
enum FirebaseOtpState {
  initial,
  codeSent,
  verifying,
  verified,
  error,
  timeout,
}

/// Résultat de la vérification OTP
class FirebaseOtpResult {
  final bool success;
  final String? errorMessage;
  final String? firebaseUid;
  final String? phoneNumber;

  FirebaseOtpResult({
    required this.success,
    this.errorMessage,
    this.firebaseUid,
    this.phoneNumber,
  });

  factory FirebaseOtpResult.success({String? firebaseUid, String? phoneNumber}) {
    return FirebaseOtpResult(
      success: true,
      firebaseUid: firebaseUid,
      phoneNumber: phoneNumber,
    );
  }

  factory FirebaseOtpResult.error(String message) {
    return FirebaseOtpResult(
      success: false,
      errorMessage: message,
    );
  }
}

/// Service pour gérer l'authentification OTP via Firebase Phone Auth
class FirebaseOtpService {
  final FirebaseAuth _auth;
  
  String? _verificationId;
  int? _resendToken;
  
  // Callbacks pour notifier l'UI
  void Function(FirebaseOtpState state, {String? error})? onStateChanged;
  void Function()? onCodeAutoRetrieved;

  FirebaseOtpService({FirebaseAuth? auth}) : _auth = auth ?? FirebaseAuth.instance;

  /// Vérifie si un verificationId est disponible
  bool get hasVerificationId => _verificationId != null;
  
  /// Récupère l'ID utilisateur Firebase actuellement connecté
  String? get currentUserId => _auth.currentUser?.uid;

  /// Envoie un code OTP au numéro de téléphone
  /// Le numéro doit être au format international (+225XXXXXXXXX)
  Future<void> sendOtp({
    required String phoneNumber,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      onStateChanged?.call(FirebaseOtpState.initial);
      
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: timeout,
        
        // Appelé quand le code est envoyé avec succès
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('[FirebaseOTP] Code envoyé à $phoneNumber');
          _verificationId = verificationId;
          _resendToken = resendToken;
          onStateChanged?.call(FirebaseOtpState.codeSent);
        },
        
        // Appelé si le code est automatiquement récupéré (Android uniquement)
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('[FirebaseOTP] Vérification automatique complétée');
          onCodeAutoRetrieved?.call();
          // Auto-sign in
          try {
            await _auth.signInWithCredential(credential);
            onStateChanged?.call(FirebaseOtpState.verified);
          } catch (e) {
            debugPrint('[FirebaseOTP] Erreur auto-sign in: $e');
            onStateChanged?.call(FirebaseOtpState.error, error: e.toString());
          }
        },
        
        // Appelé en cas d'échec
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('[FirebaseOTP] Échec de vérification: ${e.message}');
          String errorMessage = _getErrorMessage(e);
          onStateChanged?.call(FirebaseOtpState.error, error: errorMessage);
        },
        
        // Appelé quand le timeout est atteint
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('[FirebaseOTP] Timeout auto-retrieval');
          _verificationId = verificationId;
          onStateChanged?.call(FirebaseOtpState.timeout);
        },
        
        // Token pour renvoyer le code
        forceResendingToken: _resendToken,
      );
    } catch (e) {
      debugPrint('[FirebaseOTP] Erreur sendOtp: $e');
      onStateChanged?.call(FirebaseOtpState.error, error: e.toString());
    }
  }

  /// Vérifie le code OTP entré par l'utilisateur
  Future<FirebaseOtpResult> verifyOtp(String smsCode) async {
    if (_verificationId == null) {
      return FirebaseOtpResult.error('Aucun code n\'a été envoyé. Veuillez réessayer.');
    }

    try {
      onStateChanged?.call(FirebaseOtpState.verifying);
      
      // Créer le credential avec le code SMS
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );
      
      // Se connecter avec le credential
      final userCredential = await _auth.signInWithCredential(credential);
      
      debugPrint('[FirebaseOTP] Vérification réussie: ${userCredential.user?.uid}');
      onStateChanged?.call(FirebaseOtpState.verified);
      
      return FirebaseOtpResult.success(
        firebaseUid: userCredential.user?.uid,
        phoneNumber: userCredential.user?.phoneNumber,
      );
    } on FirebaseAuthException catch (e) {
      debugPrint('[FirebaseOTP] Erreur vérification: ${e.code} - ${e.message}');
      String errorMessage = _getErrorMessage(e);
      onStateChanged?.call(FirebaseOtpState.error, error: errorMessage);
      return FirebaseOtpResult.error(errorMessage);
    } catch (e) {
      debugPrint('[FirebaseOTP] Erreur inattendue: $e');
      onStateChanged?.call(FirebaseOtpState.error, error: e.toString());
      return FirebaseOtpResult.error('Une erreur est survenue. Veuillez réessayer.');
    }
  }

  /// Renvoie le code OTP
  Future<void> resendOtp({
    required String phoneNumber,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    // Réinitialiser et renvoyer
    await sendOtp(phoneNumber: phoneNumber, timeout: timeout);
  }

  /// Déconnecte l'utilisateur Firebase (pour tests ou réinitialisation)
  Future<void> signOut() async {
    await _auth.signOut();
    _verificationId = null;
    _resendToken = null;
  }

  /// Réinitialise l'état du service
  void reset() {
    _verificationId = null;
    _resendToken = null;
    onStateChanged?.call(FirebaseOtpState.initial);
  }

  /// Traduit les codes d'erreur Firebase en messages utilisateur
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'Numéro de téléphone invalide. Vérifiez le format.';
      case 'too-many-requests':
        return 'Trop de tentatives. Veuillez réessayer plus tard.';
      case 'invalid-verification-code':
        return 'Code invalide. Vérifiez et réessayez.';
      case 'session-expired':
        return 'Session expirée. Veuillez demander un nouveau code.';
      case 'quota-exceeded':
        return 'Quota SMS dépassé. Réessayez plus tard.';
      case 'network-request-failed':
        return 'Erreur réseau. Vérifiez votre connexion.';
      case 'app-not-authorized':
        return 'Application non autorisée. Contactez le support.';
      case 'captcha-check-failed':
        return 'Vérification captcha échouée. Réessayez.';
      default:
        return e.message ?? 'Une erreur est survenue.';
    }
  }
}
