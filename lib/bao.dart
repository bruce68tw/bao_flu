//import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:base_flu/all.dart';
import 'all.dart';
import 'bao_detail.dart';

class Bao extends StatefulWidget {
  const Bao({super.key});

  @override
  BaoState createState() => BaoState();
}

class BaoState extends State<Bao> {
  //1.宣告變數
  bool _isOk = false; //state variables
  late PagerSrv _pagerSrv; //pager service
  late PagerDto<BaoRowDto> _pagerDto;

  @override
  void initState() {
    //2.分頁元件, set first, coz function parameter !!
    _pagerSrv = PagerSrv(readRenderA);

    //call before rebuild()
    super.initState();

    //3.讀取資料, call async rebuild
    Future.delayed(Duration.zero, () => readRenderA());
  }

  /// read rows & render form
  Future readRenderA() async {
    //4.檢查初始狀態, check initial status
    if (!await Xp.isRegA(context)) return;

    //5.讀取資料庫, get rows & check
    await HttpUt.getJsonA(context, 'Bao/GetPage', true, _pagerSrv.getDtJson(), (json) {
      if (json != null) {
        _pagerDto = PagerDto<BaoRowDto>.fromJson(json, BaoRowDto.fromJson);
        render();
      }
    });
  }

  /// render form
  void render() {
    _isOk = true;
    setState(() {}); //call build()
  }

  /// get trail widgets(button)<br>
  /// @rows Bao list rows
  List<Widget> rowsToTrails(List<BaoRowDto> rows) {
    var widgets = <Widget>[];
    for (var row in rows) {
      var json = Xp.attendStatusJson(row.attendStatus);
      widgets.add(WG.btn(json['name'], () async => await onDetailA(row.id), json['color']));
    }
      /*
      widgets.add((status == null)
          ? WG2.textBtn('看明細', () => ToolUt.openFormA(context, BaoDetail(baoId: row.id, onUpdateParent)))
          : (status == AttendStatusEstr.attend)
              ? WG2.textBtn('已參加', () => onPlayGameA(row.id, row.name, row.replyType), Colors.green)
              : (status == AttendStatusEstr.finish)
                  ? WG2.textBtn('已答對', () => onDetail(row.id))
                  : WG2.textBtn('已取消', () => onPlayGameA(row.id, row.name, row.replyType), Colors.red));
      */
    //}

    return widgets;
  }

  /// onclick bao detail
  Future onDetailA(String baoId) async {
    var result = await ToolUt.openFormA(context, BaoDetail(baoId: baoId));
    var aa = 'aa';
  }

  ///6.顯示畫面內容, get view body widget
  Widget getBody() {
    var rows = _pagerDto.rows;
    if (rows.isEmpty) return WG2.noRowMsg();

    var widgets = Xp.baosToWidgets(rows, rowsToTrails(rows));
    widgets.add(_pagerSrv.getWidget(_pagerDto.recordsFiltered));
    return ListView(children: widgets);
  }

  ///7.render畫面
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

  ///onOpen Stage, 開始尋寶關卡
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

  ///called by BaoDetail
  ///@act 參加尋寶、進行尋寶、取消參加
  void onUpdateParent(String act, String baoId) {}
} //class