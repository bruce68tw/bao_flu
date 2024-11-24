import 'package:flutter/material.dart';
import 'package:base_flu/all.dart';
import 'all.dart';

//回復用戶帳號
class UserRecover extends StatefulWidget {
  const UserRecover({super.key, required this.email});
  final String email;

  @override
  _UserRecoverState createState() => _UserRecoverState();
}

class _UserRecoverState extends State<UserRecover> {
  int _step = 1; //control button status, 1/2
  final authCtrl = TextEditingController();

  /*
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, ()=> rebuildAsync());
  }
  */

  void rebuild(int step) {
    _step = step;
    setState(() {});
  }

  /// onclick send email
  Future onEmailA() async {
    //get error msg if any
    await HttpUt.getStrA(
        context, 'User/EmailRecover', false, {'email': widget.email}, (msg) {
      if (msg == '') {
        ToolUt.msg(context, 'Email已經送出, 請在下方欄位填入郵件裡面的認証碼後, 再按 [回復用戶帳號] 按鈕。');
        rebuild(2);
      } else {
        ToolUt.msg(context, msg);
      }
    });
  }

  Future onRecoverA() async {
    // validate
    var authCode = authCtrl.text;
    if (StrUt.isEmpty(authCode)) {
      ToolUt.msg(context, '認証碼不可空白。');
      return;
    }

    //return encode userId
    //var data = Xp.encode('$authCode,${widget.email}');
    var data = '$authCode,${widget.email}';
    await HttpUt.getStrA(context, 'User/Auth', false, {'data': data}, (key) {
      Xp.setInfo(key);
      ToolUt.msg(context, '回復帳號作業已經完成。');
    });
  }

  @override
  Widget build(BuildContext context) {
    //if (!_isOk) return Container();

    return Scaffold(
      appBar: WG2.appBar('回復用戶帳號'),
      body: SingleChildScrollView(
        padding: WG2.pagePad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            WG2.labelText('Email', widget.email),
            WG.getText('要回復這個Email所對應的用戶帳號, '
                '請點擊下方的 [寄送認証郵件] 按鈕, 系統將會寄送認証Email到上面的信箱。'),
            WG2.divider(),
            (_step == 1)
                ? WG2.tailBtn('寄送認証郵件', () => onEmailA())
                : Column(children: <Widget>[
                    TextFormField(
                      controller: authCtrl,
                      style: WG2.inputStyle(),
                      decoration: WG2.inputLabel('請輸入Email信件裡面的認証碼'),
                    ),
                    WG2.tailBtn('回復用戶帳號', () => onRecoverA()),
                  ]),
          ],
        ),
      ),
    );
  }
} //class
