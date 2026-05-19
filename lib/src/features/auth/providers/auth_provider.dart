import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

/// Immutable snapshot of the current authentication state.
///
/// Three logical states:
/// - **Loading** — `isLoading == true`; an auth operation is in flight.
/// - **Authenticated** — `accessToken != null && !isLoading`.
/// - **Unauthenticated** — `accessToken == null && !isLoading`.
///
/// The [tier] getter decodes the JWT claim to expose the user's subscription tier.
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

/// Manages [AuthState] transitions: token injection after login, clearing
/// state on logout, and surfacing loading / error flags to the UI.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  /// Stores [token] in state and clears the loading flag.
  /// Called by [AuthRepository] after login/register and by [dioProvider]
  /// after a silent token refresh.
  void setToken(String token) {
    state = state.copyWith(accessToken: token, isLoading: false);
  }

  /// Resets state to the initial unauthenticated snapshot.
  /// Does **not** call the API logout endpoint — that is handled by
  /// [AuthRepository.logout].
  void logout() {
    state = AuthState();
  }

  /// Sets the loading flag. Used by auth screens to show a spinner
  /// while an async operation is in progress.
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// Stores an error message and clears the loading flag.
  /// Pass `null` to dismiss a previous error.
  void setError(String? error) {
    state = state.copyWith(error: error, isLoading: false);
  }
}

/// Provider that exposes [AuthNotifier] / [AuthState].
///
/// Alive for the lifetime of the app. [dioProvider] reads this provider
/// on every request to inject the current access token as a `Bearer` header.
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});
