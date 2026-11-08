import 'dart:io';

import "package:firebase_storage/firebase_storage.dart";
import "package:flutter/material.dart";
import "package:flutter_smart_dialog/flutter_smart_dialog.dart";
import "package:get/get.dart";
import 'package:image_picker/image_picker.dart';

import "../api/google_firestore_services.dart";
import "auth_controller.dart";

class ProfileController extends GetxController {
  static ProfileController instance = Get.find<ProfileController>();
  AuthController authController = AuthController.instance;

  TextEditingController displayName = TextEditingController();

  File? image;
  RxString profileImage = "".obs;

  FirestoreService f = FirestoreService();
  FirebaseStorage storage = FirebaseStorage.instance;

  void init() {
    displayName.text = authController.profile.value.displayName;
    profileImage.value = authController.profile.value.image;
  }

  Future selectImage() async {
    // The original app used images_picker with a circular crop step; that
    // plugin no longer builds with current Android tooling, so the picked
    // image is used as is (it is still shown in a circle).
    final XFile? localImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (localImage != null) {
      profileImage.value = localImage.path;
      image = File(localImage.path);
    }
  }

  bool isImageChanged() {
    return profileImage.value.contains("https://");
  }

  bool isSvgImage() {
    return profileImage.value.contains(".svg?");
  }

  void clearImage() {
    profileImage.value = "";
    image = null;
  }

  Future saveImage() async {
    if (profileImage.value.isEmpty || isImageChanged()) {
      SmartDialog.showNotify(
        msg: "Please select a profile picture".tr,
        notifyType: NotifyType.warning,
      );
      return;
    }
    try {
      SmartDialog.showLoading(msg: "Updating user info...");
      String now = DateTime.now().toIso8601String();
      String ext = image!.path.split(".").last;
      Reference ref = storage.ref("v1-media/profile/img-$now.$ext");
      await ref.putFile(image!);
      String downloadUrl = await ref.getDownloadURL();
      await f.updateUserImage(image: downloadUrl);
      await authController.updateUserprofile();
      SmartDialog.showNotify(
        msg: "Successfully Updated!".tr,
        notifyType: NotifyType.success,
      );
    } catch (e) {
      SmartDialog.showNotify(
        msg: "Something went wrong!".tr,
        notifyType: NotifyType.failure,
      );
    } finally {
      SmartDialog.dismiss();
    }
  }

  Future saveDisplayName() async {
    if (displayName.text.isEmpty ||
        displayName.text == authController.profile.value.displayName) {
      SmartDialog.showNotify(
        msg: "Please Enter change display name.".tr,
        notifyType: NotifyType.warning,
      );
      return;
    }
    try {
      SmartDialog.showLoading(msg: "Updating user info.".tr);
      int count = await f.checkUserDisplayNameExist(
        displayName: displayName.text,
      );
      if (count == 0) {
        await f.updateUserDisplayName(displayName: displayName.text);
        await authController.updateUserprofile();
        SmartDialog.showNotify(
          msg: "Successfully Updated User!",
          notifyType: NotifyType.success,
        );
      } else {
        SmartDialog.dismiss();
        SmartDialog.showNotify(
          msg: "Display name already exist!".tr,
          notifyType: NotifyType.failure,
        );
      }
    } catch (e) {
      SmartDialog.showNotify(
        msg: "Something went wrong!".tr,
        notifyType: NotifyType.failure,
      );
    } finally {
      SmartDialog.dismiss();
    }
  }

  @override
  void dispose() {
    displayName.dispose();
    super.dispose();
  }
}
