import 'package:get/get.dart';

import '../controllers/chat_about_visitor_controller.dart';

class ChatAboutVisitorBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(ChatAboutVisitorController());
  }
}
