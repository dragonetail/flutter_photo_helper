package com.example.flutter_photo_helper;


import android.Manifest;
import android.annotation.TargetApi;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.util.Log;

import java.util.ArrayList;
import java.util.List;

import androidx.annotation.NonNull;
import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

import io.flutter.plugin.common.PluginRegistry;


public final class PermissionsHelper implements PluginRegistry.RequestPermissionsResultListener {

  private final Activity activity;

  /**
   * 最后一次申请权限的requestCode
   */
  private int requestCode;

  /**
   * 授权监听回调
   */
  private PermissionsListener permissionsListener;

  //方法缓存变量，回调检查用
  List<String> needToRequestPermissionsList = new ArrayList<>();


  public PermissionsHelper(PluginRegistry.Registrar registrar, int requestCode) {
    this.activity = registrar.activity();
    this.requestCode = requestCode;

    registrar.addRequestPermissionsResultListener(this);
  }

  @Override
  public boolean onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
    ArrayList<String> deniedPermissionsList = new ArrayList<>();
    ArrayList<String> permantentlyDeniedPermissionsList = new ArrayList<>();

    if (requestCode != this.requestCode) {
      return false; //不是本次的请求
    }

    if(permissions.length != needToRequestPermissionsList.size()){
      return false; //不是本次的请求
    }

    for (int i = 0; i < permissions.length; i++) {
      String permission = needToRequestPermissionsList.get(i);
      int grantResult = grantResults[i];
      if(!(grantResult == PackageManager.PERMISSION_GRANTED)){
        deniedPermissionsList.add(permission);

        //如果用户在过去拒绝了权限请求，并在权限请求系统对话框中选择了 Don’t ask again 选项，此方法将返回 false。如果设备规范禁止应用具有该权限，此方法也会返回 false
        if(!ActivityCompat.shouldShowRequestPermissionRationale(this.activity, permission)){
          permantentlyDeniedPermissionsList.add(permission);
        }
      }
    }


    if (!permantentlyDeniedPermissionsList.isEmpty()) {
      if (permissionsListener != null) {
        permissionsListener.onPermantentlyDenied(permantentlyDeniedPermissionsList);
      }
      return false;
    }else if (deniedPermissionsList.isEmpty()) {
      if (permissionsListener != null) {
        permissionsListener.onGranted();
      }
      return true;
    } else {
      if (permissionsListener != null) {
        permissionsListener.onDenied(deniedPermissionsList);
      }
      return false;
    }
  }


  @TargetApi(23)
  void requestPermissions(String[] permissions, PermissionsListener permissionsListener) {
    this.permissionsListener = permissionsListener;

    needToRequestPermissionsList = checkPermissions(permissions);
    if (needToRequestPermissionsList.isEmpty()) {
      if (permissionsListener != null) {
        permissionsListener.onGranted();
      }
      return;
    }

    String[] permissionsList = needToRequestPermissionsList.toArray(new String[0]);
    ActivityCompat.requestPermissions(activity, permissionsList, requestCode);
    for (String permission : permissionsList) {
      Log.d("requestPermissions", permission);
    }
  }

  private List<String> checkPermissions(String[] permissions) {
    if (Build.VERSION.SDK_INT >= 23) {
      List<String> needToRequestPermissionsList = new ArrayList<>();

      for (String permission : permissions) {
        if(ContextCompat.checkSelfPermission(activity,
            Manifest.permission.READ_EXTERNAL_STORAGE)
            != PackageManager.PERMISSION_GRANTED) {
          needToRequestPermissionsList.add(permission);
        }
      }
      return needToRequestPermissionsList;
    } else {
      return new ArrayList<>();
    }
  }

  static void getAppDetailSettingIntent(Activity activity) {
    Intent localIntent = new Intent();
    localIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK);
    //    if (Build.VERSION.SDK_INT >= 9) {
    localIntent.setAction("android.settings.APPLICATION_DETAILS_SETTINGS");
    localIntent.setData(Uri.fromParts("package", activity.getPackageName(), null));
    //    } else if (Build.VERSION.SDK_INT <= 8) {
    //      localIntent.setAction(Intent.ACTION_VIEW);
    //      localIntent.setClassName("com.android.settings", "com.android.settings.InstalledAppDetails");
    //      localIntent.putExtra("com.android.settings.ApplicationPkgName", context.getPackageName());
    //    }
    activity.startActivity(localIntent);
  }

}