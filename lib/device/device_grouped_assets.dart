import './device_asset.dart';

class DeviceGroupedAssets {
  String groupTitle;
  List<DeviceAsset> assets;

  DeviceGroupedAssets({this.groupTitle, this.assets});

  @override
  int get hashCode {
    return groupTitle.hashCode;
  }

  @override
  bool operator ==(other) {
    if (other is! DeviceAsset) {
      return false;
    }
    return this.groupTitle == other.groupTitle;
  }

  @override
  String toString() {
    return "AssetEntity{groupTitle:$groupTitle}";
  }
}
