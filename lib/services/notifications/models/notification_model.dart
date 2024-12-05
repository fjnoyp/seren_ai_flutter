class NotificationModel {
  final int id;
  final String title;
  final String body;
  final DateTime _scheduledDate;

  DateTime get scheduledDate => _scheduledDate.toLocal();

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required DateTime scheduledDate,
  }) : _scheduledDate = scheduledDate;

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      body: json['body'],
      scheduledDate: DateTime.parse(json['scheduled_date'])
          .add(DateTime.now().timeZoneOffset),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'scheduled_date': _scheduledDate.toIso8601String(),
    };
  }
}
