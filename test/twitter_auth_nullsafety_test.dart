import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
// import 'package:twitter_auth_nullsafety/twitter_auth_nullsafety.dart';

void main() {
  const MethodChannel channel = MethodChannel('twitter_auth_nullsafety');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  // test('getPlatformVersion', () async {
  //   expect(await TwitterAuth.platformVersion, '42');
  // });
}
