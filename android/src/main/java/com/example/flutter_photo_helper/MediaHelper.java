package com.example.flutter_photo_helper;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodChannel;

import android.content.ContentResolver;
import android.util.Log;
import android.database.Cursor;
import android.provider.MediaStore;

import java.nio.ByteBuffer;
import java.util.HashMap;
import java.util.ArrayList;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.media.ThumbnailUtils;

import java.io.ByteArrayOutputStream;
import java.util.concurrent.*;
import java.util.concurrent.ThreadPoolExecutor;

public class MediaHelper {
  private static final String TAG = "media";

  private static final String COLUMN_NAME_COUNT = "COLUMN_NAME_COUNT";

  private static final int poolSize = 8;
  private static final ThreadPoolExecutor thumbPool = new ThreadPoolExecutor(poolSize, 1000, 200, TimeUnit.MINUTES, new ArrayBlockingQueue<Runnable>(5));

  private static final ThreadPoolExecutor threadPoolExecutor = new ThreadPoolExecutor(poolSize + 3, 1000, 200, TimeUnit.MINUTES, new ArrayBlockingQueue<Runnable>(poolSize + 3));

  public static void deviceAssetPathes(final ContentResolver contentResolver, final MethodChannel.Result result) {
    threadPoolExecutor.execute(new Runnable() {
      @Override
      public void run() {
        ArrayList<HashMap<String, Object>> pathes = new ArrayList<HashMap<String, Object>>();

        Cursor cursor = contentResolver
            .query(MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                new String[]{
                    MediaStore.Images.Media.BUCKET_ID,
                    MediaStore.Images.Media.BUCKET_DISPLAY_NAME,
                    MediaStore.Images.Media.DATA,
                    "COUNT(*) AS " + COLUMN_NAME_COUNT
                },
                " 1=1 ) GROUP BY (" + MediaStore.Images.Media.BUCKET_ID,
                null,
                COLUMN_NAME_COUNT + " DESC");
        assert cursor != null;
        while (cursor.moveToNext()) {
          //String path = cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.DATA));
          //Log.d(TAG, "path:" + path);
          //      if (path.endsWith(".gif")) {
          //        continue;
          //      }
          String bucketId =
              cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.BUCKET_ID));
          String bucketName =
              cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.BUCKET_DISPLAY_NAME));
          int count = cursor.getInt(cursor.getColumnIndex(COLUMN_NAME_COUNT));

          HashMap<String, Object> path = new HashMap<String, Object>();
          path.put("id", bucketId);
          path.put("name", bucketName);
          path.put("hasVideo", false);
          path.put("count", count);

          Log.d(TAG, "deviceAssetPathes:" + bucketId + ", " + bucketName + ", " + count);

          pathes.add(path);
        }
        cursor.close();
        Log.d(TAG, "deviceAssetPathes:" + pathes.size());
        result.success(pathes);
      }
    });
  }


  public static void deviceAssets(final String assetPathId, final ContentResolver contentResolver, final MethodChannel.Result result) {
    threadPoolExecutor.execute(new Runnable() {
      @Override
      public void run() {
        ArrayList<HashMap<String, Object>> assets = new ArrayList<HashMap<String, Object>>();


        Cursor cursor = contentResolver
            .query(MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                new String[]{
                    MediaStore.Images.Media._ID, // id
                    MediaStore.Images.Media.DATA, // 数据
                    //MediaStore.Images.Media.DISPLAY_NAME, // 显示的名字
                    MediaStore.Images.Media.LONGITUDE, // 经度
                    MediaStore.Images.Media.LATITUDE, // 维度
                    //MediaStore.Images.Media.MINI_THUMB_MAGIC, // id
                    //MediaStore.Images.Media.TITLE, // id
                    //MediaStore.Images.Media.BUCKET_ID, // dir id 目录
                    //MediaStore.Images.Media.BUCKET_DISPLAY_NAME, // dir name 目录名字
                    MediaStore.Images.Media.WIDTH, // 宽
                    MediaStore.Images.Media.HEIGHT, // 高
                    MediaStore.Images.Media.DATE_TAKEN //日期
                    //MediaStore.Images.Media.ORIENTATION

                },
                MediaStore.Images.Media.BUCKET_ID + "=?",
                new String[]{String.valueOf(assetPathId)},
                MediaStore.Images.Media.DATE_TAKEN + " DESC");
        assert cursor != null;
        while (cursor.moveToNext()) {
          String id =
              cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media._ID));
          String path =
              cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.DATA));
          //      String displayName =
          //          cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.DISPLAY_NAME));
          double longitude =
              cursor.getDouble(cursor.getColumnIndex(MediaStore.Images.Media.LONGITUDE));
          double latitude =
              cursor.getDouble(cursor.getColumnIndex(MediaStore.Images.Media.LATITUDE));
          //      String miniThumbMagic =
          //          cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.MINI_THUMB_MAGIC));
          //String title =
          //    cursor.getString(cursor.getColumnIndex(MediaStore.Images.Media.TITLE));
          int pixelWidth =
              cursor.getInt(cursor.getColumnIndex(MediaStore.Images.Media.WIDTH));
          int pixelHeight =
              cursor.getInt(cursor.getColumnIndex(MediaStore.Images.Media.HEIGHT));
          long creationDate =
              cursor.getLong(cursor.getColumnIndex(MediaStore.Images.Media.DATE_TAKEN));

          double duration = 0.0;

          HashMap<String, Object> asset = new HashMap<String, Object>();
          asset.put("id", id);
          asset.put("assetId", path);
          asset.put("type", "image");
          asset.put("creationDate", creationDate);
          asset.put("modificationDate", creationDate);
          asset.put("pixelWidth", pixelWidth);
          asset.put("pixelHeight", pixelHeight);
          asset.put("duration", duration);
          asset.put("latitude", latitude);
          asset.put("longitude", longitude);


          Log.d(TAG, "deviceAssets:" + path);

          assets.add(asset);
        }
        cursor.close();
        Log.d(TAG, "deviceAssets:" + assets.size());
        result.success(assets);
      }
    });
  }

}
