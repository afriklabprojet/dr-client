import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import '../network/api_client.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final ApiClient _apiClient;

  NotificationService(this._apiClient);

  Future<void> initNotifications() async {
    try {
      // 1. Demander la permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        debugPrint('✅ User granted notification permission');

        // 2. Récupérer le token
        try {
          String? token = await _messaging.getToken(
            vapidKey: kIsWeb 
                ? 'BIHsG8xfqGxpEjGCnz8FGJ6c6iELBUzPwCzUJE2bQD3uJ-wZgTXJ7dF-wJjvC7K0qgTJnK8b8p5xVjT5rXJzYTk' 
                : null,
          );
          if (token != null) {
            debugPrint('✅ FCM Token obtained');
            // 3. Envoyer au backend
            await sendTokenToBackend(token);
          }
        } catch (tokenError) {
          // Sur web, l'erreur du service worker peut survenir ici
          debugPrint('⚠️ Could not get FCM token (may be normal on web dev): $tokenError');
        }

        // 4. Écouter les rafraîchissements de token
        _messaging.onTokenRefresh.listen((newToken) {
          sendTokenToBackend(newToken);
        });
      } else {
        debugPrint('⚠️ User declined notification permission');
      }
    } catch (e) {
      // Ne pas bloquer l'app si les notifications ne marchent pas
      debugPrint('⛔ Error initializing notifications: $e');
    }
  }

  Future<void> sendTokenToBackend(String token) async {
    try {
      String platform = 'android';
      if (kIsWeb) {
        platform = 'web';
      }
      
      await _apiClient.post(
        '/notifications/fcm-token',
        data: {
          'fcm_token': token,
          'platform': platform,
        },
      );
      debugPrint('✅ FCM Token sent to backend successfully');
    } catch (e) {
      debugPrint('⛔ Failed to send FCM token to backend: $e');
    }
  }
}
