import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dr_pharma/features/notifications/presentation/providers/notifications_provider.dart';

void main() {
  group('NotificationsProvider Tests', () {
    test('notificationsProvider should be defined', () {
      expect(notificationsProvider, isNotNull);
    });

    test('notificationsProvider should be a StateNotifierProvider', () {
      expect(notificationsProvider, isA<StateNotifierProvider>());
    });
  });
}
