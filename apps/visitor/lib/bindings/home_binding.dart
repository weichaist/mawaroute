import 'package:get/get.dart';
import 'package:mawaroute_visitor/controllers/ai_character_list_controller.dart';
import 'package:mawaroute_visitor/controllers/permission_controller.dart';
import 'package:mawaroute_visitor/controllers/voice_assistant_controller.dart';

import '../controllers/auth_controller.dart';
import '../controllers/wallet_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(AuthController());
    Get.put(AICharacterListController());
    Get.put(WalletController());
    Get.put(PermissionController());
    Get.lazyPut(() => VoiceAssistantController());
  }
}
