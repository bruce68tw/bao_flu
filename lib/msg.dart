import 'package:flutter/material.dart';
import 'package:base_flu/all.dart';
import 'msg_detail.dart';
import 'all.dart';

class Msg extends StatefulWidget {
  const Msg({super.key});

  @override
  State<Msg> createState() => MsgState();
}

class MsgState extends State<Msg> {
  bool _isOk = false; //status
  late PagerSrv _pagerSrv; //pager service
  late PagerDto<MsgRowDto> _pagerDto;

  @override
  void initState() {
    //set first, coz function parameter !!
    _pagerSrv = PagerSrv(readRenderA);

    //call before reload()
    super.initState();
    Future.delayed(Duration.zero, () => readRenderA());
  }

  /// reload page
  Future readRenderA() async {
    if (!await Xp.isRegA(context)) return;

    //get rows, check & set total rows
    await HttpUt.getJsonA(context, 'Cms/GetPage', true, _pagerSrv.getDtJson(),
        (json) {
      if (json == null) return;

      _pagerDto = PagerDto<MsgRowDto>.fromJson(json, MsgRowDto.fromJson);
      render();
    });
  }

  /// render form
  void render() {
    _isOk = true;
    setState(() {}); //call build()
  }

  ///get view body widget
  Widget getBody() {
    var rows = _pagerDto.rows;
    if (rows.isEmpty) return WG2.noRowMsg();

    //#region get rows
    var list = <Widget>[];
    for (var row in rows) {
      list.add(ListTile(
        /*
        title: Row(children: <Widget>[
          Text(row.title),
        ]),
        */
        title: Text(row.title),
        subtitle: Text('${DateUt.format2(row.startTime)} 開始'),
        trailing: WG.linkBtn('看明細', () => onDetail(row.id)),
      ));

      list.add(WG.divider());
    }
    //#endregion

    list.add(_pagerSrv.getWidget(_pagerDto.recordsFiltered));
    return ListView(children: list);
  }

  /// onclick bao item
  /// @id Bao.Id
  void onDetail(String id) {
    ToolUt.openFormA(context, MsgDetail(id: id));
  }

  @override
  Widget build(BuildContext context) {
    //check status
    if (!_isOk) return Container();

    return Scaffold(
      appBar: WG2.appBar('最新消息'),
      body: getBody(),
    );
  }
}//class
