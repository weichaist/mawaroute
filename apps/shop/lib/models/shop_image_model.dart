class ShopImageModel {
  final String? uid;
  final String imageLink;
  final String downloadUrl;
  final String shopUid;
  final int index;
  final DateTime createdAt;
  ShopImageModel({
    this.uid,
    required this.imageLink,
    required this.downloadUrl,
    required this.shopUid,
    required this.index,
    required this.createdAt,
  });

  factory ShopImageModel.fromJson(Map<String, dynamic> json, String uid) {
    return ShopImageModel(
      uid: uid,
      imageLink: json['imageLink'],
      downloadUrl: json['downloadUrl'],
      shopUid: json['shopUid'],
      index: json['index'],
      createdAt: json['createdAt'].toDate(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'imageLink': imageLink,
      'downloadUrl': downloadUrl,
      'shopUid': shopUid,
      'index': index,
      'createdAt': createdAt,
    };
  }
}

final emptyShopImageModel = ShopImageModel(
  imageLink: '',
  downloadUrl: '',
  shopUid: '',
  index: 0,
  createdAt: DateTime.now(),
);
