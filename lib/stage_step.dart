//import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:base_flu/all.dart';
import 'all.dart';

class StageStep extends StatefulWidget {
  const StageStep(
      {super.key,
      required this.id,
      required this.name,
      required this.editable});

  //input parameter
  final String id; //Bao.Id
  final String name; //Bao.Name
  final bool editable; //editable or not

  @override
  _StageStepState createState() => _StageStepState();
}

class _StageStepState extends State<StageStep> {
  bool _isOk = false; //status
  late String _baoId;
  late String _dirImage;
  late int _stageIndex; //stage image index, base 1, (-1:readOnly)
  final replyCtrl = TextEditingController();

  @override
  void initState() {
    _baoId = widget.id;
    _dirImage = Xp.dirStageImage(_baoId);

    super.initState();
    Future.delayed(Duration.zero, () => showAsync());
  }

  Future<void> showAsync() async {
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

  //onclick submit
  Future<void> onSubmitAsync() async {
    var reply = replyCtrl.text;
    if (StrUt.isEmpty(reply)) {
      ToolUt.msg(context, '不可空白。');
      return;
    }

    //0(fail),1(ok)
    var data = {'id': _baoId, 'reply': reply};
    await HttpUt.getStrA(context, 'Stage/ReplyStep', false, data, (result) {
      if (result == '1') {
        Xp.setAttendStatus(_baoId, AttendEstr.finish);
        ToolUt.msg(context, '恭喜答對了!');
      } else {
        ToolUt.msg(context, '哦哦，你猜錯了!');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOk) return Container();

    return Scaffold(
      appBar: WG2.appBar('解謎: ${widget.name}'),
      body: Xp.getStageBody(_dirImage, _stageIndex, replyCtrl, onSubmitAsync),
    );
  }
} //class