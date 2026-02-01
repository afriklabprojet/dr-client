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
import '../../features/pharmacies/presentation/pages/pharmacies_map_page.dart';
import '../../features/pharmacies/presentation/pages/on_duty_pharmacies_map_page.dart';
import '../../features/products/presentation/pages/product_details_page.dart';
import '../../features/products/presentation/pages/all_products_page.dart';
import '../../features/orders/presentation/pages/cart_page.dart';
import '../../features/orders/presentation/pages/checkout_page.dart';
import '../../features/orders/presentation/pages/orders_list_page.dart';
import '../../features/orders/presentation/pages/order_details_page.dart';
import '../../features/orders/presentation/pages/tracking_page.dart';
import '../../features/orders/domain/entities/delivery_address_entity.dart';
import '../../features/prescriptions/presentation/pages/prescriptions_list_page.dart';
import '../../features/prescriptions/presentation/pages/prescription_details_page.dart';
import '../../features/prescriptions/presentation/pages/prescription_upload_page.dart';
import '../../features/addresses/presentation/pages/addresses_list_page.dart';
import '../../features/addresses/presentation/pages/add_address_page.dart';
import '../../features/addresses/presentation/pages/edit_address_page.dart';
import '../../features/addresses/domain/entities/address_entity.dart';
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
  static const pharmaciesMap = '/pharmacies/map';
  static const onDutyPharmacies = '/on-duty-pharmacies';

  // Products
  static const products = '/products';
  static const productDetails = '/products/:id';

  // Orders
  static const cart = '/cart';
  static const checkout = '/checkout';
  static const orders = '/orders';
  static const orderDetails = '/orders/:id';
  static const orderTracking = '/orders/:id/tracking';

  // Prescriptions
  static const prescriptions = '/prescriptions';
  static const prescriptionDetails = '/prescriptions/:id';
  static const prescriptionUpload = '/prescriptions/upload';

  // Addresses
  static const addresses = '/addresses';
  static const addressesSelect = '/addresses/select';
  static const addAddress = '/addresses/add';
  static const editAddress = '/addresses/edit';

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
        path: AppRoutes.pharmaciesMap,
        name: 'pharmaciesMap',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PharmaciesMapPage(
            pharmacies: extra?['pharmacies'] ?? [],
            userLatitude: extra?['userLatitude'],
            userLongitude: extra?['userLongitude'],
          );
        },
      ),
      GoRoute(
        path: AppRoutes.onDutyPharmacies,
        name: 'onDutyPharmacies',
        builder: (context, state) => const OnDutyPharmaciesMapPage(),
      ),

      // ===== Product Routes =====
      GoRoute(
        path: '/products',
        name: 'productsList',
        builder: (context, state) => const AllProductsPage(),
      ),
      GoRoute(
        path: '/products/:id',
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
      GoRoute(
        path: AppRoutes.orderTracking,
        name: 'orderTracking',
        builder: (context, state) {
          final orderId = int.parse(state.pathParameters['id']!);
          final extra = state.extra as Map<String, dynamic>;
          return TrackingPage(
            orderId: orderId,
            deliveryAddress: extra['deliveryAddress'] as DeliveryAddressEntity,
            pharmacyAddress: extra['pharmacyAddress'] as String?,
          );
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
        path: AppRoutes.addressesSelect,
        name: 'addressesSelect',
        builder: (context, state) => const AddressesListPage(selectionMode: true),
      ),
      GoRoute(
        path: AppRoutes.addAddress,
        name: 'addAddress',
        builder: (context, state) => const AddAddressPage(),
      ),
      GoRoute(
        path: AppRoutes.editAddress,
        name: 'editAddress',
        builder: (context, state) {
          final address = state.extra as AddressEntity;
          return EditAddressPage(address: address);
        },
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
  // Auth navigation - utilise go() car on ne veut pas revenir en arrière
  void goToLogin() => go(AppRoutes.login);
  void goToRegister() => go(AppRoutes.register);
  void goToForgotPassword() => push(AppRoutes.forgotPassword); // push pour permettre retour
  void goToHome() => go(AppRoutes.home);
  void goToOnboarding() => go(AppRoutes.onboarding);
  void goToOtpVerification(String phoneNumber) =>
      go(AppRoutes.otpVerification, extra: phoneNumber);

  // Pharmacy navigation - utilise push() pour garder home dans la stack
  void goToPharmacies() => push(AppRoutes.pharmacies);
  void goToPharmacy({required int pharmacyId}) => push('/pharmacies/$pharmacyId');
  void goToPharmacyDetails(int pharmacyId) => push('/pharmacies/$pharmacyId');
  void goToOnDutyPharmacies() => push(AppRoutes.onDutyPharmacies);
  void goToPharmaciesMap({
    required List pharmacies,
    double? userLatitude,
    double? userLongitude,
  }) => push(
    '/pharmacies/map',
    extra: {
      'pharmacies': pharmacies,
      'userLatitude': userLatitude,
      'userLongitude': userLongitude,
    },
  );

  // Product navigation - utilise push()
  void goToProducts() => pushNamed('productsList');
  void goToProductDetails(int productId) => push('/products/$productId');

  // Order navigation - utilise push() sauf pour orders list
  void goToCart() => push(AppRoutes.cart);
  void goToCheckout() => push(AppRoutes.checkout);
  void goToOrders() => push(AppRoutes.orders);
  void goToOrderDetails(int orderId) => push('/orders/$orderId');
  void goToOrderTracking({
    required int orderId,
    required DeliveryAddressEntity deliveryAddress,
    String? pharmacyAddress,
  }) => push(
    '/orders/$orderId/tracking',
    extra: {
      'deliveryAddress': deliveryAddress,
      'pharmacyAddress': pharmacyAddress,
    },
  );

  // Prescription navigation - utilise push()
  void goToPrescriptions() => push(AppRoutes.prescriptions);
  void goToPrescriptionDetails(int prescriptionId) =>
      push('/prescriptions/$prescriptionId');
  void goToPrescriptionUpload() => push(AppRoutes.prescriptionUpload);

  // Address navigation - utilise push()
  void goToAddresses() => push(AppRoutes.addresses);
  void goToAddAddress() => push(AppRoutes.addAddress);
  void goToEditAddress(AddressEntity address) => push(AppRoutes.editAddress, extra: address);

  // Profile navigation - utilise push()
  void goToProfile() => push(AppRoutes.profile);
  void goToEditProfile() => push(AppRoutes.editProfile);
  void goToNotificationSettings() => push(AppRoutes.notificationSettings);

  // Notifications - utilise push()
  void goToNotifications() => push(AppRoutes.notifications);

  // Alias explicites pour push (backwards compatibility)
  void pushToPharmacyDetails(int pharmacyId) => push('/pharmacies/$pharmacyId');
  void pushToProductDetails(int productId) => push('/products/$productId');
  void pushToOrderDetails(int orderId) => push('/orders/$orderId');
  void pushToPrescriptionDetails(int prescriptionId) =>
      push('/prescriptions/$prescriptionId');
  void pushToCart() => push(AppRoutes.cart);
  void pushToCheckout() => push(AppRoutes.checkout);
}
