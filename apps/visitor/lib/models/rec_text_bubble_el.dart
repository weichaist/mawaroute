import 'package:latlong2/latlong.dart';
import 'package:mawaroute_visitor/models/rec_item_model.dart';

class TextBubbleEl {
  final String? id;
  final String type;
  final bool messageOfAvatar;
  final String message;
  final String? recLink;
  final String? recDescription;
  final String? recUid;
  final int? price;
  final LatLng? geo;
  final String? imageUrl;
  final DateTime? timestamp;
  TextBubbleEl({
    this.id,
    required this.message,
    required this.type,
    required this.messageOfAvatar,
    this.recLink,
    this.recDescription,
    this.recUid,
    this.price,
    this.geo,
    this.imageUrl,
    this.timestamp,
  });
  factory TextBubbleEl.fromWeaviate(Map<String, dynamic> json) {
    return TextBubbleEl(
      type: 'recItem',
      messageOfAvatar: true,
      message: json['title'],
      recLink: json['link'],
      recDescription: json['description'],
      recUid: json['_additional']['id'],
      price: json['price'],
      geo: json['geo'] != null
          ? LatLng(json['geo']['latitude'], json['geo']['longitude'])
          : null,
      imageUrl: json['imageUrl'],
    );
  }
  factory TextBubbleEl.fromRecItem(RecItem rec) {
    return TextBubbleEl(
      type: 'recItem',
      messageOfAvatar: true,
      message: rec.title,
      recLink: rec.link,
      recDescription: rec.description,
      recUid: rec.uid,
    );
  }

  factory TextBubbleEl.fromJson(Map<String, dynamic> json, String id) {
    return TextBubbleEl(
      id: id,
      type: json["type"],
      messageOfAvatar: json["messageOfAvatar"],
      message: json["message"],
      recLink: json["recLink"],
      recDescription: json["recDescription"],
      recUid: json["recUid"],
      price: json["price"],
      geo: json["geo"],
      imageUrl: json["imageUrl"],
      timestamp: json["timestamp"].toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "type": type,
      "messageOfAvatar": messageOfAvatar,
      "message": message,
      "recDescription": recDescription,
      "recLink": recLink,
      "recUid": recUid,
      "price": price,
      "geo": geo,
      "imageUrl": imageUrl,
    };
  }
}
