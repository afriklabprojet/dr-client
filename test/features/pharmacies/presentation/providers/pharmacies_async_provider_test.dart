import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dr_pharma/features/pharmacies/presentation/providers/pharmacies_async_provider.dart';

void main() {
  group('PharmaciesAsyncProvider Tests', () {
    test('pharmaciesAsyncProvider should be defined', () {
      expect(pharmaciesAsyncProvider, isNotNull);
    });

    test('pharmaciesAsyncProvider should be a FutureProvider', () {
      expect(pharmaciesAsyncProvider, isA<FutureProvider>());
    });
  });
}
