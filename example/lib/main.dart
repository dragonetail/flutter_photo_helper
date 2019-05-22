import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import './asset_path_list_page.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  Intl.defaultLocale = 'zh_CN';
  initializeDateFormatting();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => AssetPathListPage(),
        AssetPathListPage.route: (context) => AssetPathListPage(),
      },
    );
  }
}
