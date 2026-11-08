import 'package:cloud_firestore/cloud_firestore.dart';

import '../enums.dart';

class ShopModel {
  final String? uid;
  final String name;
  final String placeName;
  final String placeUid;
  final String description;
  final String address;
  final String homepageLink;
  final num creditBalance;
  final String status;
  final DateTime createdAt;
  final num? lat;
  final num? lng;
  final String? geoHash;
  final List<String> tags;
  final String? imageLink;
  final String? downloadUrl;
  ShopModel({
    this.uid,
    required this.name,
    required this.placeName,
    required this.placeUid,
    required this.creditBalance,
    required this.status,
    required this.createdAt,
    required this.description,
    required this.address,
    required this.homepageLink,
    this.lat,
    this.lng,
    this.geoHash,
    required this.tags,
    this.imageLink = "",
    this.downloadUrl = "",
  });

  factory ShopModel.fromJson(Map<String, dynamic> json, String uid) {
    dynamic getValue({required json, required key, defaultValue = ""}) {
      return json.containsKey(key) ? json[key] : defaultValue;
    }

    dynamic formattedTimestamp(String key) {
      final val = getValue(json: json, key: key, defaultValue: null);
      if (val != null) {
        if (val is Timestamp) {
          return val.toDate();
        } else {
          return DateTime.fromMillisecondsSinceEpoch(
              (Map<String, dynamic>.from(val)['_seconds'] * 1000 +
                      Map<String, dynamic>.from(val)['_nanoseconds'] / 1000000)
                  .toInt());
        }
      } else {
        return null;
      }
    }

    return ShopModel(
      uid: uid,
      name: json['name'],
      placeName: json['placeName'],
      placeUid: json['placeUid'],
      creditBalance: json['creditBalance'],
      status: json['status'],
      createdAt: formattedTimestamp('createdAt'),
      lat: json['_geoloc']['lat'],
      lng: json['_geoloc']['lng'],
      geoHash: json['geoHash'],
      tags: json['tags'].map<String>((e) => e.toString()).toList(),
      address: json['address'],
      homepageLink: json['homepageLink'],
      description: json['description'],
      imageLink: json['imageLink'],
      downloadUrl: json['downloadUrl'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
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
    };
  }
}

final emptyShopModel = ShopModel(
  uid: '',
  name: '',
  placeName: '',
  placeUid: '',
  homepageLink: '',
  description: '',
  address: '',
  creditBalance: 0,
  status: ShopStatusType.notOnBoarded.name,
  createdAt: DateTime.now(),
  lat: null,
  lng: null,
  geoHash: '',
  tags: [],
  imageLink: "",
  downloadUrl: "",
);
