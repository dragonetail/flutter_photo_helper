#import "FlutterPhotoHelperPlugin.h"
#import <flutter_photo_helper/flutter_photo_helper-Swift.h>

@implementation FlutterPhotoHelperPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterPhotoHelperPlugin registerWithRegistrar:registrar];
}
@end
