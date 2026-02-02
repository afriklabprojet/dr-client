import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drpharma_client/core/widgets/common_widgets.dart';

void main() {
  Widget createTestWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('AppSpacing', () {
    test('vertical spacings should have correct heights', () {
      expect((AppSpacing.vertical4 as SizedBox).height, 4);
      expect((AppSpacing.vertical8 as SizedBox).height, 8);
      expect((AppSpacing.vertical12 as SizedBox).height, 12);
      expect((AppSpacing.vertical16 as SizedBox).height, 16);
      expect((AppSpacing.vertical20 as SizedBox).height, 20);
      expect((AppSpacing.vertical24 as SizedBox).height, 24);
      expect((AppSpacing.vertical32 as SizedBox).height, 32);
    });

    test('horizontal spacings should have correct widths', () {
      expect((AppSpacing.horizontal4 as SizedBox).width, 4);
      expect((AppSpacing.horizontal8 as SizedBox).width, 8);
      expect((AppSpacing.horizontal12 as SizedBox).width, 12);
      expect((AppSpacing.horizontal16 as SizedBox).width, 16);
      expect((AppSpacing.horizontal20 as SizedBox).width, 20);
      expect((AppSpacing.horizontal24 as SizedBox).width, 24);
    });
  });

  group('AppPrimaryButton', () {
    testWidgets('should display text', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppPrimaryButton(text: 'Valider'),
        ),
      );

      // Assert
      expect(find.text('Valider'), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      // Arrange
      bool pressed = false;
      await tester.pumpWidget(
        createTestWidget(
          AppPrimaryButton(
            text: 'Click me',
            onPressed: () => pressed = true,
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert
      expect(pressed, true);
    });

    testWidgets('should be disabled when onPressed is null', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppPrimaryButton(text: 'Disabled', onPressed: null),
        ),
      );

      // Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should show loading indicator when isLoading', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          AppPrimaryButton(
            text: 'Loading',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('should be disabled when loading', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          AppPrimaryButton(
            text: 'Loading',
            isLoading: true,
            onPressed: () {},
          ),
        ),
      );

      // Assert
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('should display icon when provided', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          AppPrimaryButton(
            text: 'With Icon',
            icon: Icons.add,
            onPressed: () {},
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('should use full width by default', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const Padding(
            padding: EdgeInsets.all(16),
            child: AppPrimaryButton(text: 'Full Width'),
          ),
        ),
      );

      // Assert
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(sizedBox.width, double.infinity);
    });

    testWidgets('should use custom width when specified', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppPrimaryButton(text: 'Custom', width: 200),
        ),
      );

      // Assert
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(ElevatedButton),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(sizedBox.width, 200);
    });
  });

  group('AppOutlineButton', () {
    testWidgets('should display text', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppOutlineButton(text: 'Annuler'),
        ),
      );

      // Assert
      expect(find.text('Annuler'), findsOneWidget);
    });

    testWidgets('should call onPressed when tapped', (tester) async {
      // Arrange
      bool pressed = false;
      await tester.pumpWidget(
        createTestWidget(
          AppOutlineButton(
            text: 'Click',
            onPressed: () => pressed = true,
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(OutlinedButton));
      await tester.pumpAndSettle();

      // Assert
      expect(pressed, true);
    });

    testWidgets('should display icon when provided', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          AppOutlineButton(
            text: 'With Icon',
            icon: Icons.close,
            onPressed: () {},
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should use OutlinedButton style', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppOutlineButton(text: 'Outline'),
        ),
      );

      // Assert
      expect(find.byType(OutlinedButton), findsOneWidget);
    });
  });

  group('AppLoadingIndicator', () {
    testWidgets('should display CircularProgressIndicator', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppLoadingIndicator(),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should display message when provided', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppLoadingIndicator(message: 'Chargement en cours...'),
        ),
      );

      // Assert
      expect(find.text('Chargement en cours...'), findsOneWidget);
    });

    testWidgets('should not display message when null', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppLoadingIndicator(),
        ),
      );

      // Assert - only the indicator, no text
      expect(find.byType(Text), findsNothing);
    });

    testWidgets('should be centered', (tester) async {
      // Arrange
      await tester.pumpWidget(
        createTestWidget(
          const AppLoadingIndicator(),
        ),
      );

      // Assert
      expect(find.byType(Center), findsOneWidget);
    });
  });
}
