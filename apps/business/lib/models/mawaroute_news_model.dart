class MawarouteNewsModel {
  final String? uid;
  final String body;
  final String leadingIcon;
  final String link;
  final String title;
  final DateTime timestamp;
  MawarouteNewsModel({
    this.uid,
    required this.body,
    required this.leadingIcon,
    required this.link,
    required this.title,
    required this.timestamp,
  });

  factory MawarouteNewsModel.fromJson(Map<String, dynamic> json, String uid) {
    return MawarouteNewsModel(
      uid: uid,
      body: json["body"],
      leadingIcon: json["leadingIcon"],
      link: json["link"],
      title: json["title"],
      timestamp: json["timestamp"].toDate(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "body": body,
      "leadingIcon": leadingIcon,
      "link": link,
      "title": title,
      "timestamp": timestamp,
    };
  }
}

final emptyNews = MawarouteNewsModel(
  body: '',
  leadingIcon: '',
  link: '',
  title: '',
  timestamp: DateTime.now(),
);
