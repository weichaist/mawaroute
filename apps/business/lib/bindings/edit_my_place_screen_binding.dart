import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/auth_controller.dart';
import 'package:mawaroute_business/controllers/edit_my_place_controller.dart';

class EditMyPlaceScreenBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(EditMyPlaceController());
    Get.put(AuthController());
  }
}
