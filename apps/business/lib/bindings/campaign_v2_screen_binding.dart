import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/auth_controller.dart';
import 'package:mawaroute_business/controllers/campaign_v2_controller.dart';

class CampaignV2ScreenBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthController);
    Get.put(CampaignV2Controller());
  }
}
