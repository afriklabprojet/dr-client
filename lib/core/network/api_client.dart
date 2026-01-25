import 'package:dio/dio.dart';
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
    
    print('═══════════════════════════════════════════════════════════');
    if (statusCode == 404) {
      print('❌ [API ERROR 404] Endpoint non trouvé');
      print('   URL complète: $baseUrl$path');
      print('   Méthode: $method');
      print('   Message serveur: ${error.response?.data?['message'] ?? 'Non disponible'}');
    } else if (statusCode == 401) {
      print('🔐 [API ERROR 401] Non authentifié');
      print('   URL: $path');
    } else if (statusCode == 500) {
      print('🔥 [API ERROR 500] Erreur serveur interne');
      print('   URL: $path');
    } else if (error.type == DioExceptionType.connectionError) {
      print('🌐 [API ERROR] Impossible de se connecter');
      print('   URL tentée: $baseUrl');
      print('   Conseil: Vérifiez que le serveur Laravel est démarré');
    } else {
      print('⚠️ [API ERROR] Code: $statusCode');
      print('   URL: $path');
    }
    print('═══════════════════════════════════════════════════════════');
  }
}
