library twitter_auth_null_safety_impl.dart;

import 'dart:async';

import 'package:flutter/services.dart';

part './twitter_auth_facade.dart';
part './klasses/twitter_user.dart';
part './klasses/twitter_auth_exception.dart';

class AuthConfig {
  final String apiToken;
  final String apiTokenSecret;
  final String callbackUrl;

  const AuthConfig({
    required this.apiToken,
    required this.apiTokenSecret,
    required this.callbackUrl,
  });
}

class TwitterAuth {
  static const MethodChannel _channel =
      MethodChannel('twitter_auth_nullsafety');

  static TwitterAuth? _instance;
  static const _kMethodGetSession = 'getSession';
  static const _kMethodInstance = 'instance';
  static const _kMethodLogin = 'login';
  static const _kMethodLogout = 'logOut';

  final AuthConfig config;

  TwitterAuth._(this.config);

  static TwitterAuth? get instance => _instance;

  static Future<TwitterAuth> initialize(AuthConfig config) async {
    assert(config.apiToken.isNotEmpty, 'API Token may not be null or empty.');
    assert(config.apiTokenSecret.isNotEmpty,
        'API Token Secret may not be null or empty.');

    if (_instance == null) {
      await _channel.invokeMethod(
        _kMethodInstance,
        [config.apiToken, config.apiTokenSecret],
      );
    }

    return _instance ??= TwitterAuth._(config);
  }

  /// Logs the user in.
  ///
  /// If the user has a native Twitter client installed, this will present a
  /// native login screen. Otherwise a WebView is used.
  ///
  /// The "Callback URL" field must be configured to a valid address in your
  /// app's "Settings" tab. When using the Twitter login only on mobile devices,
  /// an example of a valid callback url would be http://127.0.0.1:4000.
  ///
  /// Use [TwitterAuthResult.status] for determining if the login was successful
  /// or not. For example:
  ///
  /// ```dart
  /// final TwitterAuthResult result = await twitterAuth.login();
  ///
  /// switch (result.status) {
  ///   case TwitterLoginStatus.loggedIn:
  ///     var session = result.session;
  ///     _sendTokenAndSecretToServer(session.token, session.secret);
  ///     break;
  ///   case TwitterLoginStatus.cancelled:
  ///     _showCancelMessage();
  ///     break;
  /// }
  /// ```
  ///
  /// See the [TwitterAuthResult] class for more documentation.
  Future<TwitterAuthResult> login({bool requestEmail = false}) async {
    final Map<dynamic, dynamic>? result =
        await _channel.invokeMethod(_kMethodLogin, [requestEmail]);

    if (result != null) {
      if (result['status'] != 'failed') {
        return TwitterAuthResult._(result.cast<String, dynamic>());
      }

      throw _parseException(result.cast<String, dynamic>());
    }

    return TwitterAuthResult.unknwon();
  }

  /// Returns whether the user is currently logged in or not.
  ///
  /// Convenience method for checking if the [currentSession] is not null.
  Future<bool> get isSessionActive async => await currentSession != null;

  /// Retrieves the currently active session, if any.
  ///
  /// A common use case for this is logging the user automatically in if they
  /// have already logged in before and the session is still active.
  ///
  /// For example:
  ///
  /// ```dart
  /// final TwitterAuthSession session = await twitterAuth.currentSession;
  ///
  /// if (session != null) {
  ///   _fetchTweets(session);
  /// } else {
  ///   _showLoginRequiredUI();
  /// }
  /// ```
  ///
  /// If the user is not logged in, this returns null.
  Future<TwitterAuthSession?> get currentSession async {
    final Map<dynamic, dynamic>? session =
        await _channel.invokeMethod(_kMethodGetSession);

    if (session == null) return null;

    return TwitterAuthSession.fromMap(session.cast<String, dynamic>());
  }

  /// Logout the current user & clear session cache.
  Future<void> signOut() async => _channel.invokeMethod(_kMethodLogout);

  TwitterAuthException _parseException(Map<String, dynamic> json) {
    if (json.containsKey('status')) {
      final status = json['status'];

      return TwitterAuthException(
        status: TwitterAuthResult.parseStatus(status, json['errorMessage']),
        message: json['errorMessage'],
      );
    }

    return TwitterAuthException(
      status: TwitterAuthResult.parseStatus('failed', null),
      message: json.containsKey('errorMessage')
          ? json['errorMessage']
          : 'Unknown error!',
    );
  }
}
