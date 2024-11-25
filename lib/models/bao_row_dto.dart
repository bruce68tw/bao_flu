class BaoRowDto {
  bool isMove;
  String answerType;
  String prizeType;
  String id;
  String name;
  String corp;
  String startTime;

  BaoRowDto(
      {required this.isMove,
      required this.answerType,
      required this.prizeType,
      required this.id,
      required this.name,
      required this.corp,
      required this.startTime});

  ///convert json to model, static for be parameter !!
  static BaoRowDto fromJson(Map<String, dynamic> json) {
    return BaoRowDto(
      isMove: (json['IsMove'] == 1),
      answerType: json['AnswerType'],
      prizeType: json['PrizeType'],
      id: json['Id'],
      name: json['Name'],
      corp: json['Corp'],
      startTime: json['StartTime'],
    );
  }
}//class