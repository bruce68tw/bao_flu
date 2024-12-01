import 'package:flutter/material.dart';
import 'package:base_flu/all.dart';
import 'all.dart';

class BaoDetail extends StatefulWidget {
  const BaoDetail({super.key, required this.baoId});
  final String baoId;
  //final Function fnUpdateParent;

  @override
  BaoDetailState createState() => BaoDetailState();
}

class BaoDetailState extends State<BaoDetail> {
  bool _isOk = false; //status
  late Map<String, dynamic>? _json; //bao row json
  String _result = '';  //傳回 Bao form
  //late Function _fnUpdateParent;

  @override
  void initState() {
    //_fnUpdateParent = widget.fnUpdateParent;
    super.initState();
    Future.delayed(Duration.zero, () => rebuildA());
  }

  Future rebuildA() async {
    //get bao detail
    await HttpUt.getJsonA(context, 'Bao/GetDetail', false, {'id': widget.baoId},
        (json) {
      _json = json;
      _isOk = (json != null);
      setState(() {});
    });
  }

  /// onclick join Bao
  /// @baoId
  Future onAttendA(String baoId) async {
    //result: 0(not start),1(start),xxx(error msg)
    await HttpUt.getStrA(context, 'Bao/Attend', false, {'baoId': baoId},
        (result) {
      if (StrUt.isEmpty(result)) {
        return;
      } else if (result == '0') {
        ToolUt.msg(context, '活動未開始, 已加入[我的尋寶]。');
      } else if (result == '1') {
        //todo
        ToolUt.ans(context, '已加入[我的尋寶], 是否開始進行尋寶活動?', () {});
      } else {
        //case of error
        ToolUt.msg(context, result);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOk) return Container();

    //start/end time
    var json = _json!;
    var isMove = (json['IsMove'] == 1);
    var startEnd =
        '${DateUt.format2(json['StartTime'])} ~\n${DateUt.format2(json['EndTime'])}';

    return PopScope(
      canPop: false,
      onPopInvokedWithResult : (didPop, result) {
        didPop = true;
        _result = '1';
        Navigator.pop(context, _result);
        //Navigator.of(context, rootNavigator: true).pop(context);
        //return false;
      },
      child: Scaffold(
        appBar: WG2.appBar('尋寶明細'),
        body: SingleChildScrollView(
          padding: WG2.pagePad,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              WG.labelText('尋寶名稱', json['Name']),
              WG.labelText('起迄時間', startEnd),
              WG.labelText('發行單位', json['Corp']),
              WG.labelText(
                  //'是否需要移動', isMove ? '是' : '否', textColor: isMove ? Colors.red : null),
                  '是否需要移動', isMove ? '是' : '否', textColor: isMove ? Colors.red : null),
              WG.labelText('關卡數目', json['StageCount'].toString()),
              WG.labelText('答題方式', json['ReplyTypeName'].toString()),
              WG.labelText('獎項內容', json['PrizeNote']),
              WG.labelText('遊戲說明', json['Note']),
              //WG.getShowCol('目前參加人數', row['JoinCount'].toString()),
              WG.endBtn(
                '我要參加',
                (Xp.getAttendStatus(widget.baoId) == null)
                  ? () => onAttendA(widget.baoId)
                  : null),
    ]))));
  }
} //class
