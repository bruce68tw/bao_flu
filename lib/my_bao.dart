import 'package:flutter/material.dart';
import 'package:base_flu/all.dart';
import 'all.dart';

class MyBao extends StatefulWidget {
  const MyBao({super.key});

  @override
  MyBaoState createState() => MyBaoState();
}

class MyBaoState extends State<MyBao> {
  bool _isOk = false; //status
  late PagerSrv _pagerSrv; //pager service
  late PagerDto<BaoRowDto> _pagerDto;

  @override
  void initState() {
    //set first, coz function parameter !!
    _pagerSrv = PagerSrv(readRenderA);

    //call before reload()
    super.initState();
    Future.delayed(Duration.zero, () => readRenderA());
  }

  //reload page
  Future readRenderA() async {
    if (!await Xp.isRegA(context)) return;

    //get rows & check
    await HttpUt.getJsonA(context, 'MyBao/GetPage', true, _pagerSrv.getDtJson(),
        (json) {
      if (json == null) return;

      _pagerDto = PagerDto<BaoRowDto>.fromJson(json, BaoRowDto.fromJson);
      setState(() => _isOk = true);
    });
  }

  /// render form
  void render() {
    _isOk = true;
    setState(() {}); //call build()
  }

  /*
  ///get view body widget
  Widget getBody() {
    var rows = _pagerDto.rows;
    if (rows.isEmpty) return WG2.noRowMsg();

    var list = Xp.baosToWidgets(rows, rowsToTrails(rows));  //todo
    list.add(_pagerSrv.getWidget(_pagerDto.recordsFiltered));
    return ListView(children: list);
  }

  //get trailings widget
  List<Widget> rowsToTrails(List<BaoRowDto> rows) {
    var widgets = <Widget>[];
    for (int i = 0; i < rows.length; i++) {
      var row = rows[i];
      //var status = Xp.getAttendStatus(row.id);
      widgets.add((row.attendStatus == AttendStatusEstr.finish) ? WG.greenText('已答對  ') :
        (row.attendStatus == AttendStatusEstr.cancel) ? WG.redText('已取消  ') :
        row.baoStatus ? WG.btn('解題',() => Xp.playGameA(context, row.id, row.name, row.replyType)) :
        WG.textWG('未開始  '));
    }
    return widgets;
  }
  */

  @override
  Widget build(BuildContext context) {
    if (!_isOk) return Container();

    return Scaffold(
      appBar: WG2.appBar('我的尋寶'),
      body: Xp.getBaoBody(context, _pagerSrv, _pagerDto, render),
    );
  }
}//class
