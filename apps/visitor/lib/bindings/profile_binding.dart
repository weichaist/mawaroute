import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(ProfileController());
  }
}
