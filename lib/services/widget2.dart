//import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:base_flu/all.dart';

/// static class(widget)
class WG2 {
  static const pagePad = EdgeInsets.all(20);

  ///get appBar widget<br>
  ///@title title string
  static AppBar appBar(String title) {
    return AppBar(
      title: WG.textWG(title, color: Colors.white),
      toolbarHeight: 40,
      backgroundColor: Colors.orange,
    );
  }

  ///return empty message(無任何資料)
  static Widget noRowMsg() {
    return const Center(
      child: Text(
        '目前無任何資料。',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 18,
          color: Colors.red,
    )));
  }

  //=== temp add below ===
  ///display label & text
  static Column labelText(String label, String text, [Color? color]) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          WG.textWG(label, color: Colors.grey),
          WG.textWG(text, color: color),
          WG2.divider(),
        ]);
  }

  ///input field style
  static TextStyle inputStyle([bool status = true]) {
    return TextStyle(
      fontSize: 18,
      color: status ? Colors.black : Colors.grey,
    );
  }

  ///return label
  static InputDecoration inputDecore(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        fontSize: 16,
        color: Colors.grey,
        height: 0.8,
      ),
    );
  }

  ///create TextButton<br>
  ///VoidCallback is need, onPressed on ()=> before function !!
  static TextButton linkBtn(String text,
      [VoidCallback? fnOnClick, Color? color]) {
    var status = (fnOnClick != null);
    var color2 = (!status) ? Colors.grey : 
      (color == null) ? Colors.blue : color;
    return TextButton(
      onPressed: status ? fnOnClick : null,
      child: WG.textWG(text, color: color2),
    );
  }

  ///one button at form end(畫面下方, 水平置中)
  static Container endBtn(String text,
      [VoidCallback? fnOnClick, double? top]) {
    var status = (fnOnClick != null);
    return Container(
      alignment: Alignment.center,
      margin: (top == null)
        ? WG.gap(15)
        : EdgeInsets.only(top: top, right: 15, bottom: 15, left: 15),
      child: ElevatedButton(
        onPressed: status ? fnOnClick : null,
        child: WG.textWG(text),
      ));
  }
  
  static Divider divider() {
    return WG.divider(15);
  }
} //class
