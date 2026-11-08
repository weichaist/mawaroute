class ImageLabel {
  final String description;
  final double score;
  ImageLabel({required this.description, required this.score});

  factory ImageLabel.fromJson(Map<dynamic, dynamic> json) {
    return ImageLabel(description: json["description"], score: json["score"]);
  }
}

final emptyImageLabel = ImageLabel(description: "", score: 0);
