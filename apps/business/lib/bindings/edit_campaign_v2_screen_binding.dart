import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/auth_controller.dart';
import 'package:mawaroute_business/controllers/edit_campaing_v2_controller.dart';

class EditCampaignV2ScreenBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(EditCampaignV2Controller());
  }
}
