import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mawaroute_visitor/models/reward_model.dart';

import '../api/_paginated_results.dart';
import '../enums.dart';
import '../models/top_reward.dart';

class RewardHomeScreenController extends GetxController {
  static RewardHomeScreenController instance =
      Get.find<RewardHomeScreenController>();
  final _db = FirebaseFirestore.instance;

  RxList<RewardModel> emailOnSpotRewards = <RewardModel>[].obs;
  DocumentSnapshot? emailOnSpotRewardsSnapshot;
  RxBool isLastPageForEmailOnSpotRewards = false.obs;

  RxList<RewardModel> couponRewards = <RewardModel>[].obs;
  DocumentSnapshot? couponRewardsSnapshot;
  RxBool isLastPageForCouponRewards = false.obs;
  RxList<TopReward> topRewards = <TopReward>[].obs;

  RxBool isLoading = false.obs;

  Future<void> init() async {
    if (isLoading.value == true) return;
    isLoading.value = true;
    emailOnSpotRewards.value = [];
    emailOnSpotRewardsSnapshot = null;
    isLastPageForEmailOnSpotRewards.value = false;

    couponRewards.value = [];
    couponRewardsSnapshot = null;
    isLastPageForCouponRewards.value = false;

    topRewards.value = [];

    await listEmailOnSpotRewards();
    await listCouponRewards();
    await fetchTopReward();
    isLoading.value = false;
  }

  Future fetchTopReward() async {
    try {
      List<TopReward> tTopRewards = [];
      await _db
          .collection('top_rewards')
          // .where("isLive", isEqualTo: true)
          .where('type', isEqualTo: 'cashback')
          .orderBy('title')
          .get()
          .then((value) {
            for (var doc in value.docs) {
              tTopRewards.add(TopReward.fromJson(doc.data(), doc.id));
            }
          });
      topRewards.value = tTopRewards;
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future listEmailOnSpotRewards() async {
    try {
      int limit = 15;
      if (isLastPageForEmailOnSpotRewards.value == true) return;

      Query query = _db
          .collection("rewards")
          .where(
            "rewardDistributionType",
            whereIn: [
              RewardDistributionType.email.name,
              RewardDistributionType.onspot.name,
            ],
          )
          .where("status", isEqualTo: RewardType.active.name)
          .orderBy("startTime", descending: true);

      Map output = await paginatedResults(
        query: query,
        snapshot: emailOnSpotRewardsSnapshot,
        limit: limit,
      );
      output["results"] = output["results"]
          .map<RewardModel>(
            (element) => RewardModel.fromJson(
              element.data() as Map<String, dynamic>,
              element.id,
            ),
          )
          .toList();

      List<RewardModel> results = output["results"];
      isLastPageForEmailOnSpotRewards.value = results.length < limit;
      emailOnSpotRewards.value += results;
      emailOnSpotRewardsSnapshot = output["snapshot"];
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }

  Future listCouponRewards() async {
    try {
      int limit = 15;
      if (isLastPageForCouponRewards.value == true) return;

      Query query = _db
          .collection("rewards")
          .where(
            "rewardDistributionType",
            isEqualTo: RewardDistributionType.coupon.name,
          )
          .where("status", isEqualTo: RewardType.active.name)
          .orderBy("startTime", descending: true);

      Map output = await paginatedResults(
        query: query,
        snapshot: couponRewardsSnapshot,
        limit: limit,
      );
      output["results"] = output["results"]
          .map<RewardModel>(
            (element) => RewardModel.fromJson(
              element.data() as Map<String, dynamic>,
              element.id,
            ),
          )
          .toList();

      List<RewardModel> results = output["results"];
      isLastPageForCouponRewards.value = results.length < limit;
      couponRewards.value += results;
      couponRewardsSnapshot = output["snapshot"];
    } catch (e) {
      if (kDebugMode) print(e);
    }
  }
}
