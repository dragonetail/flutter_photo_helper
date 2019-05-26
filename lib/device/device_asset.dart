enum AssetType { unknown, image, video, audio }

class DeviceAsset {
  String id;
  String assetId;
  AssetType type;
  DateTime creationDate;
  DateTime modificationDate;
  int pixelWidth;
  int pixelHeight;
  double duration;
  double latitude;
  double longitude;

  DeviceAsset(
      {this.id,
      this.assetId,
      this.type,
      this.creationDate,
      this.modificationDate,
      this.pixelWidth,
      this.pixelHeight,
      this.duration,
      this.latitude,
      this.longitude});

  @override
  int get hashCode {
    return assetId.hashCode;
  }

  @override
  bool operator ==(other) {
    if (other is! DeviceAsset) {
      return false;
    }
    return this.assetId == other.assetId;
  }

  @override
  String toString() {
    return "AssetEntity{assetId:$assetId}";
  }
}
