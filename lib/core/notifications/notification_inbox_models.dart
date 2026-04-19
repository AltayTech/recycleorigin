/// One row from GET /notifications `items`.
class UserNotificationItem {
  UserNotificationItem({
    required this.id,
    required this.title,
    required this.body,
    required this.category,
    required this.createdAt,
    this.readAt,
    this.deepLink,
    this.dataJson,
  });

  final int id;
  final String title;
  final String body;
  final String category;
  final String createdAt;
  final String? readAt;
  final String? deepLink;
  final String? dataJson;

  factory UserNotificationItem.fromJson(Map<String, dynamic> j) {
    return UserNotificationItem(
      id: int.tryParse('${j['id'] ?? j['ID'] ?? 0}') ?? 0,
      title: j['Title'] as String? ?? j['title'] as String? ?? '',
      body: j['Body'] as String? ?? j['body'] as String? ?? '',
      category: j['Category'] as String? ?? j['category'] as String? ?? '',
      createdAt: j['CreatedAt']?.toString() ?? j['created_at']?.toString() ?? '',
      readAt: j['ReadAt']?.toString() ?? j['read_at']?.toString(),
      deepLink: j['DeepLink'] as String? ?? j['deep_link'] as String?,
      dataJson: j['DataJSON'] as String? ?? j['data_json'] as String?,
    );
  }

  bool get isRead => readAt != null && readAt!.isNotEmpty;
}
