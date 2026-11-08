import '../enums.dart';

class CampaignModel {
  final String? uid;
  final String title;
  final String description;
  final String imageLink;
  final String downloadUrl;
  final String bannerImageLink;
  final String bannerDownloadUrl;
  final DateTime startTime;
  final String creatorUid;
  final String placeUid;
  final String taskType;
  final String targetUser;
  final String status;
  final int taskCount;
  final DateTime createdAt;
  final int? campaignTimeLimit;
  final int? maximumTaskNumber;
  final double? lat;
  final double? lng;
  final String? geoHash;
  CampaignModel({
    this.uid,
    required this.title,
    required this.description,
    required this.imageLink,
    required this.downloadUrl,
    required this.bannerImageLink,
    required this.bannerDownloadUrl,
    required this.startTime,
    required this.creatorUid,
    required this.placeUid,
    required this.taskType,
    required this.targetUser,
    required this.status,
    required this.taskCount,
    required this.createdAt,
    this.campaignTimeLimit,
    this.maximumTaskNumber,
    this.lat,
    this.lng,
    this.geoHash,
  });

  factory CampaignModel.fromJson(Map<String, dynamic> json, String uid) {
    return CampaignModel(
      uid: uid,
      title: json['title'],
      description: json['description'],
      imageLink: json['imageLink'],
      downloadUrl: json['downloadUrl'],
      bannerImageLink: json['bannerImageLink'] ?? '',
      bannerDownloadUrl: json['bannerDownloadUrl'] ?? '',
      startTime: json['startTime'].toDate(),
      creatorUid: json['creatorUid'],
      placeUid: json['placeUid'],
      taskType: json['taskType'],
      targetUser: json['targetUser'],
      status: json['status'],
      taskCount: json['taskCount'],
      createdAt: json['createdAt'].toDate(),
      campaignTimeLimit: json['campaignTimeLimit'],
      maximumTaskNumber: json['maximumTaskNumber'],
      lat: json['lat'],
      lng: json['lng'],
      geoHash: json['geoHash'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'imageLink': imageLink,
      'downloadUrl': downloadUrl,
      'bannerImageLink': bannerImageLink,
      'bannerDownloadUrl': bannerDownloadUrl,
      'startTime': startTime,
      'creatorUid': creatorUid,
      'placeUid': placeUid,
      'taskType': taskType,
      'targetUser': targetUser,
      "status": status,
      'taskCount': taskCount,
      'createdAt': createdAt,
      'campaignTimeLimit': campaignTimeLimit,
      'maximumTaskNumber': maximumTaskNumber,
      'lat': lat,
      'lng': lng,
      'geoHash': geoHash
    };
  }
}

final emptyCampaignModel = CampaignModel(
  title: '',
  description: '',
  imageLink: '',
  downloadUrl: '',
  bannerImageLink: '',
  bannerDownloadUrl: '',
  startTime: DateTime.now(),
  creatorUid: '',
  placeUid: '',
  taskType: '',
  targetUser: '',
  status: CampaignStatus.draft.name,
  taskCount: 0,
  createdAt: DateTime.now(),
  campaignTimeLimit: null,
  maximumTaskNumber: null,
  lat: null,
  lng: null,
  geoHash: null,
);
