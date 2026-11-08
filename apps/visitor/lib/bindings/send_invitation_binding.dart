import 'package:get/get.dart';
import 'package:mawaroute_visitor/controllers/send_invitation_controller.dart';

class SendInvitationBinding implements Bindings {
  @override
  void dependencies() {
    Get.put(SendInvitationController());
  }
}
