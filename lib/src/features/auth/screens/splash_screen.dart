import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/api/api_client.dart';
import '../../../core/services/push_notification_service.dart';
import '../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final dio = ref.read(dioProvider);
    try {
      // Attempt to refresh token on startup
      final response = await dio.post('/api/auth/refresh');
      final token = response.data['access_token'];
      if (token != null) {
        ref.read(authProvider.notifier).setToken(token);
        
        // Initialize push notifications
        ref.read(pushNotificationServiceProvider).initializeAndRegisterToken();
        
        if (mounted) context.go('/');
      } else {
        if (mounted) context.go('/login');
      }
    } catch (e) {
      if (mounted) context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        color: Theme.of(context).colorScheme.primary,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.restaurant, size: 80, color: Colors.white),
            const SizedBox(height: 24),
            Text(
              'Cookest',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                letterSpacing: 2.0,
              ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
