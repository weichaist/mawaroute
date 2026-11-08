class RewardReceiverModel {
  final String? uid;
  final String email;
  final String receiver;
  final String rewardUid;
  final DateTime timestamp;
  final int tokenTransferred;

  RewardReceiverModel({
    this.uid,
    required this.email,
    required this.receiver,
    required this.rewardUid,
    required this.timestamp,
    required this.tokenTransferred,
  });

  factory RewardReceiverModel.fromJson(Map<String, dynamic> json, String uid) {
    return RewardReceiverModel(
      uid: uid,
      email: json["email"],
      receiver: json["receiver"],
      rewardUid: json["rewardUid"],
      timestamp: json["timestamp"].toDate(),
      tokenTransferred: json["tokenTransferred"],
    );
  }
}
