import Flutter
import UIKit

public class SwiftTwitterAuthNullsafetyPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "twitter_auth_nullsafety", binaryMessenger: registrar.messenger())
    let instance = SwiftTwitterAuthNullsafetyPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
  }
}
