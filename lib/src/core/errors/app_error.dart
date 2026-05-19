/// Unified error type propagated by all repository calls throughout the app.
///
/// Wraps an optional HTTP [statusCode] alongside a human-readable [message]
/// so that UI layers can branch on the status code without parsing raw exceptions.
class AppError implements Exception {
  final String message;
  final int? statusCode;

  const AppError(this.message, {this.statusCode});

  @override
  String toString() => message;
}
