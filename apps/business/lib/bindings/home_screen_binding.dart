import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/auth_controller.dart';
import 'package:mawaroute_business/controllers/home_controller.dart';
import 'package:mawaroute_business/controllers/place_checklist_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(HomeController());
    Get.put(AuthController());
    Get.put(PlaceCheckListController());
  }
}
