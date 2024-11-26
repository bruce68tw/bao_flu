import 'dart:io';
import 'package:base_flu/all.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path; //or will conflict
//import 'package:base_flu/all.dart';
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
  //static const dirImage = 'image';    // image folder name
  bool _isOk = false; //status
  //int _stageCount = 0;
  late String _baoId;
  late String _dirImage;
  final replyCtrl = TextEditingController();

  @override
  void initState() {
    _baoId = widget.baoId;
    _dirImage = Xp.dirStageImage(_baoId);

    super.initState();
    Future.delayed(Duration.zero, () => rebuildA());
  }

  Future rebuildA() async {
    await Xp.downStageImage(context, _baoId, AnswerTypeEstr.batch, _dirImage);
    _isOk = true;
    setState(() {});
  }

  /* //todo
  //onclick submit
  Future onSubmitA() async {
    var reply = replyCtrl.text;
    if (StrUt.isEmpty(reply)) {
      ToolUt.msg(context, '不可空白。');
      return;
    }

    //ToolUt.openWait(context);

    //0(fail),1(ok)
    var data = {'id': _baoId, 'reply': reply};
    await HttpUt.getStrA(context, 'Stage/ReplyAll', false, data, (result) {
      if (result == '1') {
        Xp.setAttendStatus(_baoId, AttendEstr.finish);
        ToolUt.msg(context, '恭喜答對了!');
      } else {
        ToolUt.msg(context, '哦哦，你猜錯了!');
      }
    });
  }
  */

  static List<Widget> baosToWidgets(List<BaoRowDto> rows, List<Widget> trails) {
    var widgets = <Widget>[];
    if (rows.isEmpty) return widgets;

    for (int i = 0; i < rows.length; i++) {
      var row = rows[i];
      widgets.add(ListTile(
        title: Row(children: [
          Xp.baoHasMoney(row.prizeType)
              ? const Icon(Icons.paid, color: Colors.amber)
              : const Text(''),
          Xp.baoHasGift(row.prizeType)
              ? const Icon(Icons.redeem, color: Colors.blue)
              : const Text(''),
          row.isMove
              ? const Icon(Icons.directions_run, color: Colors.red)
              : const Text(''),
          Text(row.name),
        ]),
        subtitle: Text('by: ${row.corp}\n${DateUt.format2(row.startTime)} 開始'),
        trailing: trails[i],
      ));
      widgets.add(WG2.divider());
    }

    return widgets;
  }

  //get body widget for stageStep/stageBatch
  //for Step(下一關)、Batch(全部)、AnyStep(全部)
  //param stageIndex: 0(batch),n(step),-1(step read only)
  static Widget getBody(
      BuildContext context,
      String baoId,
      String dirImage,
      String answerType,
      int stageIndex,
      TextEditingController ctrl /*, Function fnOnSubmit*/) {
    var dir = Directory(dirImage);
    var files = dir.listSync().toList();
    if (files.isEmpty) return emptyMsg();

    //sorting files
    var stageLen = files.length;
    files.sort((a, b) => a.path.compareTo(b.path));

    final replyCtrl = TextEditingController();

    var widgets = <Widget>[];
    for (var file in files) {
      //圖檔名稱(底線分隔): Sort+1,StageId,Hint
      var cols = path.basename(file.path).split('_');
      var index = int.parse(cols[0]);
      //if (isStep && stageIndex != index) continue;

      //謎題圖片上方文字:關卡/謎題, 提示
      //var no = int.parse(cols[0]);
      var stageId = cols[1];
      var text = '第${cols[0]}關';
      if (cols.length > 3) {
        text += ', 提示：${cols[2]}';
      }

      //tail button
      ? WG2.textBtn('看明細', () => onDetail(row.id))
          : (status == AttendEstr.run)
              ? WG2.textBtn('已參加',
                  () => onStage(row.id, row.name, row.answerType), Colors.green)
              : (status == AttendEstr.finish)
                  ? WG2.textBtn('已答對', () => onDetail(row.id))
                  : WG2.textBtn(
                      '已取消',
                      () => onStage(row.id, row.name, row.answerType),
                      Colors.red)

      widgets.add(ListTile(
        title: Text(text),
        subtitle: Text('提示: ${row.corp}\n${DateUt.format2(row.startTime)} 開始'),
        //答題狀態
        trailing: trails[i],
      ));

      widgets.add(WG2.divider());

      //widgets.add(ListTile(title: Text('(' + StrUt.addNum(no, 1) + ')')));
      //add text
      widgets.add(Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 10, left: 5),
        child: WG.getText(text),
      ));

      //add image
      widgets.add(InteractiveViewer(
        panEnabled: true,
        boundaryMargin: WG.gap(0),
        minScale: 1,
        maxScale: 8,
        child: Image.file(file as File),
      ));

      //add text input & button
      if (isBatch || isAnyStep) {
        widgets.add(TextField(
          controller: ctrl,
          maxLines: 1,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            counterText: ctrl.text,
            labelText: '(請輸入解答)',
            //hintText: 'type something...',
            border: const OutlineInputBorder(),
          ),
          //onChanged: (text) => setState(() {}),
        ));

        var btn = ElevatedButton(
          child: const Text('送出解答', style: TextStyle(fontSize: 15)),
          onPressed: () => Xp.onReplyOneA(context, baoId, stageId, ctrl),
        );

        //add submit button if need
        widgets.add(Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(20),
          child: btn,
        ));
      }

      //分隔線
      widgets.add(const Divider());
    } //for

    //todo
    /*
    if (isBatch){
      //add submit button if need
      widgets.add(Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.all(20),
        child: ElevatedButton(
          child: const Text('送出全部解答', style: TextStyle(fontSize: 15)),
          onPressed: () => fnOnSubmit(),
        ),
      ));
    }
    */

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
      body: Xp.getStageBody(
          context, _baoId, _dirImage, AnswerTypeEstr.batch, 0, replyCtrl),
    );
  }
} //class
