import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;

class ApiConstants {
  // ============================================================
  // CONFIGURATION
  // ============================================================
  // Pour changer l'environnement, modifier cette valeur :
  // - true  = développement (serveur local)
  // - false = production (serveur distant)
  // - null  = auto-détection basée sur le mode de build Flutter
  static const bool? _forceEnvironment = null;
  
  // IP de votre machine locale (pour les appareils physiques en dev)
  static const String localMachineIP = '192.168.1.100';
  
  // ============================================================
  // URLs
  // ============================================================
  
  // URLs de production
  static const String _baseUrlProd = 'https://api.drpharma.ci/api';
  static const String _storageBaseUrlProd = 'https://api.drpharma.ci/storage';
  
  // URLs de développement (auto-détection selon la plateforme)
  static String get _baseUrlDev {
    if (kIsWeb) {
      return 'http://localhost:8000/api';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/api'; // Android Emulator
    }
    if (Platform.isIOS) {
      return 'http://localhost:8000/api'; // iOS Simulator
    }
    return 'http://localhost:8000/api';
  }

  static String get _storageBaseUrlDev {
    if (kIsWeb) {
      return 'http://localhost:8000/storage';
    }
    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8000/storage';
    }
    if (Platform.isIOS) {
      return 'http://localhost:8000/storage';
    }
    return 'http://localhost:8000/storage';
  }
  
  // ============================================================
  // GETTERS PRINCIPAUX
  // ============================================================
  
  static bool get isDevelopment {
    if (_forceEnvironment != null) {
      return _forceEnvironment!;
    }
    return !kReleaseMode;
  }
  
  static String get baseUrl => isDevelopment ? _baseUrlDev : _baseUrlProd;
  static String get storageBaseUrl => isDevelopment ? _storageBaseUrlDev : _storageBaseUrlProd;

  // ============================================================
  // ENDPOINTS - Authentication
  // ============================================================
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/me';
  static const String me = '/auth/me';
  static const String updateProfile = '/auth/profile';
  static const String uploadAvatar = '/auth/avatar';
  static const String deleteAvatar = '/auth/avatar';
  static const String updatePassword = '/auth/password';
  
  static const String verifyOtp = '/auth/verify';
  static const String resendOtp = '/auth/resend';

  // ============================================================
  // ENDPOINTS - Products
  // ============================================================
  static const String products = '/products';
  static String productDetails(int id) => '/products/\$id';
  static const String searchProducts = '/products';

  // ============================================================
  // ENDPOINTS - Orders
  // ============================================================
  static const String orders = '/customer/orders';
  static String orderDetails(int id) => '/customer/orders/\$id';
  static String cancelOrder(int id) => '/customer/orders/\$id/cancel';

  // ============================================================
  // ENDPOINTS - Pharmacies
  // ============================================================
  static const String pharmacies = '/customer/pharmacies';
  static const String featuredPharmacies = '/customer/pharmacies/featured';
  static const String nearbyPharmacies = '/customer/pharmacies/nearby';
  static const String onDutyPharmacies = '/customer/pharmacies/on-duty';
  static String pharmacyDetails(int id) => '/customer/pharmacies/\$id';

  // ============================================================
  // ENDPOINTS - Payment
  // ============================================================
  static const String createPaymentIntent = '/payments/intents';

  // ============================================================
  // TIMEOUTS
  // ============================================================
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
