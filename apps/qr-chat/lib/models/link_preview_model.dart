class LinkPreviewModel {
  final String title;
  final String description;
  final String image;
  LinkPreviewModel({
    required this.title,
    required this.description,
    required this.image,
  });

  factory LinkPreviewModel.fromJson(Map<String, dynamic> json, baseUrl) {
    String imageUrl = json["image"] ?? "";
    if (!Uri.parse(imageUrl).isAbsolute) {
      imageUrl = Uri.parse(baseUrl).resolve(imageUrl).toString();
    }
    return LinkPreviewModel(
      title: json["title"] ?? "",
      description: json["description"] ?? "",
      image: imageUrl,
    );
  }
}

final emptyLinkPreviewModel = LinkPreviewModel(
  title: '',
  image: '',
  description: '',
);
