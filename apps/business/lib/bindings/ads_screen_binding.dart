import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/ads_controller.dart';
import 'package:mawaroute_business/controllers/auth_controller.dart';

class AdsScreenBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthController);
    Get.put(AdsScreenController());
  }
}
