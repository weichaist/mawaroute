import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../api/google_firestore_services.dart';
import '../models/cashback_receiver_model.dart';
import '../models/top_reward.dart';

class CashBackController extends GetxController {
  static CashBackController instance = Get.find<CashBackController>();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;
  FirestoreService api = FirestoreService();

  RxInt cashBackCount = 0.obs;
  RxInt cashBackPermissibleCount = 0.obs;
  RxList<CashbackReceiverModel> cashBacks = <CashbackReceiverModel>[].obs;
  Rx<TopReward> topReward = emptyTopReward.obs;

  RxBool isLoading = false.obs;

  Future<void> init() async {
    if (isLoading.value == true) return;
    isLoading.value = true;
    topReward.value = emptyTopReward;
    String rewardUid = Get.parameters["rewardUid"]!;
    await fetchTopReward(rewardUid);
    await fetchCashBackRewardReceiver(rewardUid: rewardUid);
    await getCashBackPermissibleCount();
    isLoading.value = false;
  }

  Future fetchTopReward(String topRewardUid) async {
    try {
      await _db.collection('top_rewards').doc(topRewardUid).get().then((value) {
        if (value.exists) {
          topReward.value = TopReward.fromJson(value.data()!, value.id);
        }
      });
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future fetchCashBackRewardReceiver({required String rewardUid}) async {
    List<CashbackReceiverModel> list = [];
    await _db
        .collection('top_rewards')
        .doc(rewardUid)
        .collection('cashback_receivers')
        .where("receiver", isEqualTo: _auth.currentUser?.uid)
        .get()
        .then((value) {
          for (var doc in value.docs) {
            list.add(CashbackReceiverModel.fromJson(doc.data(), doc.id));
          }
        });
    cashBacks.value = list;
  }

  Future getCashBackCount({required String rewardUid}) async {
    int count = 0;
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    try {
      await _db
          .collection('top_rewards')
          .doc(rewardUid)
          .collection('cashback_receivers')
          .where('receiver', isEqualTo: _auth.currentUser!.uid)
          .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
          .where('timestamp', isLessThanOrEqualTo: endOfDay)
          .count()
          .get()
          .then((value) {
            count = value.count ?? 0;
          });
    } catch (e) {
      if (kDebugMode) print(e);
    }
    cashBackCount.value = count;
  }

  Future getCashBackPermissibleCount() async {
    int count = 0;
    DateTime now = DateTime.now();
    DateTime startOfDay = DateTime(now.year, now.month, now.day);
    DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    if (topReward.value.condition == "visited") {
      count = 1;
    } else {
      try {
        await _db
            .collectionGroup("shop_purchases")
            .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
            .where('timestamp', isLessThanOrEqualTo: endOfDay)
            .where('userUid', isEqualTo: _auth.currentUser?.uid)
            .count()
            .get()
            .then((value) {
              count = value.count ?? 0;
            });
      } catch (e) {
        if (kDebugMode) print(e);
      }
    }
    cashBackPermissibleCount.value = count;
  }
}
