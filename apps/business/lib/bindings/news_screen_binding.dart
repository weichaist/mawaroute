import 'package:get/get.dart';
import 'package:mawaroute_business/controllers/auth_controller.dart';
import 'package:mawaroute_business/controllers/news_controller.dart';

class NewsScreenBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(NewsController());
  }
}
