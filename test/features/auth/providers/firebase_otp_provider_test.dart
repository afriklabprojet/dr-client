import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:dr_pharma/features/auth/providers/firebase_otp_provider.dart';

void main() {
  group('FirebaseOtpProvider Tests', () {
    test('firebaseOtpProvider should be defined', () {
      expect(firebaseOtpProvider, isNotNull);
    });

    test('firebaseOtpProvider should be a Provider', () {
      expect(firebaseOtpProvider, isA<Provider>());
    });
  });
}
