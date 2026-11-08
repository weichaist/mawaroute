import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:mawaroute_visitor/models/chat.dart';

import '../utilis/pagination.dart';

class ChatHistoryController extends GetxController {
  static ChatHistoryController instance = Get.find<ChatHistoryController>();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  final RxBool multipleSelectionMode = false.obs;
  final RxList<String> selectedChats = <String>[].obs;

  Rx<Pagination<ChatModel>> savedChats = Pagination<ChatModel>(
    fromJson: null,
    query: null,
  ).obs;

  Future<void> init() async {
    savedChats.value = Pagination<ChatModel>(
      fromJson: (json, id) => ChatModel.fromJson(json, id),
      query: _db
          .collection("user_rec_chats")
          .doc(_auth.currentUser!.uid)
          .collection("chats")
          .where('deleted', isEqualTo: false)
          .orderBy('createdAt', descending: true),
    );
    selectedChats.clear();
    multipleSelectionMode.value = false;
    await fetchSavedChats();
  }

  Future fetchSavedChats() async {
    await savedChats.value.fetch();
    savedChats.refresh();
  }

  Future deleteChats() async {
    try {
      SmartDialog.showLoading(msg: "Deleting chats".tr);
      CollectionReference query = _db
          .collection("user_rec_chats")
          .doc(_auth.currentUser!.uid)
          .collection("chats");
      List<ChatModel> mutableSavedChats = [];
      for (ChatModel chat in savedChats.value.results) {
        if (!selectedChats.contains(chat.id)) {
          mutableSavedChats.add(chat);
        } else {
          await query.doc(chat.id).update({"deleted": true});
        }
      }
      savedChats.value.results = mutableSavedChats;
      savedChats.refresh();
      selectedChats.clear();
    } catch (e) {
      if (kDebugMode) print(e);
      SmartDialog.showNotify(
        msg: "Deleting Chats failed",
        notifyType: NotifyType.failure,
      );
    } finally {
      SmartDialog.dismiss();
    }
  }
}
