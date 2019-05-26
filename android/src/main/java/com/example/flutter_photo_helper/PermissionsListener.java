package com.example.flutter_photo_helper;

import java.util.ArrayList;

public interface PermissionsListener {
    void onDenied(ArrayList<String> deniedPermissions);
    void onPermantentlyDenied(ArrayList<String> deniedPermissions);
    void onGranted();
}