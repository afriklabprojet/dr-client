import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:drpharma_client/config/providers.dart';
import 'package:drpharma_client/core/errors/failures.dart';
import 'package:drpharma_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:drpharma_client/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:drpharma_client/features/auth/domain/usecases/login_usecase.dart';
import 'package:drpharma_client/features/auth/domain/usecases/logout_usecase.dart';
import 'package:drpharma_client/features/auth/domain/usecases/register_usecase.dart';
import 'package:drpharma_client/features/auth/presentation/pages/login_page.dart';
import 'package:drpharma_client/features/auth/presentation/providers/auth_notifier.dart';
import 'package:drpharma_client/features/auth/presentation/providers/auth_provider.dart';
import 'package:drpharma_client/core/services/notification_service.dart';

@GenerateMocks([
  AuthRepository,
  LoginUseCase,
  RegisterUseCase,
  LogoutUseCase,
  GetCurrentUserUseCase,
  NotificationService,
])
import 'login_page_test.mocks.dart';

void main() {
  late MockLoginUseCase mockLoginUseCase;
  late MockRegisterUseCase mockRegisterUseCase;
  late MockLogoutUseCase mockLogoutUseCase;
  late MockGetCurrentUserUseCase mockGetCurrentUserUseCase;
  late MockNotificationService mockNotificationService;
  late SharedPreferences sharedPreferences;

  setUp(() async {
    mockLoginUseCase = MockLoginUseCase();
    mockRegisterUseCase = MockRegisterUseCase();
    mockLogoutUseCase = MockLogoutUseCase();
    mockGetCurrentUserUseCase = MockGetCurrentUserUseCase();
    mockNotificationService = MockNotificationService();
    
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    
    // Setup default mock behavior - return failure (no user logged in)
    when(mockGetCurrentUserUseCase.call()).thenAnswer(
      (_) async => const Left(ServerFailure(message: 'Not logged in')),
    );
    when(mockNotificationService.initNotifications()).thenAnswer((_) async {});
  });

  /// Helper to create a test widget with mocked providers
  Widget createTestWidget() {
    final authNotifier = AuthNotifier(
      loginUseCase: mockLoginUseCase,
      registerUseCase: mockRegisterUseCase,
      logoutUseCase: mockLogoutUseCase,
      getCurrentUserUseCase: mockGetCurrentUserUseCase,
    );
    
    // Create a simple router for testing
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Text('Home')),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const Scaffold(body: Text('Register')),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const Scaffold(body: Text('Forgot Password')),
        ),
      ],
    );

    return ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        authProvider.overrideWith((ref) => authNotifier),
        notificationServiceProvider.overrideWithValue(mockNotificationService),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    );
  }

  group('LoginPage UI', () {
    testWidgets('should display LoginPage widget', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify LoginPage is rendered
      expect(find.byType(LoginPage), findsOneWidget);
    });

    testWidgets('should display login header text', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify header text - could be "Bon retour !" or similar
      // The page uses "Bon retour !" as the welcome text
      expect(find.text('Bon retour !'), findsOneWidget);
    });

    testWidgets('should display app branding', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify app branding
      expect(find.text('DR-PHARMA'), findsOneWidget);
    });

    testWidgets('should display two text form fields', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify form fields exist (email and password)
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('should display login button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify login button
      expect(find.text('Se connecter'), findsOneWidget);
    });

    testWidgets('should display registration link', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify registration link exists
      expect(find.text('Créer un compte'), findsOneWidget);
    });

    testWidgets('should display forgot password link', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Verify forgot password link
      expect(find.text('Mot de passe oublié ?'), findsOneWidget);
    });
  });

  group('LoginPage Form Interaction', () {
    testWidgets('should accept text input in email field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      const testEmail = 'test@example.com';
      final textFields = find.byType(TextFormField);
      
      await tester.enterText(textFields.first, testEmail);
      await tester.pumpAndSettle();

      // Verify we can enter text in the field (no exceptions)
      expect(textFields.first, findsOneWidget);
    });

    testWidgets('should accept text input in password field', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      const testPassword = 'securePassword123';
      final passwordField = find.byType(TextFormField).last;
      
      await tester.enterText(passwordField, testPassword);
      await tester.pumpAndSettle();

      // Password field exists and accepted input
      expect(find.byType(TextFormField).last, findsOneWidget);
    });

    testWidgets('should have working password visibility toggle', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find any visibility toggle icon (either off or on state)
      final visibilityIconOff = find.byIcon(Icons.visibility_off_outlined);
      final visibilityIconOn = find.byIcon(Icons.visibility_outlined);
      
      // One of them should exist
      final hasVisibilityIcon = visibilityIconOff.evaluate().isNotEmpty || 
                                visibilityIconOn.evaluate().isNotEmpty;
      expect(hasVisibilityIcon, isTrue);
    });

    testWidgets('should have tappable login button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final loginButton = find.text('Se connecter');
      expect(loginButton, findsOneWidget);
      
      // Verify the button is tappable
      await tester.ensureVisible(loginButton);
      await tester.tap(loginButton);
      await tester.pump();
      
      // Should not throw error
    });

    testWidgets('form fields should be focusable', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Find and tap email field to focus
      final textFields = find.byType(TextFormField);
      expect(textFields, findsNWidgets(2));
      
      // Tap first field - should be able to focus without errors
      await tester.tap(textFields.first);
      await tester.pumpAndSettle();
      
      // Entering text works which proves the field is focusable
      await tester.enterText(textFields.first, 'test@example.com');
      await tester.pumpAndSettle();
      
      // No exception means test passed
    });
  });

  group('LoginPage Structure', () {
    testWidgets('should have proper form structure', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Should have a Form widget
      expect(find.byType(Form), findsOneWidget);
      
      // Should have TextFormFields inside the Form
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('should have Scaffold as root', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsAtLeast(1));
    });

    testWidgets('should have SafeArea for proper padding', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(SafeArea), findsWidgets);
    });
  });
}
