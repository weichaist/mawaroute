class MUser {
  final String? id;
  final String displayName;
  final String image;
  final String publicAddress;
  final DateTime signInAt;
  MUser({
    this.id,
    required this.displayName,
    this.image = "",
    required this.publicAddress,
    required this.signInAt,
  });

  factory MUser.fromJson(Map<String, dynamic> json, String id) {
    return MUser(
      id: id,
      displayName: json['display_name'],
      image: json['image'],
      publicAddress: json['public_address'],
      signInAt: json['sign_in_at'].toDate(),
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'image': image,
      'public_address': publicAddress,
      'sign_in_at': signInAt,
    };
  }
}

final emptyMUser = MUser(
  displayName: "",
  publicAddress: "",
  signInAt: DateTime.now(),
);
