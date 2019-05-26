
class PermissionStatus {
  bool granted;
  bool permantentlyDenied;
  List<String> deniedPermissions;

  PermissionStatus._internal(
      this.granted, this.permantentlyDenied, this.deniedPermissions);

  factory PermissionStatus(Map<dynamic, dynamic> result) {
    if (result["granted"] != null) {
      return PermissionStatus._internal(true, false, null);
    } else {
      List<dynamic> deniedPermissions = result["deniedPermissions"];
      if (result["permantentlyDenied"]!= null) {
        return PermissionStatus._internal(false, true, deniedPermissions.cast<String>().toList());
      } else {
        return PermissionStatus._internal(false, false, deniedPermissions.cast<String>().toList());
      }
    }
  }
}
