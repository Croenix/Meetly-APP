class NotificationItem {
  final String id;
  final String userId;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isRead;
  final String type; // 'booking_accepted', 'booking_reminder', 'new_message', 'review_request'

  const NotificationItem({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.isRead,
    required this.type,
  });

  NotificationItem copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? timestamp,
    bool? isRead,
    String? type,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'type': type,
    };
  }

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['isRead'] as bool,
      type: json['type'] as String,
    );
  }
}
