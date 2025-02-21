class LgConfigSchemaModel {
  //final String userId;
  //final String orgId;
  final int timezoneOffsetMinutes;
  //final ConversationType conversationType;
  //final String language;

  const LgConfigSchemaModel({
    //required this.userId,
    //required this.orgId,
    required this.timezoneOffsetMinutes,
    //this.conversationType = ConversationType.chat,
    //required this.language,
  });

  Map<String, dynamic> toJson() => {
        //'user_id': userId,
        //'org_id': orgId,
        'timezone_offset_minutes': timezoneOffsetMinutes,
        //'conversation_type': conversationType.name,
        //'language': language,
      };
}
