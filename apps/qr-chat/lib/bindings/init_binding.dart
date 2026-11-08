import 'package:get/get.dart';

import '../controllers/web_chat_controller.dart';

class InitBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(WebChatController());
  }
}
