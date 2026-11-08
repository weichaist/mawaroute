import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/auth_controller.dart';
import 'package:mawaroute_business/controllers/create_ad_controller.dart';

class CreateAdScreenBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthController);
    Get.put(CreateAdController());
  }
}
