import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../constants/api_constants.dart';
import '../errors/exceptions.dart';

class ApiClient {
  late final Dio _dio;
  String? _accessToken;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectionTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add auth token if available
          if (_accessToken != null) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Handle errors globally
          if (error.response?.statusCode == 401) {
            // Token expired or invalid
            throw UnauthorizedException(
              message: error.response?.data['message'] ?? 'Unauthorized',
            );
          }
          return handler.next(error);
        },
      ),
    );
  }

  void setToken(String token) {
    _accessToken = token;
  }

  void clearToken() {
    _accessToken = null;
  }

  Options authorizedOptions(String token) {
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Response> uploadMultipart(
    String path, {
    required FormData formData,
    Map<String, dynamic>? queryParameters,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: formData,
        queryParameters: queryParameters,
        options: options,
        onSendProgress: onSendProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    // Log détaillé pour le debug
    _logApiError(error);
    
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return NetworkException(
        message: 'Délai de connexion dépassé. Vérifiez votre connexion internet.',
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return NetworkException(
        message: 'Impossible de se connecter au serveur. Vérifiez votre connexion.',
      );
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      if (statusCode == 401) {
        return UnauthorizedException(
          message: data['message'] ?? 'Session expirée. Veuillez vous reconnecter.',
        );
      }
      
      if (statusCode == 403) {
        final serverMessage = data is Map ? data['message'] : null;
        final errorCode = data is Map ? data['error_code'] : null;
        
        // Messages spécifiques selon le code d'erreur
        String message;
        if (errorCode == 'PHONE_NOT_VERIFIED') {
          message = 'Veuillez d\'abord vérifier votre numéro de téléphone.';
        } else if (serverMessage != null && serverMessage.contains('Rôle requis')) {
          message = 'Ce compte n\'a pas accès à cette application. Veuillez utiliser le bon compte.';
        } else {
          message = serverMessage ?? 'Accès non autorisé';
        }
        
        return ServerException(
          message: message,
          statusCode: statusCode,
        );
      }
      
      if (statusCode == 404) {
        final serverMessage = data is Map ? data['message'] : null;
        return ServerException(
          message: serverMessage ?? 'Ressource non trouvée',
          statusCode: statusCode,
        );
      }

      if (statusCode == 422 && data is Map && data['errors'] != null) {
        return ValidationException(
          errors: Map<String, List<String>>.from(
            data['errors'].map(
              (key, value) => MapEntry(key, List<String>.from(value)),
            ),
          ),
        );
      }

      return ServerException(
        message: data is Map ? (data['message'] ?? 'Erreur serveur') : 'Erreur serveur',
        statusCode: statusCode,
      );
    }

    return ServerException(message: error.message ?? 'Erreur inconnue');
  }
  
  void _logApiError(DioException error) {
    final baseUrl = error.requestOptions.baseUrl;
    final path = error.requestOptions.path;
    final method = error.requestOptions.method;
    final statusCode = error.response?.statusCode;
    
    debugPrint('═══════════════════════════════════════════════════════════');
    if (statusCode == 404) {
      debugPrint('❌ [API ERROR 404] Endpoint non trouvé');
      debugPrint('   URL complète: $baseUrl$path');
      debugPrint('   Méthode: $method');
      debugPrint('   Message serveur: ${error.response?.data?['message'] ?? 'Non disponible'}');
    } else if (statusCode == 401) {
      debugPrint('🔐 [API ERROR 401] Non authentifié');
      debugPrint('   URL: $path');
    } else if (statusCode == 403) {
      final errorCode = error.response?.data?['error_code'];
      debugPrint('🚫 [API ERROR 403] Accès interdit');
      debugPrint('   URL: $path');
      debugPrint('   Message: ${error.response?.data?['message'] ?? 'Non disponible'}');
      if (errorCode != null) debugPrint('   Code erreur: $errorCode');
      if (errorCode == 'PHONE_NOT_VERIFIED') {
        debugPrint('   💡 Conseil: Le numéro de téléphone doit être vérifié');
      } else if (error.response?.data?['message']?.contains('Rôle requis') == true) {
        debugPrint('   💡 Conseil: Ce compte n\'a pas le bon rôle pour cette application');
      }
    } else if (statusCode == 500) {
      debugPrint('🔥 [API ERROR 500] Erreur serveur interne');
      debugPrint('   URL: $path');
    } else if (error.type == DioExceptionType.connectionError) {
      debugPrint('🌐 [API ERROR] Impossible de se connecter');
      debugPrint('   URL tentée: $baseUrl');
      debugPrint('   Conseil: Vérifiez que le serveur Laravel est démarré');
    } else {
      debugPrint('⚠️ [API ERROR] Code: $statusCode');
      debugPrint('   URL: $path');
    }
    debugPrint('═══════════════════════════════════════════════════════════');
  }
}
