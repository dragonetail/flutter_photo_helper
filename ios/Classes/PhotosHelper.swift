import UIKit
import Photos
import Flutter

public class PhotosHelper: NSObject {
  static let imageManager = PHCachingImageManager() //PHImageManager.default()
  static let fileManager = FileManager.default

  public static func permissions(_ result: @escaping FlutterResult) {
    DispatchQueue.global(qos: .userInitiated).async {
      let authorizationStatus = PHPhotoLibrary.authorizationStatus()
      if authorizationStatus == .authorized {
        DispatchQueue.main.async {
          result(true)
        }
      } else {
        //print("Start to requestAuthorization...")
        PHPhotoLibrary.requestAuthorization({ status in
          //print("Result of requestAuthorization: \(status)")
          if status == .authorized {
            DispatchQueue.main.async {
              result(true)
            }
          } else {
            DispatchQueue.main.async {
              result(false)
            }
          }
        })
      }
    }
  }

  public static func deviceAssetPathes(_ result: @escaping FlutterResult) {
    DispatchQueue.global(qos: .userInitiated).async {
      //let types: [PHAssetCollectionType] = [.smartAlbum, .album, .moment]
      let types: [PHAssetCollectionType] = [.smartAlbum, .album]

      let fetchResults: [PHFetchResult<PHAssetCollection>] = types.map {
        return PHAssetCollection.fetchAssetCollections(with: $0, subtype: .any, options: nil)
      }

      var collections = [NSDictionary]()
      for fetchResult in fetchResults {
        fetchResult.enumerateObjects({ (collection, _, _) in
          collections.append([
            "id": collection.localIdentifier,
            "name": collection.localizedTitle ?? "-",
            "hasVideo": false,
            "count": collection.estimatedAssetCount,
          ])
        })
      }
      DispatchQueue.main.async {
        result(collections)
      }
    }
  }

  public static func deviceAssets(_ assetPathId: String, _ result: @escaping FlutterResult) {
    DispatchQueue.global(qos: .userInitiated).async {
      let fetchResult: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(withLocalIdentifiers: [assetPathId], options: nil)
      guard fetchResult.count == 1 else {
        DispatchQueue.main.async {
          result([NSDictionary]())
        }
        return
      }
      let collection = fetchResult.firstObject!

      var assets = [NSDictionary]()

      let fetchOptions = PHFetchOptions()
      fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
      let itemsFetchResult = PHAsset.fetchAssets(in: collection, options: fetchOptions)
      itemsFetchResult.enumerateObjects({ (asset, _, _) in
        assets.append([
          "id": asset.localIdentifier,
          "type": asset.mediaType.rawValue,
          "creationDate": Int((asset.creationDate?.timeIntervalSince1970 ?? 0) * 1000),
          "modificationDate": Int((asset.modificationDate?.timeIntervalSince1970 ?? 0) * 1000),
          "pixelWidth": asset.pixelWidth,
          "pixelHeight": asset.pixelHeight,
          "duration": Double(asset.duration),
          "latitude": Double(asset.location?.coordinate.latitude ?? -1),
          "longitude": Double(asset.location?.coordinate.longitude ?? -1),
        ])
      })
      DispatchQueue.main.async {
        result(assets)
      }
    }
  }

  public static func thumbnail(_ assetId: String, _ width: Int, _ height: Int, _ quality: Int, _ result: @escaping FlutterResult, _ messenger: FlutterBinaryMessenger) {
    requestImage(assetId, CGSize(width: width, height: height), quality, "thumb", result, messenger)
  }

  public static func original(_ assetId: String, _ quality: Int, _ result: @escaping FlutterResult, _ messenger: FlutterBinaryMessenger) {
    requestImage(assetId, PHImageManagerMaximumSize, quality, "original", result, messenger)
  }

  fileprivate static func requestImage(_ assetId: String, _ targetSize: CGSize, _ quality: Int, _ dataBackChannelSuffix: String, _ result: @escaping FlutterResult, _ messenger: FlutterBinaryMessenger?) {
    DispatchQueue.global(qos: .userInitiated).async {
      let options = PHImageRequestOptions()

      options.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
      options.isSynchronous = false
      options.isNetworkAccessAllowed = true
      options.resizeMode = .fast

      let fetchResult: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil)
      guard fetchResult.count == 1 else {
        DispatchQueue.main.async {
          if let _ = messenger {
            result(false)
          } else {
            result(nil)
          }
        }
        return
      }

      let asset: PHAsset = fetchResult.firstObject!;

      //TODO
      //manager.cancelImageRequest(<#T##requestID: PHImageRequestID##PHImageRequestID#>)

//      manager.requestImageData(for: <#T##PHAsset#>, options: <#T##PHImageRequestOptions?#>, resultHandler: <#T##(Data?, String?, UIImage.Orientation, [AnyHashable : Any]?) -> Void#>)
//
//      manager.requestImage(for: <#T##PHAsset#>, targetSize: <#T##CGSize#>, contentMode: <#T##PHImageContentMode#>, options: <#T##PHImageRequestOptions?#>, resultHandler: <#T##(UIImage?, [AnyHashable : Any]?) -> Void#>)


      let requestId: PHImageRequestID = imageManager.requestImage(
        for: asset,
        targetSize: targetSize,
        contentMode: PHImageContentMode.aspectFill,
        options: options,
        resultHandler: {
          (image: UIImage?, info) in
          let imageData: Data? = image?.jpegData(compressionQuality: CGFloat(quality / 100))

          if let messenger = messenger {
            messenger.send(onChannel: "\(SwiftFlutterPhotoHelperPlugin.plugin_name)/image/\(assetId).\(dataBackChannelSuffix)", message:
              imageData)
          } else {
            let filePath: String = writeToFile(assetId, dataBackChannelSuffix, imageData)
            result(filePath)
          }
        })

      DispatchQueue.main.async {
        if(PHInvalidImageRequestID == requestId) {
          if let _ = messenger {
            result(false)
          } else {
            result(nil)
          }
        } else {
          if let _ = messenger {
            result(true)
          }
        }
      }
    }
  }

  fileprivate static func writeToFile(_ assetId: String, _ dataBackChannelSuffix: String, _ imageData: Data?) -> String {
    let url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("\(assetId).\(dataBackChannelSuffix)")
    let filePath: String = url.absoluteString
    fileManager.createFile(atPath: filePath, contents: imageData, attributes: nil)

    return filePath
  }

  public static func thumbnailFile(_ assetId: String, _ width: Int, _ height: Int, _ quality: Int, _ result: @escaping FlutterResult) {
    requestImage(assetId, CGSize(width: width, height: height), quality, "thumb", result, nil)
  }

  public static func originalFile(_ assetId: String, _ quality: Int, _ result: @escaping FlutterResult) {
    requestImage(assetId, PHImageManagerMaximumSize, quality, "original", result, nil)
  }

}
