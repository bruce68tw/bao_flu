import 'dart:io';
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
  _StageAnyState createState() => _StageAnyState();
}

class _StageAnyState extends State<StageAny> {
  bool _isOk = false; //status
  late String _baoId;
  //late String _dirImage;
  List<dynamic> _stageRows = [];

  @override
  void initState() {
    _baoId = widget.baoId;
    //_dirImage = Xp.dirStageImage(_baoId);

    super.initState();
    Future.delayed(Duration.zero, () => rebuildA());
  }

  Future rebuildA() async {
    //await Xp.downStageImage(context, _baoId, true, _dirImage);

    //讀取全部關卡資料
    await HttpUt.getJsonA(context, 'Stage/GetRows', false, {'baoId': _baoId},
        (rows) {
      _stageRows = rows;
      _isOk = true;
      setState(() {});
    });
  }

  //get body widget for stageStep/stageBatch
  Widget getBody(BuildContext context) {
    //var dir = Directory(_dirImage);
    //var files = dir.listSync().toList();
    //if (files.isEmpty) return Xp.emptyMsg();
    if (_stageRows.isEmpty) return Xp.emptyMsg();

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
      var tail = WG2.textBtn('解答', () => {});

      //答題狀態
      var isNormal = false;
      var answerStatus =
          JsonUt.emptyToStr(row, 'AnswerStatus', AnswerStatusEstr.normal);
      Text ansStatus;
      if (answerStatus == AnswerStatusEstr.finish) {
        ansStatus = WG.getGreenText('答對了!!');
      } else if (answerStatus == AnswerStatusEstr.lock) {
        ansStatus = WG.getRedText('錯誤太多，無法答題');
      } else {
        isNormal = true;
        var errorCount = JsonUt.emptyToInt(row, 'ErrorCount', 0);
        ansStatus = (errorCount > 0)
            ? WG.getRedText('錯誤$errorCount次')
            : const Text('未作答');
      }

      widgets.add(ListTile(
        title: Text(title),
        subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start, //向左對齊
            children: [
              Text('提示：${row['CustHint'].toString()}'),
              ansStatus,
            ]),
        trailing: isNormal ? tail : const Text(''),
      ));

      widgets.add(WG2.divider());
    } //for

    return ListView(
      padding: WG.gap(10),
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOk) return Container();

    return Scaffold(
      appBar: WG2.appBar('解謎: ${widget.baoName}'),
      body: getBody(context),
    );
  }
} //class