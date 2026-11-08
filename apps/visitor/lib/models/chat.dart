class ChatModel {
  final String? id;
  final String avatarUid;
  final String avatarProfileUrl;
  final DateTime createdAt;
  final bool deleted;
  final String query;
  ChatModel({
    this.id,
    required this.avatarProfileUrl,
    required this.avatarUid,
    required this.createdAt,
    required this.deleted,
    required this.query,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json, String id) {
    return ChatModel(
      id: id,
      avatarProfileUrl: json["avatarUrl"],
      avatarUid: json["avatarUid"],
      createdAt: json["createdAt"].toDate(),
      deleted: json["deleted"],
      query: json["query"],
    );
  }
}

final emptyChatModel = ChatModel(
  avatarProfileUrl: '',
  avatarUid: '',
  createdAt: DateTime.now(),
  deleted: false,
  query: '',
);
