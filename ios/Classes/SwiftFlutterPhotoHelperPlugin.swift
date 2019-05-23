import Flutter
import UIKit
import Photos

public class SwiftFlutterPhotoHelperPlugin: NSObject, FlutterPlugin, PHPhotoLibraryChangeObserver {
  public static let plugin_name: String = "flutter_photo_helper"
  var messenger: FlutterBinaryMessenger
  var channel: FlutterMethodChannel

  init( messenger: FlutterBinaryMessenger, channel: FlutterMethodChannel) {
    self.messenger = messenger;
    self.channel = channel;
    super.init();
    
    PHPhotoLibrary.shared().register(self)
  }
  
  deinit {
    PHPhotoLibrary.shared().unregisterChangeObserver(self)
  }
  
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: plugin_name, binaryMessenger: registrar.messenger())
    let instance = SwiftFlutterPhotoHelperPlugin(messenger: registrar.messenger(), channel: channel)
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
    case "thumbnailFile":
      let arguments = call.arguments as! Dictionary<String, AnyObject>
      let assetId = arguments["assetId"] as! String
      let width = arguments["width"] as! Int
      let height = arguments["height"] as! Int
      let quality = arguments["quality"] as! Int
      
      PhotosHelper.thumbnailFile(assetId, width, height, quality, result)
      break;
    case "originalFile":
      let arguments = call.arguments as! Dictionary<String, AnyObject>
      let assetId = arguments["assetId"] as! String
      let quality = arguments["quality"] as! Int
      
      PhotosHelper.originalFile(assetId, quality, result)
      break;

    default:
      result(FlutterMethodNotImplemented)
    }
  }
  
  public func photoLibraryDidChange(_ changeInstance: PHChange) {
    channel.invokeMethod("change", arguments: nil)
  }
}
