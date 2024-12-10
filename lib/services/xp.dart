import 'package:flutter/material.dart';
import 'package:path/path.dart' as path; //or will conflict
//import 'package:archive/archive.dart';
import 'dart:io';
import 'package:base_flu/all.dart';
//不可加入同目錄下 all.dart, 會造成循環參照
import '../bao_detail.dart';
import '../enums/all.dart';
import '../models/all.dart';
import '../stage_batch.dart';
import '../stage_step.dart';
import '../stage_any.dart';
import 'widget2.dart';

/// static class
class Xp {
  //=== constant start ===
  ///1.is https or not
  //static const isHttps = false;
  static const isHttps = true;

  ///2.api server end point
  //static const apiServer = '192.168.43.127:5001';
  static const apiServer = 'baoapitest.eden.org.tw';
  //static const apiServer = '210.61.226.51';  
  //static const String apiServer = '192.168.66.11:83';

  ///3.aes key string with 16 chars
  //static const aesKey = 'YourAesKey';

  ///register file name
  static const regFile = 'MyApp.info';
  //=== constant end ===

  //=== auto set start ===
  ///already init or not
  static bool _isInit = false;

  ///userId in info file
  static String _userId = '';

  ///aeskey with correct length(16 char)
  //static String _aesKey16 = '';

  ///baoId,join status(1:join, else:cancel)
  ///記錄用戶參加的尋寶, 避免再
  static final Map<String, String> _attend = {};
  //=== auto set end ===

  static Future initA([bool testMode = false]) async {
    if (_isInit) return;

    await FunUt.initA(isHttps, apiServer);
    //_aesKey16 = StrUt.preZero(16, aesKey, true);
    _isInit = true;

    //set style
    FunUt.textFontSize = 16;
    FunUt.logHttpUrl = true;
  }

  /*
  /// get aes key with 16 chars(128 bits)
  static String _getAesKey() {
    return StrUt.preZero(16, XpUt.aesKey, true);
  }

  /// aes encode
  /// @data plain text
  /// @return encode string
  static String encode(String data) {
    return StrUt.aesEncode(data, _aesKey16);
  }

  /// aes decode
  /// @data encode text
  /// @return plain string
  static String decode(String data) {
    return StrUt.aesDecode(data, _aesKey);
  }
  */

  /// 判斷是否註冊, system initial & login
  /// @context current context
  /// @return initial status
  static Future<bool> isRegA(BuildContext? context) async {
    //initial if need
    await initA();
    if (FunUt.isLogin) return true;

    //read info file if need
    if (_userId == '') _userId = await readInfoA();

    //set FunHp.isLogin
    if (StrUt.isEmpty(_userId)) {
      ToolUt.msg(context, '您尚未註冊, 請先執行[我的資料]->[維護基本資料]');
      return false;
    }

    await HttpUt.getJsonA(context!, 'Home/Login', false, {'userId': _userId},
        (json) {
      if (json == null) return false;

      var token = json['token'];
      if (StrUt.notEmpty(token)) {
        HttpUt.setToken(token!);
        //FunUt.isLogin = true;
        _importAttend(json['attends']);
      }
    });

    return true;
  }

  ///import bao list into _attend json
  static void _importAttend(List<dynamic>? rows) {
    if (rows == null) return;

    for (var row in rows) {
      _attend[row['BaoId']] = row['AttendStatus'];
    }
  }

  ///get reply stage status json<br>
  ///@return <name,color>
  static Map<String, dynamic> replyStageStatusJson(String? status, int errorCount){
    return StrUt.isEmpty(status) ? {'name': '未作答', 'color': Colors.black} :
      (status == ReplyStageStatusEstr.right) ? {'name': '答對了', 'color': Colors.green} :
      (status == ReplyStageStatusEstr.wrong) ? {'name': '答錯了', 'color': Colors.red} :
      (status == ReplyStageStatusEstr.lock) ? {'name': '答錯$errorCount次', 'color': Colors.red} :
      {'name': '??', 'color': Colors.red};
  }

  ///get attend status json<br>
  ///@return <name,color>
  static Map<String, dynamic> attendStatusJson(String? status) {
    return StrUt.isEmpty(status) ? {'name': '未參加', 'color': Colors.black} :
      (status == AttendStatusEstr.attend) ? {'name': '已參加', 'color': Colors.blue} :
      (status == AttendStatusEstr.finish) ? {'name': '已答對', 'color': Colors.green} :
      (status == AttendStatusEstr.cancel) ? {'name': '已取消', 'color': Colors.red} :
      {'name': '??', 'color': Colors.red};
  }

  ///get attend status
  static String? getAttendStatus(String baoId) {
    return _attend.containsKey(baoId) ? _attend[baoId] : null;
  }

  ///attend bao
  static void setAttendStatus(String baoId, String status) {
    _attend[baoId] = status;
  }

  ///open stage form, 進行尋寶
  static Future<dynamic> playGameA(BuildContext context, String baoId, String baoName,
      String replyType) async {
    if (replyType == ReplyTypeEstr.batch) {
      //批次
      return await ToolUt.openFormA(context, StageBatch(baoId: baoId, baoName: baoName, replyType: replyType));
    } else if (replyType == ReplyTypeEstr.step) {
      //讀取目前進行關卡資料
      await HttpUt.getJsonA(context, 'Stage/GetNowStepRow', false, {'baoId': baoId}, (row) {
        return playStageStepA(context, baoId, baoName, row['Id'].toString(), replyType);
      });
    } else if (replyType == ReplyTypeEstr.anyStep) {
      return await ToolUt.openFormA(context, StageAny(baoId: baoId, baoName: baoName));
    }
  }

  ///by Step、AnyStep
  static Future<String?> playStageStepA(BuildContext context, String baoId, String baoName,
      String stageId, String replyType) async {
    //開啟畫面
    return await ToolUt.openFormA(
      context,
      StageStep(
        baoId: baoId,
        baoName: baoName,
        stageId: stageId,
        replyType: replyType));
  }

  /// set _userId & write info file
  static void setInfo(String userId) {
    _userId = userId;

    //create info file
    var file = Xp.openInfoFile();
    file.writeAsString(userId);
  }

  static void setInfoAndToken(Map<String, dynamic> json) {
    Xp.setInfo(json['userId']);
    HttpUt.setToken(json['token']);
  }

  /// get info file object
  static File openInfoFile() {
    return File(FileUt.getFilePath(Xp.regFile));
  }

  /// read info file string
  static Future<String> readInfoA() async {
    var file = openInfoFile();
    return await file.exists() ? await file.readAsString() : '';
  }

  /// baoRows to widget list<br>
  /// @rows source rows<br>
  /// @trails tail widget list<br>
  /// @onUpdateParent 呼叫父視窗函數<br>
  /// @return list widget
  static List<Widget> baosToWidgets(
      List<BaoRowDto> rows, List<Widget> trails /*, Function onUpdateParent*/) {
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
      widgets.add(WG.divider());
    }

    return widgets;
  }

  static String dirCmsCard() {
    return '${FunUt.dirApp}image/cmsCard';
  }

  static bool baoHasMoney(String prizeType) {
    return (prizeType == PrizeTypeEstr.money ||
        prizeType == PrizeTypeEstr.moneyGift);
  }

  static bool baoHasGift(String prizeType) {
    return (prizeType == PrizeTypeEstr.gift ||
        prizeType == PrizeTypeEstr.moneyGift);
  }

  /*
  //答題時顯示全部關卡
  static bool baoReplyStages(String replyType) {
    return (replyType == ReplyTypeEstr.batch ||
        replyType == ReplyTypeEstr.anyStep);
  }
  */

  /// get directory of stage image
  static String dirStageImage(String baoId) {
    return '${FunUt.dirApp}image/stage/$baoId';
  }

  /// download stage image
  /// param allImage: 是否下載多個關卡的圖檔
  /// return file index(base 1) if not batch
  static Future<int> downStageImage(BuildContext context, String baoId,
      String stageId, String replyType, String dirImage) async {
    //create folder if need
    var dir = Directory(dirImage);
    //TODO: temp add for remove cached image files
    //dir.deleteSync(recursive: true);

    //是否可同時回答多個謎題
    String action = '';
    Map<String, String> json;
    if (replyType == ReplyTypeEstr.batch) {
      if (dir.existsSync() && dir.listSync().isNotEmpty) return 0;
      action = 'Stage/GetBatchImage';
      json = {'baoId': baoId};
    } else if (replyType == ReplyTypeEstr.step) {
      if (FileUt.dirHasFileStem(dirImage, stageId, false)) return 0;
      action = 'Stage/GetNowStepImage';
      json = {'baoId': baoId};
    } else {
      if (FileUt.dirHasFileStem(dirImage, stageId, false)) return 0;
      action = 'Stage/GetAnyStepImage';
      json = {'stageId': stageId};
    }

    //download and unzip
    await HttpUt.saveUnzipA(context, action, json, dirImage);
    return 1;
  }

  ///get Bao body widget for 尋寶/我的尋寶
  ///param stageIndex: 0(batch),n(step),-1(step read only)
  ///_pagerSrv.getWidget(_pagerDto
  static Widget getBaoBody(BuildContext context, PagerSrv pagerSrv, PagerDto<BaoRowDto> pagerDto, Function fnRender){
    var rows = pagerDto.rows;    
    if (rows.isEmpty) return WG2.noRowMsg();

    var widgets = <Widget>[];
    for (int i = 0; i < rows.length; i++) {
      var row = rows[i];
      var attendJson = Xp.attendStatusJson(row.attendStatus);
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
        trailing: WG.btn(attendJson['name'], ()=> Xp.onBaoDetailA(context, row, fnRender), attendJson['color']),
      ));
      widgets.add(WG.divider());
    }

    //var widgets = Xp.baosToWidgets(rows, rowsToTrails(rows));
    widgets.add(pagerSrv.getWidget(pagerDto.recordsFiltered));
    return ListView(children: widgets);
  }

  ///顯示尋寶明細頁
  static Future onBaoDetailA(BuildContext context, BaoRowDto row, Function fnRender) async {
    //BaoDetail回傳結果更新Bao
    var result = await ToolUt.openFormA(context, BaoDetail(baoId: row.id, attendStatus: row.attendStatus));
    if (result == AttendStatusEstr.attend){   //參加尋寶
      row.attendStatus = AttendStatusEstr.attend;
      fnRender();
    } else if (result == 'P'){  //開始尋寶(AttendStatusEstr不包含此項目, for BaoDetail/Bao資料交換only)
      result = await Xp.playGameA(context, row.id, row.name, row.replyType);
      if (StrUt.notEmpty(result)){
        row.attendStatus = result;
        fnRender();
      }
    }
  }

  //get body widget for stageStep/stageBatch
  //for Step(下一關)、Batch(全部)
  //param stageIndex: 0(batch),n(step),-1(step read only)
  static Widget getStageBody(
      BuildContext context,
      String baoId,
      String dirImage,
      String replyType,
      int stageIndex,
      TextEditingController ctrl /*, Function fnOnSubmit*/) {
    //set widgets & return
    //var isBatch = (stageIndex == 0);
    //var isStep = (stageIndex > 0);
    //var readOnly = (stageIndex == -1);
    var dir = Directory(dirImage);
    var files = dir.listSync().toList();
    if (files.isEmpty) return WG2.noRowMsg();

    var isBatch = (replyType == ReplyTypeEstr.batch);
    var isStep = (replyType == ReplyTypeEstr.step);
    var isAnyStep = (replyType == ReplyTypeEstr.anyStep);

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
        child: WG.textWG(text),
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
          //onPressed: () => Xp.onReplyOneA(context, baoId, stageId, ctrl),
          onPressed: () => {},
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
} //class
