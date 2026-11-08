import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/auth_controller.dart';
import 'package:mawaroute_business/controllers/elements_controller.dart';

class ElementsScreenBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(ElementsController());
  }
}
