library twitter_auth_nullsafety_web.dart;

import 'dart:async';
// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show window;

import 'package:flutter/services.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';

import 'twitter_auth_null_safety_interface.dart';

/// A web implementation of the TwitterAuth plugin.
class TwitterAuthNullsafetyWeb {
  static const _kMethodGetSession = 'getSession';
  static const _kMethodInstance = 'instance';
  static const _kMethodLogin = 'login';
  static const _kMethodLogout = 'logOut';

  static void registerWith(Registrar registrar) {
    final MethodChannel channel = MethodChannel(
      'twitter_auth_nullsafety',
      const StandardMethodCodec(),
      registrar,
    );

    final pluginInstance = TwitterAuthNullsafetyWeb();
    channel.setMethodCallHandler(pluginInstance.handleMethodCall);
  }

  /// Handles method calls over the MethodChannel of this plugin.
  /// Note: Check the "federated" architecture for a new way of doing this:
  /// https://flutter.dev/go/federated-plugins
  Future<dynamic> handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case _kMethodInstance:
        final args = call.arguments as List<dynamic>;
        final apiToken = args[0] as String;
        final apiTokenSecret = args[1] as String;
        return initialize(AuthConfig(
          apiToken: apiToken,
          apiTokenSecret: apiTokenSecret,
          callbackUrl: '',
        ));
      case _kMethodLogin:
        final args = call.arguments as List<dynamic>;
        return login(requestEmail: args[0] as bool);
      case _kMethodGetSession:
        return currentSession;
      case _kMethodLogout:
        return signOut();
      default:
        throw PlatformException(
          code: 'Unimplemented',
          details:
              'twitter_auth_nullsafety for web doesn\'t implement \'${call.method}\'',
        );
    }
  }

  static Future<TwitterAuth> initialize(AuthConfig config) async {
    // TODO: Implement for web.
    throw UnimplementedError();
  }

  Future<TwitterAuthResult> login({bool requestEmail = false}) async {
    // TODO: Implement for web.
    throw UnimplementedError();
  }

  Future<bool> get isSessionActive async => await currentSession != null;

  Future<TwitterAuthSession?> get currentSession async {
    // TODO: Implement for web.
    throw UnimplementedError();
  }

  Future<void> signOut() async {
    // TODO: Implement for web.
    throw UnimplementedError();
  }
}
