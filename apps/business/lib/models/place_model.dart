class PlaceModel {
  String? uid;
  final String name;
  final String address;
  final String imageLink;
  final String downloadUrl;
  final String profileUrl;
  final double lat;
  final double lng;
  final String? geoHash;
  final bool isPublic;

  PlaceModel({
    this.uid,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.geoHash,
    required this.imageLink,
    required this.downloadUrl,
    required this.profileUrl,
    this.isPublic = false,
  });
  factory PlaceModel.fromJson(Map<String, dynamic> json, String uid) {
    return PlaceModel(
      uid: uid,
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      lat: json['_geoloc'] != null ? json['_geoloc']['lat'] : 0,
      lng: json['_geoloc'] != null ? json['_geoloc']['lng'] : 0,
      geoHash: json['geoHash'] ?? '',
      imageLink: json['imageLink'] ?? '',
      downloadUrl: json['downloadUrl'] ?? '',
      profileUrl: json['profileUrl'] ?? '',
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      '_geoloc': {
        'lat': lat,
        'lng': lng,
      },
      'geoHash': geoHash,
      'imageLink': imageLink,
      'downloadUrl': downloadUrl,
      'profileUrl': profileUrl,
      'isPublic': isPublic,
    };
  }
}

final emptyPlaceModel = PlaceModel(
  uid: '',
  name: '',
  address: '',
  lat: 0.0,
  lng: 0.0,
  geoHash: '',
  imageLink: '',
  downloadUrl: '',
  profileUrl: '',
  isPublic: false,
);
