import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';

class AuthRepository {
  final Dio _dio;

  AuthRepository(this._dio);

  Future<String> login(String email, String password) async {
    try {
      final response = await _dio.post('/api/auth/login', data: {
        'email': email,
        'password': password,
      });
      return response.data['access_token'];
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Login failed';
    }
  }

  Future<void> register(String email, String password, String name) async {
    try {
      await _dio.post('/api/auth/register', data: {
        'email': email,
        'password': password,
        'name': name,
      });
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Registration failed';
    }
  }

  Future<void> saveOnboarding(Map<String, dynamic> data) async {
    try {
      await _dio.post('/api/auth/onboarding', data: data);
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Failed to save onboarding';
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/api/auth/logout');
    } catch (_) {}
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});
