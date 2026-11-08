//To log when user start to earn and when all tasks in campaign are cleared
//Also used for ranking tabview to list up who finish the campaign the earliest
class RewardParticipantModel {
  final String? uid;
  final String rewardUid;
  final String participantUid;
  final String rewardTitle;
  final DateTime participatedAt;
  final DateTime rewardDeadline;
  RewardParticipantModel({
    this.uid,
    required this.participantUid,
    required this.rewardUid,
    required this.rewardDeadline,
    required this.rewardTitle,
    required this.participatedAt,
  });
  factory RewardParticipantModel.fromJson(
    Map<String, dynamic> json,
    String uid,
  ) {
    return RewardParticipantModel(
      uid: uid,
      participantUid: json['participantUid'],
      rewardUid: json['rewardUid'],
      rewardDeadline: json['rewardDeadline'].toDate(),
      rewardTitle: json['rewardTitle'],
      participatedAt: json['participatedAt'].toDate(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'participantUid': participantUid,
      'rewardUid': rewardUid,
      'rewardDeadline': rewardDeadline,
      'rewardTitle': rewardTitle,
      'participatedAt': participatedAt,
    };
  }
}
