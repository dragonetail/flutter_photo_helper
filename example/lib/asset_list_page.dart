import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_photo_helper/flutter_photo_helper.dart';
import 'package:flutter_sticky_header/flutter_sticky_header.dart';
import './thumbnail_image_item.dart';
import './selected_provider.dart';
import './image_viewer_page.dart';

class AssetListPage extends StatefulWidget {
  static const route = '/assetList';

  final String _assetPathId;

  AssetListPage({@required String assetPathId}) : _assetPathId = assetPathId;

  @override
  State<StatefulWidget> createState() {
    return _AssetListState();
  }
}

class _AssetListState extends State<AssetListPage> with SelectedProvider {
  List<DeviceGroupedAssets> _groupedAssets = List<DeviceGroupedAssets>();
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _loadAssetes(context);
  }

  void _loadAssetes(BuildContext context) async {
    final String assetPathId = widget._assetPathId;
    List<DeviceGroupedAssets> assets =
        await FlutterPhotoHelper.deviceAssets(assetPathId);

    if (this.mounted) {
      int counts = assets.length;
      if (counts <= 6) {
        _groupedAssets = assets;
        setState(() {});
      } else {
        _groupedAssets = assets.sublist(0, 6);
        setState(() {});

        Future.delayed(new Duration(milliseconds: 500), () {
          _groupedAssets = assets;
          setState(() {});
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:
          // GestureDetector(
          //   onScaleStart: (ScaleStartDetails details) {
          //     print("onScaleStart: $details");

          //     context.visitChildElements((element) {
          //       print("element: $element");
          //       //var renderObject = element.findRenderObject();
          //     });
          //   },
          //   onScaleUpdate: (ScaleUpdateDetails details) {
          //     print(
          //         "onScaleUpdate: $details ${details.focalPoint.dx} ${_scrollController.offset}");
          //     // details.focalPoint.dx
          //   },
          //   onScaleEnd: (ScaleEndDetails details) {
          //     print("onScaleEnd: $details");
          //   },
          // child:
          CustomScrollView(
        controller: _scrollController,
        slivers: _buildSlivers(context),
      ),
    );
  }

  List<Widget> _buildSlivers(BuildContext context) {
    List<Widget> slivers = List<Widget>();
    slivers.add(SliverAppBar(
      backgroundColor: Colors.blue.withOpacity(0.5),
      title: Text('Photo Asset'),
      floating: true,
      pinned: false,
    ));

    slivers.addAll(_buildGrids(context));
    return slivers;
  }

  List<Widget> _buildGrids(BuildContext context) {
    int crossAxisCount = MediaQuery.of(context).size.width <= 450.0
        ? 3
        : MediaQuery.of(context).size.width >= 1000.0 ? 5 : 4;

    return List.generate(_groupedAssets.length, (section) {
      return SliverStickyHeader(
        header: _buildHeader(section),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 2.0,
              mainAxisSpacing: 2.0),
          delegate: SliverChildBuilderDelegate(
            (context, row) => _buildItem(context, section, row),
            childCount: _groupedAssets[section].assets.length,
          ),
        ),
      );
    });
  }

  Widget _buildHeader(int section) {
    return Container(
      height: 48.0,
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 16.0),
      alignment: Alignment.centerLeft,
      child: Text(
        _groupedAssets[section].groupTitle,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  Widget _buildItem(BuildContext context, int section, int row) {
    var assets = _groupedAssets[section].assets;
    DeviceAsset asset = assets[row];
    //print("_buildItem: $section:$row, ${asset.id}");

    return ThumbnailImageItem(
      section: section,
      row: row,
      asset: asset,
      selectedProvider: this,
      onTap: _onItemClick,
    );
  }

  void _onItemClick(DeviceAsset asset, int section, int row) {
    var assets = List<DeviceAsset>();
    _groupedAssets.map((ga) => ga.assets).forEach((list) {
      assets = assets..addAll(list);
    });

    DeviceAsset asset = _groupedAssets[section].assets[row];
    int initIndex = assets.indexOf(asset);

    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) {
        return ImageViewerPage(
          assets: assets,
          initIndex: initIndex,
        );
      }),
    );
  }
}
