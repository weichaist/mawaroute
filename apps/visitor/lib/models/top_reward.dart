class TopReward {
  final String? uid;
  final String bgUrl;
  // final DateTime expiryDate;
  final bool isLive;
  final String title;
  final String description;
  final String type;
  final String condition;
  TopReward({
    this.uid,
    required this.bgUrl,
    required this.description,
    required this.isLive,
    required this.type,
    required this.condition,
    required this.title,
  });

  factory TopReward.fromJson(Map<String, dynamic> json, String id) {
    return TopReward(
      uid: id,
      bgUrl: json['bgUrl'],
      // expiryDate: json['expiryDate'].toDate(),
      isLive: json['isLive'],
      description: json['description'],
      type: json['type'],
      condition: json['condition'],
      title: json['title'],
    );
  }
}

final emptyTopReward = TopReward(
  uid: "",
  bgUrl: "",
  // expiryDate: DateTime.now(),
  isLive: false,
  description: '',
  condition: '',
  type: '',
  title: "",
);
