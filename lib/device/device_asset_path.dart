class DeviceAssetPath {
  /// android: content provider database _id column
  /// ios: collection localIdentifier
  String id;

  /// android: path name
  /// ios: photos collection name
  String name;

  /// android:
  /// ios: estimatedAssetCount
  int count;

  DeviceAssetPath({this.id, this.name, this.count});

  @override
  bool operator ==(other) {
    if (other is! DeviceAssetPath) {
      return false;
    }
    return this.id == other.id;
  }

  @override
  int get hashCode {
    return this.id.hashCode;
  }

  @override
  String toString() {
    return "AssetPathEntity{id:$id}";
  }
}
