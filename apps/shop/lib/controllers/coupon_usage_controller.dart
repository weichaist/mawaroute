import 'package:get/get.dart';
import 'package:mawaroute_shop/api/firestore_services.dart';

import '../models/reward_receiver_model.dart';
import '../models/shop_model.dart';
import 'auth_controller.dart';

class CouponUsageController extends GetxController {
  static CouponUsageController instance = Get.find<CouponUsageController>();
  final api = FireStoreService();
  final authController = AuthController.instance;

  Rx<ShopModel> shop = emptyShopModel.obs;
  RxList<String> rewards = <String>[].obs;
  RxList<RewardReceiverModel> couponUsages = <RewardReceiverModel>[].obs;

  Future<void> init() async {
    shop.value = authController.shop.value;
    rewards.value = await api.fetchCouponRewards(shopUid: shop.value.uid!);
    if (rewards.isNotEmpty) {
      couponUsages.value =
          await api.fetchCouponUsages(rewardUid: rewards.first);
    }
  }
}
