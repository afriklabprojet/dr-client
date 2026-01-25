import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../../../core/constants/app_constants.dart';
import 'dart:convert';

abstract class AuthLocalDataSource {
  Future<void> cacheToken(String token);
  Future<String?> getCachedToken();
  Future<void> clearToken();

  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> cacheToken(String token) async {
    await sharedPreferences.setString(AppConstants.tokenKey, token);
  }

  @override
  Future<String?> getCachedToken() async {
    return sharedPreferences.getString(AppConstants.tokenKey);
  }

  @override
  Future<void> clearToken() async {
    await sharedPreferences.remove(AppConstants.tokenKey);
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await sharedPreferences.setString(AppConstants.userKey, userJson);
  }

  @override
  Future<UserModel?> getCachedUser() async {
    final userJson = sharedPreferences.getString(AppConstants.userKey);
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    await sharedPreferences.remove(AppConstants.userKey);
  }
}
