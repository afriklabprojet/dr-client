import 'package:dio/dio.dart';
import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getNotifications();
  Future<List<NotificationModel>> getUnreadNotifications();
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
  Future<void> deleteNotification(String notificationId);
  Future<void> updateFcmToken(String fcmToken);
  Future<void> removeFcmToken();
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final Dio dio;

  NotificationsRemoteDataSourceImpl(this.dio);

  @override
  Future<List<NotificationModel>> getNotifications() async {
    final response = await dio.get('/notifications');
    final data = response.data['data'];
    final notifications = (data['notifications'] as List)
        .map((json) => NotificationModel.fromJson(json))
        .toList();
    return notifications;
  }

  @override
  Future<List<NotificationModel>> getUnreadNotifications() async {
    final response = await dio.get('/notifications/unread');
    final notifications = (response.data['data'] as List)
        .map((json) => NotificationModel.fromJson(json))
        .toList();
    return notifications;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await dio.post('/notifications/$notificationId/read');
  }

  @override
  Future<void> markAllAsRead() async {
    await dio.post('/notifications/read-all');
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await dio.delete('/notifications/$notificationId');
  }

  @override
  Future<void> updateFcmToken(String fcmToken) async {
    await dio.post('/notifications/fcm-token', data: {'fcm_token': fcmToken});
  }

  @override
  Future<void> removeFcmToken() async {
    await dio.delete('/notifications/fcm-token');
  }
}
