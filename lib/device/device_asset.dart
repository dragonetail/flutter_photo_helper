enum AssetType { unknown, image, video, audio }

class DeviceAsset {
  /// android: full path
  /// ios: asset id
  String id;
  AssetType type;
  DateTime creationDate;
  DateTime modificationDate;
  int pixelWidth;
  int pixelHeight;
  double duration;
  double latitude;
  double longitude;

  DeviceAsset({this.id, this.type, this.creationDate,this.modificationDate, this.pixelWidth, this.pixelHeight, this.duration, this.latitude,this.longitude});

  @override
  int get hashCode {
    return id.hashCode;
  }

  @override
  bool operator ==(other) {
    if (other is! DeviceAsset) {
      return false;
    }
    return this.id == other.id;
  }

  @override
  String toString() {
    return "AssetEntity{id:$id}";
  }
}
