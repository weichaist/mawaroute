import 'package:get/get.dart';

import '../controllers/coupon_usage_controller.dart';

class CouponUsageBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CouponUsageController());
  }
}
