import 'package:get/get.dart';
import 'package:mawaroute_shop/controllers/timetable_controller.dart';

import '../controllers/auth_controller.dart';

class TimeTableBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(TimeTableController());
  }
}
