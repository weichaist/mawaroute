class PlaceModel {
  final String? uid;
  final String name;
  final String address;
  final String imageLink;
  final String downloadUrl;
  final String profileUrl;
  final double lat;
  final double lng;
  final bool isPublic;

  PlaceModel({
    this.uid,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.imageLink,
    required this.downloadUrl,
    required this.profileUrl,
    this.isPublic = false,
  });
  factory PlaceModel.fromJson(Map<String, dynamic> json, String uid) {
    return PlaceModel(
      uid: uid,
      name: json['name'],
      address: json['address'],
      lat: double.parse(json['_geoloc']['lat'].toString()),
      lng: double.parse(json['_geoloc']['lng'].toString()),
      imageLink: json['imageLink'],
      downloadUrl: json['downloadUrl'],
      profileUrl: json['profileUrl'],
    );
  }
}

final emptyPlaceModel = PlaceModel(
  uid: '',
  name: '',
  address: '',
  lat: 0.0,
  lng: 0.0,
  imageLink: '',
  downloadUrl: '',
  profileUrl: '',
  isPublic: false,
);
