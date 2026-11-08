class GoogleMap {
  final String name;
  final String placeId;
  final String formattedAddress;
  final double lat;
  final double lng;
  GoogleMap({
    required this.name,
    required this.placeId,
    required this.formattedAddress,
    required this.lat,
    required this.lng,
  });

  factory GoogleMap.fromJson(Map<String, dynamic> json) {
    return GoogleMap(
      name: json["name"],
      placeId: json["place_id"],
      formattedAddress: json["formatted_address"],
      lat: json["geometry"]["location"]["lat"],
      lng: json["geometry"]["location"]["lng"],
    );
  }
}
