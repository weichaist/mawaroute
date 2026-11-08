import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get_utils/src/extensions/internacionalization.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../models/m_avatar_model.dart';
import '../utilis/compress_image_file.dart';
import '../utilis/graphql.dart';

class RecChatApi {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;
  Future<MAvatarModel> fetchMAvatar(String avatarUid) async {
    try {
      var documentSnapshot = await _db
          .collection('m_avatars')
          .doc(avatarUid)
          .get();
      if (documentSnapshot.exists) {
        return MAvatarModel.fromJson(
          documentSnapshot.data() as Map<String, dynamic>,
          documentSnapshot.id,
        );
      } else {
        return emptyMAvatarModel;
      }
    } catch (e) {
      if (kDebugMode) print(e);
      rethrow;
    }
  }

  Future<Position?> getCurrentLocation() async {
    Position? position;
    try {
      position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return position;
  }

  String extractAllButLastParagraph(String fullText) {
    RegExp newlineRegExp = RegExp(r'\r\n|\r|\n');
    Iterable<RegExpMatch> matches = newlineRegExp.allMatches(fullText);

    if (matches.length > 1) {
      // If more than one paragraph, extract up to the start of the last paragraph
      int endIndexBeforeLast = matches.elementAt(matches.length - 2).end;
      return formatInputString(fullText.substring(0, endIndexBeforeLast));
    }
    // Return the whole text if there's only one paragraph or no newline characters
    return formatInputString(fullText);
  }

  Future<QueryResult> getWeaviateRecs({required String query}) async {
    try {
      final GraphQLClient client = getWeaviateApiClient();
      final QueryOptions options = QueryOptions(document: gql(query));
      final QueryResult response = await client.query(options);
      return response;
    } catch (e) {
      if (kDebugMode) print(e);
      rethrow;
    }
  }

  List<String> removeDuplicates(List<String> list) {
    list = list.toSet().toList();
    return list;
  }

  Future<List<String>> fetchRecentChatsFirestore() async {
    DocumentReference document = _db
        .collection("user_rec_chats")
        .doc(_auth.currentUser!.uid);
    try {
      // Retrieve the current list from the document
      List<String> currentList = [];
      final snapshot = await document.get();
      if (snapshot.exists) {
        final data = snapshot.data() as Map;
        currentList = List<String>.from(data['recent_chats'] ?? []);
      }
      // Update the document
      return currentList;
    } catch (e) {
      if (kDebugMode) print("Error updating document: $e");
      return [];
    }
  }

  Future updateRecentChats(List<String> list) async {
    DocumentReference document = _db
        .collection("user_rec_chats")
        .doc(_auth.currentUser!.uid);
    await document.set({'recent_chats': list});
  }

  Future<String> initNewChatToFirestore({
    required MAvatarModel avatarModel,
    required String query,
  }) async {
    try {
      DocumentReference ref = await _db
          .collection("user_rec_chats")
          .doc(_auth.currentUser!.uid)
          .collection("chats")
          .add({
            "avatarUid": avatarModel.id,
            "avatarUrl": avatarModel.imageUrl,
            "query": query,
            "deleted": false,
            "createdAt": DateTime.now(),
          });
      return ref.id;
    } catch (e) {
      if (kDebugMode) print(e);
      SmartDialog.showNotify(
        msg: "Experiencing technical issues. Please try again later.".tr,
        notifyType: NotifyType.error,
      );
    }
    return '';
  }

  Future saveChatToFirestore({
    required String chatUid,
    required Map<String, dynamic> obj,
  }) async {
    obj["timestamp"] = DateTime.now();
    CollectionReference ref = _db
        .collection("user_rec_chats")
        .doc(_auth.currentUser!.uid)
        .collection("chats")
        .doc(chatUid)
        .collection("chat_elements");
    await ref.add(obj);
  }

  Future<String> uploadImage(String filePath) async {
    String now = DateTime.now().toIso8601String();
    Reference ref = _storage.ref(
      "v1-media/vision_rec/${_auth.currentUser!.uid}/img-$now.jpg",
    );
    String url = "";
    try {
      File compressedImage = await compressImageFile(File(filePath));
      await ref.putFile(compressedImage).timeout(const Duration(seconds: 10));
      url = await ref.getDownloadURL();
    } catch (e) {
      if (kDebugMode) print(e);
    }
    return url;
  }
}

String extractPlaceId(String url) {
  int startIndex = url.indexOf('place_id:') + 'place_id:'.length;
  if (startIndex == -1) {
    return '';
  }

  int endIndex = url.indexOf('&', startIndex);
  if (endIndex == -1) {
    endIndex = url.length;
  }
  return url.substring(startIndex, endIndex);
}

String formatInputString(String input) {
  String result = input.replaceAll('"', '');
  return result.replaceAll(RegExp(r'\r\n|\r|\n'), '');
}
