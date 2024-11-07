class LgAiRequestResultModel {
  final String message;
  final bool showOnly;

  LgAiRequestResultModel({
    required this.message,
    required this.showOnly,
  });

  Map<String, dynamic> toJson() => {
        'message': message,
        'showOnly': showOnly,
      };
}