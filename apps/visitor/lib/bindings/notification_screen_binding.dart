import 'package:get/get.dart';
import 'package:mawaroute_visitor/controllers/notification_controller.dart';

class NotificationScreenBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationController());
  }
}
