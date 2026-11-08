import 'package:file_picker/file_picker.dart';

class CampaignTaskModel {
  final PlatformFile? image;
  final String description;
  final double lat;
  final double lng;
  final String? imageLink;
  final String? downloadUrl;
  final int index;
  final String? shopUid;

  CampaignTaskModel({
    this.image,
    required this.description,
    required this.lat,
    required this.lng,
    this.imageLink,
    this.downloadUrl,
    required this.index,
    this.shopUid = "",
  });

  factory CampaignTaskModel.fromJson(Map<String, dynamic> json) {
    return CampaignTaskModel(
      description: json['description'],
      lat: json['lat'],
      lng: json['lng'],
      imageLink: json['imageLink'],
      downloadUrl: json['downloadUrl'],
      index: json['index'],
      shopUid: json['shopUid'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'lat': lat,
      'lng': lng,
      'imageLink': imageLink,
      'downloadUrl': downloadUrl,
      'index': index,
      'shopUid': shopUid,
    };
  }
}

final emptyCampaignTask = CampaignTaskModel(
  downloadUrl: "",
  description: "",
  lat: 0,
  lng: 0,
  index: 0,
  shopUid: "",
);
