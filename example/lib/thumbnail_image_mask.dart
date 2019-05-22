import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_photo_helper/flutter_photo_helper.dart';
import './selected_provider.dart';

class ThumbnailImageMask extends StatefulWidget {
  static const route = '/assetList';

  final int section;
  final int row;
  final DeviceAsset asset;
  final SelectedProvider selectedProvider;

  const ThumbnailImageMask({
    Key key,
    this.section,
    this.row,
    this.asset,
    this.selectedProvider,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ThumbnailImageMaskState();
  }
}

class _ThumbnailImageMaskState extends State<ThumbnailImageMask> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onScaleStart: (ScaleStartDetails details) {
        print(
            "ThumbnailImageMask.onScaleStart: $details ${details.focalPoint.dx}");
      },
      onScaleUpdate: (ScaleUpdateDetails details) {
        print(
            "ThumbnailImageMask.onScaleUpdate: $this $details ${details.focalPoint.dx}");
        var isSelected = widget.selectedProvider.containsEntity(widget.asset);
        if (!isSelected) {
          changeCheck(true, widget.asset);
        }
      },
      child: Stack(
        children: <Widget>[
          _buildMask(widget.selectedProvider.containsEntity(widget.asset)),
          _buildSelected(widget.asset),
        ],
      ),
    );
  }

  _buildMask(bool showMask) {
    return
        // IgnorePointer(
        //   child:
        AnimatedContainer(
      color: showMask ? Colors.black.withOpacity(0.5) : Colors.transparent,
      duration: Duration(milliseconds: 300),
      // ),
    );
  }

  Widget _buildSelected(DeviceAsset asset) {
    var currentSelected = widget.selectedProvider.containsEntity(asset);
    return Positioned(
      right: 0.0,
      width: 36.0,
      height: 36.0,
      child: GestureDetector(
        onTap: () {
          changeCheck(!currentSelected, asset);
        },
        behavior: HitTestBehavior.translucent,
        child: _buildText(asset),
      ),
    );
  }

  Widget _buildText(DeviceAsset asset) {
    var isSelected = widget.selectedProvider.containsEntity(asset);
    Widget child;
    BoxDecoration decoration;
    if (isSelected) {
      child = Text(
        (widget.selectedProvider.indexOfSelected(asset) + 1).toString(),
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.0,
          // color: options.textColor,
          color: Colors.black87,
        ),
      );
      // decoration = BoxDecoration(color: themeColor);
      decoration = BoxDecoration(color: Colors.green);
    } else {
      decoration = BoxDecoration(
        borderRadius: BorderRadius.circular(1.0),
        border: Border.all(
          //  color: themeColor,
          color: Colors.green,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        decoration: decoration,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  void changeCheck(bool value, DeviceAsset asset) {
    if (value) {
      widget.selectedProvider.addSelectEntity(asset);
    } else {
      widget.selectedProvider.removeSelectEntity(asset);
    }
    setState(() {});
  }
}
