import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../models/auth_response_model.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  });

  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? address,
  });

  Future<void> logout(String token);

  Future<UserModel> getCurrentUser(String token);

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Verify OTP code for phone verification
  Future<AuthResponseModel> verifyOtp({
    required String identifier,
    required String otp,
  });

  /// Resend OTP code
  /// Returns a map with 'message' and 'channel' keys
  Future<Map<String, dynamic>> resendOtp({
    required String identifier,
  });

  /// Request password reset email
  Future<void> forgotPassword({
    required String email,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<AuthResponseModel> login({
    required String email,
    required String password,
  }) async {
    // Normaliser l'email en minuscules pour éviter les problèmes de case sensitivity
    final normalizedEmail = email.toLowerCase().trim();
    
    final response = await apiClient.post(
      ApiConstants.login,
      data: {
        'email': normalizedEmail,
        'password': password,
        'device_name': 'client-app',
        'role': 'customer', // Indiquer que c'est l'app client
      },
    );

    return AuthResponseModel.fromJson(response.data['data']);
  }

  @override
  Future<AuthResponseModel> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? address,
  }) async {
    // Normaliser l'email en minuscules pour éviter les problèmes de case sensitivity
    final normalizedEmail = email.toLowerCase().trim();
    
    final response = await apiClient.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': normalizedEmail,
        'phone': phone,
        'password': password,
        'password_confirmation': password,
        if (address != null) 'address': address,
      },
    );

    return AuthResponseModel.fromJson(response.data['data']);
  }

  @override
  Future<void> logout(String token) async {
    await apiClient.post(
      ApiConstants.logout,
      options: apiClient.authorizedOptions(token),
    );
  }

  @override
  Future<UserModel> getCurrentUser(String token) async {
    final response = await apiClient.get(
      ApiConstants.me,
      options: apiClient.authorizedOptions(token),
    );

    return UserModel.fromJson(response.data['data']);
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await apiClient.post(
      ApiConstants.updatePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPassword,
      },
    );
  }

  @override
  Future<AuthResponseModel> verifyOtp({
    required String identifier,
    required String otp,
  }) async {
    final response = await apiClient.post(
      ApiConstants.verifyOtp,
      data: {
        'identifier': identifier,
        'otp': otp,
      },
    );

    return AuthResponseModel.fromJson(response.data);
  }

  @override
  Future<Map<String, dynamic>> resendOtp({
    required String identifier,
  }) async {
    final response = await apiClient.post(
      ApiConstants.resendOtp,
      data: {
        'identifier': identifier,
      },
    );
    
    return {
      'message': response.data['message'] ?? 'Code envoyé',
      'channel': response.data['channel'] ?? 'sms',
    };
  }

  @override
  Future<void> forgotPassword({
    required String email,
  }) async {
    await apiClient.post(
      ApiConstants.forgotPassword,
      data: {
        'email': email.toLowerCase().trim(),
      },
    );
  }
}
