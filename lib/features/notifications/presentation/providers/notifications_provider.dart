import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import 'notifications_notifier.dart';
import 'notifications_state.dart';
import '../../data/datasources/notifications_remote_datasource.dart';

// Dio provider for notifications (with auth token)
final notificationsDioProvider = Provider<Dio>((ref) {
  final dio = Dio(
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

  // Note: Auth token should be added via interceptor when available
  return dio;
});

// Notifications remote data source provider
final notificationsRemoteDataSourceProvider =
    Provider<NotificationsRemoteDataSource>((ref) {
      final dio = ref.watch(notificationsDioProvider);
      return NotificationsRemoteDataSourceImpl(dio);
    });

// Notifications provider
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
      final remoteDataSource = ref.watch(notificationsRemoteDataSourceProvider);
      return NotificationsNotifier(remoteDataSource);
    });

// Unread count provider (for badge)
// Returns 0 if no notifications loaded yet (prevents API call before login)
final unreadCountProvider = Provider<int>((ref) {
  final notificationsState = ref.watch(notificationsProvider);
  // Only return count if notifications were actually loaded
  if (notificationsState.status == NotificationsStatus.loaded) {
    return notificationsState.unreadCount;
  }
  return 0;
});
