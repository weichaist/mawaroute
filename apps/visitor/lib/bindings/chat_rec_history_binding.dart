import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/chat_history_controller.dart';

class ChatRecHistoryBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(ChatHistoryController());
  }
}
