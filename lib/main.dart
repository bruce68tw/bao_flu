//import 'dart:io';
//import 'package:base_flu/all.dart';
import 'package:flutter/material.dart';
import 'bao.dart';
import 'msg.dart';
import 'my_data.dart';
//import 'package:http/io_client.dart';
//import 'package:flutter/services.dart';
//import 'dart:convert';
//import 'package:http/http.dart' as http;

//http.Client? _http;

void main() {
  // 忽略 HTTPS 憑證驗證
  //HttpOverrides.global = MyHttpOverrides();
  runApp(const MainApp());
  //await initHttpA();
  //Future.delayed(Duration.zero, () => initHttpA());
}

/*
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)..badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;
  }
}

Future initHttpA() async {
  if (FunUt.http2 == null) {
    // 從 assets 中加載憑證
    final sslCert = await rootBundle.load('assets/eden.org.tw.pem');

    // 建立一個 SecurityContext 並載入 PEM 憑證
    SecurityContext context = SecurityContext.defaultContext;
    context.setTrustedCertificatesBytes(sslCert.buffer.asUint8List());

    // 使用自定義的 SecurityContext 初始化 HttpClient
    HttpClient httpClient = HttpClient(context: context);

    // 創建 client 並儲存
    FunUt.http2 = httpClient;
  }
  //return FunUt.http2!;
}

Future<http.client> createCustomHttpClient() async {
  // 從 assets 中加載憑證
  final sslCert = await rootBundle.load('assets/certificate.pem');

  // 建立一個 SecurityContext 並載入 PEM 憑證
  SecurityContext context = SecurityContext.defaultContext;
  context.setTrustedCertificatesBytes(sslCert.buffer.asUint8List());

  // 使用自定義的 SecurityContext 初始化 HttpClient
  HttpClient httpClient = HttpClient(context: context);
  return IOClient(httpClient);
}
*/

/// This Widget is the main application widget.
class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Main(),
    );
  }
} //MyApp

class Main extends StatefulWidget {
  const Main({super.key});

  @override
  MainState createState() => MainState();
}

class MainState extends State<Main> {
  //1.控制要顯示的畫面
  int _index = 0;
  final _items = <Widget>[
    const Bao(),
    const Msg(),
    const MyData(),
  ];

  @override
  Widget build(BuildContext context) {
    //2.主畫面內容
    return Scaffold(
      body: SafeArea(
        child: _items.elementAt(_index),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          item('尋寶', Icons.redeem),
          item('最新消息', Icons.unsubscribe),
          item('我的資料', Icons.person),
        ],
        currentIndex: _index,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        onTap: onItem,
        //type: BottomNavigationBarType.shifting,
        //iconSize: 40,
        //elevation: 5
      ),
    );
  }

  ///get icon item
  BottomNavigationBarItem item(String label, IconData icon) {
    return BottomNavigationBarItem(
      icon: Icon(icon),
      label: label,
    );
  }

  //onclick item
  void onItem(int index) {
    setState(() => _index = index);
  }
} //class