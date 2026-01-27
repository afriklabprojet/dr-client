import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb, kReleaseMode;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  // Base URLs
  // For Android Emulator, use 10.0.2.2 instead of localhost
  // For iOS Simulator, use localhost or your machine's IP
  // For Web (Chrome/browsers), use localhost
  // For physical device, use your machine's IP address

  // Lecture depuis les variables d'environnement
  static String get _envBaseUrl => dotenv.env['API_BASE_URL'] ?? '';
  static String get _envStorageUrl => dotenv.env['STORAGE_BASE_URL'] ?? '';
  static bool get _useEnvUrls => _envBaseUrl.isNotEmpty;
  
  // Fallback IP pour appareils physiques en dev
  static const String localMachineIP = '192.168.1.100';
  
  static String get baseUrlDev {
    // Si une URL est définie dans .env, l'utiliser
    if (_useEnvUrls) {
      return _envBaseUrl;
    }
    
    // Sinon, utiliser les valeurs par défaut selon la plateforme
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

  static String get storageBaseUrlDev {
    // Si une URL est définie dans .env, l'utiliser
    if (_envStorageUrl.isNotEmpty) {
      return _envStorageUrl;
    }
    
    // Sinon, utiliser les valeurs par défaut selon la plateforme
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
  
  // URLs de production (peuvent aussi être surchargées par .env)
  static String get baseUrlProd => 
      dotenv.env['API_BASE_URL_PROD'] ?? 'https://api.drpharma.ci/api';
  static String get storageBaseUrlProd => 
      dotenv.env['STORAGE_BASE_URL_PROD'] ?? 'https://api.drpharma.ci/storage';

  // Détection automatique de l'environnement ou lecture depuis .env
  static bool get isDevelopment {
    // Si défini dans .env, utiliser cette valeur
    final envValue = dotenv.env['IS_DEVELOPMENT'];
    if (envValue != null) {
      return envValue.toLowerCase() == 'true';
    }
    // Sinon, utiliser le mode de build Flutter
    return !kReleaseMode;
  }
  
  static String get baseUrl => isDevelopment ? baseUrlDev : baseUrlProd;
  static String get storageBaseUrl =>
      isDevelopment ? storageBaseUrlDev : storageBaseUrlProd;

  // Authentication endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/me';
  static const String me = '/auth/me'; // Alias for consistency
  static const String updateProfile = '/auth/profile';
  static const String uploadAvatar = '/auth/avatar';
  static const String deleteAvatar = '/auth/avatar';
  static const String updatePassword = '/auth/password';
  
  // OTP verification endpoints
  static const String verifyOtp = '/auth/verify';
  static const String resendOtp = '/auth/resend';

  // Products endpoints
  static const String products = '/products';
  static String productDetails(int id) => '/products/$id';
  static const String searchProducts = '/products';

  // Orders endpoints
  static const String orders = '/customer/orders';
  static String orderDetails(int id) => '/customer/orders/$id';
  static String cancelOrder(int id) => '/customer/orders/$id/cancel';

  // Pharmacies endpoints
  static const String pharmacies = '/customer/pharmacies';
  static const String featuredPharmacies = '/customer/pharmacies/featured';
  static const String nearbyPharmacies = '/customer/pharmacies/nearby';
  static const String onDutyPharmacies = '/customer/pharmacies/on-duty';
  static String pharmacyDetails(int id) => '/customer/pharmacies/$id';

  // Payment endpoints
  static const String createPaymentIntent = '/payments/intents';

  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
