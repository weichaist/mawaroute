class MUserCredential {
  final String? id;
  final String key;
  final String email;
  final String fcmToken;
  MUserCredential({
    this.id,
    required this.key,
    required this.email,
    required this.fcmToken,
  });

  factory MUserCredential.fromJson(Map<String, dynamic> json, String id) {
    return MUserCredential(
      id: id,
      key: json['key'] ?? '',
      email: json['email'] ?? '',
      fcmToken: json['fcmToken'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {'key': key, 'email': email, 'fcmKey': fcmToken};
  }
}

final emptyMUserCredential = MUserCredential(
  id: '',
  key: '',
  email: '',
  fcmToken: '',
);
