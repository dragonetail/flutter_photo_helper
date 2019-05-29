package com.example.flutter_photo_helper;

import android.Manifest;
import android.app.Activity;
import android.content.ContentResolver;
import android.content.Context;
import android.database.Cursor;
import android.database.CursorIndexOutOfBoundsException;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ThumbnailUtils;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Build;
import android.provider.MediaStore;
import android.util.Log;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.lang.ref.WeakReference;
import java.nio.ByteBuffer;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import static android.media.ThumbnailUtils.OPTIONS_RECYCLE_INPUT;

public class ImageTask extends AsyncTask<String, Void, Void> {
  private static final String TAG = "image_task";

  private final ContentResolver contentResolver;
  private final BinaryMessenger messenger;
  private final String id;
  private final String assetId;
  private final int width;
  private final int height;
  private final int quality;
  private final String channelSuffix;

  public ImageTask(ContentResolver contentResolver,
                   BinaryMessenger messenger,
                   String id,
                   String assetId,
                   int width,
                   int height,
                   int quality,
                   String channelSuffix) {
    super();
    this.contentResolver = contentResolver;
    this.messenger = messenger;
    this.id = id;
    this.assetId = assetId;
    this.width = width;
    this.height = height;
    this.quality = quality;
    this.channelSuffix = channelSuffix;
  }

  @Override

  protected Void doInBackground(String... strings) {
    //         * MINI_KIND: 512 x 384 thumbnail
    //         * MICRO_KIND: 96 x 96 thumbnail
    if(width > 512 || width == -1){
      original();
    }else{
      miniThumbnails();
    }

    return null;
    }

  private void original() {
    try {
      Bitmap sourceBitmap = BitmapFactory.decodeFile(assetId);
      if (sourceBitmap == null) {
        throw new IllegalStateException("sourceBitmap is null: " + assetId);
      }
      /*
      int orientation = getOrientation(context, photoUri);
      if (orientation > 0) {
        Matrix matrix = new Matrix();
        matrix.postRotate(orientation);

        sourceBitmap = Bitmap.createBitmap(sourceBitmap, 0, 0, sourceBitmap.getWidth(),
            sourceBitmap.getHeight(), matrix, true);
      }
      */
      Bitmap bitmap = sourceBitmap;
      if (width >= -1) { //not original
        bitmap = ThumbnailUtils.extractThumbnail(bitmap, width, height);
        if (bitmap == null) {
          throw new IllegalStateException("sourceBitmap is null: " + assetId);
        }
      }

      ByteArrayOutputStream bos = new ByteArrayOutputStream();
      bitmap.compress(Bitmap.CompressFormat.JPEG, quality, bos);
      byte[] data = bos.toByteArray();

      final ByteBuffer buffer;
      //ByteBuffer.wrap() does not work, ref: https://github.com/flutter/flutter/issues/19849
      buffer = ByteBuffer.allocateDirect(data.length);
      buffer.put(data);
      this.messenger.send(FlutterPhotoHelperPlugin.PLUGIN_NAME + "/image/" + id + channelSuffix, buffer);
      buffer.clear();

      bitmap.recycle();
      sourceBitmap.recycle();
      bos.close();
    } catch (IOException e) {
      Log.d(TAG, "doInBackground", e);
      this.messenger.send(FlutterPhotoHelperPlugin.PLUGIN_NAME + "/image/" + id + channelSuffix, null);
    }
  }


  private void miniThumbnails() {
    try {
      /*
      //MediaStore.Images.Media._ID
      Cursor cursor = MediaStore.Images.Thumbnails.queryMiniThumbnail(
          contentResolver,
          Long.getLong(id),
          MediaStore.Images.Thumbnails.MINI_KIND,
          null);
      if (cursor != null && cursor.getCount() > 0) {
        cursor.moveToFirst();
        result = cursor.getString(cursor.getColumnIndexOrThrow(MediaStore.Images.Thumbnails.DATA));
        cursor.close();
      }
      return result;
      */
      Bitmap bitmap = MediaStore.Images.Thumbnails.getThumbnail(
          contentResolver,
          Long.parseLong(this.id),
          MediaStore.Images.Thumbnails.MINI_KIND,
          null);

      ByteArrayOutputStream bos = new ByteArrayOutputStream();
      bitmap.compress(Bitmap.CompressFormat.JPEG, quality, bos);
      byte[] data = bos.toByteArray();

      final ByteBuffer buffer;
      //ByteBuffer.wrap() does not work, ref: https://github.com/flutter/flutter/issues/19849
      buffer = ByteBuffer.allocateDirect(data.length);
      buffer.put(data);
      this.messenger.send(FlutterPhotoHelperPlugin.PLUGIN_NAME + "/image/" + id + channelSuffix, buffer);
      buffer.clear();

      bitmap.recycle();
      bos.close();
    } catch (IOException e) {
      Log.d(TAG, "doInBackground", e);
      this.messenger.send(FlutterPhotoHelperPlugin.PLUGIN_NAME + "/image/" + id + channelSuffix, null);
    }
  }


  /*
  private static int getOrientation(Context context, Uri photoUri) {
    Cursor cursor = null;
    try {
      cursor = context.getContentResolver().query(photoUri,
          new String[]{MediaStore.Images.ImageColumns.ORIENTATION}, null, null, null);

      if (cursor == null || cursor.getCount() != 1) {
        return -1;
      }

      cursor.moveToFirst();
      return cursor.getInt(0);
    } catch (CursorIndexOutOfBoundsException ignored) {

    } finally {
      if (cursor != null) {
        cursor.close();
      }
    }
    return -1;
  }
  */
}
 