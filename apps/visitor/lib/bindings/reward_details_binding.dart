import 'package:get/get.dart';
import 'package:mawaroute_visitor/controllers/email_dialog_controller.dart';
import 'package:mawaroute_visitor/controllers/reward_details_controller.dart';

import '../controllers/auth_controller.dart';

class RewardDetailsBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(RewardDetailsController());
    Get.put(EmailDialogController());
  }
}
