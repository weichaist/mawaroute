import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../api/google_firestore_services.dart';
import '../enums.dart';
import '../models/campaign_model.dart';
import '../utility.dart';

class CreateCampaignV2Controller extends GetxController {
  static CreateCampaignV2Controller instance =
      Get.find<CreateCampaignV2Controller>();
  Rx<TextEditingController> title = TextEditingController().obs;
  Rx<TextEditingController> description = TextEditingController().obs;
  Rx<DateTime> startTime = DateTime.now().obs;

  FireStoreService api = FireStoreService();
  final _auth = FirebaseAuth.instance;

  Future onCreate() async {
    if (title.value.text.isEmpty | description.value.text.isEmpty) {
      showToast(
          'Create a campaign with a title, description and start date & time'
              .tr);
      return;
    }
    showLoading('Creating campaign...'.tr);
    try {
      CampaignModel campaignModel = CampaignModel(
        title: title.value.text,
        description: description.value.text,
        imageLink: '',
        downloadUrl: '',
        bannerImageLink: '',
        bannerDownloadUrl: '',
        startTime: startTime.value,
        creatorUid: _auth.currentUser!.uid,
        placeUid: _auth.currentUser!.uid,
        taskType: '',
        targetUser: TargetUser.allCustomer.name,
        status: CampaignStatus.draft.name,
        taskCount: 0,
        createdAt: DateTime.now(),
      );
      await api.addCampaign(campaignObject: campaignModel.toJson());
      clear();
      showDismiss();
      showToast('Successfully created campaign.'.tr);
      Get.toNamed('/campaigns');
    } catch (e) {
      showToast('Failed to create campaign!.'.tr);
    }
  }

  void clear() {
    startTime.value = DateTime.now();
    title.value.clear();
    description.value.clear();
  }

  @override
  void dispose() {
    title.value.dispose();
    description.value.dispose();
    super.dispose();
  }
}
