import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class AuthState {
  final String? accessToken;
  final bool isLoading;
  final String? error;

  AuthState({
    this.accessToken,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => accessToken != null;
  
  String? get tier {
    if (accessToken == null) return null;
    try {
      final payload = JwtDecoder.decode(accessToken!);
      return payload['tier'] as String?;
    } catch (_) {
      return null;
    }
  }

  AuthState copyWith({
    String? accessToken,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      accessToken: accessToken ?? this.accessToken,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  void setToken(String token) {
    state = state.copyWith(accessToken: token, isLoading: false);
  }

  void logout() {
    state = AuthState();
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error, isLoading: false);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
