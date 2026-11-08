class RewardReceiverModel {
  final String uid;
  final String rewardUid;
  final String email;
  final String receiver;
  final DateTime timestamp;
  final int tokenTransferred;
  final bool applied;
  RewardReceiverModel({
    required this.uid,
    required this.rewardUid,
    required this.email,
    required this.receiver,
    required this.timestamp,
    required this.tokenTransferred,
    required this.applied,
  });
  factory RewardReceiverModel.fromJson(Map<String, dynamic> json, String uid) {
    return RewardReceiverModel(
      uid: uid,
      rewardUid: json["rewardUid"],
      email: json["email"],
      receiver: json["receiver"],
      timestamp: json["timestamp"].toDate(),
      tokenTransferred: json["tokenTransferred"],
      applied: json["applied"] ?? false,
    );
  }
}
