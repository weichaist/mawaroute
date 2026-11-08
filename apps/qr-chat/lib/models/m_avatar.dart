class MAvatarModel {
  final String? id;
  final String name;
  final String imageUrl;
  final String description;
  final String expertise;
  final String creatorName;
  final String avatarDefinition;
  final String greetingPrompt;
  final String recPrompt;
  final String rfrPrompt;
  MAvatarModel({
    this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.expertise,
    required this.creatorName,
    required this.avatarDefinition,
    required this.greetingPrompt,
    required this.recPrompt,
    required this.rfrPrompt,
  });

  factory MAvatarModel.fromJson(Map<String, dynamic> json, String id) {
    return MAvatarModel(
      id: id,
      name: json["name"],
      imageUrl: json["imageUrl"],
      description: json["description"],
      expertise: json["expertise"],
      creatorName: json["creatorName"],
      avatarDefinition: json["avatarDefinition"] ?? '',
      greetingPrompt: json["chatStarterPrompt"] ?? '',
      recPrompt: json["recPrompt"] ?? '',
      rfrPrompt: json["rfrPrompt"] ?? '',
    );
  }
}

final emptyMAvatarModel = MAvatarModel(
  id: null,
  name: '',
  imageUrl: '',
  description: '',
  expertise: '',
  creatorName: '',
  greetingPrompt: '',
  avatarDefinition: '',
  recPrompt: '',
  rfrPrompt: '',
);
