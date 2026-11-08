import '../enums.dart';

class RewardModel {
  final String? uid;
  final String placeUid;
  final String title;
  final String description;
  final String imageLink;
  final String downloadUrl;
  final String status;
  final String rewardDistributionType;
  final DateTime startTime;
  final DateTime endTime;
  final int tokenNumber;
  final int upperLimit;
  final int maxNumberPerUser;
  final String couponShopUid;
  final String couponShopGeoHash;

  RewardModel({
    this.uid,
    required this.placeUid,
    required this.title,
    required this.description,
    required this.imageLink,
    required this.downloadUrl,
    required this.status,
    required this.rewardDistributionType,
    required this.startTime,
    required this.endTime,
    required this.tokenNumber,
    required this.upperLimit,
    required this.maxNumberPerUser,
    required this.couponShopUid,
    required this.couponShopGeoHash,
  });
  factory RewardModel.fromJson(Map<String, dynamic> json, String uid) {
    return RewardModel(
      uid: uid,
      placeUid: json['placeUid'],
      title: json['title'],
      description: json['description'],
      imageLink: json['imageLink'],
      downloadUrl: json['downloadUrl'],
      status: json['status'],
      rewardDistributionType:
          json['rewardDistributionType'] ?? RewardDistributionType.email.name,
      startTime: json['startTime'].toDate(),
      endTime: json['endTime'].toDate(),
      tokenNumber: json['tokenNumber'] ?? 5,
      upperLimit: json['upperLimit'] ?? 0,
      maxNumberPerUser: json['maxNumberPerUser'] ?? 1,
      couponShopUid: json['couponShopUid'] ?? "",
      couponShopGeoHash: json['couponShopGeoHash'] ?? "",
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'placeUid': placeUid,
      'title': title,
      'description': description,
      'imageLink': imageLink,
      'downloadUrl': downloadUrl,
      'status': status,
      'rewardDistributionType': rewardDistributionType,
      'startTime': startTime,
      'endTime': endTime,
      'tokenNumber': tokenNumber,
      'upperLimit': upperLimit,
      'maxNumberPerUser': maxNumberPerUser,
      'couponShopUid': couponShopUid,
      'couponShopGeoHash': couponShopGeoHash,
    };
  }
}

final emptyReward = RewardModel(
  uid: '',
  placeUid: '',
  title: '',
  description: '',
  imageLink: '',
  downloadUrl: '',
  status: RewardType.active.name,
  rewardDistributionType: RewardDistributionType.email.name,
  startTime: DateTime.now(),
  endTime: DateTime.now(),
  tokenNumber: 0,
  upperLimit: 0,
  maxNumberPerUser: 1,
  couponShopUid: "",
  couponShopGeoHash: "",
);
