import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../api/google_firestore_services.dart';
import '../models/m_user_credentials.dart';

class EmailDialogController extends GetxController {
  static EmailDialogController instance = Get.find<EmailDialogController>();

  FirestoreService f = FirestoreService();
  Rx<TextEditingController> email = TextEditingController().obs;

  Future<void> init() async {
    await getEmail();
  }

  Future getEmail() async {
    MUserCredential credential = await f.getUserCredentials();
    email.value.text = credential.email;
  }

  Future saveEmail(String email) async {
    MUserCredential credential = await f.getUserCredentials();
    String firstCredential = credential.id!;
    if (firstCredential != '') {
      await f.updateUserCredentials(
        uid: firstCredential,
        obj: {"email": email},
      );
    }
  }

  @override
  void dispose() {
    email.value.dispose();
    super.dispose();
  }
}
