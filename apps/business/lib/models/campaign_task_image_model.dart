class CampaignTaskImageModel {
  final String? uid;
  final String userUid;
  final String imageLink;
  final String downloadUrl;
  final double lat;
  final double lng;
  final DateTime createdAt;
  final String? shopUid; // Only utility

  CampaignTaskImageModel({
    this.uid,
    required this.userUid,
    required this.imageLink,
    required this.downloadUrl,
    required this.lat,
    required this.lng,
    required this.createdAt,
    this.shopUid = "",
  });
  factory CampaignTaskImageModel.fromJson(
      Map<String, dynamic> json, String uid) {
    return CampaignTaskImageModel(
      uid: uid,
      userUid: json["userUid"],
      imageLink: json["imageLink"],
      downloadUrl: json["downloadUrl"],
      lat: json["lat"],
      lng: json["lng"],
      createdAt: json["createdAt"].toDate(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "userUid": userUid,
      "imageLink": imageLink,
      "downloadUrl": downloadUrl,
      "lat": lat,
      "lng": lng,
      "createdAt": createdAt,
    };
  }
}
