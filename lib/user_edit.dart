import 'package:flutter/material.dart';
import 'package:base_flu/all.dart';
import 'all.dart';
import 'user_recover.dart';

class UserEdit extends StatefulWidget {
  const UserEdit({super.key});

  @override
  _UserEditState createState() => _UserEditState();
}

class _UserEditState extends State<UserEdit> {
  bool _isOk = false; //state variables
  bool _isNew = true; //new account or not
  bool _showAuth = false; //show auth field for new account or not

  final _formKey = GlobalKey<FormState>();

  //input fields
  final phoneCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final authCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () => rebuildA());
  }

  Future rebuildA() async {
    //get info file
    var file = Xp.openInfoFile();
    _isNew = !await file.exists();
    var run = true;
    if (_isNew) {
      /*
      //TODO: temp add
      phoneCtrl.text = '0912345678';
      nameCtrl.text = '尋寶1';
      emailCtrl.text = 'xxx@gmail.com';
      addressCtrl.text = 'Taipei';
      */
    } else {
      //fid 'key' is forbidden !!
      var key = await file.readAsString();
      await HttpUt.getJsonA(context, 'User/GetRow', false, {'id': key}, (json) {
        if (json == null) {
          ToolUt.msg(context, '找不到這筆資料 !');
          run = false;
          return;
        }

        //_userId = json['Id'];
        phoneCtrl.text = json['Phone'];
        //nameCtrl.text = StrHp.utf8Decode(json['Name']);
        nameCtrl.text = json['Name'];
        emailCtrl.text = json['Email'];
        //addressCtrl.text = StrHp.utf8Decode(json['Address']);
        addressCtrl.text = json['Address'];
      });
    }

    if (run) {
      _isOk = true;
      setState(() {});
    }
  }

  ///create account
  Future onCreateA() async {
    // validate
    if (!_formKey.currentState!.validate()) return;

    //insert DB
    var row = {
      'Phone': phoneCtrl.text,
      'Name': nameCtrl.text,
      'Email': emailCtrl.text,
      'Address': addressCtrl.text,
    };
    var run = true;
    await HttpUt.getStrA(context, 'User/Create', true, row, (data) {
      if (data == 'RECOVER') {
        run = false;
        ToolUt.ans(context, '這個Email已經存在, 是否回復帳號?', () {
          ToolUt.openForm(context, UserRecover(email: emailCtrl.text));
        });
      }
    });

    //case of not RECOVER
    if (run) {
      _showAuth = true;
      setState(() => ToolUt.msg(
          context, '系統已經寄送認証Email到上面的信箱, 請填入信件裡面的認証碼後, 按下 [完成認証] 按鈕。'));
    }
  }

  ///update account
  Future onUpdateA() async {
    // validate
    if (!_formKey.currentState!.validate()) return;

    var row = {
      //'Phone': phoneCtrl.text,
      //'Email': emailCtrl.text,
      'Name': nameCtrl.text,
      'Address': addressCtrl.text,
    };
    await HttpUt.getStrA(context, 'User/Update', true, row, (msg) {
      msg ??= '修改完成。';
      ToolUt.msg(context, msg);
    });
  }

  ///完成認証, on authenticate new account
  Future onAuthA() async {
    // validate
    var authCode = authCtrl.text;
    if (StrUt.isEmpty(authCode)) {
      ToolUt.msg(context, '認証碼不可空白。');
      return;
    }

    //return encode userId
    //var data = Xp.encode('$authCode,${emailCtrl.text}');
    var data = '$authCode,${emailCtrl.text}';
    await HttpUt.getStrA(context, 'User/Auth', false, {'data': data}, (json) {
      Xp.setInfoAndToken(json);
      ToolUt.msg(context, '認証作業完成。');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_isOk) return Container();

    //var hasId = StrUt.notEmpty(_userId);
    var status = _isNew; //edit status
    var isRead = !_isNew;
    return Scaffold(
      appBar: WG2.appBar('維護基本資料'),
      body: SingleChildScrollView(
        padding: WG2.pagePad,
        child: Column(
          children: <Widget>[
            Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    readOnly: isRead,
                    controller: phoneCtrl,
                    style: WG2.inputStyle(status),
                    decoration: WG2.inputLabel('手機號碼 (不含國碼, 確定後無法修改)'),
                    autofocus: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) return '手機號碼不可空白。';
                      if (value.length < 9) return '手機號碼至少要9碼。';
                      if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                        return '手機號碼只能是數字。';
                      }

                      //case ok ok
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: nameCtrl,
                    style: WG2.inputStyle(),
                    decoration: WG2.inputLabel('顯示名稱'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return '顯示名稱不可空白。';

                      //case ok ok
                      return null;
                    },
                  ),
                  TextFormField(
                    readOnly: isRead,
                    controller: emailCtrl,
                    style: WG2.inputStyle(status),
                    decoration: WG2.inputLabel('Email (須認證, 確定後無法修改)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return 'Email不可空白。';

                      //case ok ok
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: addressCtrl,
                    //initialValue: 'Taipei',
                    style: WG2.inputStyle(),
                    decoration: WG2.inputLabel('地址 (用於寄送獎品)'),
                    validator: (value) {
                      if (value == null || value.isEmpty) return '地址不可空白。';

                      //case ok ok
                      return null;
                    },
                  ),
                  !_isNew
                      ? WG2.tailBtn('修改資料', () => onUpdateA())
                      : !_showAuth
                          ? WG2.tailBtn('建立帳號', () => onCreateA())
                          : Column(children: <Widget>[
                              //WG.tailBtn('建立帳戶'),
                              TextFormField(
                                controller: authCtrl,
                                style: WG2.inputStyle(),
                                decoration: WG2.inputLabel('請輸入Email信件裡面的認証碼'),
                              ),
                              WG2.tailBtn('執行認証', () => onAuthA()),
                            ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} //class