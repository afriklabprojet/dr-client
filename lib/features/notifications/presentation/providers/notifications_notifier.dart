import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../notifications/data/datasources/notifications_remote_datasource.dart';
import '../../domain/entities/notification_entity.dart';
import 'notifications_state.dart';

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsNotifier(this.remoteDataSource)
      : super(const NotificationsState.initial());

  // Load all notifications
  Future<void> loadNotifications() async {
    state = state.copyWith(status: NotificationsStatus.loading);

    try {
      final notificationModels = await remoteDataSource.getNotifications();
      final notifications =
          notificationModels.map((model) => model.toEntity()).toList();

      final unreadCount =
          notifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        status: NotificationsStatus.loaded,
        notifications: notifications,
        unreadCount: unreadCount,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: NotificationsStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Load only unread notifications
  Future<void> loadUnreadNotifications() async {
    state = state.copyWith(status: NotificationsStatus.loading);

    try {
      final notificationModels =
          await remoteDataSource.getUnreadNotifications();
      final notifications =
          notificationModels.map((model) => model.toEntity()).toList();

      state = state.copyWith(
        status: NotificationsStatus.loaded,
        notifications: notifications,
        unreadCount: notifications.length,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(
        status: NotificationsStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Mark single notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await remoteDataSource.markAsRead(notificationId);

      // Update local state
      final updatedNotifications = state.notifications.map((notification) {
        if (notification.id == notificationId) {
          return NotificationEntity(
            id: notification.id,
            type: notification.type,
            title: notification.title,
            body: notification.body,
            data: notification.data,
            isRead: true, // Mark as read
            createdAt: notification.createdAt,
          );
        }
        return notification;
      }).toList();

      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(
        status: NotificationsStatus.error,
        errorMessage: 'Erreur lors du marquage comme lu: $e',
      );
    }
  }

  // Mark all notifications as read
  Future<void> markAllAsRead() async {
    try {
      await remoteDataSource.markAllAsRead();

      // Update all notifications to read
      final updatedNotifications = state.notifications.map((notification) {
        return NotificationEntity(
          id: notification.id,
          type: notification.type,
          title: notification.title,
          body: notification.body,
          data: notification.data,
          isRead: true,
          createdAt: notification.createdAt,
        );
      }).toList();

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      );
    } catch (e) {
      state = state.copyWith(
        status: NotificationsStatus.error,
        errorMessage: 'Erreur lors du marquage de toutes comme lues: $e',
      );
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await remoteDataSource.deleteNotification(notificationId);

      // Remove from local state
      final updatedNotifications = state.notifications
          .where((notification) => notification.id != notificationId)
          .toList();

      final unreadCount = updatedNotifications.where((n) => !n.isRead).length;

      state = state.copyWith(
        notifications: updatedNotifications,
        unreadCount: unreadCount,
      );
    } catch (e) {
      state = state.copyWith(
        status: NotificationsStatus.error,
        errorMessage: 'Erreur lors de la suppression: $e',
      );
    }
  }

  // Update FCM token
  Future<void> updateFcmToken(String fcmToken) async {
    try {
      await remoteDataSource.updateFcmToken(fcmToken);
    } catch (e) {
      // Silent fail for FCM token update
      state = state.copyWith(
        errorMessage: 'Erreur lors de la mise à jour du token FCM: $e',
      );
    }
  }

  // Remove FCM token
  Future<void> removeFcmToken() async {
    try {
      await remoteDataSource.removeFcmToken();
    } catch (e) {
      // Silent fail for FCM token removal
    }
  }

  // Clear error
  void clearError() {
    if (state.errorMessage != null) {
      state = state.copyWith(errorMessage: null);
    }
  }
}
