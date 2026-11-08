import 'package:get/get.dart';
import 'package:mawaroute_shop/controllers/visitor_list_controller.dart';

class VisitorListBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(VisitorListController());
  }
}
