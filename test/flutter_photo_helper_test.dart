import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_photo_helper/flutter_photo_helper.dart';

void main() {
  const MethodChannel channel = MethodChannel('flutter_photo_helper');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await FlutterPhotoHelper.platformVersion, '42');
  });
}
