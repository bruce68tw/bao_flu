import 'package:base_flu/all.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path; //or will conflict
import 'all.dart';

// 用在 Batch、AnyStep 解答方式
class StageAny extends StatefulWidget {
  const StageAny({super.key, required this.baoId, required this.baoName});

  //input parameter
  final String baoId; //Bao.Id
  final String baoName; //Bao.Name

  @override
  StageAnyState createState() => StageAnyState();
}

class StageAnyState extends State<StageAny> {
  bool _isOk = false; //status
  late String _baoId;
  late String _baoName;
  //late String _dirImage;
  List<dynamic> _stageRows = [];
  late dynamic _nowRow;
  String _attendResult = '';  //傳回 Bao form 的 attendStatus result

  @override
  void initState() {
    _baoId = widget.baoId;
    _baoName = widget.baoName;
    //_dirImage = Xp.dirStageImage(_baoId);

    super.initState();
    Future.delayed(Duration.zero, () => readRenderA());
  }

  Future readRenderA() async {
    //await Xp.downStageImage(context, _baoId, true, _dirImage);

    //讀取全部關卡資料
    await HttpUt.getJsonA(context, 'Stage/GetRowsForBatchAny', false, {'baoId': _baoId},
        (rows) {
      _stageRows = rows;
      render();
    });
  }

  /// render form
  void render() {
    _isOk = true;
    setState(() {}); //call build()
  }

  //解題
  Future onPlayStageStepA(dynamic row) async {
    //傳回'1'(答對), '-1'(答錯&鎖定)    
    _nowRow = row;
    var replyStatus = await Xp.playStageStepA(context, _baoId, _baoName, row['Id'].toString(), ReplyTypeEstr.anyStep);
    if (StrUt.notEmpty(replyStatus)){
      if (replyStatus == ReplyBaoStatusEstr.finish){  //尋寶完成
        replyStatus = ReplyStageStatusEstr.right;
        _attendResult = ReplyBaoStatusEstr.finish;
      } else {
        _attendResult = ReplyBaoStatusEstr.attend;
      }
      _nowRow['ReplyStatus'] = replyStatus;
      render();
    }
  }

  //get body widget for stageStep/stageBatch
  Widget getBody(BuildContext context) {
    //var dir = Directory(_dirImage);
    //var files = dir.listSync().toList();
    //if (files.isEmpty) return Xp.emptyMsg();
    if (_stageRows.isEmpty) return WG2.noRowMsg();

    //sorting files, 檔案數與 _stageRows 筆數相同
    //var fileLen = files.length;
    //files.sort((a, b) => a.path.compareTo(b.path));

    var rowLen = _stageRows.length;
    var widgets = <Widget>[];
    for (var i = 0; i < rowLen; i++) {
      //圖檔名稱(底線分隔): Sort+1,StageId,Hint
      //var file = files[i];
      var row = _stageRows[i];
      //var cols = path.basename(file.path).split('_');
      //var index = int.parse(cols[0]);
      //if (isStep && stageIndex != index) continue;

      //謎題圖片上方文字:關卡/謎題, 提示
      //var stageId = cols[1];
      var title = '謎題${i + 1}';
      var stageName = row['Name'].toString();
      if (StrUt.notEmpty(stageName)) {
        title += '：$stageName';
      }

      //tail button
      //var tail = WG.btn('解答', () => onPlayStageStepA(row['Id'].toString()));

      //答題狀態
      //var showBtn = false;
      var errorCount = JsonUt.emptyToInt(row, 'ErrorCount', 0);
      var replyStatus = row['ReplyStatus'];
      var replyStatusJson = Xp.replyStageStatusJson(replyStatus, errorCount);
      /*
      Text ansStatus;
      if (replyStatus == ReplyBaoStatusEstr.finish) {
        ansStatus = WG.greenText('答對了!!');
      } else if (replyBaoStatus == ReplyBaoStatusEstr.lock) {
        ansStatus = WG.redText('錯誤太多，無法再答');
      } else {
        showBtn = true;
        ansStatus = (errorCount > 0)
            ? WG.redText('猜錯$errorCount次')
            : const Text('未作答');
      }
      */

      widgets.add(ListTile(
        title: Text(title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start, //向左對齊
          children: [
            Text('提示：${row['AppHint'].toString()}'),
            WG.textWG(replyStatusJson['name'], color: replyStatusJson['color'])
            //ansStatus,
          ]),
        trailing: (StrUt.isEmpty(replyStatus) || replyStatus == ReplyStageStatusEstr.wrong)
          ? WG.btn('解答', () => onPlayStageStepA(row))
          : const Text(''),
      ));

      widgets.add(WG.divider());
    } //for

    return ListView(
      padding: WG.gap(10),
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOk) return Container();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult : (didPop, result) {
        if (!didPop) { //必須這樣寫, 否則會error !!
          Navigator.pop(context, _attendResult);
        }
      },
      child: Scaffold(
      appBar: WG2.appBar('解謎: ${widget.baoName}'),
      body: getBody(context),
    ));
  }
} //class