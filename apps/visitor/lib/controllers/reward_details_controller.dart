import 'package:flutter/foundation.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:mawaroute_visitor/models/reward_model.dart';
import 'package:mawaroute_visitor/models/reward_participant_model.dart';
import 'package:mawaroute_visitor/models/reward_receiver_model.dart';

import '../api/google_firestore_services.dart';

class RewardDetailsController extends GetxController {
  static RewardDetailsController instance = Get.find<RewardDetailsController>();

  Rx<RewardModel> reward = emptyReward.obs;
  RxList<RewardParticipantModel> participants = <RewardParticipantModel>[].obs;
  RxBool isUserParticipate = false.obs;
  RxBool isUserReceivedReward = false.obs;

  RxString rewardUid = ''.obs;
  FirestoreService f = FirestoreService();
  RxList<RewardReceiverModel> rewardUsages = <RewardReceiverModel>[].obs;

  Future init() async {
    SmartDialog.showLoading(msg: 'Processing...');
    rewardUid.value = Get.parameters['rewardId']!;
    reward.value = emptyReward;
    participants.value = [];
    isUserParticipate.value = false;
    rewardUsages.value = [];
    await getReward();
    await getRewardUsages();
    SmartDialog.dismiss();
  }

  Future didUserReceivedReward() async {
    await getReward();
    await getRewardUsages();
  }

  Future getReward() async {
    reward.value = await f.fetchRewardByUid(uid: rewardUid.value);
  }

  Future getRewardUsages() async {
    try {
      rewardUsages.value = await f.fetchRewardsUsageHistory(
        rewardUid: rewardUid.value,
      );
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future applyCoupon({
    required String rewardUid,
    required String rewardReceiverUid,
  }) async {
    await f.applyCoupon(
      rewardUid: rewardUid,
      rewardReceiverUid: rewardReceiverUid,
    );
  }
}
