import 'package:flutter/material.dart';

class NotPermissionDialog extends StatefulWidget {
  const NotPermissionDialog();

  @override
  _NotPermissionDialogState createState() => _NotPermissionDialogState();
}

class _NotPermissionDialogState extends State<NotPermissionDialog> {
  //TODO i18n_provider
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text("没有访问相册的权限"),
      actions: <Widget>[
        FlatButton(
          onPressed: _onCancel,
          child: Text("取消"),
        ),
        FlatButton(
          onPressed: _onSure,
          child: Text("去开启"),
        ),
      ],
    );
  }

  void _onCancel() {
    Navigator.pop(context);
  }

  void _onSure() {
    Navigator.pop(context, true);
  }
}
