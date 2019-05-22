import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_photo_helper/flutter_photo_helper.dart';

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
      appBar: AppBar(
        title: Text('Photo Asset'),
      ),
      body: PageView.builder(
        controller: pageController,
        itemBuilder: _buildItem,
        itemCount: widget.assets.length,
        onPageChanged: _onPageChanged,
      ),
    );
  }

  Widget _buildItem(BuildContext context, int index) {
    var asset = widget.assets[index];
    return BigPhotoImage(
      asset: asset,
      loadingWidget: _buildLoadingWidget(asset),
    );
  }

  Widget _buildLoadingWidget(DeviceAsset asset) {
    return Center(
      child: Container(
        width: 30.0,
        height: 30.0,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(Colors.green),
        ),
      ),
    );
  }

  void _onPageChanged(int value) {
    //pageChangeController.add(value);
  }
}

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
    print("requestThumbnail: ${widget.asset.id}");
    return FutureBuilder(
      future:
           FlutterPhotoHelper.thumbnail(widget.asset.id, width, height),
      builder: (BuildContext context, AsyncSnapshot<ByteData> snapshot) {
        var futureData = snapshot.data;
        if (snapshot.connectionState == ConnectionState.done &&
            futureData != null) {
          print(
              "requestThumbnail' result: ${widget.asset.id}, ${futureData.lengthInBytes}");
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
