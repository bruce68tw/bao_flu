//import 'dart:developer';
import 'dart:io';
import 'package:base_flu/all.dart';
import 'package:path/path.dart' as path; //or will conflict
import 'package:flutter/material.dart';
import 'all.dart';

//ReplyType=AnyStep也會開啟此畫面來答題
class StageStep extends StatefulWidget {
  const StageStep(
      {super.key,
      required this.baoId,
      required this.baoName,
      required this.stageId,
      required this.replyType});

  //input parameter
  final String baoId; //Bao.Id
  final String baoName; //Bao.Name
  final String stageId; //Stage.Id
  final String replyType; //Bao.ReplyType
  //final bool editable; //editable or not

  @override
  _StageStepState createState() => _StageStepState();
}

class _StageStepState extends State<StageStep> {
  bool _isOk = false; //status
  late String _baoId;
  late String _stageId;
  late String _replyType;
  late String _dirImage;
  //late int _stageIndex; //stage image index, base 1, (-1:readOnly)
  final replyCtrl = TextEditingController();
  Map<String, dynamic>? _stageRow;

  @override
  void initState() {
    _baoId = widget.baoId;
    _stageId = widget.stageId;
    _replyType = widget.replyType;
    _dirImage = Xp.dirStageImage(_baoId);

    super.initState();
    Future.delayed(Duration.zero, () => rebuildA());
  }

  Future rebuildA() async {
    //download image if need
    await Xp.downStageImage(context, _baoId, _stageId, _replyType, _dirImage);

    //get stage row and rebuild
    await HttpUt.getJsonA(
        context, 'Stage/GetRowForStepAny', false, {'stageId': _stageId}, (row) {
      _stageRow = row;
      setState(() => _isOk = true);
    });
  }

  //onclick 傳送一題解答
  Future onReplyA() async {
    var reply = replyCtrl.text;
    if (StrUt.isEmpty(reply)) {
      ToolUt.msg(context, '不可空白。');
      return;
    }

    //0(fail),1(ok),-1(lock)
    //答題成功或鎖定則離開此畫面
    var data = {'baoId': _baoId, 'stageId': _stageId, 'reply': reply};
    await HttpUt.getStrA(context, 'Stage/ReplyOne', false, data, (result) {
      if (result == '1') {
        //Xp.setAttendStatus(_baoId, AttendEstr.finish);
        //ToolUt.msg(context, '恭喜答對了!');
        ToolUt.closeFormMsg(context, '恭喜答對了!');
      } else if (result == '0') {
        ToolUt.msg(context, '哦哦，你猜錯了!');
      } else if (result == '-1') {
        //ToolUt.msg(context, '答錯超過次數，本題無法再答!');
        ToolUt.closeFormMsg(context, '答錯超過次數，本題無法再答!');
      }
    });
  }

  //get body widget
  Widget getBody(BuildContext context) {
    //get file
    var file = FileUt.dirGetFileByStem(_dirImage, _stageId, false);

    //title, 謎題圖片上方文字:關卡/謎題, 提示
    var widgets = <Widget>[];
    var title = (_replyType == ReplyTypeEstr.step) ? '關卡' : '謎題';
    title =
        "$title ${(_stageRow!['Sort'] + 1).toString()} / ${_stageRow!['StageCount'].toString()}";
    var hint = _stageRow!['AppHint'];

    //add title
    widgets.add(Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WG.textWG(title),
            StrUt.isEmpty(hint) ? const Text('') : WG.textWG('提示：$hint')
          ],
        )));

    //add image
    widgets.add(InteractiveViewer(
      panEnabled: true,
      boundaryMargin: WG.gap(0),
      minScale: 1,
      maxScale: 8,
      child: Image.file(file as File),
    ));

    //add text input & button
    widgets.add(TextField(
      controller: replyCtrl,
      maxLines: 1,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        counterText: replyCtrl.text,
        labelText: '(請輸入解答)',
        //hintText: 'type something...',
        border: const OutlineInputBorder(),
      ),
      //onChanged: (text) => setState(() {}),
    ));

    var btn = ElevatedButton(
      child: const Text('送出解答', style: TextStyle(fontSize: 15)),
      onPressed: () => onReplyA(),
    );

    //add submit button if need
    widgets.add(Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.all(20),
      child: btn,
    ));

    //分隔線
    //widgets.add(const Divider());

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