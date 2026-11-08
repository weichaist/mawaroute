import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/auth_controller.dart';
import 'package:mawaroute_business/controllers/rewards_controller.dart';

class RewardsScreenBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(RewardController());
  }
}
