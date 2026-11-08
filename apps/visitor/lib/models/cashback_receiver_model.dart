class CashbackReceiverModel {
  final String? uid;
  final String rewardUid;
  final String receiver;
  final DateTime timestamp;
  final String email;
  final int tokenTransferred;
  final int cashBackAmount;
  // final String status;
  final bool sent;

  CashbackReceiverModel({
    this.uid,
    required this.rewardUid,
    required this.receiver,
    required this.timestamp,
    required this.email,
    required this.tokenTransferred,
    required this.cashBackAmount,
    // required this.status,
    required this.sent,
  });

  factory CashbackReceiverModel.fromJson(
    Map<String, dynamic> json,
    String uid,
  ) {
    return CashbackReceiverModel(
      uid: uid,
      rewardUid: json["rewardUid"],
      receiver: json["receiver"],
      timestamp: json["timestamp"].toDate(),
      email: json["email"],
      tokenTransferred: json["tokenTransferred"],
      cashBackAmount: json["cashBackAmount"],
      // status: json["sent"] ?? false,
      sent: json["sent"] ?? false,
    );
  }
}
