import Flutter
import UIKit

public class SwiftFlutterPhotoHelperPlugin: NSObject, FlutterPlugin {
  public static let plugin_name: String = "flutter_photo_helper"
  var messenger: FlutterBinaryMessenger

  init(messenger: FlutterBinaryMessenger) {
    self.messenger = messenger;
    super.init();
  }
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: plugin_name, binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterPhotoHelperPlugin(messenger: registrar.messenger())
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch (call.method) {
    case "platformVersion":
      result("iOS " + UIDevice.current.systemVersion)
      break
    case "permissions":
      PhotosHelper.permissions(result)
      break
    case "deviceAssetPathes":
      PhotosHelper.deviceAssetPathes(result)
      break;
    case "deviceAssets":
      let assetPathId: String = call.arguments as! String
      PhotosHelper.deviceAssets(assetPathId, result)
      break;
    case "thumbnail":
      let arguments = call.arguments as! Dictionary<String, AnyObject>
      let assetId = arguments["assetId"] as! String
      let width = arguments["width"] as! Int
      let height = arguments["height"] as! Int
      let quality = arguments["quality"] as! Int

      PhotosHelper.thumbnail(assetId, width, height, quality, result, messenger)
      break;
    case "original":
      let arguments = call.arguments as! Dictionary<String, AnyObject>
      let assetId = arguments["assetId"] as! String
      let quality = arguments["quality"] as! Int

      PhotosHelper.original(assetId, quality, result, messenger)
      break;
    default:
      result(FlutterMethodNotImplemented)
    }
  }

}
