import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:drpharma_client/core/errors/error_handler.dart';

void main() {
  group('ErrorHandler', () {
    group('getErrorMessage', () {
      test('should return user message for AppException', () {
        // Arrange
        const exception = AppException(
          userMessage: 'Something went wrong',
          technicalMessage: 'Technical error',
        );

        // Act
        final result = ErrorHandler.getErrorMessage(exception);

        // Assert
        expect(result, 'Something went wrong');
      });

      test('should return timeout message for TimeoutException', () {
        // Arrange
        final exception = TimeoutException('Timeout');

        // Act
        final result = ErrorHandler.getErrorMessage(exception);

        // Assert
        expect(result, 'La requête a pris trop de temps');
      });

      test('should return format error message for FormatException', () {
        // Arrange
        const exception = FormatException('Invalid format');

        // Act
        final result = ErrorHandler.getErrorMessage(exception);

        // Assert
        expect(result, 'Données invalides reçues du serveur');
      });

      test('should return generic message for unknown exception', () {
        // Arrange
        final exception = Exception('Unknown error');

        // Act
        final result = ErrorHandler.getErrorMessage(exception);

        // Assert
        expect(result, contains('erreur'));
      });

      group('DioException handling', () {
        test('should return timeout message for connection timeout', () {
          // Arrange
          final exception = DioException(
            type: DioExceptionType.connectionTimeout,
            requestOptions: RequestOptions(path: '/test'),
          );

          // Act
          final result = ErrorHandler.getErrorMessage(exception);

          // Assert
          expect(result, 'Délai de connexion dépassé');
        });

        test('should return timeout message for send timeout', () {
          // Arrange
          final exception = DioException(
            type: DioExceptionType.sendTimeout,
            requestOptions: RequestOptions(path: '/test'),
          );

          // Act
          final result = ErrorHandler.getErrorMessage(exception);

          // Assert
          expect(result, 'Délai de connexion dépassé');
        });

        test('should return timeout message for receive timeout', () {
          // Arrange
          final exception = DioException(
            type: DioExceptionType.receiveTimeout,
            requestOptions: RequestOptions(path: '/test'),
          );

          // Act
          final result = ErrorHandler.getErrorMessage(exception);

          // Assert
          expect(result, 'Délai de connexion dépassé');
        });

        test('should return connection error message', () {
          // Arrange
          final exception = DioException(
            type: DioExceptionType.connectionError,
            requestOptions: RequestOptions(path: '/test'),
          );

          // Act
          final result = ErrorHandler.getErrorMessage(exception);

          // Assert
          expect(result, 'Impossible de se connecter au serveur');
        });

        test('should return cancel message', () {
          // Arrange
          final exception = DioException(
            type: DioExceptionType.cancel,
            requestOptions: RequestOptions(path: '/test'),
          );

          // Act
          final result = ErrorHandler.getErrorMessage(exception);

          // Assert
          expect(result, 'Requête annulée');
        });

        test('should return certificate error message', () {
          // Arrange
          final exception = DioException(
            type: DioExceptionType.badCertificate,
            requestOptions: RequestOptions(path: '/test'),
          );

          // Act
          final result = ErrorHandler.getErrorMessage(exception);

          // Assert
          expect(result, 'Certificat de sécurité invalide');
        });

        test('should return connection error for unknown type', () {
          // Arrange
          final exception = DioException(
            type: DioExceptionType.unknown,
            requestOptions: RequestOptions(path: '/test'),
          );

          // Act
          final result = ErrorHandler.getErrorMessage(exception);

          // Assert
          expect(result, 'Erreur de connexion');
        });

        group('HTTP error handling', () {
          test('should return session expired for 401', () {
            // Arrange
            final exception = DioException(
              type: DioExceptionType.badResponse,
              requestOptions: RequestOptions(path: '/test'),
              response: Response(
                statusCode: 401,
                requestOptions: RequestOptions(path: '/test'),
              ),
            );

            // Act
            final result = ErrorHandler.getErrorMessage(exception);

            // Assert
            expect(result, contains('Session'));
            expect(result, contains('reconnecter'));
          });

          test('should return access denied for 403', () {
            // Arrange
            final exception = DioException(
              type: DioExceptionType.badResponse,
              requestOptions: RequestOptions(path: '/test'),
              response: Response(
                statusCode: 403,
                requestOptions: RequestOptions(path: '/test'),
              ),
            );

            // Act
            final result = ErrorHandler.getErrorMessage(exception);

            // Assert
            expect(result, 'Accès non autorisé');
          });

          test('should return not found for 404', () {
            // Arrange
            final exception = DioException(
              type: DioExceptionType.badResponse,
              requestOptions: RequestOptions(path: '/test'),
              response: Response(
                statusCode: 404,
                requestOptions: RequestOptions(path: '/test'),
              ),
            );

            // Act
            final result = ErrorHandler.getErrorMessage(exception);

            // Assert
            expect(result, 'Ressource non trouvée');
          });

          test('should return invalid data for 422', () {
            // Arrange
            final exception = DioException(
              type: DioExceptionType.badResponse,
              requestOptions: RequestOptions(path: '/test'),
              response: Response(
                statusCode: 422,
                requestOptions: RequestOptions(path: '/test'),
              ),
            );

            // Act
            final result = ErrorHandler.getErrorMessage(exception);

            // Assert
            expect(result, 'Données invalides');
          });

          test('should return too many requests for 429', () {
            // Arrange
            final exception = DioException(
              type: DioExceptionType.badResponse,
              requestOptions: RequestOptions(path: '/test'),
              response: Response(
                statusCode: 429,
                requestOptions: RequestOptions(path: '/test'),
              ),
            );

            // Act
            final result = ErrorHandler.getErrorMessage(exception);

            // Assert
            expect(result, contains('Trop de requêtes'));
          });

          test('should return server error for 500', () {
            // Arrange
            final exception = DioException(
              type: DioExceptionType.badResponse,
              requestOptions: RequestOptions(path: '/test'),
              response: Response(
                statusCode: 500,
                requestOptions: RequestOptions(path: '/test'),
              ),
            );

            // Act
            final result = ErrorHandler.getErrorMessage(exception);

            // Assert
            expect(result, contains('Erreur serveur'));
          });

          test('should return service unavailable for 503', () {
            // Arrange
            final exception = DioException(
              type: DioExceptionType.badResponse,
              requestOptions: RequestOptions(path: '/test'),
              response: Response(
                statusCode: 503,
                requestOptions: RequestOptions(path: '/test'),
              ),
            );

            // Act
            final result = ErrorHandler.getErrorMessage(exception);

            // Assert
            expect(result, 'Service temporairement indisponible');
          });

          test('should extract server message from response', () {
            // Arrange
            final exception = DioException(
              type: DioExceptionType.badResponse,
              requestOptions: RequestOptions(path: '/test'),
              response: Response(
                statusCode: 400,
                data: {'message': 'Email already exists'},
                requestOptions: RequestOptions(path: '/test'),
              ),
            );

            // Act
            final result = ErrorHandler.getErrorMessage(exception);

            // Assert
            expect(result, 'Email already exists');
          });

          test('should extract error from response', () {
            // Arrange
            final exception = DioException(
              type: DioExceptionType.badResponse,
              requestOptions: RequestOptions(path: '/test'),
              response: Response(
                statusCode: 400,
                data: {'error': 'Validation failed'},
                requestOptions: RequestOptions(path: '/test'),
              ),
            );

            // Act
            final result = ErrorHandler.getErrorMessage(exception);

            // Assert
            expect(result, 'Validation failed');
          });

          test('should extract first error from errors map', () {
            // Arrange
            final exception = DioException(
              type: DioExceptionType.badResponse,
              requestOptions: RequestOptions(path: '/test'),
              response: Response(
                statusCode: 422,
                data: {
                  'errors': {
                    'email': ['Email is required'],
                    'password': ['Password is too short'],
                  }
                },
                requestOptions: RequestOptions(path: '/test'),
              ),
            );

            // Act
            final result = ErrorHandler.getErrorMessage(exception);

            // Assert
            // Should extract the first validation error
            expect(result, isNotEmpty);
          });
        });
      });
    });

    group('runSafe', () {
      test('should return result on success', () async {
        // Arrange
        Future<int> successOperation() async => 42;
        String? capturedError;

        // Act
        final result = await ErrorHandler.runSafe(
          successOperation,
          onError: (message) => capturedError = message,
        );

        // Assert
        expect(result, 42);
        expect(capturedError, isNull);
      });

      test('should call onError and return fallback on failure', () async {
        // Arrange
        Future<int> failingOperation() async => throw Exception('Test error');
        String? capturedError;

        // Act
        final result = await ErrorHandler.runSafe(
          failingOperation,
          onError: (message) => capturedError = message,
          fallbackValue: -1,
        );

        // Assert
        expect(result, -1);
        expect(capturedError, isNotNull);
      });

      test('should return null when no fallback on failure', () async {
        // Arrange
        Future<int> failingOperation() async => throw Exception('Test error');
        String? capturedError;

        // Act
        final result = await ErrorHandler.runSafe(
          failingOperation,
          onError: (message) => capturedError = message,
        );

        // Assert
        expect(result, isNull);
        expect(capturedError, isNotNull);
      });

      test('should log operation name on error', () async {
        // Arrange
        Future<int> failingOperation() async => throw Exception('Test error');
        String? capturedError;

        // Act
        await ErrorHandler.runSafe(
          failingOperation,
          onError: (message) => capturedError = message,
          operationName: 'testOperation',
        );

        // Assert
        expect(capturedError, isNotNull);
      });
    });
  });

  group('AppException', () {
    test('should create with required parameters', () {
      // Act
      final exception = AppException(
        userMessage: 'User friendly message',
      );

      // Assert
      expect(exception.userMessage, 'User friendly message');
      expect(exception.technicalMessage, isNull);
      expect(exception.code, isNull);
    });

    test('should create with optional code', () {
      // Act
      final exception = AppException(
        userMessage: 'Message',
        code: 'ERR_001',
        technicalMessage: 'Technical details',
      );

      // Assert
      expect(exception.code, 'ERR_001');
      expect(exception.technicalMessage, 'Technical details');
    });

    test('toString should return formatted message', () {
      // Arrange
      final exception = AppException(
        userMessage: 'User message',
        code: 'TEST_CODE',
      );

      // Act
      final result = exception.toString();

      // Assert
      expect(result, contains('User message'));
      expect(result, contains('TEST_CODE'));
    });
  });

  group('NetworkException', () {
    test('should create with default user message', () {
      // Act
      const exception = NetworkException();

      // Assert
      expect(exception.userMessage, contains('connexion'));
      expect(exception.code, 'NETWORK_ERROR');
    });

    test('should allow custom user message', () {
      // Act
      const exception = NetworkException(userMessage: 'Custom network error');

      // Assert
      expect(exception.userMessage, 'Custom network error');
    });
  });

  group('AuthException', () {
    test('should create with default user message', () {
      // Act
      const exception = AuthException();

      // Assert
      expect(exception.userMessage, contains('authentification'));
      expect(exception.code, 'AUTH_ERROR');
    });
  });

  group('ValidationException', () {
    test('should create with field errors', () {
      // Arrange
      final fieldErrors = {
        'email': 'Email is required',
        'password': 'Password too short',
      };

      // Act
      final exception = ValidationException(
        userMessage: 'Validation failed',
        fieldErrors: fieldErrors,
      );

      // Assert
      expect(exception.userMessage, 'Validation failed');
      expect(exception.fieldErrors, fieldErrors);
      expect(exception.code, 'VALIDATION_ERROR');
    });

    test('should have default empty field errors', () {
      // Act
      const exception = ValidationException(userMessage: 'Validation failed');

      // Assert
      expect(exception.fieldErrors, isEmpty);
    });
  });

  group('NotFoundException', () {
    test('should create with default user message', () {
      // Act
      const exception = NotFoundException();

      // Assert
      expect(exception.userMessage, contains('non trouvé'));
      expect(exception.code, 'NOT_FOUND');
    });
  });

  group('ForbiddenException', () {
    test('should create with default user message', () {
      // Act
      const exception = ForbiddenException();

      // Assert
      expect(exception.userMessage, contains('non autorisé'));
      expect(exception.code, 'FORBIDDEN');
    });
  });
}
