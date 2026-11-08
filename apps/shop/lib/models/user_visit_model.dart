class UserVisitModel {
  final String? uid;
  final String visitorUid;
  final String campaignUid;
  final String taskUid;
  final String placeUid;
  final String shopUid;
  final DateTime visitTime;
  final String visitorName;
  final String visitorProfile;
  final List<String> visitorTags;

  UserVisitModel({
    this.uid,
    required this.visitorUid,
    required this.campaignUid,
    required this.taskUid,
    required this.placeUid,
    required this.shopUid,
    required this.visitTime,
    required this.visitorName,
    required this.visitorProfile,
    required this.visitorTags,
  });

  factory UserVisitModel.fromJson(Map<String, dynamic> json, String uid) {
    return UserVisitModel(
      uid: uid,
      visitorUid: json['visitorUid'],
      campaignUid: json['campaignUid'],
      taskUid: json['taskUid'],
      placeUid: json['placeUid'],
      shopUid: json['shopUid'],
      visitTime: json['visitTime'].toDate(),
      visitorName: json['visitorName'],
      visitorProfile: json['visitorProfile'],
      visitorTags:
          json['visitorTags'].map<String>((e) => e.toString()).toList(),
    );
  }
}
