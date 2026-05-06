import 'package:harvest/core/utils/utils.dart';

class NoticeHistory {
  final int id;
  final String title;
  final String content;
  final String? url;
  final bool isRead;
  final String? createdAt;
  final String? updatedAt;

  const NoticeHistory({
    required this.id,
    required this.title,
    required this.content,
    required this.isRead,
    this.url,
    this.createdAt,
    this.updatedAt,
  });

  factory NoticeHistory.fromJson(Map<String, dynamic> json) {
    return NoticeHistory(
      id: parseInt(json['id']),
      title: '${json['title'] ?? ''}',
      content: '${json['content'] ?? ''}',
      url: parseNullableString(json['url']),
      isRead: parseBool(json['is_read']),
      createdAt: parseNullableString(
        json['created_at'] ?? json['create_time'] ?? json['created'],
      ),
      updatedAt: parseNullableString(
        json['updated_at'] ?? json['update_time'] ?? json['updated'],
      ),
    );
  }

  NoticeHistory copyWith({
    int? id,
    String? title,
    String? content,
    String? url,
    bool? isRead,
    String? createdAt,
    String? updatedAt,
  }) {
    return NoticeHistory(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      url: url ?? this.url,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
