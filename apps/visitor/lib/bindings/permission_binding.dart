import 'package:get/get.dart';
import 'package:mawaroute_visitor/controllers/permission_controller.dart';

class PermissionBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(PermissionController());
  }
}
