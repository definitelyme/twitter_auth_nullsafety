part of twitter_auth_null_safety_impl.dart;

class TwitterAuthException implements Exception {
  final TwitterAuthStatus status;
  final String message;

  const TwitterAuthException({required this.status, required this.message});

  @override
  String toString() => 'AuthException(message: $message, status: $status)';
}
