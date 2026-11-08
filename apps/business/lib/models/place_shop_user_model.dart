import '../enums.dart';

class PlaceShopUserModel {
  final String? uid;
  final String email;
  final String status;
  final DateTime timestamp;
  PlaceShopUserModel({
    this.uid,
    required this.email,
    required this.status,
    required this.timestamp,
  });

  factory PlaceShopUserModel.fromJson(Map<String, dynamic> json, String uid) {
    return PlaceShopUserModel(
      uid: uid,
      email: json['email'],
      status: json['status'],
      timestamp: json['timestamp'].toDate(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'status': status,
      'timestamp': timestamp,
    };
  }
}

final emptyPlaceShopUserModel = PlaceShopUserModel(
  email: "",
  status: ShopStatusType.sent.name,
  timestamp: DateTime.now(),
);
