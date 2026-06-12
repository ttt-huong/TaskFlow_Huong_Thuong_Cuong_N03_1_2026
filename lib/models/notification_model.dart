class NotificationModel {
  final String id;
  final String userId;
  final String? relatedTaskId;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final String type;

  NotificationModel({
    required this.id,
    required this.userId,
    this.relatedTaskId,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    required this.type,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      userId: map['userId'] ?? '',
      relatedTaskId: map['relatedTaskId'],
      title: map['title'],
      message: map['message'],
      createdAt: DateTime.parse(map['createdAt']),
      isRead: map['isRead'] == 1,
      type: map['type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'relatedTaskId': relatedTaskId,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead ? 1 : 0,
      'type': type,
    };
  }

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      userId: userId,
      relatedTaskId: relatedTaskId,
      title: title,
      message: message,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      type: type,
    );
  }
}
