import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui show Codec;
import 'dart:ui' show Size, Locale, TextDirection, hashValues;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';

import 'package:flutter_photo_helper/flutter_photo_helper.dart';

// import 'binding.dart';
// import 'image_cache.dart';
// import 'image_stream.dart';

class PlatformImageProvider extends ImageProvider<PlatformImageProvider> {
  const PlatformImageProvider(this.assetId,
      {this.section, this.row, this.width, this.height, this.scale = 1.0})
      : assert(assetId != null),
        assert(scale != null);

  static ImageLruCache<String> thumbnailCache = ImageLruCache<String>(500);

  /// The bytes to decode into an image.
  final String assetId;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  final int section;
  final int row;

  final int width;
  final int height;

  @override
  Future<PlatformImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<PlatformImageProvider>(this);
  }

  @override
  ImageStreamCompleter load(PlatformImageProvider key) {
    return MultiFrameImageStreamCompleter(
        codec: _loadAsync(key),
        scale: key.scale,
        informationCollector: (StringBuffer information) {
          information.writeln('Image provider: $this');
          information.write('Image key: $key');
        });
  }

  Future<ui.Codec> _loadAsync(PlatformImageProvider key) async {
    assert(key == this);

    Uint8List data = thumbnailCache.getData(assetId);
    if (data == null) {
      //print("requestThumbnail: $section:$row, $assetId");
      ByteData byteData =
          await FlutterPhotoHelper.thumbnail(assetId, width, height);
      data = byteData.buffer.asUint8List();
      if (data.lengthInBytes == 0) {
        throw Exception(
            'PlatformImage is an empty file: $section:$row,  $assetId');
      }
      thumbnailCache.setData(assetId, data);
    }
    //print("requestThumbnail' result: $section:$row, $assetId, ${data.lengthInBytes}");

    return PaintingBinding.instance.instantiateImageCodec(data);
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final PlatformImageProvider typedOther = other;
    return assetId == typedOther.assetId &&
        scale == typedOther.scale &&
        width == typedOther.width &&
        height == typedOther.height;
  }

  @override
  int get hashCode => hashValues(assetId, scale, width, height);

  @override
  String toString() =>
      '$runtimeType("$assetId", scale: $scale), width: $width), height: $height), section: $section), row: $row)';
}
