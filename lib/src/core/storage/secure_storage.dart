import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Persistent, encrypted key-value store for session secrets.
///
/// Holds the access token, the refresh token (mirrors the server's `httpOnly`
/// cookie on native), and the `rememberMe` flag. Uses AES-encrypted
/// `EncryptedSharedPreferences` on Android and the iOS Keychain on iOS.
class SecureStorage {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _rememberMeKey = 'remember_me';

  /// Persists both access and refresh tokens atomically after a successful login.
  static Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessKey, value: accessToken),
      _storage.write(key: _refreshKey, value: refreshToken),
    ]);
  }

  /// Returns the stored access token, or `null` if no session exists.
  static Future<String?> getAccessToken() =>
      _storage.read(key: _accessKey);

  /// Returns the stored refresh token, or `null` if no session exists.
  static Future<String?> getRefreshToken() =>
      _storage.read(key: _refreshKey);

  /// Deletes both access and refresh tokens without touching other auth flags.
  static Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _accessKey),
      _storage.delete(key: _refreshKey),
    ]);
  }

  /// Overwrites the access token in place — used after a silent token refresh.
  static Future<void> saveAccessToken(String accessToken) =>
      _storage.write(key: _accessKey, value: accessToken);

  /// Persists the user's "remember me" preference so the splash screen can
  /// decide whether to attempt auto-login on next cold start.
  static Future<void> setRememberMe(bool rememberMe) =>
      _storage.write(key: _rememberMeKey, value: rememberMe ? 'true' : 'false');

  /// Returns `true` if the user chose to stay signed in across app restarts.
  static Future<bool> getRememberMe() async =>
      (await _storage.read(key: _rememberMeKey)) == 'true';

  /// Wipes all auth-related storage: tokens and the `rememberMe` flag.
  /// Called on explicit logout or when a refresh cycle fails.
  static Future<void> clearAuthState() async {
    await Future.wait([
      clearTokens(),
      _storage.delete(key: _rememberMeKey),
    ]);
  }
}
