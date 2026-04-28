import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/api_client.dart';

class PushNotificationService {
  final Dio _dio;

  PushNotificationService(this._dio);

  /// Note: To fully enable Firebase Messaging, the `firebase_messaging` and 
  /// `firebase_core` packages must be added to pubspec.yaml, and the platform
  /// specific configuration files (google-services.json, GoogleService-Info.plist)
  /// must be provided in the android/app and ios/Runner directories respectively.
  Future<void> initializeAndRegisterToken() async {
    try {
      // 1. Initialize Firebase (Mocked)
      // await Firebase.initializeApp();
      
      // 2. Request Permissions
      // final messaging = FirebaseMessaging.instance;
      // await messaging.requestPermission();
      
      // 3. Get Token
      // final token = await messaging.getToken();
      final mockToken = "mock_fcm_token_12345"; 

      if (mockToken.isNotEmpty) {
        await _registerTokenWithBackend(mockToken);
      }

      // 4. Listen for token refreshes
      // FirebaseMessaging.instance.onTokenRefresh.listen(_registerTokenWithBackend);
    } catch (e) {
      // Handle initialization error
      print("PushNotificationService Error: $e");
    }
  }

  Future<void> _registerTokenWithBackend(String token) async {
    try {
      final platform = Platform.isIOS ? 'ios' : (Platform.isAndroid ? 'android' : 'web');
      await _dio.post('/api/me/push-tokens', data: {
        'token': token,
        'platform': platform,
      });
    } catch (e) {
      print("Failed to register push token with backend: $e");
    }
  }
}

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService(ref.watch(dioProvider));
});
