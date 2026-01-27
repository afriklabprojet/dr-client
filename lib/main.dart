import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'firebase_options.dart';
import 'config/providers.dart';
import 'core/constants/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/navigation_service.dart';
import 'features/auth/presentation/pages/splash_page.dart';
import 'features/orders/presentation/pages/order_details_page.dart';
import 'features/orders/presentation/pages/orders_list_page.dart';
import 'features/notifications/presentation/pages/notifications_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Charger les variables d'environnement depuis assets/env/
  // Utiliser --dart-define=ENV=prod pour charger .env.prod
  const envFile = String.fromEnvironment('ENV', defaultValue: '');
  try {
    if (envFile == 'prod') {
      await dotenv.load(fileName: 'assets/env/.env.prod');
      debugPrint("✅ Environment loaded: .env.prod");
    } else if (envFile == 'dev') {
      await dotenv.load(fileName: 'assets/env/.env.dev');
      debugPrint("✅ Environment loaded: .env.dev");
    } else {
      await dotenv.load(fileName: 'assets/env/.env');
      debugPrint("✅ Environment loaded: .env");
    }
  } catch (e) {
    debugPrint("⚠️ Could not load .env file: $e - Using default values");
  }

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint("✅ Firebase initialized successfully");
  } catch (e) {
    debugPrint("❌ Firebase initialization failed: $e");
  }

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey, // Global navigator key for notifications
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeState.themeMode,
      home: const SplashPage(),
      // Named routes for deep linking from notifications
      routes: {
        '/orders': (context) => const OrdersListPage(),
        '/notifications': (context) => const NotificationsPage(),
      },
      onGenerateRoute: (settings) {
        // Handle /order-details route with parameter
        if (settings.name == '/order-details') {
          final orderId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => OrderDetailsPage(orderId: orderId),
          );
        }
        return null;
      },
    );
  }
}
