
import 'dart:async';

import 'package:flutter/services.dart';

class TwitterAuthNullsafety {
  static const MethodChannel _channel = MethodChannel('twitter_auth_nullsafety');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
