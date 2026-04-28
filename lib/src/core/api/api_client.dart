import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config.dart';
import '../../features/auth/providers/auth_provider.dart';

final cookieJarProvider = Provider<CookieJar>((ref) => CookieJar());

final dioProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: AppConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  final cookieJar = ref.watch(cookieJarProvider);
  dio.interceptors.add(CookieManager(cookieJar));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) {
      final token = ref.read(authProvider).accessToken;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      return handler.next(options);
    },
    onError: (DioException error, handler) async {
      if (error.response?.statusCode == 401 && !error.requestOptions.path.contains('/auth/refresh')) {
        // Attempt to refresh token
        try {
          final response = await dio.post('/api/auth/refresh');
          final newToken = response.data['access_token'];
          
          if (newToken != null) {
            ref.read(authProvider.notifier).setToken(newToken);
            
            // Retry the original request
            final options = error.requestOptions;
            options.headers['Authorization'] = 'Bearer $newToken';
            
            final retryResponse = await dio.fetch(options);
            return handler.resolve(retryResponse);
          }
        } catch (e) {
          // Refresh failed, logout
          ref.read(authProvider.notifier).logout();
        }
      }
      
      return handler.next(error);
    },
  ));

  return dio;
});
