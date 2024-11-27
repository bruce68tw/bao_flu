//import 'dart:developer';
import 'dart:io';
import 'package:base_flu/all.dart';
import 'package:path/path.dart' as path; //or will conflict
import 'package:flutter/material.dart';
import 'all.dart';

//AnswerType=AnyStep也會開啟此畫面來答題
class StageStep extends StatefulWidget {
  const StageStep(
      {super.key,
      required this.baoId,
      required this.baoName,
      required this.stageId,
      required this.editable});

  //input parameter
  final String baoId; //Bao.Id
  final String baoName; //Bao.Name
  final String stageId; //Stage.Id
  final bool editable; //editable or not

  @override
  _StageStepState createState() => _StageStepState();
}

class _StageStepState extends State<StageStep> {
  bool _isOk = false; //status
  late String _baoId;
  late String _stageId;
  late String _dirImage;
  late int _stageIndex; //stage image index, base 1, (-1:readOnly)
  final replyCtrl = TextEditingController();

  @override
  void initState() {
    _baoId = widget.baoId;
    _stageId = widget.stageId;
    _dirImage = Xp.dirStageImage(_baoId);

    super.initState();
    Future.delayed(Duration.zero, () => rebuildA());
  }

  Future rebuildA() async {
    /*
    //create folder if need
    var dirBao = Directory(_dirImage);
    if (!await dirBao.exists()) {
      await dirBao.create(recursive: true);
    }

    //if no file, download it
    if (dirBao.listSync().isEmpty){
      var bytes =
          await HttpUt.getFileBytesAsync(context, 'Stage/GetStepImage', {'id': _baoId});
      if (bytes != null) {
        var file = ZipDecoder().decodeBytes(bytes)[0];

        // Extract the contents of the Zip archive to disk.
        //..cascade operator
        File(dirBao.path + '/' + file.name)
          ..createSync()
          ..writeAsBytesSync(file.content as List<int>, flush:true);
      }
    }
    */

    _stageIndex = widget.editable
        ? await Xp.downStageImage(context, _baoId, false, _dirImage)
        : -1;
    setState(() => _isOk = true);
  }

  //get body widget for stageStep/stageBatch
  //for Step(下一關)、Batch(全部)
  //param stageIndex: 0(batch),n(step),-1(step read only)
  Widget getBody(BuildContext context, int stageIndex) {
    //var dir = Directory(dirImage);
    //var files = dir.listSync().toList();
    if (!FileUt.dirHasFileStem(_dirImage, _stageId)) return Xp.emptyMsg();

    /*
    var btnText = isBatch ? '送出全部解答' : 
      isStep ? '送出解答' : 
      isAnyStep ? '送出' : '';
    */

    //sorting files
    var stageLen = files.length;
    files.sort((a, b) => a.path.compareTo(b.path));

    final replyCtrl = TextEditingController();

    var widgets = <Widget>[];
    for (var file in files) {
      //圖檔名稱(底線分隔): Sort+1,StageId,Hint
      var cols = path.basename(file.path).split('_');
      var index = int.parse(cols[0]);
      if (isStep && stageIndex != index) continue;

      //謎題圖片上方文字:關卡/謎題, 提示
      //var no = int.parse(cols[0]);
      var stageId = cols[1];
      var text = '第${cols[0]}關';
      if (cols.length > 3) {
        text += ', 提示：${cols[2]}';
      }

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
      body: Xp.getStageBody(context, _baoId, _dirImage, AnswerTypeEstr.step,
          _stageIndex, replyCtrl),
    );
  }
} //class