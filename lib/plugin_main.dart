import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import './device/device_asset_path.dart';
import './device/device_asset.dart';
import './device/device_grouped_assets.dart';
import './device/permission_status.dart';

class FlutterPhotoHelper {
  static const String _plugin_name = 'flutter_photo_helper';
  static const MethodChannel _channel = const MethodChannel(_plugin_name);

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('platformVersion');
    return version;
  }

  /// android: WRITE_EXTERNAL_STORAGE  READ_EXTERNAL_STORAGE
  /// ios: photos permission
  static Future<PermissionStatus> get permissions async {
    Map<dynamic, dynamic> result = await _channel.invokeMethod("permissions");

    return PermissionStatus(result);
  }

  static void openSetting() {
    _channel.invokeMethod("openSetting");
  }

  static Future<List<DeviceAssetPath>> get deviceAssetPathes async {
    final List<dynamic> results =
        await _channel.invokeMethod('deviceAssetPathes');

    var assets = List<DeviceAssetPath>();
    for (var item in results) {
      var asset = DeviceAssetPath(
        id: item['id'],
        name: item['name'],
        count: item['count'],
      );

      assets.add(asset);
    }
    return assets;
  }

  static Future<List<DeviceGroupedAssets>> deviceAssets(
      String assetPathId) async {
    //initializeDateFormatting();

    assert(assetPathId != null);
    final List<dynamic> results =
        await _channel.invokeMethod('deviceAssets', assetPathId);

    String preCreation = "-";
    var groupedAssets = List<DeviceGroupedAssets>();
    var assets = List<DeviceAsset>();
    for (var item in results) {
      var creationDate =
          DateTime.fromMillisecondsSinceEpoch(item['creationDate'] ?? 0);
      var modificationDate =
          DateTime.fromMillisecondsSinceEpoch(item['modificationDate'] ?? 0);
      var asset = DeviceAsset(
        id: item['id'],
        assetId: item['assetId'],
        type: AssetType.unknown,
        creationDate: creationDate,
        modificationDate: modificationDate,
        pixelWidth: item['pixelWidth'],
        pixelHeight: item['pixelHeight'],
        duration: item['duration'],
        latitude: item['latitude'],
        longitude: item['longitude'],
      );

      var formatter = DateFormat.yMMMMEEEEd();
      String creationDateStr = formatter.format(creationDate);
      if (preCreation == creationDateStr) {
        assets.add(asset);
      } else {
        preCreation = creationDateStr;
        assets = List<DeviceAsset>();
        assets.add(asset);
        groupedAssets.add(
            DeviceGroupedAssets(groupTitle: creationDateStr, assets: assets));
      }
    }
    return groupedAssets;
  }

  static Future<ByteData> thumbnail(
      String id, String assetId, int width, int height,
      {int quality = 100}) async {
    assert(id != null);
    assert(assetId != null);
    assert(width != null && width >= 0);
    assert(height != null && height >= 0);
    assert(quality != null && quality >= 0 && quality <= 100);

    String _thumbChannel = '$_plugin_name/image/$id.thumb';
    print("Waiting for channel: $_thumbChannel");
    Completer<ByteData> completer = new Completer<ByteData>();
    BinaryMessages.setMessageHandler(_thumbChannel, (ByteData message) {
      print("Waited for channel: $_thumbChannel ${message.lengthInBytes}");
      completer.complete(message);
      //BinaryMessages.setMessageHandler(_thumbChannel, null);
    });

    bool result = await _channel.invokeMethod("thumbnail", <String, dynamic>{
      "id": id,
      "assetId": assetId,
      "width": width,
      "height": height,
      "quality": quality
    });

    if (result) {
      return completer.future;
    } else {
      BinaryMessages.setMessageHandler(_thumbChannel, null);
      return Future.error("Failed to fetch thumbnail data.");
    }
  }

  static Future<ByteData> original(String id, String assetId,
      {int quality = 100}) async {
    assert(id != null);
    assert(assetId != null);
    assert(quality != null && quality >= 0 && quality <= 100);

    String _thumbChannel = '$_plugin_name/image/$id.original';
    Completer<ByteData> completer = new Completer<ByteData>();
    BinaryMessages.setMessageHandler(_thumbChannel, (ByteData message) {
      completer.complete(message);
      BinaryMessages.setMessageHandler(_thumbChannel, null);
    });

    bool result = await _channel.invokeMethod("original", <String, dynamic>{
      "id": id,
      "assetId": assetId,
      "quality": quality,
    });

    if (result) {
      return completer.future;
    } else {
      BinaryMessages.setMessageHandler(_thumbChannel, null);
      return Future.error("Failed to fetch original data.");
    }
  }

  static Future<File> thumbnailFile(
      String id, String assetId, int width, int height,
      {int quality = 100}) async {
    assert(id != null);
    assert(assetId != null);
    assert(width != null && width >= 0);
    assert(height != null && height >= 0);
    assert(quality != null && quality >= 0 && quality <= 100);

    if (Platform.isAndroid) {
      return File(assetId);
    } else if (Platform.isIOS) {
      String path =
          await _channel.invokeMethod("thumbnailFile", <String, dynamic>{
        "id": id,
        "assetId": assetId,
        "width": width,
        "height": height,
        "quality": quality
      });

      if (path != null) {
        return File(path);
      } else {
        return Future.error("Failed to fetch thumbnail file.");
      }
    } else {
      return Future.error(
          "Not supported platform: ${Platform.operatingSystem}");
    }
  }

  static Future<File> originalFile(String id, String assetId,
      {int quality = 100}) async {
    assert(id != null);
    assert(assetId != null);
    assert(quality != null && quality >= 0 && quality <= 100);

    if (Platform.isAndroid) {
      return File(assetId);
    } else if (Platform.isIOS) {
      String path =
          await _channel.invokeMethod("originalFile", <String, dynamic>{
        "id": id,
        "assetId": assetId,
        "quality": quality,
      });

      if (path != null) {
        return File(path);
      } else {
        return Future.error("Failed to fetch original file.");
      }
    } else {
      return Future.error(
          "Not supported platform: ${Platform.operatingSystem}");
    }
  }

  static void startHandleNotify() {
    _channel.setMethodCallHandler(_notify);
  }

  /// stop handle notify
  static void stopHandleNotify() {
    _channel.setMethodCallHandler(null);
  }

  static Future<dynamic> _notify(MethodCall call) async {
    print("call.method = ${call.method}");
    if (call.method == "change") {
      _onChange(call);
    }
    return 1;
  }

  static Future<dynamic> _onChange(MethodCall call) async {
    print("_onChange = ${call.method}");
  }
}
