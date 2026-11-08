import '../utils/enums.dart';

class ShopModel {
  final String? uid;
  final String managerUid;
  final String name;
  final String placeName;
  final String placeUid;
  final String description;
  final String userDescription;
  final String address;
  final String homepageLink;
  final num creditBalance;
  final String status;
  final DateTime createdAt;
  final double? lat;
  final double? lng;
  final String? geoHash;
  final List<String> tags;
  final String? imageLink;
  final String? downloadUrl;
  final bool isLive;
  final Map<String, dynamic> timeTable;
  final int purchaseTokenReward;
  ShopModel({
    this.uid,
    required this.managerUid,
    required this.name,
    required this.placeName,
    required this.placeUid,
    required this.creditBalance,
    required this.status,
    required this.createdAt,
    required this.description,
    required this.userDescription,
    required this.address,
    required this.homepageLink,
    this.lat,
    this.lng,
    this.geoHash,
    required this.tags,
    this.imageLink = "",
    this.downloadUrl = "",
    required this.isLive,
    this.timeTable = const {},
    this.purchaseTokenReward = 1,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json, String uid) {
    Map<String, dynamic> timeTable = {};
    for (String day in days) {
      String key = day.substring(0, 3);
      for (String timeKey in ["open", "close"]) {
        timeTable["${key}_$timeKey"] = json["${key}_$timeKey"];
      }
    }
    return ShopModel(
      uid: uid,
      managerUid: json['managerUid'],
      name: json['name'],
      placeName: json['placeName'],
      placeUid: json['placeUid'],
      creditBalance: json['creditBalance'],
      status: json['status'],
      createdAt: json['createdAt'].toDate(),
      lat: json['_geoloc'] == null ? null : json['_geoloc']['lat'],
      lng: json['_geoloc'] == null ? null : json['_geoloc']['lng'],
      geoHash: json['geoHash'],
      tags: json['tags'].map<String>((e) => e.toString()).toList(),
      address: json['address'],
      homepageLink: json['homepageLink'],
      description: json['description'],
      userDescription: json['userDescription'] ?? "",
      imageLink: json['imageLink'],
      downloadUrl: json['downloadUrl'],
      isLive: json['isLive'] ?? false,
      timeTable: timeTable,
      purchaseTokenReward: json['purchaseTokenReward'] ?? 1,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'managerUid': managerUid,
      'name': name,
      'placeName': placeName,
      'placeUid': placeUid,
      'creditBalance': creditBalance,
      "status": status,
      'createdAt': createdAt,
      '_geoloc': {
        'lat': lat,
        'lng': lng,
      },
      'geoHash': geoHash,
      'tags': tags,
      'imageLink': imageLink,
      'downloadUrl': downloadUrl,
      'address': address,
      'homepageLink': homepageLink,
      'description': description,
      'userDescription': userDescription,
      'purchaseTokenReward': purchaseTokenReward,
    };
  }
}

final emptyShopModel = ShopModel(
  managerUid: '',
  name: '',
  placeName: '',
  placeUid: '',
  homepageLink: '',
  description: '',
  userDescription: '',
  address: '',
  creditBalance: 0,
  status: ShopStatusType.notOnBoarded.name,
  createdAt: DateTime.now(),
  lat: null,
  lng: null,
  geoHash: null,
  tags: [],
  imageLink: "",
  downloadUrl: "",
  isLive: false,
  timeTable: {},
  purchaseTokenReward: 1,
);
