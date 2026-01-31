import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/forgot_password_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/change_password_page.dart';
import '../../home_page.dart';
import '../../features/pharmacies/presentation/pages/pharmacies_list_page_v2.dart';
import '../../features/pharmacies/presentation/pages/pharmacy_details_page.dart';
import '../../features/pharmacies/presentation/pages/on_duty_pharmacies_map_page.dart';
import '../../features/products/presentation/pages/product_details_page.dart';
import '../../features/orders/presentation/pages/cart_page.dart';
import '../../features/orders/presentation/pages/checkout_page.dart';
import '../../features/orders/presentation/pages/orders_list_page.dart';
import '../../features/orders/presentation/pages/order_details_page.dart';
import '../../features/prescriptions/presentation/pages/prescriptions_list_page.dart';
import '../../features/prescriptions/presentation/pages/prescription_details_page.dart';
import '../../features/prescriptions/presentation/pages/prescription_upload_page.dart';
import '../../features/addresses/presentation/pages/addresses_list_page.dart';
import '../../features/addresses/presentation/pages/add_address_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/notification_settings_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../services/navigation_service.dart';

/// Routes de l'application - Constantes type-safe
abstract class AppRoutes {
  // Auth
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const otpVerification = '/otp-verification';
  static const changePassword = '/change-password';

  // Main
  static const home = '/home';

  // Pharmacies
  static const pharmacies = '/pharmacies';
  static const pharmacyDetails = '/pharmacies/:id';
  static const onDutyPharmacies = '/on-duty-pharmacies';

  // Products
  static const productDetails = '/products/:id';

  // Orders
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const orders = '/orders';
  static const orderDetails = '/orders/:id';

  // Prescriptions
  static const prescriptions = '/prescriptions';
  static const prescriptionDetails = '/prescriptions/:id';
  static const prescriptionUpload = '/prescriptions/upload';

  // Addresses
  static const addresses = '/addresses';
  static const addAddress = '/addresses/add';

  // Profile
  static const profile = '/profile';
  static const editProfile = '/profile/edit';
  static const notificationSettings = '/profile/notifications';

  // Notifications
  static const notifications = '/notifications';
}

/// Provider pour le router GoRouter
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: navigatorKey,
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,
    routes: [
      // ===== Auth Routes =====
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        name: 'forgotPassword',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.otpVerification,
        name: 'otpVerification',
        builder: (context, state) {
          final phoneNumber = state.extra as String? ?? '';
          return OtpVerificationPage(phoneNumber: phoneNumber);
        },
      ),
      GoRoute(
        path: AppRoutes.changePassword,
        name: 'changePassword',
        builder: (context, state) => const ChangePasswordPage(),
      ),

      // ===== Main Routes =====
      GoRoute(
        path: AppRoutes.home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // ===== Pharmacy Routes =====
      GoRoute(
        path: AppRoutes.pharmacies,
        name: 'pharmacies',
        builder: (context, state) => const PharmaciesListPageV2(),
      ),
      GoRoute(
        path: AppRoutes.pharmacyDetails,
        name: 'pharmacyDetails',
        builder: (context, state) {
          final pharmacyId = int.parse(state.pathParameters['id']!);
          return PharmacyDetailsPage(pharmacyId: pharmacyId);
        },
      ),
      GoRoute(
        path: AppRoutes.onDutyPharmacies,
        name: 'onDutyPharmacies',
        builder: (context, state) => const OnDutyPharmaciesMapPage(),
      ),

      // ===== Product Routes =====
      GoRoute(
        path: AppRoutes.productDetails,
        name: 'productDetails',
        builder: (context, state) {
          final productId = int.parse(state.pathParameters['id']!);
          return ProductDetailsPage(productId: productId);
        },
      ),

      // ===== Order Routes =====
      GoRoute(
        path: AppRoutes.cart,
        name: 'cart',
        builder: (context, state) => const CartPage(),
      ),
      GoRoute(
        path: AppRoutes.checkout,
        name: 'checkout',
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: AppRoutes.orders,
        name: 'orders',
        builder: (context, state) => const OrdersListPage(),
      ),
      GoRoute(
        path: AppRoutes.orderDetails,
        name: 'orderDetails',
        builder: (context, state) {
          final orderId = int.parse(state.pathParameters['id']!);
          return OrderDetailsPage(orderId: orderId);
        },
      ),

      // ===== Prescription Routes =====
      GoRoute(
        path: AppRoutes.prescriptions,
        name: 'prescriptions',
        builder: (context, state) => const PrescriptionsListPage(),
      ),
      GoRoute(
        path: AppRoutes.prescriptionDetails,
        name: 'prescriptionDetails',
        builder: (context, state) {
          final prescriptionId = int.parse(state.pathParameters['id']!);
          return PrescriptionDetailsPage(prescriptionId: prescriptionId);
        },
      ),
      GoRoute(
        path: AppRoutes.prescriptionUpload,
        name: 'prescriptionUpload',
        builder: (context, state) => const PrescriptionUploadPage(),
      ),

      // ===== Address Routes =====
      GoRoute(
        path: AppRoutes.addresses,
        name: 'addresses',
        builder: (context, state) => const AddressesListPage(),
      ),
      GoRoute(
        path: AppRoutes.addAddress,
        name: 'addAddress',
        builder: (context, state) => const AddAddressPage(),
      ),

      // ===== Profile Routes =====
      GoRoute(
        path: AppRoutes.profile,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        name: 'editProfile',
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: AppRoutes.notificationSettings,
        name: 'notificationSettings',
        builder: (context, state) => const NotificationSettingsPage(),
      ),

      // ===== Notification Routes =====
      GoRoute(
        path: AppRoutes.notifications,
        name: 'notifications',
        builder: (context, state) => const NotificationsPage(),
      ),
    ],

    // Error page
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Erreur')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page non trouvée',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.uri.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.home),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
  );
});

/// Extension pour faciliter la navigation type-safe
extension GoRouterExtension on BuildContext {
  // Auth navigation
  void goToLogin() => go(AppRoutes.login);
  void goToRegister() => go(AppRoutes.register);
  void goToForgotPassword() => go(AppRoutes.forgotPassword);
  void goToHome() => go(AppRoutes.home);
  void goToOnboarding() => go(AppRoutes.onboarding);
  void goToOtpVerification(String phoneNumber) =>
      go(AppRoutes.otpVerification, extra: phoneNumber);

  // Pharmacy navigation
  void goToPharmacies() => go(AppRoutes.pharmacies);
  void goToPharmacyDetails(int pharmacyId) => go('/pharmacies/$pharmacyId');
  void goToOnDutyPharmacies() => go(AppRoutes.onDutyPharmacies);

  // Product navigation
  void goToProductDetails(int productId) => go('/products/$productId');

  // Order navigation
  void goToCart() => go(AppRoutes.cart);
  void goToCheckout() => go(AppRoutes.checkout);
  void goToOrders() => go(AppRoutes.orders);
  void goToOrderDetails(int orderId) => go('/orders/$orderId');

  // Prescription navigation
  void goToPrescriptions() => go(AppRoutes.prescriptions);
  void goToPrescriptionDetails(int prescriptionId) =>
      go('/prescriptions/$prescriptionId');
  void goToPrescriptionUpload() => go(AppRoutes.prescriptionUpload);

  // Address navigation
  void goToAddresses() => go(AppRoutes.addresses);
  void goToAddAddress() => go(AppRoutes.addAddress);

  // Profile navigation
  void goToProfile() => go(AppRoutes.profile);
  void goToEditProfile() => go(AppRoutes.editProfile);
  void goToNotificationSettings() => go(AppRoutes.notificationSettings);

  // Notifications
  void goToNotifications() => go(AppRoutes.notifications);

  // Push navigation (keeps stack)
  void pushToPharmacyDetails(int pharmacyId) => push('/pharmacies/$pharmacyId');
  void pushToProductDetails(int productId) => push('/products/$productId');
  void pushToOrderDetails(int orderId) => push('/orders/$orderId');
  void pushToPrescriptionDetails(int prescriptionId) =>
      push('/prescriptions/$prescriptionId');
  void pushToCart() => push(AppRoutes.cart);
  void pushToCheckout() => push(AppRoutes.checkout);
}
