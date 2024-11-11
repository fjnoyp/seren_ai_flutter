class LgConfigSchemaModel {
  final String userId;
  final String orgId;
  final int timezoneOffsetMinutes;
  final String language;

  const LgConfigSchemaModel({
    required this.userId,
    required this.orgId, 
    required this.timezoneOffsetMinutes,
    required this.language,
  });

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'org_id': orgId,
    'timezone_offset_minutes': timezoneOffsetMinutes,
    'language': language,
  };

}
