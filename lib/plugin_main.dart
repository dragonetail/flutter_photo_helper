import 'dart:async';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import './device/device_asset_path.dart';
import './device/device_asset.dart';
import './device/device_grouped_assets.dart';

class FlutterPhotoHelper {
  static const String _plugin_name = 'flutter_photo_helper';
  static const MethodChannel _channel = const MethodChannel(_plugin_name);

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('platformVersion');
    return version;
  }

  /// android: WRITE_EXTERNAL_STORAGE  READ_EXTERNAL_STORAGE
  /// ios: photos permission
  static Future<bool> get permissions async {
    var result = await _channel.invokeMethod("permissions");
    return result;
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

  static Future<ByteData> thumbnail(String assetId, int width, int height,
      {int quality = 100}) async {
    assert(assetId != null);
    assert(width != null && width >= 0);
    assert(height != null && height >= 0);
    assert(quality != null && quality >= 0 && quality <= 100);

    String _thumbChannel = '$_plugin_name/image/$assetId.thumb';
    Completer<ByteData> completer = new Completer<ByteData>();
    BinaryMessages.setMessageHandler(_thumbChannel, (ByteData message) {
      completer.complete(message);
      BinaryMessages.setMessageHandler(_thumbChannel, null);
    });

    bool result = await _channel.invokeMethod("thumbnail", <String, dynamic>{
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

  static Future<ByteData> original(String assetId, {int quality = 100}) async {
    assert(assetId != null);
    assert(quality != null && quality >= 0 && quality <= 100);

    String _thumbChannel = '$_plugin_name/image/$assetId.original';
    Completer<ByteData> completer = new Completer<ByteData>();
    BinaryMessages.setMessageHandler(_thumbChannel, (ByteData message) {
      completer.complete(message);
      BinaryMessages.setMessageHandler(_thumbChannel, null);
    });

    bool result = await _channel.invokeMethod("original", <String, dynamic>{
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

  static Future<File> thumbnailFile(String assetId, int width, int height,
      {int quality = 100}) async {
    assert(assetId != null);
    assert(width != null && width >= 0);
    assert(height != null && height >= 0);
    assert(quality != null && quality >= 0 && quality <= 100);

    if (Platform.isAndroid) {
      return File(assetId);
    } else if (Platform.isIOS) {
      String path = await _channel.invokeMethod(
          "thumbnailFile", <String, dynamic>{
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

  static Future<File> originalFile(String assetId, {int quality = 100}) async {
    assert(assetId != null);
    assert(quality != null && quality >= 0 && quality <= 100);

    if (Platform.isAndroid) {
      return File(assetId);
    } else if (Platform.isIOS) {
      String path =
          await _channel.invokeMethod("originalFile", <String, dynamic>{
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
}
