import 'package:base_flu/all.dart';
import 'package:flutter/material.dart';
import 'all.dart';
import 'user_edit.dart';
import 'my_bao.dart';

class MyData extends StatelessWidget {
  const MyData({super.key});

  /// onclick myBao
  void onMyBao(BuildContext context) {
    ToolUt.openForm(context, const MyBao());
  }

  /// onclick edit user info
  void onEdit(BuildContext context) {
    ToolUt.openForm(context, const UserEdit());
  }

  SizedBox preIcon(IconData icon) {
    return SizedBox(
      width: 20,
      height: 20,
      //alignment: Alignment.center,
      child: Icon(icon, color: Colors.blue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WG2.appBar('我的資料'),
      body: ListView(
        children: <Widget>[
          ListTile(
              leading: preIcon(Icons.redeem),
              title: Align(
                alignment: Alignment.centerLeft,
                child: WG2.textBtn('我的尋寶', () => onMyBao(context)),
              )),
          WG2.divider(),
          ListTile(
              leading: preIcon(Icons.edit),
              title: Align(
                alignment: Alignment.centerLeft,
                child: WG2.textBtn('維護基本資料', () => onEdit(context)),
              )),
          WG2.divider(),
        ],
      ),
    );
  }
} //class
