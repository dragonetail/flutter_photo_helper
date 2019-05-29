import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_photo_helper/flutter_photo_helper.dart';
import './transparent_image.dart';
import './platform_image_provider.dart';
import 'dart:typed_data';

class ImageViewerPage extends StatefulWidget {
  static const route = '/imageViewer';

  final int initIndex;
  final List<DeviceAsset> assets;

  const ImageViewerPage({
    Key key,
    this.assets,
    this.initIndex = 0,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ImageViewerState();
  }
}

class _ImageViewerState extends State<ImageViewerPage> {
  PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(
      initialPage: widget.initIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Photo Asset'),
        actions: <Widget>[
          new IconButton(
            // action button
            icon: new Icon(Icons.directions_car),
            onPressed: _testThumbnailFile,
          ),
          new IconButton(
            // action button
            icon: new Icon(Icons.directions_bike),
            onPressed: _testOriginalFile,
          ),
          new PopupMenuButton<Choice>(
            // overflow menu
            onSelected: (choice) {},
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return new PopupMenuItem<Choice>(
                  value: choice,
                  child: ListTile(
                      leading: Icon(choice.icon), title: Text(choice.title)),
                );
              }).toList();
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: pageController,
        itemBuilder: _buildItem,
        itemCount: widget.assets.length,
        //onPageChanged: _onPageChanged,
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    var width = (MediaQuery.of(context).size.width * 2).floor();
    var height = (MediaQuery.of(context).size.height * 2).floor();

    var asset = widget.assets[index];
    return 
    // FadeInImage(
    //   placeholder: MemoryImage(kTransparentImage),
    //   image: PlatformImageProvider(asset.id, asset.assetId,
    //       width: width, height: height, scale: 1.0),
    //   fit: BoxFit.cover,
    //   width: MediaQuery.of(context).size.width,
    //   height: MediaQuery.of(context).size.height,
    //   fadeOutDuration: const Duration(milliseconds: 0),
    //   fadeOutCurve: Curves.easeOut,
    //   fadeInDuration: const Duration(milliseconds: 0),
    //   fadeInCurve: Curves.elasticIn,
    // );
        BigPhotoImage(
      asset: asset,
      //loadingWidget: _buildLoadingWidget(),
    );
  }

  void _testThumbnailFile() async {
    int index = pageController.page.toInt();
    DeviceAsset asset = widget.assets[index];
    File thumbFile = await FlutterPhotoHelper.thumbnailFile(
        asset.id, asset.assetId, 200, 200);

    print(thumbFile.path);

    _listTemp("/thumb");
  }

  void _testOriginalFile() async {
    int index = pageController.page.toInt();
    DeviceAsset asset = widget.assets[index];
    File originalFile =
        await FlutterPhotoHelper.originalFile(asset.id, asset.assetId);

    print(originalFile.path);
    _listTemp("/original");
  }

  void _listTemp(String subDir) {
    var systemTempDir = Directory(Directory.systemTemp.path + subDir);
    systemTempDir
        .list(recursive: true, followLinks: false)
        .listen((FileSystemEntity entity) {
      print(entity.path);
    });
  }
}

class Choice {
  const Choice({this.title, this.icon});
  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Car', icon: Icons.directions_car),
  const Choice(title: 'Bicycle', icon: Icons.directions_bike),
  const Choice(title: 'Boat', icon: Icons.directions_boat),
  const Choice(title: 'Bus', icon: Icons.directions_bus),
  const Choice(title: 'Train', icon: Icons.directions_railway),
  const Choice(title: 'Walk', icon: Icons.directions_walk),
];


class BigPhotoImage extends StatefulWidget {
  final DeviceAsset asset;
  final Widget loadingWidget;

  const BigPhotoImage({
    Key key,
    this.asset,
    this.loadingWidget,
  }) : super(key: key);

  @override
  _BigPhotoImageState createState() => _BigPhotoImageState();
}

class _BigPhotoImageState extends State<BigPhotoImage>
    with AutomaticKeepAliveClientMixin {
  Widget get loadingWidget {
    return widget.loadingWidget ?? Container();
  }

  @override
  Widget build(BuildContext context) {
    var width = (MediaQuery.of(context).size.width *2).floor();
    var height = (MediaQuery.of(context).size.height * 2).floor();
    print("original: ${widget.asset.id}");
    return FutureBuilder(
      future:
           FlutterPhotoHelper.thumbnail(widget.asset.id, widget.asset.assetId, width, height),
           //FlutterPhotoHelper.original(widget.asset.id, widget.asset.assetId),
      builder: (BuildContext context, AsyncSnapshot<ByteData> snapshot) {
        var futureData = snapshot.data;
        if (snapshot.connectionState == ConnectionState.done &&
            futureData != null) {
          print(
              "original' result: ${widget.asset.assetId}, ${futureData.lengthInBytes}");
          Uint8List data = futureData.buffer.asUint8List();
          return Image.memory(
            data,
            fit: BoxFit.contain,
            width: double.infinity,
            height: double.infinity,
          );
        }
        return loadingWidget;
      },
    );
  }

  @override
  bool get wantKeepAlive => true;
}