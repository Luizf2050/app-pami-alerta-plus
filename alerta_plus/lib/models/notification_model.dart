class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type;
  final DateTime dateTime;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.dateTime,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'dateTime': dateTime.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory NotificationModel.fromMap(
    Map<String, dynamic> map,
  ) {
    final dateTimeValue = map['dateTime']?.toString() ?? '';
    final readValue = map['isRead'];

    return NotificationModel(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      type: map['type']?.toString() ?? 'mensagem',
      dateTime: DateTime.tryParse(dateTimeValue) ?? DateTime.now(),
      isRead: readValue is bool ? readValue : false,
    );
  }
}
