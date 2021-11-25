part of twitter_auth_null_safety_impl.dart;

/// The status after a Twitter login flow has completed.
enum TwitterAuthStatus {
  /// The login was successful and the user is now logged in.
  loggedIn,

  /// Login flow is still in progress.
  inProgress,

  /// The user cancelled the login flow, usually by backing out of the dialog.
  ///
  /// This might be unrealiable; see the [_parse] method in TwitterAuthResult.
  cancelled,

  /// The login flow completed, but for some reason resulted in an error. The
  /// user couldn't log in.
  failed,
}

/// The result when a Twitter login flow has completed.
///
/// To handle this result, first check what the [status] is. If the status
/// equals [TwitterAuthStatus.loggedIn], the login was successful. In this
/// case, the [session] contains all relevant information about the
/// currently logged in user.
class TwitterAuthResult {
  // /// Only available when the [status] equals [TwitterAuthStatus.error]
  // /// otherwise null.
  // final TwitterAuthException? exception;

  /// Only available when the [status] equals [TwitterAuthStatus.loggedIn],
  /// otherwise null.
  final TwitterAuthSession? session;

  /// The status after a Twitter login flow has completed.
  ///
  /// This affects whether the [session] or [error] are available or not.
  /// If the user cancelled the login flow, both [session] and [errorMessage]
  /// are null.
  final TwitterAuthStatus status;

  TwitterAuthResult._(Map<String, dynamic>? map)
      : status = parseStatus(map?['status'], map?['errorMessage']),
        session = map != null && map['session'] != null
            ? TwitterAuthSession.fromMap(map['session'].cast<String, dynamic>())
            : null;

  TwitterAuthResult.unknwon({
    this.session,
    this.status = TwitterAuthStatus.failed,
  });

  static TwitterAuthStatus parseStatus(String? status, String? error) {
    switch (status) {
      case 'loggedIn':
        return TwitterAuthStatus.loggedIn;
      case 'cancelled':
        return TwitterAuthStatus.cancelled;
      case 'failed':
        // Kind of a hack, but the only way of determining this.
        if (error != null &&
            (error.contains('cancel') ||
                error.contains('canceled') ||
                error.contains('cancelled'))) {
          return TwitterAuthStatus.cancelled;
        }

        return TwitterAuthStatus.failed;
    }

    throw StateError('Invalid status: $status');
  }
}

/// The information about a Twitter user session.
///
/// Includes the token and secret, along with the user's id and name, email address (if availeble) & username.
///
/// Both the [token] and [secret] are needed for making authenticated Twitter API calls.
class TwitterAuthSession {
  // ignore: unused_element
  const TwitterAuthSession._({
    required this.token,
    required this.secret,
    required this.user,
  });

  /// Auth secret used to make Twitter API calls.
  final String secret;

  /// Auth token for the user.
  final String token;

  // The Authenticated user.
  final TwitterUser user;

  /// Constructs a new access token instance from a [Map].
  ///
  /// This is used mostly internally by this library.
  TwitterAuthSession.fromMap(Map<String, dynamic> map)
      : user = TwitterUser.fromMap(map),
        token = map['auth_token'],
        secret = map['auth_secret'];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TwitterAuthSession &&
          runtimeType == other.runtimeType &&
          token == other.token &&
          secret == other.secret &&
          user == other.user;

  @override
  int get hashCode => secret.hashCode ^ token.hashCode ^ user.hashCode;

  /// Transforms this access token to a [Map].
  ///
  /// This could be useful for encoding this access token as JSON and then
  /// sending it to a server.
  Map<String, dynamic> toMap() {
    return {
      'id': user.id,
      'user_id': user.userId,
      'username': user.username,
      'email': user.email,
      'auth_token': token,
      'auth_secret': secret,
    };
  }

  @override
  String toString() =>
      'AuthSession(token: $token, secret: $secret, user: $user)';
}
