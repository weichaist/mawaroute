import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/capture_product_image_controller.dart';
import '../controllers/rec_chat_controller.dart';

class ChatRecBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(RecChatController());
    Get.lazyPut(() => CaptureProductImageController());
  }
}
