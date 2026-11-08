class MawarouteNewsModel {
  final String id;
  final String leadingIcon;
  final String link;
  final String title;
  final String body;
  final DateTime timestamp;
  MawarouteNewsModel({
    required this.id,
    required this.leadingIcon,
    required this.link,
    required this.title,
    required this.timestamp,
    required this.body,
  });

  factory MawarouteNewsModel.fromJson(Map<String, dynamic> json, String id) {
    return MawarouteNewsModel(
      id: id,
      leadingIcon: json["leadingIcon"],
      link: json["link"],
      title: json["title"],
      body: json["body"],
      timestamp: json["timestamp"].toDate(),
    );
  }
}
