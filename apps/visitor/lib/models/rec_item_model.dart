class RecItem {
  final String uid;
  final String title;
  final String description;
  final String link;
  final double? price; // Nullable price
  final Map? geo;

  RecItem({
    required this.uid,
    required this.title,
    required this.description,
    required this.link,
    this.price,
    this.geo,
  });

  factory RecItem.fromJson(Map<String, dynamic> json, String uid) {
    return RecItem(
      uid: uid,
      title: json["title"],
      description: json["description"],
      link: json["link"],
      price: json["price"] != null
          ? double.tryParse(json["price"].toString())
          : null,
      geo: json['geo'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "link": link,
      "price": price,
    };
  }
}

final emptyRecItem = RecItem(
  uid: "",
  title: "",
  description: "",
  link: "",
  price: null,
  geo: null,
);
