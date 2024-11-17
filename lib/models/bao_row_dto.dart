class BaoRowDto {
  bool isMove;
  bool isBatch;
  bool isMoney;
  String id;
  String name;
  String corp;
  String startTime;

  BaoRowDto({required this.isMove, required this.isBatch,
    required this.isMoney,
    required this.id, required this.name,
    required this.corp, required this.startTime
    });

  ///convert json to model, static for be parameter !!
  static BaoRowDto fromJson(Map<String, dynamic> json){
    return BaoRowDto(
      isMove : (json['IsMove'] == 1),
      isBatch : (json['IsBatch'] == 1),
      isMoney : (json['IsMoney'] == 1),
      id : json['Id'],
      name : json['Name'],
      corp : json['Corp'],
      startTime : json['StartTime'],
    );    
  }

}//class