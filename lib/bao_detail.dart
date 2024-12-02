import 'package:flutter/material.dart';
import 'package:base_flu/all.dart';
import 'all.dart';

///傳回 Bao:
class BaoDetail extends StatefulWidget {
  const BaoDetail({super.key, required this.baoId, required this.attendStatus});
  final String baoId;
  final String attendStatus;
  //final Function fnUpdateParent;

  @override
  BaoDetailState createState() => BaoDetailState();
}

class BaoDetailState extends State<BaoDetail> {
  static const String Attend = 'A';   //參加尋寶
  static const String PlayGame = 'P'; //開始尋寶

  bool _isOk = false; //status
  late String _baoId;
  late String _attendStatus;
  late Map<String, dynamic>? _json; //bao detail row json
  String _result = '';  //傳回 Bao form
  //late Function _fnUpdateParent;

  @override
  void initState() {
    _baoId = widget.baoId;
    _attendStatus = widget.attendStatus;

    //_fnUpdateParent = widget.fnUpdateParent;
    super.initState();
    Future.delayed(Duration.zero, () => readRenderA());
  }

  /// read rows & render form
  Future readRenderA() async {
    //get bao detail
    await HttpUt.getJsonA(context, 'Bao/GetDetail', false, {'baoId': _baoId},
        (json) {
      if (json != null){
        _json = json;
        render();
      }
    });
  }

  /// render form
  void render() {
    _isOk = true;
    setState(() {}); //call build()
  }

  /// onclick join Bao
  /// @baoId
  Future onAttendA() async {
    //result: 0(not start),1(start),xxx(error msg)
    await HttpUt.getStrA(context, 'Bao/Attend', false, {'baoId': _baoId},
        (result) {
      if (StrUt.isEmpty(result)) {
        return;
      } else if (result == '0') {
        _result = Attend;
        ToolUt.msg(context, '目前活動尚未開始, 已加入[我的尋寶]。');
      } else if (result == '1') {
        _result = Attend;
        ToolUt.ans(context, '已加入[我的尋寶], 是否開始進行尋寶活動?', ()=> onPlayGame());
      } else {
        //case of error
        ToolUt.msg(context, result);
      }
    });
  }

  onPlayGame() {
    ToolUt.closeFormMsg(context, PlayGame);
  }

  List<Widget> getBody() {
    //start/end time
    var json = _json!;
    var isMove = (json['IsMove'] == 1);
    var startEnd =
        '${DateUt.format2(json['StartTime'])} ~\n${DateUt.format2(json['EndTime'])}';

    var widgets = <Widget>[
      WG.labelText('尋寶名稱', json['Name']),
      WG.labelText('起迄時間', startEnd),
      WG.labelText('發行單位', json['Corp']),
      WG.labelText(
        '是否需要移動', isMove ? '是' : '否', textColor: isMove ? Colors.red : null),
      WG.labelText('關卡數目', json['StageCount'].toString()),
      WG.labelText('答題方式', json['ReplyTypeName'].toString()),
      WG.labelText('獎項內容', json['PrizeNote']),
      WG.labelText('遊戲說明', json['Note']),
      //WG.getShowCol('目前參加人數', row['JoinCount'].toString()),
      //我要參加, 開始尋寶
      /*
      WG.endBtn(
        '我要參加',
        (Xp.getAttendStatus(widget.baoId) == null)
          ? () => onAttendA(widget.baoId)
          : null),
      */
    ];

    if (StrUt.isEmpty(_attendStatus)){
      widgets.add(WG.endBtn('我要參加', () => onAttendA()));
    } else if (_attendStatus == AttendStatusEstr.attend){
      if (_json!['BaoStatus'] == '1'){  //可以尋寶
        widgets.add(WG.endBtn('開始尋寶', () => onPlayGame()));
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOk) return Container();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult : (didPop, result) {
        if (!didPop) { //必須這樣寫, 否則會error !!
          Navigator.pop(context, _result);
        }
      },
      child: Scaffold(
        appBar: WG2.appBar('尋寶明細${_json!['BaoStatus'] == '1' ? '' : ' (活動未開始)'}'),
        body: SingleChildScrollView(
          padding: WG2.pagePad,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: getBody()
      ))));
  }
} //class
