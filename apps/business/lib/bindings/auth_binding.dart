import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/auth_controller.dart';

class AuthBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
  }
}
