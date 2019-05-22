import 'package:flutter/material.dart';
import 'package:flutter_photo_helper/flutter_photo_helper.dart';
import './selected_provider.dart';
import './thumbnail_image_mask.dart';
import 'package:transparent_image/transparent_image.dart';
import './platform_image_provider.dart';

class ThumbnailImageItem extends StatelessWidget {
  final int section;
  final int row;
  final DeviceAsset asset;
  final SelectedProvider selectedProvider;
  final Function(DeviceAsset asset, int section, int row) onTap;

  const ThumbnailImageItem({
    Key key,
    this.section,
    this.row,
    this.asset,
    this.selectedProvider,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GridTile(
        child: Card(
          margin: EdgeInsets.all(0.0),
          child: GestureDetector(
            onTap: () => onTap(asset, section, row),
            child: Stack(
              children: <Widget>[
                _buildImageItem(context),
                ThumbnailImageMask(
                  section: section,
                  row: row,
                  asset: asset,
                  selectedProvider: selectedProvider,
                ),
              ],
            ),
          ),
        ),
        footer: Container(
          color: Colors.white.withOpacity(0.5),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Grid tile $section:$row',
              style: const TextStyle(color: Colors.black),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImageItem(BuildContext context) {
    return Stack(
      children: <Widget>[
        //TODO backboardd 100% CPU
        //Center(child: CircularProgressIndicator()),
        Center(
          child: FadeInImage(
            placeholder: MemoryImage(kTransparentImage),
            image: PlatformImageProvider(asset.id,
                width: 200, height: 200),
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          ),
        ),
      ],
    );
  }
}
