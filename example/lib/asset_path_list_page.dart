import 'package:flutter/material.dart';
import 'package:flutter_photo_helper/flutter_photo_helper.dart';
import './asset_list_page.dart';
import './not_permission_dialog.dart';

class AssetPathListPage extends StatefulWidget {
  static const route = '/assetPathList';

  @override
  State<StatefulWidget> createState() {
    return new _AssetPathListState();
  }
}

class _AssetPathListState extends State<AssetPathListPage> {
  List<DeviceAssetPath> _deviceAssetPathes = List<DeviceAssetPath>();

  @override
  void initState() {
    super.initState();
    _loadAssetPathes();
  }

  void _loadAssetPathes() async {
    PermissionStatus status = await FlutterPhotoHelper.permissions;
    if (!status.granted) {
      var result = await showDialog(
        context: context,
        builder: (ctx) => NotPermissionDialog(),
      );
      if (result == true) {
        FlutterPhotoHelper.openSetting();
      }
      return null;
    }

    _deviceAssetPathes = await FlutterPhotoHelper.deviceAssetPathes;

    FlutterPhotoHelper.startHandleNotify();

    if (this.mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Photo Asset Path'),
      ),
      body: _buildAssetPathList(),
    );
  }

  Widget _buildAssetPathList() {
    return new ListView.builder(
      itemCount: _deviceAssetPathes.length * 2,
      padding: const EdgeInsets.all(10.0),
      itemBuilder: (context, i) {
        if (i.isOdd) return Divider();
        final index = i ~/ 2;
        return _buildRow(_deviceAssetPathes[index]);
      },
    );
  }

  Widget _buildRow(DeviceAssetPath path) {
    return new ListTile(
        title: new Text("${path.name} (${path.count})",
            style: TextStyle(fontSize: 18.0)),
        subtitle: new Text(path.id),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (ctx) {
              return AssetListPage(
                assetPathId: path.id,
              );
            }),
          );
        });
  }
}
