//用於尋寶, 我的尋寶
class BaoRowDto {
  String id;
  String name;
  String corp;
  bool isMove;
  String attendStatus;
  String replyType;
  String prizeType;
  String startTime;
  bool baoStatus;

  BaoRowDto({
    required this.id,
    required this.name,
    required this.corp,
    required this.isMove,
    required this.attendStatus,
    required this.replyType,
    required this.prizeType,
    required this.startTime,
    required this.baoStatus});

  ///convert json to model, static for be parameter !!
  static BaoRowDto fromJson(Map<String, dynamic> json) {
    return BaoRowDto(
      id: json['Id'],
      name: json['Name'],
      corp: json['Corp'],
      isMove: (json['IsMove'] == 1),
      replyType: json['ReplyType'],
      attendStatus: json['AttendStatus'],
      prizeType: json['PrizeType'],
      startTime: json['StartTime'],
      baoStatus: (json['BaoStatus'] == 1),
    );
  }
}//class