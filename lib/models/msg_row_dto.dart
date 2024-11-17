class MsgRowDto {
  String id;
  String title;
  String text;
  String startTime;

  MsgRowDto({required this.id, required this.title, 
    required this.text, required this.startTime});

  ///convert json to model, static for be parameter !!
  static MsgRowDto fromJson(Map json){
    return MsgRowDto(
      id : json['Id'],
      title : json['Title'],
      text : json['Text'],
      startTime : json['StartTime'],
    );
  }

}