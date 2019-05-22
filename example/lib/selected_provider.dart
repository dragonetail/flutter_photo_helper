import 'dart:async';
import 'package:flutter_photo_helper/flutter_photo_helper.dart';

abstract class SelectedProvider {
  List<DeviceAsset> selectedList = [];

  int get selectedCount => selectedList.length;

  bool containsEntity(DeviceAsset asset) {
    return selectedList.contains(asset);
  }

  int indexOfSelected(DeviceAsset asset) {
    return selectedList.indexOf(asset);
  }

  bool addSelectEntity(DeviceAsset asset) {
    if (containsEntity(asset)) {
      return false;
    }
    selectedList.add(asset);
    return true;
  }

  bool removeSelectEntity(DeviceAsset entity) {
    return selectedList.remove(entity);
  }

  void compareAndRemoveEntities(List<DeviceAsset> previewSelectedList) {
    var srcList = List.of(selectedList);
    selectedList.clear();
    srcList.forEach((entity) {
      if (previewSelectedList.contains(entity)) {
        selectedList.add(entity);
      }
    });
  }

  Future checkPickImageEntity() async {
    List<DeviceAsset> notExistsList = [];
    for (var asset in selectedList) {
      notExistsList.add(asset);
    }

    selectedList.removeWhere((e) {
      return notExistsList.contains(e);
    });
  }
}
