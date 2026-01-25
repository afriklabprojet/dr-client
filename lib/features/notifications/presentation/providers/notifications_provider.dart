import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../config/providers.dart';
import 'notifications_notifier.dart';
import 'notifications_state.dart';
import '../../data/datasources/notifications_remote_datasource.dart';

// Notifications remote data source provider (uses ApiClient with auth token)
final notificationsRemoteDataSourceProvider =
    Provider<NotificationsRemoteDataSource>((ref) {
      final apiClient = ref.watch(apiClientProvider);
      return NotificationsRemoteDataSourceImpl(apiClient);
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
