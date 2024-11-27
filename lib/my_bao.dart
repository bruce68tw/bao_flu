import 'package:flutter/material.dart';
import 'package:base_flu/all.dart';
import 'all.dart';
import 'stage_step.dart';

class MyBao extends StatefulWidget {
  const MyBao({super.key});

  @override
  _MyBaoState createState() => _MyBaoState();
}

class _MyBaoState extends State<MyBao> {
  bool _isOk = false; //status
  late PagerSrv _pagerSrv; //pager service
  late PagerDto<BaoRowDto> _pagerDto;

  @override
  void initState() {
    //set first, coz function parameter !!
    _pagerSrv = PagerSrv(rebuildA);

    //call before reload()
    super.initState();
    Future.delayed(Duration.zero, () => rebuildA());
  }

  //reload page
  Future rebuildA() async {
    if (!await Xp.isRegA(context)) return;

    //get rows & check
    await HttpUt.getJsonA(
        context, 'MyBao/GetPage', true, _pagerSrv.getDtJson2(), (json) {
      if (json == null) return;

      _pagerDto = PagerDto<BaoRowDto>.fromJson(json, BaoRowDto.fromJson);
      setState(() => _isOk = true);
    });
  }

  ///get view body widget
  Widget getBody() {
    var rows = _pagerDto.rows;
    if (rows.isEmpty) return Xp.emptyMsg();

    var list = Xp.baosToWidgets(rows, rowsToTrails(rows));
    list.add(_pagerSrv.getWidget(_pagerDto.recordsFiltered));
    return ListView(children: list);
  }

  //get trailings widget
  List<Widget> rowsToTrails(List<BaoRowDto> rows) {
    var widgets = <Widget>[];
    for (int i = 0; i < rows.length; i++) {
      var row = rows[i];
      var status = Xp.getAttendStatus(row.id);
      widgets.add((status == AttendEstr.finish)
          ? WG2.textBtn(
              '已答對',
              () => ToolUt.openForm(context,
                  StageStep(baoId: row.id, baoName: row.name, editable: false)))
          : WG2.textBtn(
              '解題', () => onAnswer(row.answerType, row.id, row.name)));
    }
    return widgets;
  }

  //onclick answer
  void onAnswer(String answerType, String baoId, String baoName) {
    Xp.openStage(context, answerType, baoId, baoName);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOk) return Container();

    return Scaffold(
      appBar: WG2.appBar('我的尋寶'),
      body: getBody(),
    );
  }
}//class
