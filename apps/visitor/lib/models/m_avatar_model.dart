class MAvatarModel {
  final String? id;
  final String name;
  final String imageUrl;
  final String description;
  final String expertise;
  final DateTime createdAt;
  final bool isLive;
  final String creatorUid;
  final String creatorName;
  final int chatCount;
  final int knowledgePointCounter;
  final String chatStarterPrompt;
  final String recPrompt;
  final String visionPrompt;
  final bool proAvatar;
  MAvatarModel({
    this.id,
    required this.name,
    required this.imageUrl,
    required this.description,
    required this.expertise,
    required this.createdAt,
    required this.creatorName,
    required this.chatStarterPrompt,
    required this.recPrompt,
    required this.visionPrompt,
    this.creatorUid = '',
    this.isLive = false,
    this.proAvatar = false,
    this.chatCount = 0,
    this.knowledgePointCounter = 0,
  });

  factory MAvatarModel.fromJson(Map<String, dynamic> json, String id) {
    return MAvatarModel(
      id: id,
      name: json["name"],
      imageUrl: json["imageUrl"],
      description: json["description"],
      expertise: json["expertise"],
      createdAt: json["createdAt"].toDate(),
      creatorUid: json["creatorUid"],
      creatorName: json["creatorName"],
      chatCount: json["chatCount"] ?? 0,
      knowledgePointCounter: json["knowledgePointCounter"] ?? 0,
      chatStarterPrompt: json["chatStarterPrompt"] ?? '',
      recPrompt: json["recPrompt"] ?? '',
      visionPrompt: json["visionPrompt"] ?? '',
      proAvatar: json["proAvatar"] ?? false,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "imageUrl": imageUrl,
      "description": description,
      "expertise": expertise,
      "createdAt": createdAt,
      "isLive": isLive,
      "creatorUid": creatorUid,
      "creatorName": creatorName,
    };
  }
}

final emptyMAvatarModel = MAvatarModel(
  id: null,
  name: '',
  imageUrl: '',
  description: '',
  expertise: '',
  createdAt: DateTime.now(),
  isLive: false,
  creatorName: '',
  creatorUid: '',
  chatCount: 0,
  knowledgePointCounter: 0,
  chatStarterPrompt: '',
  recPrompt: '',
  visionPrompt: '',
  proAvatar: false,
);
