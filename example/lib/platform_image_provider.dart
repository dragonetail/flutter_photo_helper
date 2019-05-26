import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui show Codec;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';

import 'package:flutter_photo_helper/flutter_photo_helper.dart';

class PlatformImageProvider extends ImageProvider<PlatformImageProvider> {
  const PlatformImageProvider(this.id, this.assetId,
      {this.width, this.height, this.scale = 1.0})
      : cacheKey = "$id${width}x$height",
        assert(id != null),
        assert(assetId != null),
        assert(scale != null);

  static ImageLruCache<String> thumbnailCache = ImageLruCache<String>(500);

  /// The bytes to decode into an image.
  ///
  final String id;
  final String assetId;

  /// The scale to place in the [ImageInfo] object of the image.
  final double scale;

  // final int section;
  // final int row;

  final int width;
  final int height;

  final String cacheKey;

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

    Uint8List data = thumbnailCache.getData(cacheKey);
    if (data == null) {
      //print("requestThumbnail: $section:$row, $assetId");
      ByteData byteData =
          await FlutterPhotoHelper.thumbnail(id, assetId, width, height);
      data = byteData.buffer.asUint8List();
      if (data.lengthInBytes == 0) {
        throw Exception('PlatformImage is an empty file: $assetId');
      }
      thumbnailCache.setData(cacheKey, data);
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
      '$runtimeType("$assetId", scale: $scale), width: $width), height: $height))';
}
