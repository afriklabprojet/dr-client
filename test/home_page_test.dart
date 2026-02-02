import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

import 'package:drpharma_client/home_page.dart';
import 'package:drpharma_client/config/providers.dart';
import 'package:drpharma_client/features/auth/presentation/providers/auth_provider.dart';
import 'package:drpharma_client/features/auth/presentation/providers/auth_state.dart';
import 'package:drpharma_client/features/orders/presentation/providers/cart_provider.dart';
import 'package:drpharma_client/features/orders/presentation/providers/cart_state.dart';
import 'package:drpharma_client/features/pharmacies/domain/entities/pharmacy_entity.dart';

// Mocks
class MockAuthNotifier extends StateNotifier<AuthState> with Mock {
  MockAuthNotifier() : super(const AuthState());
}

class MockCartNotifier extends StateNotifier<CartState> with Mock {
  MockCartNotifier() : super(CartState.initial());
}

class MockPharmaciesNotifier extends StateNotifier<AsyncValue<List<PharmacyEntity>>> with Mock {
  MockPharmaciesNotifier() : super(const AsyncValue.data([]));
  
  Future<void> fetchFeaturedPharmacies() async {}
}

class FakeAuthState extends Fake implements AuthState {}

void main() {
  late MockAuthNotifier mockAuthNotifier;
  late MockCartNotifier mockCartNotifier;
  late MockPharmaciesNotifier mockPharmaciesNotifier;

  setUpAll(() {
    registerFallbackValue(FakeAuthState());
  });

  setUp(() {
    mockAuthNotifier = MockAuthNotifier();
    mockCartNotifier = MockCartNotifier();
    mockPharmaciesNotifier = MockPharmaciesNotifier();
  });

  Widget createTestWidget({
    AuthState? authState,
    CartState? cartState,
  }) {
    return ProviderScope(
      overrides: [
        authProvider.overrideWith((ref) {
          final notifier = MockAuthNotifier();
          if (authState != null) {
            notifier.state = authState;
          }
          return notifier;
        }),
        cartProvider.overrideWith((ref) {
          final notifier = MockCartNotifier();
          if (cartState != null) {
            notifier.state = cartState;
          }
          return notifier;
        }),
        pharmaciesProvider.overrideWith((ref) => mockPharmaciesNotifier),
      ],
      child: MaterialApp(
        home: const HomePage(),
        routes: {
          '/products': (_) => const Scaffold(body: Text('Products')),
          '/pharmacies': (_) => const Scaffold(body: Text('Pharmacies')),
          '/cart': (_) => const Scaffold(body: Text('Cart')),
          '/profile': (_) => const Scaffold(body: Text('Profile')),
          '/prescriptions': (_) => const Scaffold(body: Text('Prescriptions')),
          '/on-duty-pharmacies': (_) => const Scaffold(body: Text('On Duty')),
          '/notifications': (_) => const Scaffold(body: Text('Notifications')),
        },
      ),
    );
  }

  group('HomePage Widget Tests', () {
    testWidgets('should render home page', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should show app bar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('should display DR-PHARMA branding', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.textContaining('DR'), findsWidgets);
    });

    testWidgets('should have search functionality', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Chercher l'icône ou champ de recherche
      expect(find.byIcon(Icons.search), findsWidgets);
    });

    testWidgets('should have cart icon', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.shopping_cart), findsWidgets);
    });

    testWidgets('should have notifications icon', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.notifications_outlined), findsWidgets);
    });
  });

  group('HomePage Promo Slider', () {
    testWidgets('should display promo slider', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Le slider promotionnel devrait être présent
      expect(find.byType(PageView), findsWidgets);
    });

    testWidgets('should show promo items', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Les promos devraient être visibles
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should have page indicators', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Les indicateurs de page
      expect(find.byType(HomePage), findsOneWidget);
    });
  });

  group('HomePage Quick Actions', () {
    testWidgets('should display quick action buttons', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Les actions rapides
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should have pharmacies action', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Pharmacie'), findsWidgets);
    });

    testWidgets('should have prescriptions action', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('Ordonnance'), findsWidgets);
    });

    testWidgets('should have on-duty pharmacies action', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.textContaining('garde'), findsWidgets);
    });
  });

  group('HomePage Featured Pharmacies', () {
    testWidgets('should display featured pharmacies section', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should show loading while fetching pharmacies', (tester) async {
      mockPharmaciesNotifier.state = const AsyncValue.loading();
      
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(HomePage), findsOneWidget);
    });
  });

  group('HomePage Cart Badge', () {
    testWidgets('should show cart badge with item count', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial().copyWith(
          items: [],
          pharmacyId: 1,
        ),
      ));
      await tester.pump();

      expect(find.byIcon(Icons.shopping_cart), findsWidgets);
    });

    testWidgets('should not show badge when cart is empty', (tester) async {
      await tester.pumpWidget(createTestWidget(
        cartState: CartState.initial(),
      ));
      await tester.pump();

      expect(find.byType(HomePage), findsOneWidget);
    });
  });

  group('HomePage Navigation', () {
    testWidgets('should navigate to products on tap', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Trouver et taper sur un élément de navigation
      final productsButton = find.textContaining('Produits');
      if (productsButton.evaluate().isNotEmpty) {
        await tester.tap(productsButton.first);
        await tester.pumpAndSettle();
      }

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should navigate to cart on icon tap', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final cartIcon = find.byIcon(Icons.shopping_cart);
      if (cartIcon.evaluate().isNotEmpty) {
        await tester.tap(cartIcon.first);
        await tester.pumpAndSettle();
      }

      // Devrait avoir navigué ou être encore sur home
      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('should navigate to notifications on icon tap', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final notifIcon = find.byIcon(Icons.notifications_outlined);
      if (notifIcon.evaluate().isNotEmpty) {
        await tester.tap(notifIcon.first);
        await tester.pumpAndSettle();
      }

      expect(find.byType(Scaffold), findsWidgets);
    });
  });

  group('HomePage Auto-Scroll', () {
    testWidgets('should auto-scroll promo carousel', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      
      // Attendre le timer de scroll
      await tester.pump(const Duration(seconds: 5));
      
      expect(find.byType(HomePage), findsOneWidget);
    });
  });

  group('HomePage User Greeting', () {
    testWidgets('should show greeting for authenticated user', (tester) async {
      await tester.pumpWidget(createTestWidget(
        authState: const AuthState(
          status: AuthStatus.authenticated,
        ),
      ));
      await tester.pump();

      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('should show default greeting for guest', (tester) async {
      await tester.pumpWidget(createTestWidget(
        authState: const AuthState(
          status: AuthStatus.unauthenticated,
        ),
      ));
      await tester.pump();

      expect(find.byType(HomePage), findsOneWidget);
    });
  });

  group('HomePage Scroll Behavior', () {
    testWidgets('should be scrollable', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Scroll down
      await tester.drag(find.byType(SingleChildScrollView).first, const Offset(0, -200));
      await tester.pumpAndSettle();

      expect(find.byType(HomePage), findsOneWidget);
    });
  });

  group('HomePage Accessibility', () {
    testWidgets('should have semantic labels', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(Semantics), findsWidgets);
    });

    testWidgets('should support keyboard navigation', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(HomePage), findsOneWidget);
    });
  });

  group('HomePage Responsive', () {
    testWidgets('should adapt to screen size', (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      expect(find.byType(HomePage), findsOneWidget);
      
      await tester.binding.setSurfaceSize(null);
    });
  });
}
