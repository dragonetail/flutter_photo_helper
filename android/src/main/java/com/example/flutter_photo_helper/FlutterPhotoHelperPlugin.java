package com.example.flutter_photo_helper;

import android.Manifest;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.util.Log;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterPhotoHelperPlugin
 */
public class FlutterPhotoHelperPlugin implements MethodCallHandler {
  public static String PLUGIN_NAME = "flutter_photo_helper";

  private static final int REQUEST_CODE_GRANT_PERMISSIONS = 2001;

  private final Registrar registrar;
  private final Activity activity;
  private final Context context;
  private final MethodChannel channel;
  private final BinaryMessenger messenger;
  private final ContentResolver contentResolver;

  private final PermissionsHelper permissionsHelper;

  private FlutterPhotoHelperPlugin(Registrar registrar, MethodChannel channel) {
    this.registrar = registrar;
    this.activity = registrar.activity();
    this.context = registrar.context();
    this.channel = channel;
    this.messenger = registrar.messenger();
    this.contentResolver = this.activity.getContentResolver();

    permissionsHelper = new PermissionsHelper(registrar, REQUEST_CODE_GRANT_PERMISSIONS);
  }

  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(),
        "flutter_photo_helper");
    FlutterPhotoHelperPlugin instance = new FlutterPhotoHelperPlugin(registrar, channel);

    channel.setMethodCallHandler(instance);
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    switch (call.method) {
      case "platformVersion":
        result.success("Android " + android.os.Build.VERSION.RELEASE);
        break;
      case "permissions":
        requestPermission(result);
        break;
      case "openSetting":
        result.success("");
        PermissionsHelper.getAppDetailSettingIntent(this.activity);
        break;
      case "deviceAssetPathes":
        MediaHelper.deviceAssetPathes(contentResolver, result);
        break;
      case "deviceAssets":
        String assetPathId = call.arguments();
        MediaHelper.deviceAssets(assetPathId, contentResolver, result);
        break;
      case "thumbnail":
        String id = call.argument("id");
        String assetId = call.argument("assetId");
        Integer width = call.argument("width");
        Integer height = call.argument("height");
        Integer quality = call.argument("quality");

        MediaHelper.thumbnail(id, assetId, width, height, quality, result, messenger);
        break;
      case "original":
        result.success(true);
        break;
      case "thumbnailFile":
        result.success("");
        break;
      case "originalFile":
        result.success("");
        break;
      default:
        result.notImplemented();
    }
  }

  private void requestPermission(final Result result) {
    this.permissionsHelper.requestPermissions(
        new String[]{
            Manifest.permission.READ_EXTERNAL_STORAGE,
            Manifest.permission.WRITE_EXTERNAL_STORAGE
        },//Manifest.permission.CAMERA
        new PermissionsListener() {
          public void onPermantentlyDenied(ArrayList<String> deniedPermissions) {
            for (String permission : deniedPermissions) {
              Log.w("permission", "onPermantentlyDenied: " + permission);
            }
            Map<String,Object>model = new HashMap<String,Object>();
            model.put("permantentlyDenied", true);
            model.put("deniedPermissions", deniedPermissions);
            result.success(model);
          }
          public void onDenied(ArrayList<String> deniedPermissions) {
            for (String permission : deniedPermissions) {
              Log.w("permission", "onDenied: " + permission);
            }
            Map<String,Object>model = new HashMap<String,Object>();
            model.put("denied", true);
            model.put("deniedPermissions", deniedPermissions);
            result.success(model);
          }

          public void onGranted() {
            Log.i("permission", "onGranted");
            Map<String,Object>model = new HashMap<String,Object>();
            model.put("granted", true);
            result.success(model);
          }
        }
    );
  }

}
 