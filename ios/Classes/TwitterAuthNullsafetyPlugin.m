#import "TwitterAuthNullsafetyPlugin.h"
#if __has_include(<twitter_auth_nullsafety/twitter_auth_nullsafety-Swift.h>)
#import <twitter_auth_nullsafety/twitter_auth_nullsafety-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "twitter_auth_nullsafety-Swift.h"
#endif

@implementation TwitterAuthNullsafetyPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftTwitterAuthNullsafetyPlugin registerWithRegistrar:registrar];
}
@end
