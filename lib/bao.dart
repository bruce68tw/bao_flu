//import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:base_flu/all.dart';
import 'all.dart';
import 'bao_detail.dart';
import 'stage_any.dart';
import 'stage_batch.dart';
import 'stage_step.dart';

class Bao extends StatefulWidget {
  const Bao({super.key});

  @override
  _BaoState createState() => _BaoState();
}

class _BaoState extends State<Bao> {
  //1.宣告變數
  bool _isOk = false; //state variables
  late PagerSrv _pagerSrv; //pager service
  late PagerDto<BaoRowDto> _pagerDto;

  @override
  void initState() {
    //2.分頁元件, set first, coz function parameter !!
    _pagerSrv = PagerSrv(rebuildA);

    //call before rebuild()
    super.initState();

    //3.讀取資料, call async rebuild
    Future.delayed(Duration.zero, () => rebuildA());
  }

  /// rebuild page
  Future rebuildA() async {
    //4.檢查初始狀態, check initial status
    if (!await Xp.isRegA(context)) return;

    //5.讀取資料庫, get rows & check
    await HttpUt.getJsonA(context, 'Bao/GetPage', true, _pagerSrv.getDtJson2(),
        (json) {
      if (json == null) return;

      _pagerDto = PagerDto<BaoRowDto>.fromJson(json, BaoRowDto.fromJson);
      _isOk = true;
      setState(() {}); //call build()
    });
  }

  //6.顯示畫面內容, get view body widget
  Widget getBody() {
    var rows = _pagerDto.rows;
    if (rows.isEmpty) return Xp.emptyMsg();

    var list = Xp.baosToWidgets(rows, rowsToTrails(rows));
    list.add(_pagerSrv.getWidget(_pagerDto.recordsFiltered));
    return ListView(children: list);
  }

  //7.畫面結構
  @override
  Widget build(BuildContext context) {
    //check status
    if (!_isOk) return Container();

    //return page
    return Scaffold(
      appBar: WG2.appBar('尋寶'),
      body: getBody(),
    );
  }

  /// onclick bao item
  /// @id Bao.Id
  void onDetail(String id) {
    ToolUt.openForm(context, BaoDetail(id: id));
  }

  //onOpen Stage, 開始尋寶關卡
  Future onPlayGameA(String baoId, String baoName, String replyType) async {
    await Xp.openStageA(context, baoId, baoName, replyType);
    /*
    if (replyType == ReplyTypeEstr.batch) {
      ToolUt.openForm(context, StageBatch(baoId: baoId, baoName: baoName, replyType: replyType));
    } else if (replyType == ReplyTypeEstr.step) {
      //讀取目前關卡資料
      await HttpUt.getJsonA(context, 'Stage/GetNowStepRow', false, {'baoId': baoId},
          (row) {
        //開啟畫面
        ToolUt.openForm(context, StageStep(baoId: baoId, baoName: baoName, stageId: row['Id'].toString(), replyType: replyType));
      });

    } else if (replyType == ReplyTypeEstr.anyStep) {
      ToolUt.openForm(context, StageAny(baoId: baoId, baoName: baoName));
    }
    */
  }

  /// get trailings widget
  /// @rows Bao list rows
  List<Widget> rowsToTrails(List<BaoRowDto> rows) {
    var widgets = <Widget>[];
    for (int i = 0; i < rows.length; i++) {
      var row = rows[i];
      var status = Xp.getAttendStatus(row.id);
      widgets.add((status == null)
          ? WG2.textBtn('看明細', () => onDetail(row.id))
          : (status == AttendEstr.run)
              ? WG2.textBtn('已參加',
                  () => onPlayGameA(row.id, row.name, row.replyType), Colors.green)
              : (status == AttendEstr.finish)
                  ? WG2.textBtn('已答對', () => onDetail(row.id))
                  : WG2.textBtn(
                      '已取消',
                      () => onPlayGameA(row.id, row.name, row.replyType),
                      Colors.red));
    }

    return widgets;
  }
} //class