import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_client.dart';
import '../models/profile.dart';

class ProfileRepository {
  final Dio _dio;

  ProfileRepository(this._dio);

  Future<UserProfile> getProfile() async {
    final response = await _dio.get('/api/me');
    return UserProfile.fromJson(response.data);
  }

  Future<Subscription> getSubscription() async {
    final response = await _dio.get('/api/subscription');
    return Subscription.fromJson(response.data);
  }

  Future<void> resetTastePreferences() async {
    await _dio.delete('/api/me/preferences');
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    await _dio.put('/api/me', data: data);
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(dioProvider));
});

final profileProvider = FutureProvider<UserProfile>((ref) async {
  return ref.watch(profileRepositoryProvider).getProfile();
});

final subscriptionProvider = FutureProvider<Subscription>((ref) async {
  return ref.watch(profileRepositoryProvider).getSubscription();
});
