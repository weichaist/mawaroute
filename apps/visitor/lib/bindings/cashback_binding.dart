import 'package:get/get.dart';

import '../controllers/cashback_controller.dart';
import '../controllers/email_dialog_controller.dart';

class CashBackBinding implements Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => CashBackController());
    Get.lazyPut(() => EmailDialogController());
  }
}
